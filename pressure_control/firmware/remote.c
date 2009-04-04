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


#define BAUDRATE	38400 /* Error = 0.2% */
#define USE_2X		0


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
		reply.pressure.mbar = state.mbar;
		send_message(&reply);
		break;
	}
	case MSG_GET_DESIRED_PRESSURE: {
		struct pressure_config conf;

		get_pressure_config(&conf);
		reply.id = MSG_DESIRED_PRESSURE;
		reply.pressure.mbar = conf.desired;
		send_message(&reply);
		break;
	}
	case MSG_GET_HYSTERESIS: {
		struct pressure_config conf;

		get_pressure_config(&conf);
		reply.id = MSG_HYSTERESIS;
		reply.pressure.mbar = conf.hysteresis;
		send_message(&reply);
		break;
	}
	case MSG_GET_CONFIG_FLAGS: {
		struct pressure_config conf;

		get_pressure_config(&conf);
		reply.id = MSG_CONFIG_FLAGS;
		if (conf.autoadjust_enable)
			reply.config.flags |= (1 << CFG_FLAG_AUTOADJUST_ENABLE);
		send_message(&reply);
		break;
	}
	case MSG_SET_DESIRED_PRESSURE: {
		struct pressure_config conf;

		cli();
		get_pressure_config(&conf);
		conf.desired = rx_msg.pressure.mbar;
		set_pressure_config(&conf);
		sei();
		break;
	}
	case MSG_SET_HYSTERESIS: {
		struct pressure_config conf;

		cli();
		get_pressure_config(&conf);
		conf.hysteresis = rx_msg.pressure.mbar;
		set_pressure_config(&conf);
		sei();
		break;
	}
	case MSG_SET_CONFIG_FLAGS: {
		struct pressure_config conf;
		bool flag;

		cli();
		get_pressure_config(&conf);
		flag = !!(rx_msg.config.flags & (1 << CFG_FLAG_AUTOADJUST_ENABLE));
		if (conf.autoadjust_enable != flag) {
			conf.autoadjust_enable = flag;
			/* Make sure the values are idle. */
			valves_global_switch(VALVES_IDLE);
		}
		set_pressure_config(&conf);
		sei();
		break;
	}
	case MSG_SET_VALVE: {
		struct pressure_config conf;

		get_pressure_config(&conf);
		if (conf.autoadjust_enable) {
			err = MSG_ERR_BUSY;
			break;
		}
		if (rx_msg.valve.nr == 0) {
			valve0_switch(rx_msg.valve.state == 0 ?
				      VALVE_STATE_12 : VALVE_STATE_14);
		} else if (rx_msg.valve.nr == 1) {
			valve1_switch(rx_msg.valve.state == 0 ?
				      VALVE_STATE_12 : VALVE_STATE_14);
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
	sei();
}

/* Maintanance work. Called at a frequency of 1KHz with IRQs disabled. */
void remote_1khz_work(void)
{
	usart_rx_timeout_check();
}

void remote_pressure_change_notification(uint16_t mbar,
					 uint16_t hysteresis)
{
	struct remote_message msg;

	static uint16_t prev_value;

	if (abs((int32_t)mbar - (int32_t)prev_value) <= hysteresis)
		return;
	prev_value = mbar;

	memset(&msg, 0, sizeof(msg));
	msg.id = MSG_CURRENT_PRESSURE;
	msg.pressure.mbar = mbar;
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
	/* 8 Data bits, 1 Stop bit, No parity */
	UCSRC = (1 << URSEL) | (1 << UCSZ0) | (1 << UCSZ1);
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
