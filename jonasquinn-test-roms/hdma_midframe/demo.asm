;demo_hdma.asm
lorom : header

org $008000 : fill $020000

org $00ffc0
  db 'bsnes hdma test rom  '
  db $30   ;lorom ($31 = hirom)
  db $02   ;rom+save ram
  db $08   ;2mbit rom
  db $03   ;64kb sram
  db $00   ;japan
  db $00   ;no developer
  db $01   ;version 1.1
  dw $0000 ;inverse checksum
  dw $ffff ;checksum

  dw $ffff,$ffff,$ffff
  dw $0000 ;brk
  dw $ffff
  dw $8800 ;nmi
  dw $ffff
  dw $8c00 ;irq
  dw $ffff,$ffff
  dw $0000 ;cop
  dw $ffff,$ffff,$ffff
  dw $8000 ;reset
  dw $ffff

org $008000
  clc : xce

  rep #$10
  lda #$8f : sta $2100 ;disable screen
  lda #$01 : sta $2105 ;mode1
  lda #$80 : sta $2115 ;inc after $2119 write
  stz $212c
  stz $212d

  lda #$07 : sta $4300 ;4x = indirect, 0x = absolute
  lda #$21 : sta $4301
  lda.b #hdma_table     : sta $4302
  lda.b #hdma_table>>8  : sta $4303
  lda.b #hdma_table>>16 : sta $4304
  stz $420c

  lda #$0f : sta $2100

.loop
- bit $4212 : bpl -
  stz $420c
- bit $4212 : bmi -

  ldx #$0020
.line_loop
- bit $4212 : bvc -
- bit $4212 : bvs -
  dex : bne .line_loop

  lda $4302 : sta $4308
  lda $4303 : sta $4309
  stz $430a
  lda #$01 : sta $420c

  bra .loop

hdma_table:
  db $07 : dw $0000,$001f
  db $07 : dw $0000,$001e
  db $07 : dw $0000,$001d
  db $07 : dw $0000,$001c
  db $07 : dw $0000,$001b
  db $07 : dw $0000,$001a
  db $07 : dw $0000,$0019
  db $07 : dw $0000,$0018
  db $00
