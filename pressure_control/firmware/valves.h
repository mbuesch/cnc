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

struct valve_coil {
	uint16_t ddr;
	uint16_t port;
	uint8_t bitmask;
};

struct valves {
	uint8_t type;			/* enum valves_type */

	struct valve_coil open0;	/* Coil for opening valve 0 */
	struct valve_coil close0;	/* Coil for closing valve 0 */
	struct valve_coil open1;	/* Coil for opening valve 1 */
	struct valve_coil close1;	/* Coil for closing valve 1 */

	uint8_t current_global_state;	/* enum valves_global_state */
	bool need_switch_to_idle;	/* Need transition to VALVE_STATE_IDLE. */
	jiffies_t switch_to_idle_time;	/* Deadline for VALVE_STATE_IDLE transition. */

	uint16_t state_force_threshold;	/* Threshold for forcing the valve state */
};

#define DEFINE_VALVE_1MAG(name,				\
			  port_0open, bit_0open,	\
			  port_1open, bit_1open,	\
			  force_thres)			\
	struct valves name = {				\
		.type			= VALVES_1MAG,	\
		.state_force_threshold	= force_thres,	\
		.open0			= {				\
			.ddr		= _SFR_ADDR(DDR##port_0open),	\
			.port		= _SFR_ADDR(PORT##port_0open),	\
			.bitmask	= (1 << (bit_0open)),		\
		},							\
		.open1			= {				\
			.ddr		= _SFR_ADDR(DDR##port_1open),	\
			.port		= _SFR_ADDR(PORT##port_1open),	\
			.bitmask	= (1 << (bit_1open)),		\
		},							\
	}

#define DEFINE_VALVE_2MAG(name,				\
			  port_0open, bit_0open,	\
			  port_0close, bit_0close,	\
			  port_1open, bit_1open,	\
			  port_1close, bit_1close,	\
			  force_thres)			\
	struct valves name = {				\
		.type			= VALVES_2MAG,	\
		.state_force_threshold	= force_thres,	\
		.open0			= {				\
			.ddr		= _SFR_ADDR(DDR##port_0open),	\
			.port		= _SFR_ADDR(PORT##port_0open),	\
			.bitmask	= (1 << (bit_0open)),		\
		},							\
		.close0			= {				\
			.ddr		= _SFR_ADDR(DDR##port_0close),	\
			.port		= _SFR_ADDR(PORT##port_0close),	\
			.bitmask	= (1 << (bit_0close)),		\
		},							\
		.open1			= {				\
			.ddr		= _SFR_ADDR(DDR##port_1open),	\
			.port		= _SFR_ADDR(PORT##port_1open),	\
			.bitmask	= (1 << (bit_1open)),		\
		},							\
		.close1			= {				\
			.ddr		= _SFR_ADDR(DDR##port_1close),	\
			.port		= _SFR_ADDR(PORT##port_1close),	\
			.bitmask	= (1 << (bit_1close)),		\
		},							\
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
