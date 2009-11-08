;
;   Atmel Mega8 based ODIN chipset
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


.def zero		= r0	; Always zero'd			(constant value)
.def one		= r1	; Always one			(constant value)
.def two		= r2	; Always two			(constant value)
.def three		= r3	; Always three			(constant value)
.def sigin		= r4	; Input signal
.def t0			= r16	; Temp reg 0
.def t1			= r17	; Temp reg 1
.def t2			= r18	; Temp reg 2
.def t3			= r19	; Temp reg 3
.def steptab_start	= r22	; Step table start marker	(constant value)
.def steptab_center	= r23	; Step table center marker	(constant value)
.def steptab_end	= r24	; Step table end marker		(constant value)
.def directions		= r25	; LMD dir pin states in bit0/1

.equ DAC_PORT		= PORTD
.equ DIROUT_PORT	= PORTB
.equ DIROUT_LMD1_BIT	= 0
.equ DIROUT_LMD2_BIT	= 1
.equ IN_PIN		= PINC
.equ IN_CLK_BIT		= 0
.equ IN_DIR_BIT		= 1


.dseg

; Allocate enough space for 60 microsteps.
; Align to 0x100 so that the high byte of the pointer will
; never change.
.org 0x100
MEM_STEPTABLE:		.byte (60 * 2)


; Direction pin helper macros.
; The two direction pins can be seen as a two bit gray code number.
; So we convert to binary, increment/decrement and convert back to gray.
; We convert to binary/gray by flipping the lower bit, if the upper bit is set.
;
; The gray code sequence is
; gray  |  binary
;  00   |  00
;  01   |  01
;  11   |  10
;  10   |  11
;
.macro dir_increment
	sbrc directions, 1	; Convert to binary number
	eor directions, one	;
	inc directions		; Increment ...
	andi directions, 3	; ... and mask the number.
	sbrc directions, 1	; Convert to gray code
	eor directions, one	;
.endm

.macro dir_decrement
	sbrc directions, 1	; Convert to binary number
	eor directions, one	;
	dec directions		; Decrement ...
	andi directions, 3	; ... and mask the number.
	sbrc directions, 1	; Convert to gray code
	eor directions, one	;
.endm

; A big delay used for debouncing the switches on the debug-board.
.macro debug_delay
 .ifdef DEBUG
	push t0
	push t1
	ldi t0, 0xFF
 l1:
	ldi t1, 0xFF
 l2:
	dec t1
	brne l2
	dec t0
	brne l1
	pop t1
	pop t0
 .endif
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
	clr one
	inc one
	mov two, one
	inc two
	mov three, two
	inc three

	; Init the stackpointer
	ldi t0, low(RAMEND)
	out SPL, t0
	ldi t0, high(RAMEND)
	out SPH, t0

	; Setup the port configuration
	ldi t0, 0xFF	; B=out
	out DDRB, t0
	ldi t0, 0x00
	out PORTB, t0

	ldi t0, 0x00	; C=in
	out DDRC, t0
	ldi t0, 0xFF	; C=pullups
	out PORTC, t0

	ldi t0, 0xFF	; D=out
	out DDRD, t0
	ldi t0, 0x00
	out PORTD, t0

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

	; Init the status registers
	ldi XL, low(MEM_STEPTABLE)		; X is the table pointer
	ldi XH, high(MEM_STEPTABLE)		; High byte is constant
	ldi directions, 0
	ldi steptab_start,  low(MEM_STEPTABLE)
	ldi steptab_center, low(MEM_STEPTABLE) + NR_STEPS
	ldi steptab_end,    low(MEM_STEPTABLE) + NR_STEPS * 2 - 1

	; Initially set the outputs and enter the mainloop
	ld t0, X
	out DIROUT_PORT, directions
	out DAC_PORT, t0
	rjmp mainloop

;*******************************************
;*** MAINLOOP                            ***
;*******************************************
mainloop:
	sbic IN_PIN, IN_CLK_BIT			; Wait for falling edge
	rjmp mainloop
	debug_delay
 wait_rising:
	in sigin, IN_PIN			; Get the input signals
	sbrs sigin, IN_CLK_BIT			; Wait for rising edge
	rjmp wait_rising

	; Test the direction bit to decide whether we move forward or backward
	sbrs sigin, IN_DIR_BIT
	rjmp backward


	; *** Forward move ***
	cp XL, steptab_start		; If we're at the table start ...
	breq fwd1
	cpse XL, steptab_center		; ... or at the table center ...
	rjmp fwd2
 fwd1:	dir_increment			; ... increment the LMD direction state
 fwd2:	cp XL, steptab_end		; Increment the table pointer
	breq fwd3
	inc XL
	rjmp fwd4
 fwd3:	mov XL, steptab_start
 fwd4:	out DIROUT_PORT, directions	; Commit LMD dir state, if not done, yet
	ld t0, X
	out DAC_PORT, t0		; Commit the LMD DAC state
	rjmp mainloop


 backward:
	; *** Backward move ***
	out DIROUT_PORT, directions	; Commit LMD dir state, if not done, yet
	cp XL, steptab_start		; Decrement the table pointer
	breq bwd1
	dec XL
	rjmp bwd2
 bwd1:	mov XL, steptab_end
 bwd2:	cp XL, steptab_start		; If we're at the table start ...
	breq bwd3
	cpse XL, steptab_center		; ... or at the table center ...
	rjmp bwd4
 bwd3:	dir_decrement			; ... decrement the LMD direction state
 bwd4:	ld t0, X
	out DAC_PORT, t0		; Commit the LMD DAC state
	rjmp mainloop


.include "tables.S"
