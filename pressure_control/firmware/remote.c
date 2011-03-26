/*
 *  Pneumatic pressure controller.
 *  Remote control.
 *
 *  Copyright (C) 2008-2009 Michael Buesch <mb@bu3sch.de>
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


/* Last received message. */
static struct remote_message rx_msg;
static uint8_t rx_msg_count;
static bool rx_msg_valid;
static bool rx_softirq;
static uint16_t rx_timeout;

/* Transmission queue. */
static struct remote_message tx_queue[32];
static uint8_t tx_queue_in_ptr;
static uint8_t tx_queue_out_ptr;
static uint8_t tx_queue_used;
static uint8_t tx_byte_ptr;


static inline uint8_t message_calc_crc(const struct remote_message *msg)
{
	uint8_t crc;

	crc = crc8_block_update(0xFF, msg,
				sizeof(*msg) - sizeof(msg->crc));
	crc ^= 0xFF;

	return crc;
}

static void tx_put_next_byte(void)
{
	const struct remote_message *msg;
	const uint8_t *buf;

	msg = &tx_queue[tx_queue_out_ptr];
	buf = (const uint8_t *)msg;

	UDR = buf[tx_byte_ptr];
	tx_byte_ptr++;
	if (tx_byte_ptr >= sizeof(struct remote_message)) {
		tx_byte_ptr = 0;
		tx_queue_out_ptr++;
		if (tx_queue_out_ptr >= ARRAY_SIZE(tx_queue))
			tx_queue_out_ptr = 0;
		tx_queue_used--;
		if (!tx_queue_used)
			UCSRB &= ~(1 << UDRIE);
	}
}

ISR(USART_UDRE_vect)
{
	if (tx_queue_used)
		tx_put_next_byte();
}

static void queue_tx_message(struct remote_message *msg)
{
	uint8_t sreg;

	sreg = irq_disable_save();

	mb();
	if (unlikely(tx_queue_used >= ARRAY_SIZE(tx_queue))) {
		/* TX queue is full. Notify the overflow condition
		 * to the remote control, once we get the message out. */
		msg->id |= MSG_FLAG_QOVERFLOW;
		msg->crc = message_calc_crc(msg);

		/* Emergency situation. Manually push TX to get things
		 * out of the box. */
		do {
			if (UCSRA & (1 << UDRE))
				tx_put_next_byte();
			if (!__irqs_disabled(sreg)) {
				/* IRQs were enabled before we were called.
				 * Be nice to other interrupts and re-enable them
				 * for a microsecond. */
				irq_enable();
				udelay(1);
				irq_disable();
				mb();
			}
		} while (tx_queue_used >= ARRAY_SIZE(tx_queue));
	}

	memcpy(&tx_queue[tx_queue_in_ptr], msg, sizeof(*msg));
	tx_queue_used++;
	tx_queue_in_ptr++;
	if (tx_queue_in_ptr >= ARRAY_SIZE(tx_queue))
		tx_queue_in_ptr = 0;

	if (tx_queue_used == 1)
		UCSRB |= (1 << UDRIE);

	irq_restore(sreg);
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
	msg->crc = message_calc_crc(msg);
	queue_tx_message(msg);
}

static void handle_received_message(void)
{
	struct remote_message reply;
	uint8_t calc_crc;
	uint8_t err = MSG_ERR_NONE;

	calc_crc = message_calc_crc(&rx_msg);
	if (calc_crc != rx_msg.crc) {
		/* CRC mismatch. */
		err = MSG_ERR_CHKSUM;
		goto out;
	}

	memset(&reply, 0, sizeof(reply));

	switch (rx_msg.id & MSG_ID_MASK) {
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

		if (!device_is_enabled()) {
			err = MSG_ERR_BUSY;
			goto out;
		}

		irq_disable();
		get_pressure_config(&xy, &z);
		if (rx_msg.setpressure.island == 0)
			xy.desired = rx_msg.setpressure.mbar;
		else if (rx_msg.setpressure.island == 1)
			z.desired = rx_msg.setpressure.mbar;
		set_pressure_config(&xy, &z);
		irq_enable();
		break;
	}
	case MSG_SET_HYSTERESIS: {
		struct pressure_config xy, z;

		if (!device_is_enabled()) {
			err = MSG_ERR_BUSY;
			goto out;
		}

		irq_disable();
		get_pressure_config(&xy, &z);
		if (rx_msg.setpressure.island == 0)
			xy.hysteresis = rx_msg.setpressure.mbar;
		else if (rx_msg.setpressure.island == 1)
			z.hysteresis = rx_msg.setpressure.mbar;
		set_pressure_config(&xy, &z);
		irq_enable();
		break;
	}
	case MSG_SET_CONFIG_FLAGS: {
		struct pressure_config xy, z;
		bool flag;

		if (!device_is_enabled()) {
			err = MSG_ERR_BUSY;
			goto out;
		}

		irq_disable();
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
		irq_enable();
		break;
	}
	case MSG_SET_VALVE: {
		struct pressure_config xy, z;
		struct valves *v;

		if (!device_is_enabled()) {
			err = MSG_ERR_BUSY;
			goto out;
		}

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
			valve1_switch(v, VALVE_STATE_IDLE);
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
	case MSG_GET_MAXIMA: {
		reply.id = MSG_MAXIMA;
		if (rx_msg.getmaxima.island == 0) {
			reply.maxima.pressure = XY_MAX_PRESSURE;
			reply.maxima.hysteresis = XY_MAX_HYSTERESIS;
			send_message(&reply);
		} else if (rx_msg.getmaxima.island == 1) {
			reply.maxima.pressure = Z_MAX_PRESSURE;
			reply.maxima.hysteresis = Z_MAX_HYSTERESIS;
			send_message(&reply);
		} else
			err = MSG_ERR_INVAL;
		break;
	}
	case MSG_INVALID:
		break;
	default:
		err = MSG_ERR_NOCMD;
		break;
	}

out:
	if (rx_msg.id & MSG_FLAG_REQ_ERRCODE) {
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
static void usart_rx_timeout_check(void)
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
	irq_disable();
	if (rx_softirq) {
		rx_softirq = 0;
		usart_handle_rx_irq();
	}
	if (last_timeout_check != now) {
		last_timeout_check = now;
		usart_rx_timeout_check();
	}
	irq_enable();
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
	BUILD_BUG_ON(sizeof(struct remote_message) != 6);

	usart_init();
}
