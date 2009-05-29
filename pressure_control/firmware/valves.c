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


/*** Valve interface definitions ***///XXX
#define VALVE_DDR		DDRD
#define VALVE_PORT		PORTD
#define VALVE0_14		6 /* Pin for valve-0 position 14 */
#define VALVE0_12		7 /* Pin for valve-0 position 12 */
#define VALVE1_14		4 /* Pin for valve-1 position 14 */
#define VALVE1_12		5 /* Pin for valve-1 position 12 */

#define MMIO8(mem_addr)		_MMIO_BYTE(mem_addr)

void valve0_switch(struct valves *v, uint8_t state)
{
	MMIO8(v->port) &= ~(BITMASK8(v->bit_0_12) | BITMASK8(v->bit_0_14));
	if (state == VALVE_STATE_12)
		MMIO8(v->port) |= BITMASK8(v->bit_0_12);
	else if (state == VALVE_STATE_14)
		MMIO8(v->port) |= BITMASK8(v->bit_0_14);
}

void valve1_switch(struct valves *v, uint8_t state)
{
	MMIO8(v->port) &= ~(BITMASK8(v->bit_1_12) | BITMASK8(v->bit_1_14));
	if (state == VALVE_STATE_12)
		MMIO8(v->port) |= BITMASK8(v->bit_1_12);
	else if (state == VALVE_STATE_14)
		MMIO8(v->port) |= BITMASK8(v->bit_1_14);
}

void valves_global_switch(struct valves *v, uint8_t state)
{
	if (state != v->current_global_state)
		__valves_global_switch(v, state);
}

void __valves_global_switch(struct valves *v, uint8_t state)
{
	switch (state) {
	case VALVES_IDLE:
		valve0_switch(v, VALVE_STATE_12);
		valve1_switch(v, VALVE_STATE_12);
		break;
	case VALVES_FLOW_IN:
		valve1_switch(v, VALVE_STATE_12);
		valve0_switch(v, VALVE_STATE_14);
		break;
	case VALVES_FLOW_OUT:
		valve0_switch(v, VALVE_STATE_12);
		valve1_switch(v, VALVE_STATE_14);
		break;
	}
	v->switch_to_idle_time = get_jiffies() + msec_to_jiffies(VALVE_TOGGLE_MSEC);
	v->need_switch_to_idle = 1;
	v->current_global_state = state;
}

void valves_work(struct valves *v)
{
	if (v->need_switch_to_idle &&
	    time_after(get_jiffies(), v->switch_to_idle_time)) {
		v->need_switch_to_idle = 0;
		valve0_switch(v, VALVE_STATE_IDLE);
		valve1_switch(v, VALVE_STATE_IDLE);
	}
}

static inline void valves_ddr_setup(struct valves *v)
{
	MMIO8(v->ddr) |= BITMASK8(v->bit_0_12) | BITMASK8(v->bit_0_14) |
			 BITMASK8(v->bit_1_12) | BITMASK8(v->bit_1_14);
}

void valves_shutdown(struct valves *v)
{
	__valves_global_switch(v, VALVES_FLOW_OUT);
	valve_wait_toggle(v);
	valve0_switch(v, VALVE_STATE_IDLE);
	valve1_switch(v, VALVE_STATE_IDLE);
}

void valves_emergency_state(struct valves *v)
{
	valves_ddr_setup(v);
	__valves_global_switch(v, VALVES_IDLE);
	valve_wait_toggle(v);
	valve0_switch(v, VALVE_STATE_IDLE);
	valve1_switch(v, VALVE_STATE_IDLE);
}

void valves_init(struct valves *v)
{
	v->current_global_state = 0xFF;
	valves_ddr_setup(v);
	__valves_global_switch(v, VALVES_IDLE);
}
