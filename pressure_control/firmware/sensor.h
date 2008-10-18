#ifndef SENSOR_H_
#define SENSOR_H_

#include <stdint.h>


void sensor_trigger_read(void);
void sensor_init(void);

/* Callback for sensor value reporting. */
extern void sensor_result(uint16_t millibar_result_value);

#endif /* SENSOR_H_ */
