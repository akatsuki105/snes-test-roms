; DSP1 DETECT PROGRAM VERSION 1.1
; BY OVERLOAD

.INCLUDE "memory.asm"
.INCLUDE "regs.asm"

;DEFINE ! $01
;DEFINE   $02
;DEFINE # $03
;DEFINE $ $04
;DEFINE % $05
;DEFINE & $06
;DEFINE ' $07
;DEFINE ( $08
;DEFINE ) $09
;DEFINE * $0A
;DEFINE + $0B
;DEFINE , $0C
;DEFINE - $0D
;DEFINE . $0E
;DEFINE / $0F
;DEFINE 0 $10
;DEFINE 1 $11
;DEFINE 2 $12
;DEFINE 3 $13
;DEFINE 4 $14
;DEFINE 5 $15
;DEFINE 6 $16
;DEFINE 7 $17
;DEFINE 8 $18
;DEFINE 9 $19
.DEFINE A $1A
.DEFINE B $1B
.DEFINE C $1C
.DEFINE D $1D
.DEFINE E $1E
.DEFINE F $1F
.DEFINE G $20
.DEFINE H $21
.DEFINE I $22
.DEFINE J $23
.DEFINE K $24
.DEFINE L $25
.DEFINE M $26
.DEFINE N $27
.DEFINE O $28
.DEFINE P $29
.DEFINE Q $2A
.DEFINE R $2B
.DEFINE S $2C
.DEFINE T $2D
.DEFINE U $2E
.DEFINE V $2F
.DEFINE W $30
.DEFINE X $31
.DEFINE Y $32
.DEFINE Z $33

.ENUM $00
	line			dw
.ENDE

.DEFINE StrOutput	 	$1000

.BANK 0
.ORG $8000

Reset:
	jsl	$808100
        
.ORG $8100
	clc
	xce
	rep	#$30
        sta	$0000
        stx	$0002
        sty	$0004
        tdc
        sta	$0006
        tsc
        sta	$0008

	lda	#$2100
	tcd

	stz	$4200

	sep	#$20
	lda	#$80
	sta	$00

	ldx	#$0033
Reset_PPU1:
	stz	$00, x
	stz	$00, x
	dex
	bne	Reset_PPU1

	ldx	#$0100
Reset_CGRAM:
	stz	$22
	stz	$22
	dex
	bne	Reset_CGRAM

	rep	#$20
	ldx	#$8000
Reset_VRAM:
	stz	$18
	dex
	bne	Reset_VRAM

	lda	#$4200
	tcd

	sep	#$20

	ldx	#$000e
Reset_PPU2:
	dex
	stz	$00, x
	bne	Reset_PPU2

	rep	#$20
	lda	#$0000
	tcd

	sep	#$20
	ldx	#$1000
ClearWRAM:
        stz	$1000, x
        dex
        bne	ClearWRAM

	lda	#$80
	sta	VMAIN

	ldx	#$1801
	stx	$4300
	ldx	#VROM
	stx	$4302
	stz	$4304
	ldx	#$4000
	stx	$4305

	ldx	#$2202
	stx	$4310
	ldx	#Palette
	stx	$4312
	stz	$4314
	ldx	#$0008
	stx	$4315

	lda	#$03
	sta	MDMAEN

	lda	#$01
	sta	BGMODE

	lda	#$40
	sta	BG1SC

	lda	#$01
	sta	TM

	lda	#$ff
	sta	BG1VOFS
	sta	BG1VOFS

        ldx	#Regs
        ldy	#$0021
        jsr	StrCopy
        lda	$0001
	jsr	StrOutputHexB
        lda	$0000
	jsr	StrOutputHexB

        ldy	#$0041
        jsr	StrCopy
        lda	$0003
	jsr	StrOutputHexB
        lda	$0002
	jsr	StrOutputHexB

        ldy	#$0061
        jsr	StrCopy
        lda	$0005
	jsr	StrOutputHexB
        lda	$0004
	jsr	StrOutputHexB

        ldy	#$0081
        jsr	StrCopy
        lda	$0007
	jsr	StrOutputHexB
        lda	$0006
	jsr	StrOutputHexB

        ldy	#$00A1
        jsr	StrCopy
        lda	$0009
	jsr	StrOutputHexB
        lda	$0008
	jsr	StrOutputHexB

	ldx	#$0000
        ldy	#$00E1

Stack0:
	lda	$01f0, x
        jsr	StrOutputHexB
        iny
        inx
        cpx	#$0008
        bne	Stack0

        ldy	#$0101

Stack1:
	lda	$01f0, x
        jsr	StrOutputHexB
        iny
        inx
        cpx	#$0010
        bne	Stack1

	lda	#$81
	sta	NMITIMEN

Main:	bra	Main

;	x - @string
;	y - position
;
StrCopy:
	lda	$0000, x
	bmi	EndChar
	sta	StrOutput, y
	inx
	iny
	bra	StrCopy
EndChar:
	inx
	rts

;	a - data
;	y - position
;
StrOutputHexB:
	php
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	#$10
	sta.w	StrOutput, y
	iny
	pla
	and	#$0f
	clc
	adc	#$10
	sta.w	StrOutput, y
	iny
	plp
	rts

;------------------------------------------------------------------------------------

VBlank:
	pha
	phx
	phy
	php

	rep	#$10
	sep	#$20

	lda	#$0f
	sta	INIDSP

Read_NMI:
	lda	RDNMI
	bmi	Read_NMI

Joy_Ready:
	lda	HVBJOY
	and	#$01
	bne	Joy_Ready

	lda	#$00
	sta	VMAIN

	ldx	#$4000
	stx	VMADD

	ldx	#$1800
	stx	$4300
	ldx	#$1000
	stx	$4302
	stz	$4304
	ldx	#$0400
	stx	$4305

	lda	#$01
	sta	MDMAEN

	plp
	ply
	plx
	pla

EmptyHandler:
	rti

Palette:
.DW	$0000
.DW	$0000	; back color
.DW	$7fc0	; font color
.DW	$0000

Regs:
.DB A,0,0,$04,$80
.DB X,0,0,$04,$80
.DB Y,0,0,$04,$80
.DB D,0,0,$04,$80
.DB S,P,0,$04,$80

VROM:
.INCBIN "font.chr"

