#ifndef VALVES_H_
#define VALVES_H_

#include <stdint.h>


enum valves_global_state {
	VALVES_IDLE,
	VALVES_FLOW_IN,
	VALVES_FLOW_OUT,
};

void valves_init(void);
void valves_global_switch(uint8_t state);

#endif /* VALVES_H_ */
