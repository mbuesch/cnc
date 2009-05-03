/*
 *  Pneumatic pressure controller.
 *  Valve control.
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

#include "valves.h"
#include "util.h"
#include "main.h"

#include <avr/io.h>


/*** Valve interface definitions ***/
#define VALVE_DDR		DDRD
#define VALVE_PORT		PORTD
#define VALVE0_14		6 /* Pin for valve-0 position 14 */
#define VALVE0_12		7 /* Pin for valve-0 position 12 */
#define VALVE1_14		4 /* Pin for valve-1 position 14 */
#define VALVE1_12		5 /* Pin for valve-1 position 12 */


static uint8_t current_global_state = 0xFF;
static bool need_switch_to_idle;
static jiffies_t switch_to_idle_time;


void valve0_switch(uint8_t state)
{
	VALVE_PORT &= ~((1 << VALVE0_12) | (1 << VALVE0_14));
	if (state == VALVE_STATE_12)
		VALVE_PORT |= (1 << VALVE0_12);
	else if (state == VALVE_STATE_14)
		VALVE_PORT |= (1 << VALVE0_14);
}

void valve1_switch(uint8_t state)
{
	VALVE_PORT &= ~((1 << VALVE1_12) | (1 << VALVE1_14));
	if (state == VALVE_STATE_12)
		VALVE_PORT |= (1 << VALVE1_12);
	else if (state == VALVE_STATE_14)
		VALVE_PORT |= (1 << VALVE1_14);
}

void valves_global_switch(uint8_t state)
{
	if (state != current_global_state)
		__valves_global_switch(state);
}

void __valves_global_switch(uint8_t state)
{
	switch (state) {
	case VALVES_IDLE:
		valve0_switch(VALVE_STATE_12);
		valve1_switch(VALVE_STATE_12);
		break;
	case VALVES_FLOW_IN:
		valve1_switch(VALVE_STATE_12);
		valve0_switch(VALVE_STATE_14);
		break;
	case VALVES_FLOW_OUT:
		valve0_switch(VALVE_STATE_12);
		valve1_switch(VALVE_STATE_14);
		break;
	}
	switch_to_idle_time = get_jiffies() + msec_to_jiffies(VALVE_TOGGLE_MSEC);
	need_switch_to_idle = 1;
	current_global_state = state;
}

void valves_disarm_auto_idle(void)
{
	need_switch_to_idle = 0;
}

void valves_work(void)
{
	if (need_switch_to_idle &&
	    time_after(get_jiffies(), switch_to_idle_time)) {
		need_switch_to_idle = 0;
		valve0_switch(VALVE_STATE_IDLE);
		valve1_switch(VALVE_STATE_IDLE);
	}
}

uint8_t valves_get_global_state(void)
{
	return current_global_state;
}

static inline void valves_ddr_setup(void)
{
	VALVE_DDR |= (1 << VALVE0_12) | (1 << VALVE0_14) |
		     (1 << VALVE1_12) | (1 << VALVE1_14);
}

void valves_shutdown(void)
{
	__valves_global_switch(VALVES_FLOW_OUT);
	valve_wait_toggle();
	valve0_switch(VALVE_STATE_IDLE);
	valve1_switch(VALVE_STATE_IDLE);
}

void valves_emergency_state(void)
{
	valves_ddr_setup();
	__valves_global_switch(VALVES_IDLE);
	valve_wait_toggle();
	valve0_switch(VALVE_STATE_IDLE);
	valve1_switch(VALVE_STATE_IDLE);
}

void valves_init(void)
{
	valves_ddr_setup();
	__valves_global_switch(VALVES_IDLE);
}
