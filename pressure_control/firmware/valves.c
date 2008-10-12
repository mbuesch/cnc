/*
 *  Pneumatic pressure controller.
 *  Valve control.
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

#include "valves.h"

#include <avr/io.h>


/*** Valve interface definitions ***/
#define VALVE_DDR		DDRD
#define VALVE_PORT		PORTD
#define VALVE0_14		4 /* Pin for valve-0 position 14 */
#define VALVE0_12		5 /* Pin for valve-0 position 12 */
#define VALVE1_14		6 /* Pin for valve-1 position 14 */
#define VALVE1_12		7 /* Pin for valve-1 position 12 */

/* State for one valve. */
enum valve_state {
	VALVE_STATE_12,
	VALVE_STATE_14,
};


static void valve0_switch(uint8_t state)
{
	VALVE_PORT &= ~((1 << VALVE0_12) | (1 << VALVE0_14));
	if (state == VALVE_STATE_12)
		VALVE_PORT |= (1 << VALVE0_12);
	else
		VALVE_PORT |= (1 << VALVE0_14);
}

static void valve1_switch(uint8_t state)
{
	VALVE_PORT &= ~((1 << VALVE1_12) | (1 << VALVE1_14));
	if (state == VALVE_STATE_12)
		VALVE_PORT |= (1 << VALVE1_12);
	else
		VALVE_PORT |= (1 << VALVE1_14);
}

void valves_global_switch(uint8_t state)
{
	switch (state) {
	case VALVES_IDLE:
		valve0_switch(VALVE_STATE_12);
		valve1_switch(VALVE_STATE_12);
		break;
	case VALVES_FLOW_IN:
		valve0_switch(VALVE_STATE_12);
		valve1_switch(VALVE_STATE_14);
		break;
	case VALVES_FLOW_OUT:
		valve1_switch(VALVE_STATE_12);
		valve0_switch(VALVE_STATE_14);
		break;
	}
}

void valves_init(void)
{
	VALVE_DDR |= (1 << VALVE0_12) | (1 << VALVE0_14) |
		     (1 << VALVE1_12) | (1 << VALVE1_14);
	valves_global_switch(VALVES_IDLE);
}
