/*
 *  Pneumatic pressure controller.
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

#include "util.h"
#include "calibration.h"
#include "sensor.h"
#include "valves.h"


static inline void usart_tx(uint8_t data)
{
	while (!(UCSRA & (1 << UDRE)))
		;
	UDR = data;
}

static void __print(const prog_char *msg)
{
	uint8_t c;

	for ( ; ; msg++) {
		c = pgm_read_byte(msg);
		if (c == '\0')
			break;
		usart_tx(c);
	}
}
#define print(msg)	__print(PSTR(msg))

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

#define BAUDRATE	9600

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
	UCSRB = (1 << RXEN) | (1 << TXEN);// | (1 << RXCIE);
	/* Drain the RX buffer */
	while (usart_rx(&dummy) != -ENODATA)
		mb();
}

int main(void)
{
	cli();

	valves_init();
	usart_init();

	sei();

	while (1) {
		print("Hallo!\n");
		//TODO
	}
}
