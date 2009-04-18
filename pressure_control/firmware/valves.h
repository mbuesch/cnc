#ifndef VALVES_H_
#define VALVES_H_

#include "util.h"

#include <stdint.h>


/* Global valves state */
enum valves_global_state {
	VALVES_IDLE,
	VALVES_FLOW_IN,
	VALVES_FLOW_OUT,
};

/* State for one valve. */
enum valve_state {
	VALVE_STATE_IDLE,
	VALVE_STATE_12,
	VALVE_STATE_14,
};

/* Wait for the valve to toggle from one position to another. */
static inline void valve_wait_toggle(void)
{
	mdelay(10);
}

void valves_init(void);
void valves_emergency_state(void);
void valves_shutdown(void);
void valves_global_switch(uint8_t global_state);
uint8_t valves_get_global_state(void);

void valve0_switch(uint8_t state);
void valve1_switch(uint8_t state);

#endif /* VALVES_H_ */
