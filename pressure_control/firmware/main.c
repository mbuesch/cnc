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

#include "main.h"
#include "util.h"
#include "calibration.h"
#include "sensor.h"
#include "valves.h"
#include "remote.h"

#include <stdint.h>
#include <string.h>

#include <avr/eeprom.h>


struct eeprom_data {
	struct pressure_config cfg;
};

/* The pressure configuration data. */
struct pressure_config cfg;
/* The pressure state data. */
struct pressure_state state;

/* EEPROM contents */
static struct eeprom_data EEMEM eeprom = {
	.cfg = {
		.desired		= 4000,	/* Millibar */
		.hysteresis		= 200,	/* Millibar */
		.autoadjust_enable	= 1,
	},
};


void get_pressure_config(struct pressure_config *ret)
{
	uint8_t sreg;

	sreg = irq_disable_save();
	memcpy(ret, &cfg, sizeof(*ret));
	irq_restore(sreg);
}

void set_pressure_config(struct pressure_config *new_cfg)
{
	uint8_t sreg;

	sreg = irq_disable_save();
	memcpy(&cfg, new_cfg, sizeof(cfg));
	irq_restore(sreg);
}

void get_pressure_state(struct pressure_state *ret)
{
	uint8_t sreg;

	sreg = irq_disable_save();
	memcpy(ret, &state, sizeof(*ret));
	irq_restore(sreg);
}

/* Load the configuration from the EEPROM. */
static void eeprom_load_config(void)
{
	eeprom_busy_wait();
	eeprom_read_block(&cfg, &eeprom.cfg, sizeof(cfg));
	eeprom_busy_wait();
}

/* Store the configuration to the EEPROM. */
static void eeprom_store_config(void)
{
	eeprom_busy_wait();
	eeprom_write_block(&cfg, &eeprom.cfg, sizeof(cfg));
	eeprom_busy_wait();
}

/* Sensor measurement completed.
 * Called in IRQ context. */
void sensor_result(uint16_t mbar)
{
	/* Defer processing of the value to the mainloop, so we can do it with
	 * interrupts enabled. */
	state.mbar = mbar;
	mb();
	state.needs_checking = 1;
}

/* 1kHz system timer. */
ISR(TIMER1_COMPA_vect)
{
	if (state.sensor_trigger_cnt > 0)
		state.sensor_trigger_cnt--;
	remote_1khz_work();
}

void system_timer_init(void)
{
	TCCR1B = (1 << WGM12) | (1 << CS10) | (1 << CS11); /* prescaler 64 */
	OCR1A = 250; /* 1kHz timer at 16MHz crystal */
	TIMSK |= (1 << OCIE1A);
}

/* Check the current pressure value against the desired value and
 * adjust the pressure if needed. */
static void check_pressure(void)
{
	int32_t offset;
	uint16_t abs_offset;
	bool is_too_big;
	bool report_change = 0;
	uint8_t cur_state;

	if (cfg.autoadjust_enable) {
		offset = (int32_t)state.mbar - (int32_t)cfg.desired;
		abs_offset = abs(offset);
		is_too_big = (offset >= 0);
		cur_state = valves_get_global_state();

		if (abs_offset > cfg.hysteresis) {
			/* Adjust the pressure */
			report_change = (cur_state == VALVES_IDLE);
			if (is_too_big)
				valves_global_switch(VALVES_FLOW_OUT);
			else
				valves_global_switch(VALVES_FLOW_IN);
		} else if (abs_offset > cfg.hysteresis / 4) {
			/* If we're idle, stay idle.
			 * If we're increasing or decreasing pressure,
			 * keep on doing this to reach the desired center value
			 * more closely. */
		} else {
			/* We're within half the hysteresis.
			 * The pressure is OK. Make sure the valves are
			 * all idle. */
			report_change = (cur_state != VALVES_IDLE);
			valves_global_switch(VALVES_IDLE);
		}
	}
	if (abs((int32_t)state.mbar - (int32_t)state.reported_mbar) >= 100)
		report_change = 1;
	if (report_change) {
		remote_pressure_change_notification(state.mbar);
		state.reported_mbar = state.mbar;
	}
}

int main(void)
{
	cli();

	/* It's OK to init the remote interface that early, as we
	 * have IRQs disabled throughout the init process. So we can't
	 * receive any remote commands, yet. But early init allows us
	 * to send error messages early. */
	remote_init();
	print("Pressure control initializing...\n");

	valves_init();
	sensor_init();
	eeprom_load_config();
	system_timer_init();

	sei();

	print("Monitoring...\n");
	while (1) {
		mb();
		if (state.sensor_trigger_cnt == 0) {
			/* It's time for triggering another sensor measurement. */
			state.sensor_trigger_cnt = -1;
			mb();
			sensor_trigger_read();
		}
		if (state.needs_checking) {
			check_pressure();
			/* Trigger another measurement in 50 milliseconds. */
			state.sensor_trigger_cnt = 50;
			state.needs_checking = 0;
			mb();
		}
		remote_work();
	}
}
