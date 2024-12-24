; Program Name: Tom Thumb Routines
; Author(s): clevor
; Description: Contains routines for the Tom Thumb font

include 'z80.inc'
include 'ti83plusg.inc'
include 'tiformat.inc'
format ti executable 'FONT'

_LCD_BUSY_QUICK = $000B

_start:
	b_call(ti.homeUp)
	b_call(ti.RunIndicOff)
	call clearScreen

	ld hl, hello
	call printString
	call newLine

	xor a, a
_:
	push af
	call putChar
	pop af
	inc a
	jp po, -_
	
	call copyToScreen
	
_:
	b_call(ti.GetCSC)
	or a, a
	jr z, -_

	xor a, a
_:
	push af
	call putChar
	pop af
	inc a
	jp po, -_

	call copyToScreen
	
_:
	b_call(ti.GetCSC)
	or a, a
	jr z, -_
	
	jr clearScreen


hello:
	.db "Hello, Tom Thumb!", 0

include "font.asm"
