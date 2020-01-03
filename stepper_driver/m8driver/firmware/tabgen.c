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
	unsigned int lmd1, lmd2;
	unsigned int count;
	unsigned char *buf;

	buf = malloc(nr_steps * 2);
	if (!buf) {
		fprintf(stderr, "Out of memory.\n");
		return 1;
	}

	/* Generate the lookup table. */
	/* sin() takes radians as arg. pi rad == 180deg */
	for (count = 0; count < nr_steps * 2; count++) {
		pos = M_PI / (nr_steps * 2) * count;

		s = sin(pos);
		s = s * 0xF;
		lmd1 = (unsigned int)round(s) & 0xF;

		s = cos(pos);
		if (s < 0)
			s = -s;
		s = s * 0xF;
		lmd2 = (unsigned int)round(s) & 0xF;
		lmd2 <<= 4;

		buf[count] = lmd1 | lmd2;
	}

	/* Print the lookup table. */
	printf("steptable:\n");
	for (count = 0; count < nr_steps * 2; count++) {
		if (count % 8 == 0)
			printf("%s.db 0x%02X", count ? "\n" : "", buf[count]);
		else
			printf(", 0x%02X", buf[count]);
	}
	printf("\n\n");

	free(buf);

	return 0;
}

int main(int argc, char **argv)
{
	unsigned long nr_steps;
	int err;

	if (argc != 2) {
		fprintf(stderr, "Usage: %s NR_OF_STEPS\n", argv[0]);
		return 1;
	}
	nr_steps = strtoul(argv[1], NULL, 10);
	if (nr_steps < 1 || nr_steps > 60) {
		fprintf(stderr, "Please select a step count between 1 and 60\n");
		return 1;
	}

	printf("; THIS FILE IS GENERATED. DO NOT EDIT.\n");
	printf("\n\n");
	printf(".equ NR_STEPS=%lu\n", nr_steps);
	printf("\n");
	printf(".cseg\n");

	err = gen_lmd_tab(nr_steps);
	if (err)
		return 1;

	printf("; For reference store the build parameters in the binary image\n");
	printf(".db 0,0,0,0\n");
	printf(".db \"NR_STEPS=%lu\"%s\n", nr_steps, ((nr_steps > 9) ? ",0" : ""));
	printf(".db 0,0,0,0\n");
	printf(".db \"BUILD_DATE=%04u.%02u.%02u\",0\n",
	       (unsigned int)COMPILE_YEAR,
	       (unsigned int)COMPILE_MONTH,
	       (unsigned int)COMPILE_DAY);
	printf("\n");

	return 0;
}
