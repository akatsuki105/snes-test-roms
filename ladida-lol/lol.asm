arch snes.cpu
output "lol.sfc", create
origin 0x0000
base 0x8000
init:
	clc
	xce
	rep #$28
	lda #$2100
	tcd
	ldx #$80
	stx $00
	tay
	tax
	inx
	sty $01
	stz $02
	stz $05
	stz $07
	stz $09
	stz $0B
	stz $0D
	stz $0D
	stz $0F
	stz $0F
	stz $11
	stz $11
	stz $13
	stz $13
	sty $15
	stz $16
	stz $1A
	stx $1B
	stz $1C
	stz $1C
	sty $1E
	stx $1E
	stz $1F
	stz $1F
	stz $21
	sty $22
	stz $23
	stz $25
	stz $27
	stz $29
	stz $2B
	stz $2D
	sty $2F
	ldx #$30
	stx $30
	sty $31
	ldx #$E0
	stx $32
	sty $33
	stz $40
	stz $42
	asl
	tcd
	lda #$FF00
	sta $00
	stz $02
	stz $04
	stz $06
	stz $08
	stz $0A
	stz $0C
	tya
	tcd
	ldx #$80
	stx $2115
	rep #$10
	stz $2116
	ldx #$7FFF
-
	stz $2118
	dex
	bpl -
	ldx #$1FFF
	txs
	dex
-
	stz $00,x
	dex #2
	bpl -
	sep #$30
	phk
	plb
	stz $4016
	cli
	bra +
-
	wai
	lda $15
	beq -
	inc $13
+
	jsr main
	stz $15
	bra -
nmi:
	rep #$30
	pha
	phy
	phx
	phb
	phk
	plb
	phd
	lda #$0000
	tcd
	sep #$30
	lda $4210
	lda #$80
	sta $2100
	stz $420C
	lda $15
	beq +
	jmp _nmi_skip
+
	inc $15
	stz $16
	lda $1B
	sta $210D
	lda $1C
	sta $210D
	lda $1D
	sta $210E
	lda $1E
	sta $210E
	lda $1F
	sta $210F
	lda $20
	sta $210F
	lda $21
	sta $2110
	lda $22
	sta $2110
	lda $23
	sta $2111
	lda $24
	sta $2111
	lda $25
	sta $2112
	lda $26
	sta $2112
	lda $27
	sta $2113
	lda $28
	sta $2113
	lda $29
	sta $2114
	lda $2A
	sta $2114
	rep #$20
	lda $38
	sta $2123
	ldy $3A
	sty $2125
	lda $3B 
	sta $2126
	lda $3D
	sta $2128
	lda $3F
	sta $212A
	lda $19
	sta $212C
	sta $212E
	lda $2C
	sta $2130
	lda $2E
	sta $210B
	lda $30
	sta $2107
	lda $32
	sta $2109
	ldy $18
	sty $2105
	ldy $37
	sty $2106
	ldy $17
	sty $2133
	lda #$2202
	sta $4300
	lda #$0100
	sta $4302
	ldy #$00
	sty $4304
	sty $2121
	lda #$0200
	sta $4305
	iny
	sty $420B
	lda $34
	asl #3
	sep #$21
	ror #3
	xba
	ora #$40
	sta $2132
	lda $35
	lsr
	sec
	ror
	sta $2132
	xba
	sta $2132
	jsr joypad
	jsr nmi_main
	sta $4200
_nmi_skip:
	lda $12
	sta $2100
	lda $2B
	sta $420C
	rep #$30
	pld
	plb
	plx
	ply
	pla
	rti
irq:
	rep #$30
	pha
	phy
	phx
	phb
	phk
	plb
	phd
	lda #$0000
	tcd
	sep #$30
	lda $4211
-
	bit $4212
	bvc -
	lda #$80
	sta $2100
	rep #$20
	lda #$2103
	sta $4300
	lda #gradient
	sta $4302
	sta $4308
	sep #$20
	stz $4304
	lda #$01
	sta $430A
	sta $420C
-
	bit $4212
	bvs -
-
	bit $4212
	bvc -
	lda #$0F
	sta $2100
	rep #$30
	pld
	plb
	plx
	ply
	pla
	rti
main:
	lda $10
	bne _next
	lda #$0F
	sta $12
	lda #$FF
	sta $0100
	sta $0101
	rep #$20
	lda #$2601
	sta $4370
	lda #window
	sta $4372
	sep #$20
	stz $4374
	lda #$80
	sta $2C
	inc $10
	lda #$81
	sta $4200
	rts
_next:
	lda $42
	and #$80
	eor $2B
	sta $2B
	lsr #2
	sta $3A
	rts
nmi_main:
	lda $4211
	lda #$A0
	sta $4209
	stz $420A
	lda #$A1
	rts
joypad:
	lsr $4212
	bcs joypad
	rep #$30
	ldx $4218
	lda $47
	stx $47
	and $47
	sta $43
	eor $47
	sta $41
	lda $45
	trb $41
	trb $43
	stz $45
	sep #$30
	rts
break:
	sep #$34
	phk
	plb
-
	lda $4212
	bpl -
-
	lda $4212
	bmi -
	stz $4200
	stz $420C
	pea $2100
	pld
	stz $30
	stz $33
	stz $2C
	stz $2E
	stz $31
	stz $05
	stz $06
	stz $21
	lda #$FF
	sta $22
	sta $22
	lda #$0F
-
	sta $00
	eor #$0F
	bra -
gradient:
	db $08
	dw $0000,$001F
	db $08
	dw $0000,$001B
	db $08
	dw $0000,$0017
	db $08
	dw $0000,$0013
	db $08
	dw $0000,$000F
	db $08
	dw $0000,$000B
	db $08
	dw $0000,$0007
	db $08
	dw $0000,$0003
	db $00
window:
	db $30
	dw $00FF
	db $50
	dw $C040
	db $01
	dw $00FF
	db $00
origin 0x7fc0
base 0xffc0
header:
	db $20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	db $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	db $00
	db $00
	db $05
	db $00
	db $00
	db $00
	db $00
	dw ~$0000
	dw $0000
_init:
	dw $FFFF,$FFFF
	dw $FFFF,break,$FFFF,nmi,$FFFF,irq
	dw $FFFF,$FFFF
	dw $FFFF,$FFFF,$FFFF,$FFFF,init,$4842