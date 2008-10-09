#ifndef CALIBRATION_H_
#define CALIBRATION_H_

/****************************************************************************
 * Microcontroller CPU speed calibration                                    *
 ****************************************************************************/

/* CPU frequency in HZ */
#define CPU_HZ			16000000
/* 1ms timer calibration */
#define DELAY_1MS_TIMERFREQ	(1 << CS01) /* == CPU_FREQ/8 */
#define DELAY_1MS_LOOP		80
#define DELAY_1MS_LOOP_TIMES	25
/* 1us delayloop calibration */
#define DELAY_1US_LOOP		4


#endif /* CALIBRATION_H_ */
