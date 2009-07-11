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


static int gen_lmd_tab(unsigned int nr_steps)
{
	double pos;
	double s;
	unsigned int lmd1, lmd2, polarity;
	unsigned int count;
	int row, col;
	char *buf;

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
		lmd2 |= polarity;

		buf[count * 2] = lmd1;
		buf[count * 2 + 1] = lmd2;
	}

	/* Print a diagram. */
	for (row = 15; row >= -15; row--) {
		printf("; %3d | ", row);
		for (col = 0; col < nr_steps * 2; col++) {
			char c = ' ';
			int l1, l2;
			char polarity;

			l1 = buf[col * 2];
			l2 = buf[col * 2 + 1] >> 4;
			polarity = buf[col * 2 + 1] & 0xF;
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
		lmd1 = buf[count * 2];
		lmd2 = buf[count * 2 + 1];
		printf(".db 0x%02X, 0x%02X    ; LMD1 = %2u/%s,  LMD2 = %2u/%s\n",
		       lmd1, lmd2,
		       lmd1, (lmd2 & 1) ? "f" : "b",
		       lmd2 >> 4, (lmd2 & 2) ? "f" : "b");
	}
	printf("\n");

	free(buf);

	return 0;
}

int main(int argc, char **argv)
{
	unsigned long nr_steps;

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
	printf(".cseg\n");
	printf("\n");

	return gen_lmd_tab(nr_steps);
}
