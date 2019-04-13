arch snes.cpu
incsrc header.asm

org $8000
  incsrc initialize.asm

main:
  sep #$30
  stz $2121
  lda #$ff; sta $2122
  lda #$7f; sta $2122
  lda #$0f; sta $2100
  lda #$00; sta $0000
  pea $2100; pld
  lda #$05; ldx #$0f

  -; sta $00; stx $00; bra -
