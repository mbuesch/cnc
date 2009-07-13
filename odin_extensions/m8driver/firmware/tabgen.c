/*
 *   Atmel Mega8 based ODIN chipset
 *   Lookup table generator
 *
 *   Copyright (c) 2009 Michael Buesch <mb@bu3sch.de>
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

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#undef M_PI
#define M_PI		3.14159265358979323846264338327


#define COMPILE_YEAR ((((__DATE__[7] - '0') * 10 +				\
			(__DATE__[8] - '0')) * 10 +				\
			(__DATE__[9] - '0')) * 10 +				\
			(__DATE__[10] - '0'))

#define COMPILE_MONTH ((__DATE__[2] == 'n' ? (__DATE__[1] == 'a' ? 0 : 5)	\
			: __DATE__[2] == 'b' ? 1				\
			: __DATE__[2] == 'r' ? (__DATE__[0] == 'M' ? 2 : 3)	\
			: __DATE__[2] == 'y' ? 4				\
			: __DATE__[2] == 'l' ? 6				\
			: __DATE__[2] == 'g' ? 7				\
			: __DATE__[2] == 'p' ? 8				\
			: __DATE__[2] == 't' ? 9				\
			: __DATE__[2] == 'v' ? 10 : 11) + 1)

#define COMPILE_DAY ((__DATE__[4] == ' ' ? 0 : __DATE__[4] - '0') * 10 +	\
		     (__DATE__[5] - '0'))


static int gen_lmd_tab(unsigned int nr_steps)
{
	double pos;
	double s;
	unsigned int lmd1, lmd2, polarity;
	unsigned int count;
	int row, col;
	unsigned char *buf;

	buf = malloc(nr_steps * 2 * 2);
	if (!buf) {
		fprintf(stderr, "Out of memory.\n");
		return 1;
	}

	/* Generate the lookup table. */
	/* sin() takes radians as arg. pi rad == 180deg */
	for (count = 0; count < nr_steps * 2; count++) {
		pos = M_PI / (nr_steps * 2) * count;
		polarity = 0;

		s = sin(pos);
		s = s * 0xF;
		lmd1 = (unsigned int)round(s) & 0xF;
		polarity |= 1;

		s = cos(pos);
		if (s < 0)
			s = -s;
		else
			polarity |= 2;
		s = s * 0xF;
		lmd2 = (unsigned int)round(s) & 0xF;
		lmd2 <<= 4;

		buf[count * 2] = lmd1 | lmd2;
		buf[count * 2 + 1] = polarity;
	}

	/* Print a diagram. */
	for (row = 15; row >= -15; row--) {
		printf("; %3d | ", row);
		for (col = 0; col < nr_steps * 2; col++) {
			char c = ' ';
			int l1, l2;
			unsigned char polarity;

			l1 = buf[col * 2] & 0xF;
			l2 = buf[col * 2] >> 4;
			polarity = buf[col * 2 + 1];
			if (!(polarity & 1))
				l1 = -l1;
			if (!(polarity & 2))
				l2 = -l2;
			if (l1 == row)
				c = '&';
			if (l2 == row)
				c = '$';
			putchar(c);
		}
		putchar('\n');
	}
	printf(";     L-");
	for (col = 0; col < nr_steps * 2; col++)
		putchar('-');
	printf("\n;       ");
	for (col = 0; col < nr_steps * 2; col += 4)
		printf("%-4u", col);
	putchar('\n');

	/* Print the lookup table. */
	printf("steptable:\n");
	for (count = 0; count < nr_steps * 2; count++) {
		unsigned int a, b;
		int l1, l2;

		a = buf[count * 2];
		b = buf[count * 2 + 1];
		l1 = a & 0xF;
		if (!(b & 1))
			l1 = -l1;
		l2 = a >> 4;
		if (!(b & 2))
			l2 = -l2;
		printf(".db 0x%02X, 0x%02X    ; LMD1 = %3d,  LMD2 = %3d\n",
		       a, b, l1, l2);
	}
	printf("\n");

	free(buf);

	return 0;
}

int main(int argc, char **argv)
{
	unsigned long nr_steps;
	unsigned int i;
	char buf[32];

	if (argc != 2) {
		fprintf(stderr, "Usage: %s NR_OF_STEPS\n", argv[0]);
		return 1;
	}
	nr_steps = strtoul(argv[1], NULL, 10);
	if (nr_steps < 8 || nr_steps > 30) {
		fprintf(stderr, "Please select a step count between 8 and 30\n");
		return 1;
	}

	printf("; THIS FILE IS GENERATED. DO NOT EDIT.\n");
	printf("\n");
	printf(".equ NR_STEPS = %lu\n", nr_steps);
	snprintf(buf, sizeof(buf), "%02lu", nr_steps);
	printf(".equ NR_STEPS_ASCII_0 = %u ; ASCII %c\n",
	       (unsigned int)buf[0], (unsigned int)buf[0]);
	printf(".equ NR_STEPS_ASCII_1 = %u ; ASCII %c\n",
	       (unsigned int)buf[1], (unsigned int)buf[1]);
	snprintf(buf, sizeof(buf), "%04u.%02u.%02u",
		 COMPILE_YEAR, COMPILE_MONTH, COMPILE_DAY);
	for (i = 0; i < 10; i++) {
		printf(".equ BDATE%u = %u ; ASCII %c\n",
		       i, (unsigned int)buf[i], (unsigned int)buf[i]);
	}
	printf(".cseg\n");
	printf("\n");

	return gen_lmd_tab(nr_steps);
}
