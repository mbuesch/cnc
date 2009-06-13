/*
 *  Pneumatic pressure controller.
 *  Remote control.
 *
 *  Copyright (C) 2008 Michael Buesch <mb@bu3sch.de>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "remote.h"
#include "util.h"
#include "calibration.h"
#include "main.h"
#include "valves.h"

#include <string.h>

#include <avr/io.h>


#define BAUDRATE	115200
#define USE_2X		1


static struct remote_message rx_msg;
static uint8_t rx_msg_count;
static bool rx_msg_valid;
static bool rx_softirq;
static uint16_t rx_timeout;


static inline void usart_tx(uint8_t data)
{
	while (!(UCSRA & (1 << UDRE)))
		;
	UDR = data;
}

static void usart_tx_buf(const void *_buf, uint8_t size)
{
	const uint8_t *buf = _buf;

	while (size) {
		usart_tx(*buf);
		buf++;
		size--;
	}
}

#define ERXFE		1 /* USART RX frame error */
#define ERXPE		2 /* USART RX parity error */
#define ERXOV		3 /* USART RX hardware buffer overflow */
#define ENODATA		4 /* No data available */

static inline int8_t usart_rx(uint8_t *data)
{
	uint8_t status;
	int8_t err = 0;

	status = UCSRA;
	if (!(status & (1 << RXC)))
		return -ENODATA;
	if (unlikely(status & ((1 << FE) | (1 << PE) | (1 << DOR)))) {
		if (status & (1 << FE))
			err = -ERXFE;
		if (status & (1 << PE))
			err = -ERXPE;
		if (status & (1 << DOR))
			err = -ERXOV;
	}
	*data = UDR;

	return err;
}

static void send_message(struct remote_message *msg)
{
	/* Calculate the CRC. */
	msg->crc = crc16_block_update(0xFFFF, msg,
				      sizeof(*msg) - sizeof(msg->crc));
	msg->crc ^= 0xFFFF;
	/* And transmit the bits. */
	usart_tx_buf(msg, sizeof(*msg));
}

static void handle_received_message(void)
{
	struct remote_message reply;
	uint16_t calc_crc;
	uint8_t err = MSG_ERR_NONE;

	calc_crc = crc16_block_update(0xFFFF, &rx_msg,
				      sizeof(rx_msg) - sizeof(rx_msg.crc));
	calc_crc ^= 0xFFFF;
	if (calc_crc != rx_msg.crc) {
		/* CRC mismatch. */
		err = MSG_ERR_CHKSUM;
		goto out;
	}

	memset(&reply, 0, sizeof(reply));

	switch (rx_msg.id) {
	case MSG_PING:
		reply.id = MSG_PONG;
		send_message(&reply);
		break;
	case MSG_GET_CURRENT_PRESSURE: {
		struct pressure_state state;

		get_pressure_state(&state);
		reply.id = MSG_CURRENT_PRESSURE;
		reply.pressure.mbar[0] = state.measured_mbar_xy;
		reply.pressure.mbar[1] = state.measured_mbar_z;
		send_message(&reply);
		break;
	}
	case MSG_GET_DESIRED_PRESSURE: {
		struct pressure_config xy, z;

		get_pressure_config(&xy, &z);
		reply.id = MSG_DESIRED_PRESSURE;
		reply.pressure.mbar[0] = xy.desired;
		reply.pressure.mbar[1] = z.desired;
		send_message(&reply);
		break;
	}
	case MSG_GET_HYSTERESIS: {
		struct pressure_config xy, z;

		get_pressure_config(&xy, &z);
		reply.id = MSG_HYSTERESIS;
		reply.pressure.mbar[0] = xy.hysteresis;
		reply.pressure.mbar[1] = z.hysteresis;
		send_message(&reply);
		break;
	}
	case MSG_GET_CONFIG_FLAGS: {
		struct pressure_config xy, z;

		get_pressure_config(&xy, &z);
		reply.id = MSG_CONFIG_FLAGS;
		if (xy.autoadjust_enable)
			reply.config.flags[0] |= (1 << CFG_FLAG_AUTOADJUST_ENABLE);
		if (z.autoadjust_enable)
			reply.config.flags[1] |= (1 << CFG_FLAG_AUTOADJUST_ENABLE);
		send_message(&reply);
		break;
	}
	case MSG_SET_DESIRED_PRESSURE: {
		struct pressure_config xy, z;

		cli();
		get_pressure_config(&xy, &z);
		if (rx_msg.setpressure.island == 0)
			xy.desired = rx_msg.setpressure.mbar;
		else if (rx_msg.setpressure.island == 1)
			z.desired = rx_msg.setpressure.mbar;
		set_pressure_config(&xy, &z);
		sei();
		break;
	}
	case MSG_SET_HYSTERESIS: {
		struct pressure_config xy, z;

		cli();
		get_pressure_config(&xy, &z);
		if (rx_msg.setpressure.island == 0)
			xy.hysteresis = rx_msg.setpressure.mbar;
		else if (rx_msg.setpressure.island == 1)
			z.hysteresis = rx_msg.setpressure.mbar;
		set_pressure_config(&xy, &z);
		sei();
		break;
	}
	case MSG_SET_CONFIG_FLAGS: {
		struct pressure_config xy, z;
		bool flag;

		cli();
		get_pressure_config(&xy, &z);
		flag = !!(rx_msg.setconfig.flags & (1 << CFG_FLAG_AUTOADJUST_ENABLE));
		if (rx_msg.setconfig.island == 0) {
			if (xy.autoadjust_enable != flag) {
				xy.autoadjust_enable = flag;
				/* Make sure the values are idle. */
				valves_global_switch(&xy_control_valves, VALVES_IDLE);
			}
		} else if (rx_msg.setconfig.island == 1) {
			if (z.autoadjust_enable != flag) {
				z.autoadjust_enable = flag;
				/* Make sure the values are idle. */
				valves_global_switch(&z_control_valves, VALVES_IDLE);
			}
		}
		set_pressure_config(&xy, &z);
		sei();
		break;
	}
	case MSG_SET_VALVE: {
		struct pressure_config xy, z;
		struct valves *v;

		get_pressure_config(&xy, &z);
		if (rx_msg.valve.island == 0) {
			if (xy.autoadjust_enable) {
				err = MSG_ERR_BUSY;
				break;
			}
			v = &xy_control_valves;
		} else {
			if (z.autoadjust_enable) {
				err = MSG_ERR_BUSY;
				break;
			}
			v = &z_control_valves;
		}
		if (rx_msg.valve.nr == 0) {
			valve0_switch(v, rx_msg.valve.state == 0 ?
				      VALVE_STATE_CLOSE : VALVE_STATE_OPEN);
			valve_wait_toggle(v);
			valve0_switch(v, VALVE_STATE_IDLE);
		} else if (rx_msg.valve.nr == 1) {
			valve1_switch(v, rx_msg.valve.state == 0 ?
				      VALVE_STATE_CLOSE : VALVE_STATE_OPEN);
			valve_wait_toggle(v);
			valve0_switch(v, VALVE_STATE_IDLE);
		} else
			err = MSG_ERR_INVAL;
		break;
	}
	case MSG_SHUTDOWN:
		prepare_shutdown();
		valves_shutdown(&xy_control_valves);
		valves_shutdown(&z_control_valves);
		break;
	case MSG_TURNON:
		prepare_turn_on();
		break;
	case MSG_INVALID:
		break;
	default:
		err = MSG_ERR_NOCMD;
		break;
	}

out:
	if (rx_msg.flags & (1 << MSG_FLAG_REQ_ERRCODE)) {
		memset(&reply, 0, sizeof(reply));
		reply.id = MSG_ERROR;
		reply.error.code = err;
		send_message(&reply);
	}
}

static void usart_handle_rx_irq(void)
{
	uint8_t *rxbuf = (uint8_t *)&rx_msg;
	int8_t err;
	uint8_t data;

	while (1) {
		err = usart_rx(&data);
		if (err == -ENODATA)
			break;
		/* Ignore other errors. The CRC check will detect them later. */

		rxbuf[rx_msg_count++] = data;
		if (rx_msg_count == sizeof(struct remote_message)) {
			rx_msg_count = 0;
			rx_timeout = 0;
			mb();
			rx_msg_valid = 1;
			break;
		}
	}
}

/* RX interrupt */
ISR(USART_RXC_vect)
{
	if (rx_msg_valid) {
		/* We're busy. Schedule a software IRQ for later. */
		rx_softirq = 1;
		return;
	}
	usart_handle_rx_irq();
}

/* Called with IRQs disabled. */
static void usart_rx_timeout_check()
{
	if (rx_msg_count > 0)
		rx_timeout++;
	if (rx_timeout > 100 /* milliseconds */) {
		/* Timeout! Reset the RX buffer. */
		rx_msg_count = 0;
		rx_timeout = 0;
	}
	mb();
}

void print_sram(const char *str)
{
	struct remote_message msg;
	uint8_t c, i;

	do {
		memset(&msg, 0, sizeof(msg));
		msg.id = MSG_LOGMESSAGE;

		for (i = 0; i < sizeof(msg.logmessage.str); i++) {
			c = *str;
			if (c == '\0')
				break;
			str++;
			msg.logmessage.str[i] = c;
		}

		send_message(&msg);
	} while (c != '\0');
}

void print_pgm(const prog_char *str)
{
	struct remote_message msg;
	uint8_t c, i;

	do {
		memset(&msg, 0, sizeof(msg));
		msg.id = MSG_LOGMESSAGE;

		for (i = 0; i < sizeof(msg.logmessage.str); i++) {
			c = pgm_read_byte(str);
			if (c == '\0')
				break;
			str++;
			msg.logmessage.str[i] = c;
		}

		send_message(&msg);
	} while (c != '\0');
}

static void __print_dec(char prefix, uint16_t number)
{
	uint8_t num[NUM16_NR_DIGITS + sizeof(prefix) + 1];

	num[0] = prefix;
	num16_to_ascii(num + 1, number);
	if (prefix)
		print_sram((char *)num);
	else
		print_sram((char *)(num + 1));
}

void print_dec(uint16_t number)
{
	__print_dec(0, number);
}

void print_dec_signed(int16_t number)
{
	if (number < 0)
		__print_dec('-', -number);
	else
		__print_dec(0, number);
}

void print_hex(uint8_t number)
{
	char hex[3];

	hex[0] = hexdigit_to_ascii(number >> 4);
	hex[1] = hexdigit_to_ascii(number & 0xF);
	hex[2] = '\0';

	print_sram(hex);
}

/* Maintanance work. Called with IRQs enabled. */
void remote_work(void)
{
	static jiffies_t last_timeout_check;
	jiffies_t now = get_jiffies();

	if (rx_msg_valid) {
		handle_received_message();
		mb();
		rx_msg_valid = 0;
	}
	cli();
	if (rx_softirq) {
		rx_softirq = 0;
		usart_handle_rx_irq();
	}
	if (last_timeout_check != now) {
		last_timeout_check = now;
		usart_rx_timeout_check();
	}
	sei();
}

void remote_pressure_change_notification(uint16_t xy_mbar, uint16_t z_mbar)
{
	struct remote_message msg;

	memset(&msg, 0, sizeof(msg));
	msg.id = MSG_CURRENT_PRESSURE;
	msg.pressure.mbar[0] = xy_mbar;
	msg.pressure.mbar[1] = z_mbar;
	send_message(&msg);
}

void remote_notify_restart(void)
{
	struct remote_message msg;

	memset(&msg, 0, sizeof(msg));
	msg.id = MSG_RESTARTED;
	send_message(&msg);
}

#if USE_2X
# define UBRR_FACTOR	2
#else
# define UBRR_FACTOR	1
#endif

static void usart_init(void)
{
	uint8_t dummy;

	/* Set baud rate */
	UBRRL = lo8((CPU_HZ / 16 / BAUDRATE) * UBRR_FACTOR);
	UBRRH = hi8((CPU_HZ / 16 / BAUDRATE) * UBRR_FACTOR) & ~(1 << URSEL);
#if USE_2X
	UCSRA = (1 << U2X);
#endif
	/* 8 Data bits, 2 Stop bits, No parity */
	UCSRC = (1 << URSEL) | (1 << UCSZ0) | (1 << UCSZ1) | (1 << USBS);
	/* Enable transceiver and RX IRQs */
	UCSRB = (1 << RXEN) | (1 << TXEN) | (1 << RXCIE);
	/* Drain the RX buffer */
	while (usart_rx(&dummy) != -ENODATA)
		mb();
}

void remote_init(void)
{
	/* The remote tool depends on the exact size (and layout). */
	BUILD_BUG_ON(sizeof(struct remote_message) != 12);

	usart_init();
}
