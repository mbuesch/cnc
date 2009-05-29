#ifndef SENSOR_H_
#define SENSOR_H_

#include <stdint.h>


struct sensor {
	/* ADMUX */
	uint8_t adc_mux;
	/* The sensor value offset, in millivolts.
	 * This value is subtracted from the measured voltage before
	 * processing. */
	uint16_t mv_offset;
	/* The Full Scale Output (maximum) output value of the sensor,
	 * in millivolts. */
	uint16_t full_scale_mv;
	/* The pressure at Full Scale Output, in millibar. */
	uint16_t full_scale_mbar;
};

#define DEFINE_SENSOR(name, mux, _mv_offset, _full_scale_mv, _full_scale_mbar)	\
	struct sensor name = {							\
		.adc_mux		= mux,					\
		.mv_offset		= _mv_offset,				\
		.full_scale_mv		= _full_scale_mv,			\
		.full_scale_mbar	= _full_scale_mbar,			\
	}

void sensor_trigger_read(struct sensor *s);
void sensor_init(struct sensor *s);

/* Callback for sensor value reporting. */
extern void sensor_result(struct sensor *s,
			  uint16_t millibar_result_value);

#endif /* SENSOR_H_ */
