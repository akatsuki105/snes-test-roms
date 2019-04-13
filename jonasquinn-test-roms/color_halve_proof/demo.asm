lorom : header

org $008000 : fill $20000

org $7fc0
  db 'bsnes sprite test rom'
  db $30   ;lorom ($30 = lorom, $31 = hirom)
  db $02   ;rom+save ram
  db $08   ;2mbit rom
  db $07   ;128kb sram
  db $00   ;japan
  db $00   ;no developer
  db $01   ;version 1.1
  dw $0000 ;inverse checksum
  dw $ffff ;checksum

  dw $ffff,$ffff,$ffff
  dw $0000 ;brk
  dw $ffff
  dw $0000 ;nmi
  dw $ffff,$ffff,$ffff,$ffff
  dw $0000 ;cop
  dw $ffff,$ffff,$ffff
  dw $8000 ;reset
  dw $ffff

!hcounter = $00

org $008000
  clc : xce
  sep #$20 : rep #$10

  lda #$8f : sta $2100
  lda #$00
  ldx #$2101
- sta $0000,x : inx : cpx #$210d : bcc -
- sta $0000,x : sta $0000,x : inx : cpx #$2115 : bcc -
  ldx #$2116
- sta $0000,x : inx : cpx #$211b : bcc -
- sta $0000,x : sta $0000,x : inx : cpx #$2121 : bcc -
- sta $0000,x : inx : cpx #$2134 : bcc -
  ldx #$4202
- sta $0000,x : inx : cpx #$420e : bcc -

  lda #$80 : sta $2115 ;increment on $2119 write
  lda #$01 : sta $4200 ;enable joypad, not nmi
  lda #$81 : sta $4212 ;bit7=in vblank, bit0=joypad ready

  lda #$00 : sta $2121
  lda #$00 : sta $2122
  lda #$3c : sta $2122

  lda.b #%00000000 : sta $2130
  lda.b #%01100000 : sta $2131

  lda #$0f : sta $2100

-
  jsr draw_screen
  bra -

draw_screen() {
  ldx #$0000 : stx !hcounter
- lda $4212 : bpl -
- lda $4212 : bmi -

.loop
- lda $4212 : bit #$40 : bne -
- lda $4212 : bit #$40 : beq -

  lda !hcounter
  lsr #7 ;a /= 128
  and #$1f
  ora #$80
  sta $2132
  rep #$20
  inc !hcounter
  lda !hcounter
  cmp.w #224 : bcs .end
  sep #$20 : bra .loop
.end
  sep #$20
  lda #$00 : sta $2132
  rts
}
