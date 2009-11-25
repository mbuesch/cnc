/*
 *  Pneumatic pressure controller.
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

#include "main.h"
#include "util.h"
#include "calibration.h"
#include "sensor.h"
#include "valves.h"
#include "remote.h"

#include <stdint.h>
#include <string.h>

#include <avr/eeprom.h>
#include <avr/io.h>
#include <avr/wdt.h>


struct eeprom_data {
	struct pressure_config cfg_xy;
	struct pressure_config cfg_z;
};

/* The pressure configuration data. */
static struct pressure_config cfg_xy;
static struct pressure_config cfg_z;
/* The pressure state data. */
static struct pressure_state state;
/* The 1000Hz jiffies counter */
static jiffies_t jiffies_counter;
/* The sensor that we're currently handling. */
static uint8_t sensor_cycle;


/* The hardware definitions. */
DEFINE_VALVE_2MAG(z_control_valves,
		  D,6,	D,7,
		  D,4,	D,5,
		  0);
DEFINE_VALVE_1MAG(xy_control_valves,
		  D,3,	D,2,
		  400);
static DEFINE_SENSOR(z_control_sensor, 0, 245, 4400, 10000);
static DEFINE_SENSOR(xy_control_sensor, (1<<MUX0), 245, 4400, 10000);

/* Absolute maximum pressures (in mBar). */
#define XY_MAX_PRESSURE		3500
#define XY_MAX_HYSTERESIS	300
#define Z_MAX_PRESSURE		1500
#define Z_MAX_HYSTERESIS	300

/* Report hysteresis (in mBar).
 * Don't report changes lower than this (With some exceptions). */
#define REPORT_HYSTERESIS	15



/* EEPROM contents */
static struct eeprom_data EEMEM eeprom = {
	.cfg_xy = {
		.desired		= min(2900, XY_MAX_PRESSURE), /* mBar */
		.hysteresis		= min(50, XY_MAX_HYSTERESIS), /* mBar */
		.autoadjust_enable	= 1,
	},
	.cfg_z = {
		.desired		= min(1100, Z_MAX_PRESSURE), /* mBar */
		.hysteresis		= min(50, Z_MAX_HYSTERESIS), /* mBar */
		.autoadjust_enable	= 1,
	},
};


/* Load the configuration from the EEPROM. */
static void eeprom_load_config(void)
{
	eeprom_busy_wait();
	eeprom_read_block(&cfg_xy, &eeprom.cfg_xy, sizeof(cfg_xy));
	eeprom_read_block(&cfg_z, &eeprom.cfg_z, sizeof(cfg_z));
	eeprom_busy_wait();
}

/* Store the configuration to the EEPROM. */
static void eeprom_store_config(void)
{
	eeprom_busy_wait();
	eeprom_write_block(&cfg_xy, &eeprom.cfg_xy, sizeof(cfg_xy));
	eeprom_write_block(&cfg_z, &eeprom.cfg_z, sizeof(cfg_z));
	eeprom_busy_wait();
}

void get_pressure_config(struct pressure_config *xy,
			 struct pressure_config *z)
{
	uint8_t sreg;

	sreg = irq_disable_save();
	memcpy(xy, &cfg_xy, sizeof(*xy));
	memcpy(z, &cfg_z, sizeof(*z));
	irq_restore(sreg);
}

void set_pressure_config(struct pressure_config *new_xy,
			 struct pressure_config *new_z)
{
	uint8_t sreg;

	sreg = irq_disable_save();

	memcpy(&cfg_xy, new_xy, sizeof(cfg_xy));
	if (cfg_xy.desired > XY_MAX_PRESSURE)
		cfg_xy.desired = XY_MAX_PRESSURE;
	if (cfg_xy.hysteresis > XY_MAX_HYSTERESIS)
		cfg_xy.hysteresis = XY_MAX_HYSTERESIS;

	memcpy(&cfg_z, new_z, sizeof(cfg_z));
	if (cfg_z.desired > Z_MAX_PRESSURE)
		cfg_z.desired = Z_MAX_PRESSURE;
	if (cfg_z.hysteresis > Z_MAX_HYSTERESIS)
		cfg_z.hysteresis = Z_MAX_HYSTERESIS;

	eeprom_store_config();
	irq_restore(sreg);
}

void get_pressure_state(struct pressure_state *ret)
{
	uint8_t sreg;

	sreg = irq_disable_save();
	memcpy(ret, &state, sizeof(*ret));
	irq_restore(sreg);
}

/* Sensor measurement completed.
 * Called in IRQ context. */
void sensor_result(struct sensor *s, uint16_t mbar)
{
	state.measured_mbar += mbar;

	if (++state.nr_adc_measurements >= 4) {
		state.nr_adc_measurements = 0;
		state.measured_mbar /= 4;
		mb();
		/* Defer processing of the value to the mainloop, so we can
		 * do it with interrupts enabled. */
		state.needs_checking = 1;
	} else
		sensor_retrigger();
}

jiffies_t get_jiffies(void)
{
	uint16_t sreg;
	jiffies_t j;

	sreg = irq_disable_save();
	j = jiffies_counter;
	irq_restore(sreg);

	return j;
}

/* 1kHz system timer. */
ISR(TIMER1_COMPA_vect)
{
	jiffies_counter++;
}

static void system_timer_init(void)
{
	TCCR1B = (1 << WGM12) | (1 << CS10) | (1 << CS11); /* prescaler 64 */
	OCR1A = 250; /* 1kHz timer at 16MHz crystal */
	TIMSK |= (1 << OCIE1A);
}

/* Check the current pressure value against the desired value and
 * adjust the pressure if needed. */
static void do_check_pressure(struct valves *valves,
			      struct pressure_config *cfg,
			      uint16_t mbar,
			      uint16_t *reported_mbar)
{
	int32_t offset;
	uint16_t abs_offset;
	bool is_too_big;
	bool report_change = 0;
	uint8_t cur_state;

	if (cfg->autoadjust_enable) {
		offset = (int32_t)mbar - (int32_t)cfg->desired;
		abs_offset = abs(offset);
		is_too_big = (offset >= 0);
		cur_state = valves_get_global_state(valves);

		if (abs_offset > cfg->hysteresis) {
			/* Adjust the pressure */
			report_change = (cur_state == VALVES_IDLE);
			if (is_too_big)
				valves_global_switch(valves, VALVES_FLOW_OUT);
			else
				valves_global_switch(valves, VALVES_FLOW_IN);
		} else if (abs_offset > cfg->hysteresis / 4) {
			/* If we're idle, stay idle.
			 * If we're increasing or decreasing pressure,
			 * keep on doing this to reach the desired center value
			 * more closely. */
		} else {
			/* We're within quarter of the hysteresis.
			 * The pressure is OK. Make sure the valves are
			 * all idle. */
			report_change = (cur_state != VALVES_IDLE);
			valves_global_switch(valves, VALVES_IDLE);
		}
		if (mbar < valves->state_force_threshold) {
			/* If the pressure in the reservoir is low,
			 * the feedforward of the pneumatic valve for
			 * flow-out might not work correctly. So force poke
			 * the valves again until we reach a good pressure. */
			__valves_global_switch(valves,
				valves_get_global_state(valves));
			valves_disarm_auto_idle(valves);
		}
	}
	if (abs((int32_t)mbar - (int32_t)(*reported_mbar)) >= REPORT_HYSTERESIS)
		report_change = 1;
	if (report_change) {
		remote_pressure_change_notification(state.measured_mbar_xy,
						    state.measured_mbar_z);
		*reported_mbar = mbar;
	}
}

static void check_pressure(void)
{
	switch (sensor_cycle) {
	case SENSOR_CYCLE_XY:
		state.measured_mbar_xy = state.measured_mbar;
		if (state.device_enabled) {
			do_check_pressure(&xy_control_valves, &cfg_xy,
					  state.measured_mbar_xy,
					  &state.reported_mbar_xy);
		}
		break;
	case SENSOR_CYCLE_Z:
		state.measured_mbar_z = state.measured_mbar;
		if (state.device_enabled) {
			do_check_pressure(&z_control_valves, &cfg_z,
					  state.measured_mbar_z,
					  &state.reported_mbar_z);
		}
		break;
	default:
		BUG_ON(1);
	}
}

static void print_banner(void)
{
	char str[128];

	strcpy(str, "Pressure control -- " __DATE__ " -- GCC-");
	num16_to_ascii((uint8_t *)str + strlen(str), __GNUC__);
	strcat(str, ".");
	num16_to_ascii((uint8_t *)str + strlen(str), __GNUC_MINOR__);
	strcat(str, ".");
	num16_to_ascii((uint8_t *)str + strlen(str), __GNUC_PATCHLEVEL__);
	strcat(str, "\n");
	print_sram(str);
}

void prepare_turn_on(void)
{
	state.device_enabled = 1;
}

void prepare_shutdown(void)
{
	state.device_enabled = 0;
}

int main(void)
{
	uint8_t mcucsr;

	cli();
	mcucsr = MCUCSR;
	MCUCSR = 0;
	wdt_disable();
	if (mcucsr & (1 << BORF)) {
		/* If we have a brownout, try to enter valve emergency state. */
		valves_emergency_state(&xy_control_valves);
		valves_emergency_state(&z_control_valves);
		mdelay(500);
		/* This wasn't a real brownout, if we're still alife.
		 * Go on with initialization. */
	}
	wdt_enable(WDTO_500MS);

	/* It's OK to init the remote interface that early, as we
	 * have IRQs disabled throughout the init process. So we can't
	 * receive any remote commands, yet. But early init allows us
	 * to send error messages early. */
	remote_init();
	print_banner();
	if (!(mcucsr & (1 << PORF)) && (mcucsr & (1 << WDRF)))
		print("WATCHDOG RESET!\n");

	valves_init(&xy_control_valves);
	valves_init(&z_control_valves);
	sensor_init(&xy_control_sensor);
	sensor_init(&z_control_sensor);
	eeprom_load_config();
	system_timer_init();

	sei();

	print("Monitoring...\n");
	remote_work();
	remote_notify_restart();
	sensor_cycle = SENSOR_CYCLE_XY;
	sensor_trigger_read(&xy_control_sensor);
	while (1) {
		static jiffies_t next_sensor_trigger;
		static bool need_sensor_trigger;
		jiffies_t now;

		mb();
		now = get_jiffies();
		if (state.needs_checking) {
			check_pressure();
			/* Trigger another measurement in
			 * a few milliseconds. */
			if (++sensor_cycle == __NR_SENSOR_CYCLE)
				sensor_cycle = 0;
			state.needs_checking = 0;
			next_sensor_trigger = now + msec_to_jiffies(5);
			mb();
			need_sensor_trigger = 1;
		}
		if (need_sensor_trigger &&
		    time_after(now, next_sensor_trigger)) {
			/* It's time for triggering another
			 * sensor measurement. */
			need_sensor_trigger = 0;
			state.measured_mbar = 0;
			switch (sensor_cycle) {
			case SENSOR_CYCLE_XY:
				sensor_trigger_read(&xy_control_sensor);
				break;
			case SENSOR_CYCLE_Z:
				sensor_trigger_read(&z_control_sensor);
				break;
			default:
				BUG_ON(1);
			}
		}
		remote_work();
		valves_work(&xy_control_valves);
		valves_work(&z_control_valves);
		wdt_reset();
	}
}

/* The fuse bits - AT_Mega8
 * External clock, 0ms startup
 * BOD 4.0V
 * Boot vector disabled
 * Preserve EEPROM disabled
 * SPI enabled
 */
FUSES = {
	.low	= 0x00,
	.high	= 0xD9,
};
