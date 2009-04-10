/*
 *  Pneumatic pressure controller.
 *  Sensor input.
 *
 *  Copyright (C) 2008-2009 Michael Buesch <mb@bu3sch.de>
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


/* The sensor value offset, in millivolts.
 * This value is subtracted from the measured voltage before
 * processing. */
#define SENSOR_MV_OFFSET	245

/* The Full Scale Output (maximum) output value of the sensor,
 * in millivolts. */
#define SENSOR_FULL_SCALE_MV	U32(4400)

/* The pressure at Full Scale Output, in millibar. */
#define SENSOR_FULL_SCALE_MBAR	U32(10000)

/* The sensor enable signal pin. */
#define SENSOR_ENABLE_DDR	DDRC
#define SENSOR_ENABLE_PORT	PORTC
#define SENSOR_ENABLE_BIT	1



#define ADC_MAX			U32(0x3FF)

ISR(ADC_vect)
{
	const uint16_t full_scale_adc = ADC_MAX * SENSOR_FULL_SCALE_MV / 5000;

	uint16_t adc, mv, mbar;

	/* Convert the ADC value to millivolts. */
	adc = ADC;
	if (adc > full_scale_adc)
		adc = full_scale_adc;
	mv = SENSOR_FULL_SCALE_MV * (uint32_t)adc / full_scale_adc;

	/* Subtract the sensor voltage offset, so 0 mBar results in 0 mV. */
	if (mv > SENSOR_MV_OFFSET)
		mv -= SENSOR_MV_OFFSET;
	else
		mv = 0;

	mbar = SENSOR_FULL_SCALE_MBAR * (uint32_t)mv / SENSOR_FULL_SCALE_MV;

	sensor_result(mbar);
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
	/* Trigger an ADC conversion with interrupt notification. */
	adc_trigger(1);
}

void sensor_init(void)
{
	SENSOR_ENABLE_DDR |= (1 << SENSOR_ENABLE_BIT);
	SENSOR_ENABLE_PORT |= (1 << SENSOR_ENABLE_BIT);
	mdelay(20); /* Warm-up time */
	/* Discard the first ADC result. */
	adc_trigger(0);
	while (ADCSRA & (1 << ADSC))
		mb();
}
