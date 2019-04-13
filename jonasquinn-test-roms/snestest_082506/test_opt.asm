;test_opt
;version 1.00 ~byuu (10/25/05)

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

org $008000
  incsrc libinit.asm

  stz $2121
  lda #$00 : sta $2122
  lda #$7c : sta $2122
  lda #$ff : sta $2122
  lda #$7f : sta $2122

  lda #$02 : sta $2105
  lda #$10 : sta $2107 ;bg1 tilemap
  lda #$20 : sta $2109 ;bg3 tilemap
  lda #$00 : sta $210b ;bg1 tiledata
  lda #$01 : sta $212c

  ldx #$0000 : stx $2116
  lda #$80 : sta $2115
  lda #$01 : sta $4300
  lda #$18 : sta $4301
  lda.b #tiledata     : sta $4302
  lda.b #tiledata>>8  : sta $4303
  lda.b #tiledata>>16 : sta $4304
  lda #$40 : sta $4305
  lda #$00 : sta $4306
  lda #$01 : sta $420b

  ldx #$1048 : stx $2116
  lda #$01 : sta $2118
  lda #$00 : sta $2119

  lda #$1f : sta $210d
  lda #$00 : sta $210d

  ldx #$2006 : stx $2116
  ldx #$2008 : stx $2118
  ldx #$2026 : stx $2116
  ldx #$2008 : stx $2118

  lda #$0f : sta $2100
- bra -

tiledata() {
  db $00,$00,$00,$00,$00,$00,$00,$00
  db $00,$00,$00,$00,$00,$00,$00,$00
  db $00,$00,$00,$00,$00,$00,$00,$00
  db $00,$00,$00,$00,$00,$00,$00,$00
  db $78,$00,$cc,$00,$cc,$00,$fc,$00
  db $cc,$00,$cc,$00,$cc,$00,$00,$00
  db $00,$00,$00,$00,$00,$00,$00,$00
  db $00,$00,$00,$00,$00,$00,$00,$00
}
