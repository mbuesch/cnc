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


static struct sensor *active_sensor;

#define ADC_MAX			U32(0x3FF)

ISR(ADC_vect)
{
	struct sensor *s = active_sensor;
	const uint16_t full_scale_adc = ADC_MAX * (uint32_t)s->full_scale_mv / 5000;
	uint16_t adc, mv, mbar;

	/* Convert the ADC value to millivolts. */
	adc = ADC;
	if (adc > full_scale_adc)
		adc = full_scale_adc;
	mv = (uint32_t)s->full_scale_mv * (uint32_t)adc / full_scale_adc;

	/* Subtract the sensor voltage offset, so 0 mBar results in 0 mV. */
	if (mv > s->mv_offset)
		mv -= s->mv_offset;
	else
		mv = 0;

	mbar = (uint32_t)s->full_scale_mbar * (uint32_t)mv / (uint32_t)s->full_scale_mv;

	sensor_result(s, mbar);
}

static inline void adc_trigger(uint8_t mux, bool with_irq)
{
	/* Set the multiplexer to ADC-0, AVcc Ref. */
	ADMUX = (1 << REFS0) | mux;
	/* Start ADC with a prescaler of 128. That's a ADC freq
	 * of 125kHz on a 16MHz crystal. */
	ADCSRA = (1 << ADEN) | (1 << ADSC) |
		 (1 << ADPS0) | (1 << ADPS1) | (1 << ADPS2) |
		 (with_irq ? (1 << ADIE) : 0);
}

void sensor_trigger_read(struct sensor *s)
{
	active_sensor = s;
	mb();
	/* Trigger an ADC conversion with interrupt notification. */
	adc_trigger(s->adc_mux, 1);
}

void sensor_init(struct sensor *s)
{
	mdelay(20); /* Warm-up time */
	/* Discard the first ADC result. */
	adc_trigger(s->adc_mux, 0);
	while (ADCSRA & (1 << ADSC))
		mb();
}
