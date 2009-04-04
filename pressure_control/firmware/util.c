/*
 *  Utility functions.
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

#include <util/crc16.h>
#include <avr/io.h>
#include <avr/sleep.h>


void mdelay(uint16_t msecs)
{
	uint8_t timer, i;

	TCCR0 = DELAY_1MS_TIMERFREQ;
	do {
		/* Delay one millisecond */
		for (i = DELAY_1MS_LOOP_TIMES; i; i--) {
			TCNT0 = 0;
			do {
				timer = TCNT0;
			} while (timer < DELAY_1MS_LOOP);
		}
	} while (--msecs);
	TCCR0 = 0;
}

void udelay(uint16_t usecs)
{
	uint8_t tmp;

	__asm__ __volatile__(
	"1:				\n"
	"	ldi %1, %2		\n"
	"2:				\n"
	"	dec %1			\n"
	"	brne 2b			\n"
	"	dec %A3			\n"
	"	brne 1b			\n"
	"	cp %B3, __zero_reg__	\n"
	"	breq 3f			\n"
	"	dec %B3			\n"
	"	ldi %A3, 0xFF		\n"
	"	rjmp 1b			\n"
	"3:				\n"
	: "=d" (usecs),
	  "=d" (tmp)
	: "M" (DELAY_1US_LOOP),
	  "0" (usecs)
	);
}

void panic(const prog_char *msg)
{
//TODO
	infinite_sleep();
}

void infinite_sleep(void)
{
	cli();
	set_sleep_mode(SLEEP_MODE_PWR_DOWN);
	while (1)
		sleep_mode();
}

uint16_t crc16_block_update(uint16_t crc, const void *_data, uint16_t size)
{
	const uint8_t *data = _data;

	while (size) {
		crc = _crc16_update(crc, *data);
		data++;
		size--;
	}

	return crc;
}

uint8_t hexdigit_to_ascii(uint8_t digit)
{
	/* Convert a hexadecimal digit (0-F) to an ASCII character */
	if (digit >= 0xA)
		digit += 0x41 - 0xA;
	else
		digit += 0x30;
	return digit;
}

void num16_to_ascii(uint8_t *buf, uint16_t v)
{
	uint16_t orig = v;

	if (orig >= 10000) {
		*buf++ = v / 10000 + '0';
		v %= 10000;
	}
	if (orig >= 1000) {
		*buf++ = v / 1000 + '0';
		v %= 1000;
	}
	if (orig >= 100) {
		*buf++ = v / 100 + '0';
		v %= 100;
	}
	if (orig >= 10) {
		*buf++ = v / 10 + '0';
		v %= 10;
	}
	*buf++ = v + '0';
	*buf = '\0';
}
