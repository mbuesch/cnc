;
;   ODIN Motion Control Emergency Stop Extension
;
;   Copyright (c) 2009 Michael Buesch <mb@bu3sch.de>
;
;   This program is free software; you can redistribute it and/or
;   modify it under the terms of the GNU General Public License
;   as published by the Free Software Foundation; either version 2
;   of the License, or (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.

.listmac
.include "m8def.inc"


.def zero			= r0	; Always zero'd
.def t0				= r16	; Temp reg 0
.def t1				= r17	; Temp reg 1
.def t2				= r18	; Temp reg 2
.def t3				= r19	; Temp reg 3

.equ MSPINDLESTOP_IN_PIN	= PIND	; Master Spindle stop signal from EMC
.equ MSPINDLESTOP_IN_BIT	= 4
.equ MSPINDLERUN_OUT_PORT	= PORTB	; Master Spindle enable signal to spindle Relais
.equ MSPINDLERUN_OUT_BIT	= 0
.equ ESTOP_IN_PIN		= PIND	; E-STOP signal from EMC
.equ ESTOP_IN_BIT		= 5
.equ ESTOP_OUT_PORT		= PORTD	; E-STOP signal to EMC
.equ ESTOP_OUT_BIT		= 6
.equ ESTOPBTN_PIN		= PIND	; E-STOP push button
.equ ESTOPBTN_BIT		= 7
.equ JOINTBRAKE_PORT		= PORTB	; Joints brake signal output to LMDs
.equ JOINTBRAKE_BIT		= 1


; Millisecond delay
.macro mdelay ; mdelay(milliseconds)
	push t0
	push t1
	ldi t0, low(@0)
	ldi t1, high(@0)
	rcall __mdelay
	pop t1
	pop t0
.endm

.cseg
.org 0x000
	rjmp reset

.org 0x026

;*******************************************
;*** ENTRY POINT                         ***
;*******************************************
reset:
	cli
	clr zero

	; Init the stackpointer
	ldi t0, low(RAMEND)
	out SPL, t0
	ldi t0, high(RAMEND)
	out SPH, t0

	; Setup the port configuration
	ldi t0, (1<<JOINTBRAKE_BIT)
	out PORTB, t0
	ldi t0, ((1<<MSPINDLERUN_OUT_BIT) | (1<<JOINTBRAKE_BIT))
	out DDRB, t0

	ldi t0, 0x00
	out PORTC, t0
	ldi t0, 0xFF
	out DDRC, t0

	ldi t0, ((1<<MSPINDLESTOP_IN_BIT) | (1<<ESTOP_IN_BIT) | (1<<ESTOP_OUT_BIT) | (1<<ESTOPBTN_BIT))
	out PORTD, t0
	ldi t0, (1<<ESTOP_OUT_BIT)
	out DDRD, t0

	; Wait for the X/Y/Z driver circuits to finish initialization
	mdelay 1000

	; We start with an E-STOP condition
	rjmp enter_estop_loop

;*******************************************
;*** ESTOP - loop                        ***
;*** Emergency Stop is asserted          ***
;*******************************************
enter_estop_loop:
	cbi MSPINDLERUN_OUT_PORT, MSPINDLERUN_OUT_BIT	; Stop the master spindle
	sbi JOINTBRAKE_PORT, JOINTBRAKE_BIT		; Activate the joints brake
	sbi ESTOP_OUT_PORT, ESTOP_OUT_BIT		; Assert the E-STOP output signal
estop_loop:
	sbic ESTOP_IN_PIN, ESTOP_IN_BIT			; Have E-STOP from EMC?
	rjmp estop_loop
	sbic ESTOPBTN_PIN, ESTOPBTN_BIT			; Have E-STOP from button?
	rjmp estop_loop

	rjmp enter_run_loop				; We're OK to run again

;*******************************************
;*** RUN - loop                          ***
;*** Emergency Stop is not asserted      ***
;*******************************************
enter_run_loop:
	cbi JOINTBRAKE_PORT, JOINTBRAKE_BIT		; Deactivate the joints brake
	cbi ESTOP_OUT_PORT, ESTOP_OUT_BIT		; De-assert the E-STOP output signal
run_loop:
	sbic ESTOP_IN_PIN, ESTOP_IN_BIT			; Have E-STOP from EMC?
	rjmp enter_estop_loop
	sbic ESTOPBTN_PIN, ESTOPBTN_BIT			; Have E-STOP from button?
	rjmp enter_estop_loop

	in t0, MSPINDLESTOP_IN_PIN			; Update Master Spindle run state
	sbrc t0, MSPINDLESTOP_IN_BIT
	cbi MSPINDLERUN_OUT_PORT, MSPINDLERUN_OUT_BIT
	sbrs t0, MSPINDLESTOP_IN_BIT
	sbi MSPINDLERUN_OUT_PORT, MSPINDLERUN_OUT_BIT

	rjmp run_loop


;*******************************************
;*** Utility functions                   ***
;*******************************************

.equ DELAY_1MS_TIMERFREQ	= (1 << CS01) ; == CPU_FREQ/8
.equ DELAY_1MS_LOOP		= 80
.equ DELAY_1MS_LOOP_TIMES	= 13
__mdelay:
	push t2
	push t3
	ldi t2, DELAY_1MS_TIMERFREQ	; Enable timer0
	out TCCR0, t2
 __mdelay_loop:
	ldi t2, DELAY_1MS_LOOP_TIMES	; Loop for 1ms
 __mdelay_1ms_loop:
	out TCNT0, zero			; Start TCNT0 at zero
 __mdelay_timer_loop:
	in t3, TCNT0			; Wait for TCNT0 >= DELAY_1MS_LOOP
	cpi t3, DELAY_1MS_LOOP
	brlo __mdelay_timer_loop
	dec t2				; Decrement the 1ms loop counter
	brne __mdelay_1ms_loop
	subi t0, low(1)
	sbci t1, high(1)
	brne __mdelay_loop		; Wait another millisecond
	out TCCR0, zero			; Stop timer0
	pop t3
	pop t2
	ret
