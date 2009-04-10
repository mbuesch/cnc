#ifndef MAIN_H_
#define MAIN_H_

#include "util.h"

#include <stdint.h>


struct pressure_config {
	/* Desired pressure in mBar */
	uint16_t desired;
	/* Pressure hysteresis in mBar */
	uint16_t hysteresis;
	/* Auto-adjustment is enabled. */
	bool autoadjust_enable;
};

struct pressure_state {
	/* Current pressure in the tank (in mBar) */
	uint16_t mbar;
	/* Reported pressure via RS232 */
	uint16_t reported_mbar;
	/* True, if the current pressure value needs checking against
	 * the desired pressure config. */
	bool needs_checking;
	/* Trigger count:
	 * >0 = waiting
	 * 0  = trigger now
	 * -1 = triggered and running. */
	int8_t sensor_trigger_cnt;
};

void get_pressure_config(struct pressure_config *cfg);
void set_pressure_config(struct pressure_config *cfg);
void get_pressure_state(struct pressure_state *state);

#endif /* MAIN_H_ */
