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

#include <string.h>

#include <avr/io.h>


#define BAUDRATE	9600


static struct remote_message rx_msg;
static uint8_t rx_msg_count;
static bool rx_msg_valid;


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

	status = UCSRA;
	if (!(status & (1 << RXC)))
		return -ENODATA;
	if (unlikely(status & ((1 << FE) | (1 << PE) | (1 << DOR)))) {
		if (status & (1 << FE))
			return -ERXFE;
		if (status & (1 << PE))
			return -ERXPE;
		if (status & (1 << DOR))
			return -ERXOV;
	}
	*data = UDR;

	return 0;
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

static void send_message_error(uint8_t error_code)
{
	struct remote_message msg;

	memset(&msg, 0, sizeof(msg));
	msg.id = MSG_ERROR;
	msg.error.code = error_code;

	send_message(&msg);
}

static void handle_received_message(void)
{
	struct remote_message reply;
	uint16_t calc_crc;

	calc_crc = crc16_block_update(0xFFFF, &rx_msg,
				      sizeof(rx_msg) - sizeof(rx_msg.crc));
	calc_crc ^= 0xFFFF;
	if (calc_crc != rx_msg.crc) {
		/* CRC mismatch. */
		send_message_error(MSG_ERR_CHKSUM);
		return;
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
	} }
}

/* RX interrupt */
ISR(USART_RXC_vect)
{
	uint8_t *rxbuf = (uint8_t *)&rx_msg;
	int8_t err;
	uint8_t data;

	if (rx_msg_valid)
		return;

	while (1) {
		err = usart_rx(&data);
		if (err == -ENODATA)
			break;
		if (unlikely(err)) {
			//TODO other error
			data = 0;
		}
		rxbuf[rx_msg_count++] = data;
		if (rx_msg_count == sizeof(struct remote_message)) {
			rx_msg_count = 0;
			mb();
			rx_msg_valid = 1;
		}
	}
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

/* Maintanance work. Called with IRQs enabled. */
void remote_work(void)
{
	if (rx_msg_valid) {
		handle_received_message();
		mb();
		rx_msg_valid = 0;
	}
}

static void usart_init(void)
{
	uint8_t dummy;

	/* Set baud rate */
	UBRRL = lo8((CPU_HZ / 16 / BAUDRATE) * 2);
	UBRRH = hi8((CPU_HZ / 16 / BAUDRATE) * 2) & ~(1 << URSEL);
	UCSRA = (1 << U2X);
	/* 8 Data bits, 2 Stop bits, Even parity */
	UCSRC = (1 << URSEL) | (1 << UCSZ0) | (1 << UCSZ1) | (1 << UPM1) | (1 << USBS);
	/* Enable transceiver and RX IRQs */
	UCSRB = (1 << RXEN) | (1 << TXEN) | (1 << RXCIE);
	/* Drain the RX buffer */
	while (usart_rx(&dummy) != -ENODATA)
		mb();
}

void remote_init(void)
{
	/* The remote tool depends on the exact size (and layout). */
	BUILD_BUG_ON(sizeof(struct remote_message) != 38);

	usart_init();
}
