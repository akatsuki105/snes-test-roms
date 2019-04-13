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

loop:
  lda $0000; inc; and #$0f; sta $0000; tax; ldy #$0f
  pea $2100; pld
  jsl seek_frame

  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -

  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00

  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -

  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00

  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -

  nop #10; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00

  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -

  nop #7; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; sty $00; nop; sty $ff; sty $ff
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; stx $00; nop; stx $00; sty $00

  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -
  -; bit $4212; bvc -
  -; bit $4212; bvs -

  nop #6; stx $00; sty $ff; nop; sty $ff; sty $00
  nop #79
  nop #8; stx $00; sty $ff; nop; sty $ff; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $00; nop; stx $00; sty $00
  nop #79
  nop #8; stx $00; sty $ff; nop; sty $ff; sty $00
  nop #79
  nop #8; stx $00; sty $ff; nop; sty $ff; sty $00

  jmp loop

  incsrc synchronize.asm
