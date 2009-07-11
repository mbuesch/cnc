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


static const char template_25steps[] =
"                     ########                     "
"                  ###        ###                  "
"                ##              ##                "
"              ##                  ##              "
"            ##                      ##            "
"          ##                          ##          "
"         #                              #         "
"        #                                #        "
"       #                                  #       "
"      #                                    #      "
"     #                                      #     "
"    #                                        #    "
"   #                                          #   "
"  #                                            #  "
" #                                              # "
"#                                                #";


static unsigned int template_find_amplitude(const char *template,
					    unsigned int nr_steps, unsigned int column)
{
	unsigned int row;
	char c;

	for (row = 0; row <= 0xF; row++) {
		c = template[row * nr_steps * 2 + column];
		if (c != ' ')
			break;
	}
	if (row > 0xF) {
		fprintf(stderr, "Table error\n");
		return 1;
	}

	return 0xF - row;
}

static int gen_tab(const char *template, unsigned int nr_steps)
{
	unsigned int col, col2, lmd;
	unsigned int count;

	printf("; THIS FILE IS GENERATED. DO NOT EDIT.\n");
	printf("\n");
	printf(".equ NR_STEPS = %u\n", nr_steps);
	printf(".cseg\n");
	printf("\n");

	printf("steptable_lmd1:");
	count = 0;
	for (col = 0; col < nr_steps * 2; col++) {
		lmd = template_find_amplitude(template, nr_steps, col);
		if (count == 0)
			printf("\n.db ");
		printf("0x%02X, ", lmd);
		count = (count + 1) & 3;
	}
	printf("\n\n");

	printf("steptable_lmd2:");
	count = 0;
	for (col = 0; col < nr_steps * 2; col++) {
		col2 = col + nr_steps;
		if (col2 >= nr_steps * 2)
			col2 -= nr_steps * 2;
		lmd = template_find_amplitude(template, nr_steps, col2);
		lmd <<= 4;
		/* Polarity */
		if (col <= nr_steps)
			lmd |= 3;
		else
			lmd |= 2;

		if (count == 0)
			printf("\n.db ");
		printf("0x%02X, ", lmd);
		count = (count + 1) & 3;
	}
	printf("\n");

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
	switch (nr_steps) {
	case 25:
		return gen_tab(template_25steps, nr_steps);
	default:
		fprintf(stderr, "%lu is not a valid microstep value\n", nr_steps);
		return 1;
	}
}
