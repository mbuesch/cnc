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


.def zero		= r0	; Always zero'd
.def one		= r1	; Always one
.def two		= r2	; Always two
.def three		= r3	; Always three
.def sigin		= r4	; Input signal
.def t0			= r16	; Temp reg 0
.def t1			= r17	; Temp reg 1
.def t2			= r18	; Temp reg 2
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


.dseg

; Allocate enough space for 60 microsteps.
; Align to 0x100 so that the high byte of the pointer will
; never change.
.org 0x100
MEM_STEPTABLE:		.byte (60 * 2 * 2)


.cseg
.org 0x000
	rjmp reset

.org 0x026
; For reference, store the build parameters in the flash image.
.db "NR_STEPS=", NR_STEPS_ASCII_0, NR_STEPS_ASCII_1, 0,0,0
.db "BUILD_DATE=",BDATE0,BDATE1,BDATE2,BDATE3,BDATE4,BDATE5,BDATE6,BDATE7,BDATE8,BDATE9,0,0,0

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
	ldi t0, (NR_STEPS * 2 * 2)
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
	ldi XH, high(MEM_STEPTABLE)
	ldi steptabstart, (low(MEM_STEPTABLE) - 2)
	ldi steptabend, (low(MEM_STEPTABLE) + (NR_STEPS * 2 * 2))
	clr dirswap

	; Initially set the outputs and enter the mainloop
	in sigin, IN_PIN
	rjmp handle_rising_clk

;*******************************************
;*** MAINLOOP                            ***
;*******************************************
mainloop:
	in sigin, IN_PIN			; Get the input signals
	sbrs sigin, IN_CLK_BIT
	rjmp mainloop

 handle_rising_clk:				; We got a rising clock
	sbrs sigin, IN_DIR_BIT
	rjmp backward
	add XL, two				; Forward move
	cpse XL, steptabend			; Check for table wrap
	rjmp fetchlmd
	ldi XL, low(MEM_STEPTABLE)		; Reset the table pointer
	eor dirswap, three			; Swap polarity
	rjmp fetchlmd
 backward:
	sub XL, two				; Backward move
	cpse XL, steptabstart			; Check for table wrap
	rjmp fetchlmd
	ldi XL, (low(MEM_STEPTABLE) + (NR_STEPS * 2 * 2) - 2) ; Reset the table pointer
	eor dirswap, three			; Swap polarity

 fetchlmd:
	ld t0, X+				; Get the LMD1/LMD2 DAC values
	ld t1, X				; Get the polarities
	dec XL
	eor t1, dirswap				; Apply the polarity swap

	out DIROUT_PORT, t1			; Set the directions (polarity)
	out DAC_PORT, t0			; Set the voltage levels

 waitfall:					; Wait for falling clock
	sbic IN_PIN, IN_CLK_BIT
	rjmp waitfall
	rjmp mainloop


.include "tables.S"
