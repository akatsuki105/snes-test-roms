;test_math_back
;version 1.00 ~byuu (11/03/05)

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

org $008000
  incsrc libinit.asm

  stz $2121
  lda #$0f : sta $2122
  lda #$00 : sta $2122
  lda #$01 : sta $2105
  lda #$e0 : sta $2132
  lda #$8f : sta $2132
  lda #$27 : sta $2132

  lda #$20 : sta $2125 ;enable color window 1
  lda #$40 : sta $2126
  lda #$c0 : sta $2127

  lda #$04 : sta $4300
  lda #$30 : sta $4301
  lda.b #hdma_table     : sta $4302
  lda.b #hdma_table>>8  : sta $4303
  lda.b #hdma_table>>16 : sta $4304
  lda #$01 : sta $420c

- bit $4212 : bmi -
- bit $4212 : bpl -

  lda #$0f : sta $2100
- bra -

hdma_table:
  db $20,$00,$00,$00,$00
;main (always), sub (always)
  db $04,$00,$20,$00,$00 ;000
  db $04,$00,$60,$00,$00 ;001
  db $04,$00,$a0,$00,$00 ;010
  db $04,$00,$e0,$00,$00 ;011

  db $04,$02,$20,$00,$00 ;100
  db $04,$02,$60,$00,$00 ;101
  db $04,$02,$a0,$00,$00 ;110
  db $04,$02,$e0,$00,$00 ;111

  db $08,$00,$00,$00,$00
;main (inside), sub(always)
  db $04,$40,$20,$00,$00 ;000
  db $04,$40,$60,$00,$00 ;001
  db $04,$40,$a0,$00,$00 ;010
  db $04,$40,$e0,$00,$00 ;011

  db $04,$42,$20,$00,$00 ;100
  db $04,$42,$60,$00,$00 ;101
  db $04,$42,$a0,$00,$00 ;110
  db $04,$42,$e0,$00,$00 ;111

  db $08,$00,$00,$00,$00
;main (always), sub(inside)
  db $04,$10,$20,$00,$00
  db $04,$10,$60,$00,$00
  db $04,$10,$a0,$00,$00
  db $04,$10,$e0,$00,$00

  db $04,$12,$20,$00,$00
  db $04,$12,$60,$00,$00
  db $04,$12,$a0,$00,$00
  db $04,$12,$e0,$00,$00

  db $08,$00,$00,$00,$00
;main (inside), sub(inside)
  db $04,$50,$20,$00,$00
  db $04,$50,$60,$00,$00
  db $04,$50,$a0,$00,$00
  db $04,$50,$e0,$00,$00

  db $04,$52,$20,$00,$00
  db $04,$52,$60,$00,$00
  db $04,$52,$a0,$00,$00
  db $04,$52,$e0,$00,$00

  db $08,$00,$00,$00,$00
;
  db $00
