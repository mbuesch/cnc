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


.def zero		= r1	; Always zero'd
.def rFF		= r2	; Always 0xFF
.def sigin		= r3	; Input signal
.def t0			= r16	; Temp reg 0
.def t1			= r17	; Temp reg 1
.def t2			= r18	; Temp reg 2
.def t3			= r19	; Temp reg 3
.def t4			= r20	; Temp reg 4
.def steptabstart	= r23	; Step table start marker
.def steptabend		= r24	; Step table end marker
.def dirswap		= r25	; Polarity swapper

.equ DAC_PORT		= PORTD
.equ DIROUT_PORT	= PORTB
.equ DIROUT_LMD1_BIT	= 0
.equ DIROUT_LMD2_BIT	= 1
.equ IN_PIN		= PINC
.equ IN_CLK_BIT		= 0
.equ IN_DIR_BIT		= 1
.equ IN_JP1_BIT		= 2
.equ IN_JP2_BIT		= 3
.equ IN_REDUCT_BIT	= 4
.equ IN_INV_BIT		= 5


.dseg

MEM_STEPTABLE_LMD1:	.byte 60
MEM_STEPTABLE_LMD2:	.byte 60


.cseg
.org 0x000
	rjmp reset

reset:
	cli

	clr zero
	clr rFF
	com rFF

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

	; Copy the step tables to RAM
	ldi t0, (NR_STEPS * 2)
	ldi ZL, low(steptable_lmd1 * 2)
	ldi ZH, high(steptable_lmd1 * 2)
	ldi XL, low(MEM_STEPTABLE_LMD1)
	clr XH
 copy1:	lpm t1, Z+
	st X+, t1
	dec t0
	brne copy1

	ldi t0, (NR_STEPS * 2)
	ldi ZL, low(steptable_lmd2 * 2)
	ldi ZH, high(steptable_lmd2 * 2)
	ldi YL, low(MEM_STEPTABLE_LMD2)
	clr YH
 copy2:	lpm t1, Z+
	st Y+, t1
	dec t0
	brne copy2

	; Init the status registers
	ldi XL, low(MEM_STEPTABLE_LMD1)		; X is the LMD1 step pointer
	clr XH
	ldi YL, low(MEM_STEPTABLE_LMD2)		; Y is the LMD2 step pointer
	clr YH
	ldi steptabend, (low(MEM_STEPTABLE_LMD1) + (NR_STEPS * 2))
	ldi steptabstart, (low(MEM_STEPTABLE_LMD1) - 1)
	clr dirswap


mainloop:
	in sigin, IN_PIN			; Get the input signals
	sbrs sigin, IN_CLK_BIT
	rjmp mainloop
						; We got a rising clock
	sbrs sigin, IN_DIR_BIT
	rjmp backward
	inc XL					; Forward move
	inc YL
	cpse XL, steptabend			; Check for table wrap
	rjmp fetchlmd
	ldi XL, low(MEM_STEPTABLE_LMD1)		; Reset the table pointers
	ldi YL, low(MEM_STEPTABLE_LMD2)
	ldi t0, 0x03
	eor dirswap, t0				; Swap polarity
	rjmp fetchlmd
 backward:
	dec XL					; Backward move
	dec YL
	cpse XL, steptabstart			; Check for table wrap
	rjmp fetchlmd
	ldi XL, (low(MEM_STEPTABLE_LMD1) + (NR_STEPS * 2) - 1)	; Reset the table pointers
	ldi YL, (low(MEM_STEPTABLE_LMD2) + (NR_STEPS * 2) - 1)
	ldi t0, 0x03
	eor dirswap, t0				; Swap polarity

 fetchlmd:
	ld t0, X				; Get the LMD1 value
	ld t4, Y				; Get the LMD2 value
	mov t1, t4				; Get the polarity values
	andi t4, 0xF0
	andi t1, 0x03
	eor t1, dirswap				; Apply the polarity swap
	or t0, t4				; Prepare the DAC output value

	out DIROUT_PORT, t1			; Set the directions (polarity)
	out DAC_PORT, t0			; Set the voltage levels

 waitfall:					; Wait for falling clock
	sbic IN_PIN, IN_CLK_BIT
	rjmp waitfall
	rjmp mainloop


.include "tables.S"
