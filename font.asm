column: db 0
row: db 0

; Prints a string to the graph buffer
; Inputs: (HL): zero-terminated string
; Outputs: (plotSScreen)
; Destroys: HL, BC, DE, AF
printString:
	ld a, (hl)
	or a, a
	ret z
	push hl
	call putChar
	pop hl
	inc hl
	jr printString


; Prints a new line to the graph buffer
; Inputs: (row), (column)
; Outputs: (row), (column)
; Destroys: HL, BC, DE, AF
; Notes: May scroll the screen
newLine:
	ld hl, (column)
	ld a, 9
	cp a, h
	jr z, scrollScreen

	inc h
	ld l, 0
	ld (column), hl
	ret

; Scrolls the screen by one line
; Outputs: (plotSScreen)
; Destroys: HL, BC, DE, AF
scrollScreen:
	ld hl, plotSScreen+6
	ld de, plotSScreen
	ld bc, 768
	ldir
	
	; The last 6 rows in each column are garbage, so I have to zero them.
	ld c, 24
	ld hl, plotSScreen+64-6
	ld de, 64-6

scrollLoop:
	ld b, 6
_:
	ld (hl), 0
	inc hl
	djnz -_
	
	add hl, de
	dec c
	jr nz, scrollLoop
	
	xor a, a
	ld (column), a
	ret



; Prints a character to the graph buffer
; Inputs: A = the character, (row), (column)
; Outputs: (plotSScreen), (row), (column)
; Destroys: HL, BC, DE, AF
putChar:
	ld hl, (column)
	ld c, h
	call drawChar

	ld hl, (column)
	inc l
	ld a, l
	cp a, 24
	jr z, newLine

	ld (column), hl
	ret

; Clears the screen AND graph buffer
; Outputs: (plotSScreen)
; Destroys: HL, DE, BC, AF
clearScreen:
	ld hl, plotSScreen
	ld de, plotSScreen+1
	ld (hl), 0
	ld bc, 768-1
	ldir
	; Fall through

; Copies the contents of the graph buffer to the screen
; Inputs: (plotSScreen)
; Outputs: Contents of plotSScreen displayed
; Destroys: HL, BC, AF
copyToScreen:
	ld c, $11
	ld hl, plotSScreen
	ld a, $80
	out ($10), a
	ld a, $20
outerLoop:
	call _LCD_BUSY_QUICK
	out ($10), a
	inc a
	ld b, 64
_:
	call _LCD_BUSY_QUICK
	outi
	jr nz, -_

	cp a, $2E+1
	jr nz, outerLoop

	ret




; Font structure:
; .db ROW0ROW1, ROW2ROW3, ROW4ROW5

; Inputs: A = char index, C = row, L = column
; Outputs: Character drawn to the screen buffer
; Destroys: HL, BC, DE, AF
; Notes: 0 <= row < 10, 0 <= column < 24
;	Assumes a column-major screen buffer
drawChar:
	ld h, 0		; HL = COL, BC = ROW
	ld b, h
	push hl

	srl l
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl	; (COL >> 1) * 64
	ld de, plotSScreen
	add hl, de	; That + the screen buffer
	ex de, hl
	ld h, b
	ld l, c
	add hl, hl	; *2
	add hl, bc	; *3
	add hl, hl	; *6
	add hl, de	; screenBuffer + ROW*6 + (COL >> 1) * 64

	ex de, hl
	ld hl, font
	ld b, 0
	ld c, a
	add hl, bc
	sla c
	add hl, bc
	ex de, hl	; DE=font+index*3, HL=screenBuffer+ROW+(COL>>1)*64

	pop bc

; Draws a character with a known font data location into a known location on the screen
; Inputs: HL = The position to draw to, DE = Pointer to the font data
;	C = Bit 0 set if lower nibble (right), reset if higher nibble (left)
; Outputs: Character drawn to buffer
; Destroys: HL += 6, DE += 3, B = 0, C >>= 1, AF
drawCharFast:
	rr c
	ld b, 3
	jr c, lower_half
upper_half:
	ld a, (de)
	and a, $F0	; DATA0000
	ld c, a
	ld a, $0F
	and a, (hl)
	or a, c
	ld (hl), a
	inc hl

	ld a, (de)
	add a, a
	add a, a
	add a, a
	add a, a	; DATA0000
	ld c, a
	ld a, $0F
	and a, (hl)
	or a, c
	ld (hl), a
	inc hl

	inc de
	djnz upper_half
	ret

lower_half:
	ld a, (de)
	rra
	rra
	rra
	rra
	and a, $0F	; 0000DATA
	ld c, a
	ld a, $F0
	and a, (hl)
	or a, c
	ld (hl), a
	inc hl

	ld a, (de)
	and a, $0F	; 0000DATA
	ld c, a
	ld a, $F0
	and a, (hl)
	or a, c
	ld (hl), a
	inc hl

	inc de
	djnz lower_half
	ret

font:
tom_thumb:
	; $00-$1E: Special characters
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EA, $AA, $E0
	db $EE, $EE, $E0	; $1F: Cursor I guess
	db $00, $00, $00	; $20: ' '
	db $44, $40, $40	; $21: '!'
	db $AA, $00, $00	; $22: '"'
	db $AE, $AE, $A0	; $23: '#'
	db $6C, $6C, $40	; $24: '$'
	db $42, $48, $20	; $25: '%'
	db $CC, $EA, $60	; $26: '&'
	db $44, $00, $00	; $27: '''
	db $24, $44, $20	; $28: '('
	db $84, $44, $80	; $29: ')'
	db $A4, $A0, $00	; $2A: '*'
	db $04, $E4, $00	; $2B: '+'
	db $00, $04, $80	; $2C: ','
	db $00, $E0, $00	; $2D: '-'
	db $00, $00, $40	; $2E: '.'
	db $22, $48, $80	; $2F: '/'
	db $6A, $AA, $C0	; $30: '0'
	db $44, $44, $40	; $31: '1'
	db $C2, $48, $E0	; $32: '2'
	db $C2, $42, $C0	; $33: '3'
	db $AA, $E2, $20	; $34: '4'
	db $E8, $C2, $C0	; $35: '5'
	db $68, $EA, $E0	; $36: '6'
	db $E2, $48, $80	; $37: '7'
	db $EA, $EA, $E0	; $38: '8'
	db $EA, $E2, $C0	; $39: '9'
	db $04, $04, $00	; $3A: ':'
	db $04, $04, $80	; $3B: ';'
	db $24, $84, $20	; $3C: '<'
	db $0E, $0E, $00	; $3D: '='
	db $84, $24, $80	; $3E: '>'
	db $E2, $40, $40	; $3F: '?'
	db $4A, $E8, $60	; $40: '@'
	db $4A, $EA, $A0	; $41: 'A'
	db $CA, $CA, $C0	; $42: 'B'
	db $68, $88, $60	; $43: 'C'
	db $CA, $AA, $C0	; $44: 'D'
	db $E8, $E8, $E0	; $45: 'E'
	db $E8, $E8, $80	; $46: 'F'
	db $68, $EA, $60	; $47: 'G'
	db $AA, $EA, $A0	; $48: 'H'
	db $E4, $44, $E0	; $49: 'I'
	db $22, $2A, $40	; $4A: 'J'
	db $AA, $CA, $A0	; $4B: 'K'
	db $88, $88, $E0	; $4C: 'L'
	db $AE, $EA, $A0	; $4D: 'M'
	db $AE, $EE, $A0	; $4E: 'N'
	db $4A, $AA, $40	; $4F: 'O'
	db $CA, $C8, $80	; $50: 'P'
	db $4A, $AE, $60	; $51: 'Q'
	db $CA, $EC, $A0	; $52: 'R'
	db $68, $42, $C0	; $53: 'S'
	db $E4, $44, $40	; $54: 'T'
	db $AA, $AA, $60	; $55: 'U'
	db $AA, $A4, $40	; $56: 'V'
	db $AA, $EE, $A0	; $57: 'W'
	db $AA, $4A, $A0	; $58: 'X'
	db $AA, $44, $40	; $59: 'Y'
	db $E2, $48, $E0	; $5A: 'Z'
	db $E8, $88, $E0	; $5B: '['
	db $08, $42, $00	; $5C: '\'
	db $E2, $22, $E0	; $5D: ']'
	db $4A, $00, $00	; $5E: '^'
	db $00, $00, $E0	; $5F: '_'
	db $84, $00, $00	; $60: '`'
	db $0C, $6A, $E0	; $61: 'a'
	db $8C, $AA, $C0	; $62: 'b'
	db $06, $88, $60	; $63: 'c'
	db $26, $AA, $60	; $64: 'd'
	db $06, $AC, $60	; $65: 'e'
	db $24, $E4, $40	; $66: 'f'
	db $06, $AE, $24	; $67: 'g'
	db $8C, $AA, $A0	; $68: 'h'
	db $40, $44, $40	; $69: 'i'
	db $20, $22, $A4	; $6A: 'j'
	db $8A, $CC, $A0	; $6B: 'k'
	db $C4, $44, $E0	; $6C: 'l'
	db $0E, $EE, $A0	; $6D: 'm'
	db $0C, $AA, $A0	; $6E: 'n'
	db $04, $AA, $40	; $6F: 'o'
	db $0C, $AA, $C8	; $70: 'p'
	db $06, $AA, $C2	; $71: 'q'
	db $06, $88, $80	; $72: 'r'
	db $06, $C6, $C0	; $73: 's'
	db $8E, $88, $60	; $74: 't'
	db $0A, $AA, $60	; $75: 'u'
	db $0A, $44, $A0	; $76: 'v'
	db $0A, $EE, $E0	; $77: 'w'
	db $0A, $44, $A0	; $78: 'x'
	db $0A, $A6, $24	; $79: 'y'
	db $0E, $6C, $E0	; $7A: 'z'
	db $64, $84, $60	; $7B: '{'
	db $44, $04, $40	; $7C: '¦' &brvbar;
	db $C4, $24, $C0	; $7D: '}'
	db $6C, $00, $00	; $7E: '~'
	db $EE, $EE, $E0	; $7F: Cursor
