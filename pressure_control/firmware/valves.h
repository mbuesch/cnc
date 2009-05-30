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
	VALVE_STATE_CLOSE,
	VALVE_STATE_OPEN,
};

enum valves_type {
	VALVES_1MAG,	/* One magnet for opening the valve. Spring reset. */
	VALVES_2MAG,	/* One magnet for opening; one magnet for closing the valve. */
};

struct valves {
	uint8_t type;			/* enum valves_type */
	uint16_t ddr;			/* DDRx */
	uint16_t port;			/* PORTx */
	uint8_t bit_0_open;		/* Pin for opening valve 0. */
	uint8_t bit_0_close;		/* Pin for closing valve 0. */
	uint8_t bit_1_open;		/* Pin for opening valve 1. */
	uint8_t bit_1_close;		/* Pin for closing valve 1. */

	uint8_t current_global_state;	/* enum valves_global_state */
	bool need_switch_to_idle;	/* Need transition to VALVE_STATE_IDLE. */
	jiffies_t switch_to_idle_time;	/* Deadline for VALVE_STATE_IDLE transition. */
};

#define DEFINE_VALVE(name, _type, portid, bit0_open, bit0_close, bit1_open, bit1_close)	\
	struct valves name = {						\
		.type		= _type,				\
		.ddr		= _SFR_ADDR(DDR##portid),		\
		.port		= _SFR_ADDR(PORT##portid),		\
		.bit_0_open	= bit0_open,				\
		.bit_0_close	= bit0_close,				\
		.bit_1_open	= bit1_open,				\
		.bit_1_close	= bit1_close,				\
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
