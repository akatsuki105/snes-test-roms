arch snes.cpu; lorom

org $8000; fill $20000
org $ffc0; db "ADC SBC TEST         "
org $ffd5; db $30
org $ffd6; db $02
org $ffd7; db $07
org $ffd8; db $05
org $ffdc; dw $5555,$aaaa
org $fffc; dw $8000

org $8000
  clc; xce
  rep #$10
  ldx #$01ff; txs

  ldx #$0000; stx $00
  ldx #$0000

  .loop:
    lda $00; clc; sed; adc $01
    php; pla
    sta $700000,x
    rep #$20; inc $00; sep #$20
    inx; cpx #$8000; bne .loop

  stz $2121
  lda #$00; sta $2122
  lda #$7c; sta $2122
  lda #$0f; sta $2100
  stp
