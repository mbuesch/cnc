;
;   Atmel Mega8 based LMD18245 controller
;
;   Copyright (c) 2009-2020 Michael Buesch <m@bues.ch>
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

.include "m8def.inc"


.def zero		= r0	; Always zero
.def t0			= r16	; Temp reg 0
.def t1			= r17	; Temp reg 1
.def steptab_start	= r22	; Step table start marker	(constant value)
.def steptab_center0	= r23	; Step table center marker	(constant value)
.def steptab_center1	= r24	; Step table center marker	(constant value)
.def steptab_end	= r25	; Step table end marker		(constant value)

.equ DAC_PORT		= PORTD
.equ DIROUT_PORT	= PORTB
.equ DIROUT_LMD1_BIT	= 0
.equ DIROUT_LMD2_BIT	= 1
.equ IN_PIN		= PINC
.equ IN_CLK_BIT		= 0
.equ IN_DIR_BIT		= 1
.equ DEBUG_PORT		= PORTC
.equ DEBUG_BIT		= 5


; Allocate enough space for 60 microsteps.
; Align to 0x100 so that the high byte of the pointer will
; never change.
.dseg ; data section
.org 0x100
MEM_STEPTABLE:		.byte (60 * 2)


; Allocate 4 bytes for the direction state lookup table.
; Align to 0x200 so that the high byte of the pointer will
; never change.
.dseg ; data section
.org 0x200
MEM_DIRTABLE:		.byte 4


; A big delay used for debouncing the switches on the debug-board.
.macro debug_delay
 .ifdef DEBUG
	push t0
	push t1
	ldi t0, 0xFF
 l1:
	ldi t1, 0xFF
 l2:
	wdr
	dec t1
	brne l2
	dec t0
	brne l1
	pop t1
	pop t0
 .endif
.endm


.cseg ; code section
.org 0x000
	rjmp reset ; interrupt vector 1
	rjmp reset ; interrupt vector 2
	rjmp reset ; interrupt vector 3
	rjmp reset ; interrupt vector 4
	rjmp reset ; interrupt vector 5
	rjmp reset ; interrupt vector 6
	rjmp reset ; interrupt vector 7
	rjmp reset ; interrupt vector 8
	rjmp reset ; interrupt vector 9
	rjmp reset ; interrupt vector 10
	rjmp reset ; interrupt vector 11
	rjmp reset ; interrupt vector 12
	rjmp reset ; interrupt vector 13
	rjmp reset ; interrupt vector 14
	rjmp reset ; interrupt vector 15
	rjmp reset ; interrupt vector 16
	rjmp reset ; interrupt vector 17
	rjmp reset ; interrupt vector 18
	rjmp reset ; interrupt vector 19


;*******************************************
;*** ENTRY POINT                         ***
;*******************************************
.cseg ; code section
reset:
	cli
	clr zero

	; Configure watchdog timeout = 16 ms
	wdr
	out MCUSR, zero
	in t0, WDTCR
	ori t0, (1 << WDCE) | (1 << WDE)
	ldi t1, (1 << WDE) | (0 << WDP2) | (0 << WDP1) | (0 << WDP0)
	out WDTCR, t0
	out WDTCR, t1
	wdr

	; Init the stackpointer
	ldi t0, low(RAMEND)
	out SPL, t0
	ldi t0, high(RAMEND)
	out SPH, t0

	; Setup the port configuration
	ldi t0, 0xFF	; B=out
	ldi t1, 0x00	; B=low
	out DDRB, t0
	out PORTB, t1
	ldi t0, 0x20	; C5=out, others=in
	ldi t1, 0xDF	; C5=low, others=pullups
	out DDRC, t0
	out PORTC, t1
	ldi t0, 0xFF	; D=out
	ldi t1, 0x00	; D=low
	out DDRD, t0
	out PORTD, t1

	; Copy the step table to RAM
	ldi t0, (NR_STEPS * 2)
	ldi ZL, low(steptable * 2)
	ldi ZH, high(steptable * 2)
	ldi XL, low(MEM_STEPTABLE)
	ldi XH, high(MEM_STEPTABLE)
 copy:	lpm t1, Z+
	st X+, t1
	dec t0
	brne copy

	; Init the step table register X
	ldi XL, low(MEM_STEPTABLE)		; X is the table pointer
	ldi XH, high(MEM_STEPTABLE)		; High byte is constant
	ldi steptab_start,   low(MEM_STEPTABLE)
	ldi steptab_center0, low(MEM_STEPTABLE) + NR_STEPS
	ldi steptab_center1, low(MEM_STEPTABLE) + NR_STEPS + 1
	ldi steptab_end,     low(MEM_STEPTABLE) + NR_STEPS * 2 - 1

	; Init the direction table
	ldi t0, (0 << DIROUT_LMD2_BIT) | (1 << DIROUT_LMD1_BIT)
	sts MEM_DIRTABLE + 0, t0
	ldi t0, (1 << DIROUT_LMD2_BIT) | (1 << DIROUT_LMD1_BIT)
	sts MEM_DIRTABLE + 1, t0
	ldi t0, (1 << DIROUT_LMD2_BIT) | (0 << DIROUT_LMD1_BIT)
	sts MEM_DIRTABLE + 2, t0
	ldi t0, (0 << DIROUT_LMD2_BIT) | (0 << DIROUT_LMD1_BIT)
	sts MEM_DIRTABLE + 3, t0

	; Init the direction table register Y
	ldi YL, low(MEM_DIRTABLE)		; Y is the table pointer
	ldi YH, high(MEM_DIRTABLE)		; High byte is constant

	; Initially set the outputs and enter the main loop.
	rjmp write_power_stage


;*******************************************
;*** MAIN LOOP                           ***
;*******************************************

write_power_stage:
	; Write the values from the tables to the power stage.
	andi YL, 3			; Mask the direction table pointer (overflow)
	ld t0, Y			; Fetch the direction table value
	ld t1, X			; Fetch the LMD DAC table value
	out DAC_PORT, t1		; Commit the LMD DAC state
	out DIROUT_PORT, t0		; Commit LMD dir state
;	cbi DEBUG_PORT, DEBUG_BIT

wait_falling:
	; Wait for input clock falling edge.
	wdr				; Reset watchdog counter
	sbic IN_PIN, IN_CLK_BIT		; Wait for falling edge
	rjmp wait_falling
	debug_delay

wait_rising:
	; Wait for input clock rising edge.
	wdr				; Reset watchdog counter
	sbis IN_PIN, IN_CLK_BIT		; Wait for rising edge
	rjmp wait_rising

	; From here on each possible path of execution is supposed to
	; have the same execution time.

;	sbi DEBUG_PORT, DEBUG_BIT

	; Test the direction bit
	; to decide whether to move forwards or backwards.
	sbis IN_PIN, IN_DIR_BIT
	rjmp backward
	nop				; Compensate execution time: half rjmp


	; *** Forward move ***
	cp XL, steptab_center0
	breq fwd_center0
	cp XL, steptab_end
	breq fwd_end

	nop				; Compensate execution time: full breq
	nop				; Compensate execution time: inc YL
	inc XL				; Increment microstep position
	rjmp write_power_stage		; Write to power stage
fwd_center0:
	nop				; Compensate execution time: cp
	nop				; Compensate execution time: half breq
	inc YL				; Increment current direction state
	inc XL				; Increment microstep position
	rjmp write_power_stage		; Write to power stage
fwd_end:
	inc YL				; Increment current direction state
	mov XL, steptab_start		; Increment microstep position
	rjmp write_power_stage		; Write to power stage


backward:
	; *** Backward move ***
	cp XL, steptab_start
	breq bwd_start
	cp XL, steptab_center1
	breq bwd_center1

	nop				; Compensate execution time: full breq
	nop				; Compensate execution time: dec YL
	dec XL				; Decrement microstep position
	rjmp write_power_stage		; Write to power stage
bwd_start:
	nop				; Compensate execution time: cp
	nop				; Compensate execution time: half breq
	dec YL				; Decrement current direction state
	mov XL, steptab_end		; Decrement microstep position
	rjmp write_power_stage		; Write to power stage
bwd_center1:
	dec YL				; Decrement current direction state
	dec XL				; Decrement microstep position
	rjmp write_power_stage		; Write to power stage


.include "tables.S"
