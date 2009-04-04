/*
 *  Pneumatic pressure controller.
 *  Sensor input.
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

#include "sensor.h"
#include "util.h"
#include "remote.h"

#include <avr/io.h>
#include <avr/interrupt.h>


/*** The sensor enable signal ***/
#define SENSOR_ENABLE_DDR	DDRC
#define SENSOR_ENABLE_PORT	PORTC
#define SENSOR_ENABLE_BIT	1


static inline void sensor_enable(void)
{
	SENSOR_ENABLE_PORT |= (1 << SENSOR_ENABLE_BIT);
}

static inline void sensor_disable(void)
{
	SENSOR_ENABLE_PORT &= ~(1 << SENSOR_ENABLE_BIT);
}

ISR(ADC_vect)
{
	uint16_t val;

	val = ADC;
	sensor_disable();
print_dec(val);
print("\n");
	//TODO process value
	sensor_result(val);
}

static inline void adc_trigger(bool with_irq)
{
	/* Set the multiplexer to ADC-0, AVcc Ref. */
	ADMUX = (1 << REFS0);
	/* Start ADC with a prescaler of 128. That's a ADC freq
	 * of 125kHz on a 16MHz crystal. */
	ADCSRA = (1 << ADEN) | (1 << ADSC) |
		 (1 << ADPS0) | (1 << ADPS1) | (1 << ADPS2) |
		 (with_irq ? (1 << ADIE) : 0);
}

void sensor_trigger_read(void)
{
	/* Enable the sensor and wait a dwell time for the
	 * sensor to stabilize. */
	sensor_enable();
	udelay(500);
	/* Finally trigger the ADC conversion. */
	adc_trigger(1);
}

void sensor_init(void)
{
	SENSOR_ENABLE_DDR |= (1 << SENSOR_ENABLE_BIT);
	sensor_disable();
	/* Discard the first ADC result. */
	adc_trigger(0);
	while (ADCSRA & (1 << ADSC))
		mb();
}
