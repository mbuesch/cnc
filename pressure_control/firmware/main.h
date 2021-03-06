#ifndef MAIN_H_
#define MAIN_H_

#include "util.h"

#include <stdint.h>


typedef uint16_t jiffies_t;
typedef int16_t s_jiffies_t;

/* Jiffies timing helpers derived from the Linux Kernel sources.
 * These inlines deal with timer wrapping correctly.
 *
 * time_after(a, b) returns true if the time a is after time b.
 *
 * Do this with "<0" and ">=0" to only test the sign of the result. A
 * good compiler would generate better code (and a really good compiler
 * wouldn't care). Gcc is currently neither.
 */
#define time_after(a, b)	((s_jiffies_t)(b) - (s_jiffies_t)(a) < 0)
#define time_before(a, b)	time_after(b, a)

#define JIFFIES_PER_SECOND	1000
#define msec_to_jiffies(msec)	((jiffies_t)((uint32_t)JIFFIES_PER_SECOND * (uint32_t)(msec) / (uint32_t)1000))

jiffies_t get_jiffies(void);

enum {
	SENSOR_CYCLE_XY = 0,
	SENSOR_CYCLE_Z,
	__NR_SENSOR_CYCLE,
};

struct pressure_config {
	/* Desired pressure in mBar */
	uint16_t desired;
	/* Pressure hysteresis in mBar */
	uint16_t hysteresis;
	/* Auto-adjustment is enabled. */
	bool autoadjust_enable;
};

struct pressure_state {
	/* Sensing and adjustment logic enabled? */
	bool device_enabled;
	/* The sum of the last measured pressures (in mBar).
	 * It depends on sensor_cycle which valves this
	 * value belongs to. */
	uint32_t measured_mbar;
	/* The current pressure for the individual valves */
	uint16_t measured_mbar_xy;
	uint16_t measured_mbar_z;
	/* Reported pressure via RS232 */
	uint16_t reported_mbar_xy;
	uint16_t reported_mbar_z;
	/* True, if the current pressure value needs checking against
	 * the desired pressure config. */
	bool needs_checking;
	/* The current count of lowlevel ADC measurements. */
	uint8_t nr_adc_measurements;
};

void get_pressure_config(struct pressure_config *xy,
			 struct pressure_config *z);
void set_pressure_config(struct pressure_config *xy,
			 struct pressure_config *z);
void get_pressure_state(struct pressure_state *state);
void prepare_turn_on(void);
void prepare_shutdown(void);
bool device_is_enabled(void);


struct valves;
extern struct valves xy_control_valves;
extern struct valves z_control_valves;


/* Absolute maximum pressures (in mBar). */
#define XY_MAX_PRESSURE		3500
#define XY_MAX_HYSTERESIS	300
#define Z_MAX_PRESSURE		2500
#define Z_MAX_HYSTERESIS	300


#endif /* MAIN_H_ */
