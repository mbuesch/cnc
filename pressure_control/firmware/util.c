/*
 *   Utility functions
 *
 *   Copyright (C) 2008 Michael Buesch <mb@bu3sch.de>
 *
 *   This program is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU General Public License
 *   as published by the Free Software Foundation; either version 2
 *   of the License, or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 */

#include "util.h"
#include "calibration.h"

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
