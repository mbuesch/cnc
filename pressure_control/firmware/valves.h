#ifndef VALVES_H_
#define VALVES_H_

#include "util.h"
#include "main.h"

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

struct valves {
	uint16_t ddr;			/* DDRx */
	uint16_t port;			/* PORTx */
	uint8_t bit_0_14;		/* Valve 0: Pin for valve position 14 */
	uint8_t bit_0_12;		/* Valve 0: Pin for valve position 12 */
	uint8_t bit_1_14;		/* Valve 1: Pin for valve position 14 */
	uint8_t bit_1_12;		/* Valve 1: Pin for valve position 12 */

	uint8_t current_global_state;	/* enum valves_global_state */
	bool need_switch_to_idle;	/* Need transition to VALVE_STATE_IDLE. */
	jiffies_t switch_to_idle_time;	/* Deadline for VALVE_STATE_IDLE transition. */
};

#define DEFINE_VALVE(name, portid, bit0_14, bit0_12, bit1_14, bit1_12)	\
	struct valves name = {						\
		.ddr		= _SFR_ADDR(DDR##portid),		\
		.port		= _SFR_ADDR(PORT##portid),		\
		.bit_0_14	= bit0_14,				\
		.bit_0_12	= bit0_12,				\
		.bit_1_14	= bit1_14,				\
		.bit_1_12	= bit1_12,				\
	}

#define VALVE_TOGGLE_MSEC	10

/* Wait for the valve to toggle from one position to another. */
static inline void valve_wait_toggle(struct valves *v)
{
	mdelay(VALVE_TOGGLE_MSEC);
}

void valves_init(struct valves *v);
void valves_work(struct valves *v);
void valves_emergency_state(struct valves *v);
void valves_shutdown(struct valves *v);
void valves_global_switch(struct valves *v, uint8_t global_state);
void __valves_global_switch(struct valves *v, uint8_t global_state);

static inline void valves_disarm_auto_idle(struct valves *v)
{
	v->need_switch_to_idle = 0;
}

static inline uint8_t valves_get_global_state(struct valves *v)
{
	return v->current_global_state;
}

void valve0_switch(struct valves *v, uint8_t state);
void valve1_switch(struct valves *v, uint8_t state);

#endif /* VALVES_H_ */
