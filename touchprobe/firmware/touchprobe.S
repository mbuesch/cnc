;
;   CNC touch probe driver
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
.def sregsave			= r1	; SREG scratch space for IRQ handlers
.def t0				= r16	; Temp reg 0
.def t1				= r17	; Temp reg 1
.def t2				= r18	; Temp reg 2
.def t3				= r19	; Temp reg 3
.def buzzcount			= r25	; Buzzer duration counter


; Hardware definitions
.equ PROBESW_PIN		= PINC	; Probe switches input
.equ PROBESW1_BIT		= 0	; Trip switch 1
.equ PROBESW2_BIT		= 1	; Trip switch 2
.equ PROBESW3_BIT		= 2	; Trip switch 3
.equ PROBEEN_BIT		= 3	; Probe-enable switch
.equ PROBESW_MASK		= (1<<PROBESW1_BIT)|(1<<PROBESW2_BIT)|(1<<PROBESW3_BIT)
.equ TRIPLED_PORT		= PORTB	; Trip LED
.equ TRIPLED_BIT		= 0
.equ BUZZER_PORT		= PORTB	; Trip buzzer
.equ BUZZER_BIT			= 3
.equ TRIPSIG_PORT		= PORTD	; Trip output signal (to CNC control)
.equ TRIPSIG_BIT		= 7


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
.org OC2addr
	rjmp interrupt_timer2_comp

.org 0x026

;*******************************************
;*** Timer 2 overflow interrupt handler  ***
;*******************************************
interrupt_timer2_comp:
	in sregsave, SREG
	dec buzzcount					; Decrement the duration counter
	brne __tm0comp_out				; Duration = zero?
	out TCCR2, zero					; Turn off the buzzer timer
	cbi BUZZER_PORT, BUZZER_BIT			; Ensure buzzer is off
 __tm0comp_out:
	out SREG, sregsave
	reti

; Turn on the buzzer (clobbers t0)
.macro buzzer_poke
	cli
	ldi buzzcount, 250
	out TCCR2, zero
	out TCNT2, zero
	; Set compare match value
	ldi t0, 10
	out OCR2, t0
	; Start Timer2 in CTC mode. Toggle OC2 on compmatch.
	; Frequency = CPU_HZ / 256
	ldi t0, (1<<COM20)|(1<<WGM21)|(1<<CS21)|(1<<CS22)
	sei
	out TCCR2, t0
.endm

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
	ldi t0, 0x00
	out PORTB, t0
	ldi t0, (1<<TRIPLED_BIT)|(1<<BUZZER_BIT)
	out DDRB, t0

	ldi t0, PROBESW_MASK | (1<<PROBEEN_BIT)
	out PORTC, t0
	ldi t0, 0x00
	out DDRC, t0

	ldi t0, 0x00
	out PORTD, t0
	ldi t0, (1<<TRIPSIG_BIT)
	out DDRD, t0

	; Setup interrupt masks
	in t0, TIMSK
	ori t0, (1<<OCIE2)
	out TIMSK, t0

	sei
	; Start in the idle loop
	rjmp enter_idleloop

;*********************************************
;*** Idle loop - The probe is disconnected ***
;*********************************************
enter_idleloop:
	cbi TRIPSIG_PORT, TRIPSIG_BIT			; Deassert trip sig to CNC
	cbi TRIPLED_PORT, TRIPLED_BIT			; Turn off the trip LED
	mdelay 500					; Debounce
idleloop:
	sbis PROBESW_PIN, PROBEEN_BIT
	rjmp enter_probeloop
	rjmp idleloop

;*********************************************
;*** Probe loop - The probe is connected   ***
;*********************************************
enter_probeloop:
	cbi TRIPSIG_PORT, TRIPSIG_BIT			; Deassert trip sig to CNC
	cbi TRIPLED_PORT, TRIPLED_BIT			; Turn off the trip LED
	mdelay 500					; Debounce
probeloop:
	in t0, PROBESW_PIN				; Get the probe switches state
	andi t0, PROBESW_MASK
	cp t0, zero					; Is the probe tripped?
	breq probeloop					; No, check again

	sbi TRIPSIG_PORT, TRIPSIG_BIT			; Forward trip sig to CNC
	sbi TRIPLED_PORT, TRIPLED_BIT			; Turn on the trip LED
	buzzer_poke					; Poke the trip buzzer
	mdelay 20					; Debounce

 waitrelease:						; Wait until probe is released
	sbic PROBESW_PIN, PROBEEN_BIT			; Is the probe still connected?
	rjmp enter_idleloop				; No, enter idle loop
	in t0, PROBESW_PIN				; Get the probe switches state
	andi t0, PROBESW_MASK
	cp t0, zero					; Is the probe still tripped?
	brne waitrelease				; Yep, check again

	cbi TRIPSIG_PORT, TRIPSIG_BIT			; Deassert trip sig to CNC
	cbi TRIPLED_PORT, TRIPLED_BIT			; Turn off the trip LED
	mdelay 50					; Debounce

	rjmp probeloop

;*******************************************
;*** Utility functions                   ***
;*******************************************

.equ DELAY_1MS_TIMERFREQ	= (1 << CS01) ; == CPU_FREQ/8
.equ DELAY_1MS_LOOP		= 80
.equ DELAY_1MS_LOOP_TIMES	= 25
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
