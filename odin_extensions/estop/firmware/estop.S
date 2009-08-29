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

; CPU_HZ is 8MHz

.def zero			= r0	; Always zero'd
.def sregsave			= r1	; Scratch register for SREG in IRQ handlers
.def t0				= r16	; Temp reg 0
.def t1				= r17	; Temp reg 1
.def t2				= r18	; Temp reg 2
.def t3				= r19	; Temp reg 3
.def econditions		= r23	; Scratch register to store E-STOP conditions
.def sigtimer			= r24	; Input signal conditioning timer counter
.def tov1_clear_mask		= r25	; Holds mask to clear TOV1


.equ CHGPUMP_IN_PIN		= PIND	; Charge pump signal from EMC
.equ CHGPUMP_IN_BIT		= 3
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


; E-STOP conditions
.equ ECOND_FROMEMC		= 0
.equ ECOND_FROMBUTTON		= 1
.equ ECOND_FROMCHGPUMP		= 2


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

; cpsne - Compare and skip if not equal - Inverted cpse
.macro cpsne
	cpse @0, @1
	cpse r0, r0
.endm


.cseg
.org 0x000
	rjmp reset
.org INT1addr
	rjmp interrupt_int1
.org OC2addr
	rjmp interrupt_timer2_oc

.org 0x026

;*******************************************
;*** INT1 interrupt handler              ***
;*******************************************
interrupt_int1:
	; No need to save SREG. Nobody changes flags.
	out TCNT1H, zero		; Reset the charge pump monitor timer
	out TCNT1L, zero
	out TIFR, tov1_clear_mask	; Clear the overflow flag
	reti

;*******************************************
;*** TIMER2 OC interrupt handler         ***
;*******************************************
interrupt_timer2_oc:
	in sregsave, SREG
	cpse sigtimer, zero		; Decrement the counter, if it's bigger than zero.
	dec sigtimer
	out SREG, sregsave
	reti

;*********************************************
;*** Check for charge pump monitor timeout ***
;*** Returns t0=1  =>  timeout             ***
;***         t0=0  =>  no timeout          ***
;*********************************************
check_charge_pump_timeout:
	cli						; Get charge pump monitor timer state
	in t0, TCNT1L
	in t1, TCNT1H
	sei
	in t2, TIFR
	sbrc t2, TOV1					; Charge pump timer overflow
	rjmp __chg_pump_timeout
	ldi t2, 10					; Timeout, if bigger
	cp t0, t2					; Charge pump monitor timeout?
	cpc t1, zero
	brsh __chg_pump_timeout
	ldi t0, 0
	ret
 __chg_pump_timeout:
	ldi t0, 1
	ret

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

	ldi t0, ((1<<MSPINDLESTOP_IN_BIT) | (1<<ESTOP_IN_BIT) | (1<<ESTOP_OUT_BIT) | (1<<ESTOPBTN_BIT) | (1<<CHGPUMP_IN_BIT))
	out PORTD, t0
	ldi t0, (1<<ESTOP_OUT_BIT)
	out DDRD, t0

	; Initialize timer2 for input signal conditioning.
	; Timer2 triggers the OC interrupt approx every 200uSec.
	ldi t0, 25
	out OCR2, t0
	ldi t0, ((1<<WGM21) | (1<<CS22))	; freq = CPU_HZ / 64
	out TCCR2, t0
	ldi t0, (1<<OCF2)			; Clear IRQ flag
	out TIFR, t0
	in t0, TIMSK
	ori t0, (1<<OCIE2)			; Enable OC interrupt
	out TIMSK, t0

	; Initialize timer1 for charge pump monitoring
	ldi t0, 0x00
	out TCCR1A, t0
	ldi t0, ((1<<CS10) | (1<<CS12))		; freq = CPU_HZ / 1024
	out TCCR1B, t0
	; Init the timer1 interrupt
	in t0, MCUCR
	sbr t0, (1<<ISC10)			; Logical change triggers IRQ
	cbr t0, (1<<ISC11)
	out MCUCR, t0
	in t0, GICR
	sbr t0, (1<<INT1)			; INT1 enable
	out GICR, t0
	ldi t0, (1<<INTF1)
	out GIFR, t0
	ldi tov1_clear_mask, (1<<TOV1)		; Init the mask to clear TOV1

	; Wait for the X/Y/Z driver circuits to finish initialization
	mdelay 1000

	; Reset the charge pump monitor timer and enable interrupts
	out TCNT1H, zero
	out TCNT1L, zero
	out TIFR, tov1_clear_mask
	sei

	; We start with an E-STOP condition
	rjmp enter_estop_loop


;*** HOW THE LOOPS WORK ***
; The basic idea is that it's easier to enter the E-STOP loop than
; it is to leave it. So we enter it after checking the conditions
; for a few microseconds, but only leave it after checking the
; conditions for several milliseconds.

;*******************************************
;*** ESTOP - loop                        ***
;*** Emergency Stop is asserted          ***
;*******************************************
.equ ESTOP_SIGTIMER = 255	; time = ESTOP_SIGTIMER * 200uS
enter_estop_loop:
	cbi MSPINDLERUN_OUT_PORT, MSPINDLERUN_OUT_BIT	; Stop the master spindle
	sbi JOINTBRAKE_PORT, JOINTBRAKE_BIT		; Activate the joints brake
	sbi ESTOP_OUT_PORT, ESTOP_OUT_BIT		; Assert the E-STOP output signal
	mdelay 100					; Debounce E-STOP buttons
	ldi sigtimer, ESTOP_SIGTIMER			; Reset the conditioning timer counter.
estop_loop:
	clr econditions
	sbic ESTOP_IN_PIN, ESTOP_IN_BIT			; Have E-STOP from EMC?
	ori econditions, (1<<ECOND_FROMEMC)
	sbic ESTOPBTN_PIN, ESTOPBTN_BIT			; Have E-STOP from button?
	ori econditions, (1<<ECOND_FROMBUTTON)
	rcall check_charge_pump_timeout			; Charge pump monitor timeout?
	sbrc t0, 0
	ori econditions, (1<<ECOND_FROMCHGPUMP)

	cpse econditions, zero				; If we have an E-STOP condition...
	ldi sigtimer, ESTOP_SIGTIMER			; ...reset the conditioning timer counter.
	cpsne sigtimer, zero				; If the conditioning timer counter is zero...
	rjmp enter_run_loop				; ...enter RUN state.

	rjmp estop_loop


;*******************************************
;*** RUN - loop                          ***
;*** Emergency Stop is not asserted      ***
;*******************************************
.equ RUN_SIGTIMER = 5	; time = RUN_SIGTIMER * 200uS
enter_run_loop:
	cbi JOINTBRAKE_PORT, JOINTBRAKE_BIT		; Deactivate the joints brake
	cbi ESTOP_OUT_PORT, ESTOP_OUT_BIT		; De-assert the E-STOP output signal
	ldi sigtimer, RUN_SIGTIMER			; Reset the conditioning timer counter.
run_loop:
	clr econditions
	sbic ESTOP_IN_PIN, ESTOP_IN_BIT			; Have E-STOP from EMC?
	ori econditions, (1<<ECOND_FROMEMC)
	sbic ESTOPBTN_PIN, ESTOPBTN_BIT			; Have E-STOP from button?
	ori econditions, (1<<ECOND_FROMBUTTON)
	rcall check_charge_pump_timeout			; Charge pump monitor timeout?
	sbrc t0, 0
	rjmp enter_estop_loop				; Immediately enter E-STOP state for chgpump timeout

	cpsne econditions, zero				; If we don't have an E-STOP condition...
	ldi sigtimer, RUN_SIGTIMER			; ...reset the conditioning timer counter.
	cpsne sigtimer, zero				; If the conditioning timer counter is zero...
	rjmp enter_estop_loop				; ...enter E-STOP.

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
