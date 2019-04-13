lorom

org $008000 : fill $020000

org $ffc0
  db 'RESET DEMO ROM       '
  db $30 ;fastrom/lorom
  db $02 ;rom+save ram
  db $08 ;2mbit rom
  db $03 ;64kb sram
  db $00 ;japan
  db $33 ;nintendo
  db $01 ;version 1.1
  dw $0000 ;inverse checksum
  dw $0000 ;rom     checksum
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  dw $8800
  db $00,$00,$00,$00
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  dw $8000
  db $00,$00

org $008800
  rti

org $008000

intro() {
  clc : xce

  rep #$30
  sta $7e8000
  txa : sta $7e8002
  tya : sta $7e8004
  tsx : txa : sta $7e8006
  lda $7ec000 : sta $7e8008

  sep #$30

  lda #$8f : sta $2100
  lda #$00
  ldx #$01
- sta $2100,x : inx : cpx #$0d : bcc -
- sta $2100,x : sta $2100,x : inx : cpx #$15 : bcc -
  ldx #$16
- sta $2100,x : inx : cpx #$1b : bcc -
- sta $2100,x : sta $2100,x : inx : cpx #$21 : bcc -
- sta $2100,x : inx : cpx #$34 : bcc -
  ldx #$02
- sta $4200,x : inx : cpx #$0e : bcc -

  lda #$80 : sta $2115 ;increment on $2119 write
  lda #$01 : sta $4200 ;enable joypad, not nmi
  lda #$ff : sta $4201 ;...
  lda #$81 : sta $4212 ;bit7=in vblank, bit0=joypad ready

  lda #$00 : sta $2105 ;mode0 [bg1-4: 4]
  lda #$00 : sta $2107 ;bg1 tilemap  [$0000]
  lda #$01 : sta $210b ;bg1 tiledata [$1000]
  lda #$01 : sta $212c ;enable bg1

  jsr write_tiledata
  jsr write_tilemap
  jsr write_palette

  rep #$30

  ldx.w #32*1+1 : stx $2116
  ldx.w #string0 : jsr write_str
  ldx.w #32*2+2 : stx $2116
  ldx.w #string1 : jsr write_str
  ldx.w #32*3+2 : stx $2116
  ldx.w #string2 : jsr write_str

  ldx.w #32*2+4 : stx $2116
  lda $7e8000 : jsr write_word
  ldx.w #32*2+11 : stx $2116
  lda $7e8002 : jsr write_word
  ldx.w #32*2+18 : stx $2116
  lda $7e8004 : jsr write_word
  ldx.w #32*2+25 : stx $2116
  lda $7e8006 : jsr write_word
  ldx.w #32*3+13 : stx $2116
  lda $7e8008 : jsr write_word

  sep #$20
  lda #$0f : sta $2100

  lda #$00 : pha                  ;stack reset test
  rep #$30
  lda $7ec000 : inc : sta $7ec000 ;memory reset test
  lda #$dead
  ldx #$beef
  ldy #$0123                      ;register reset test
- bra -
}

table font.tbl,ltr

string0: db 'States at initialization:',$ff
string1: db 'A:0000 X:0000 Y:0000 S:0000',$ff
string2: db 'MEM.7EC000:0000',$ff

write_str() {
  php
  rep #$30
- {
    lda $0000,x : and #$00ff
    cmp #$00ff : beq +
    sta $2118
    inx : bra -
  }
+ plp : rts
}

write_word() {
  php
  rep #$30 : sta $20

  xba : lsr #4
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++  sta $2118

  lda $20 : xba
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++  sta $2118

  lda $20 : lsr #4
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++  sta $2118

  lda $20
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++  sta $2118

  plp : rts
}

write_tiledata() {
  lda #$00 : sta $2116
  lda #$10 : sta $2117

  lda #$01 : sta $4300
  lda #$18 : sta $4301

  lda.b #tiledata     : sta $4302
  lda.b #tiledata>>8  : sta $4303
  lda.b #tiledata>>16 : sta $4304

  rep #$20
  lda #end_tiledata-tiledata : sta $4305
  sep #$20

  lda #$01 : sta $420b
  rts
}

write_tilemap() {
  rep #$30
  lda #$0000 : sta $2116 : tax
- {
    sta $2118
    inx : cpx.w #32*28 : bcc -
  }
  sep #$30
  rts
}

write_palette() {
  lda #$00 : sta $2121
  tax
- lda.l palette,x : sta $2122 : inx
  lda.l palette,x : sta $2122 : inx
  cpx #$08 : bcc -
  rts
}

org $018000
palette:
  dw $0000,$1ce7,$0000,$7fff
org $018200
tiledata: incbin font8.bin
end_tiledata:
