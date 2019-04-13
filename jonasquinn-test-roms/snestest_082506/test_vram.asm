;test_vram
;version 1.1 ~byuu (07/22/06)

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

!test_number = $700000
!inc_test_number = "lda $700000 : inc : sta $700000"

org $008000
  incsrc libinit.asm

  lda.b #0 : sta !test_number
  lda #$0f : sta $2100
  lda #$80 : sta $2115

;*** test 1 ***
;verify that vram writes outside of vblank
;still update the write position
  jsl seek_frame
- bit $4212 : bpl -
  ldx #$0000 : stx $2116
  lda #$00 : sta $2118
  lda #$01 : sta $2119
  lda #$02 : sta $2118
  lda #$03 : sta $2119
  lda #$04 : sta $2118
  lda #$05 : sta $2119
- bit $4212 : bmi -
  ldx #$0000 : stx $2116
  lda #$06 : sta $2118
  lda #$07 : sta $2119
- bit $4212 : bpl -
  lda $213a ;dummy read
  lda $2139 : cmp #$02 : beq +
  jmp fail
+ lda $213a : cmp #$03 : beq +
  jmp fail
+

;*** test 2 ***
;verify that writes to VRAM during HDMA
;are not blocked. eg they will still
;succeed if in force blank mode, or in
;extreme cases when HDMA at V=224 extends
;into vblank and then writes to VRAM
  lda #$8f : sta $2100
  lda #$80 : sta $2115

  ldx #$0000 : stx $2116
  lda #$10 : sta $2118
  lda #$11 : sta $2119
  lda #$12 : sta $2118
  lda #$13 : sta $2119
  lda #$14 : sta $2118
  lda #$15 : sta $2119

  ldx #$0000 : stx $2116
  lda #$01 : sta $4300
  lda #$18 : sta $4301
  lda #$00 : sta $4302
  lda #$00 : sta $4303
  lda #$7f : sta $4304
  stz $4305 : stz $4306 : stz $4307
  stz $4308 : stz $4309 : stz $430a

  lda #$01 : sta $7f0000
  lda #$16 : sta $7f0001
  lda #$17 : sta $7f0002
  lda #$00 : sta $7f0003

- bit $4212 : bmi -
- bit $4212 : bpl -
  lda #$01 : sta $420c

- bit $4212 : bmi -
- bit $4212 : bpl -
  stz $420c

  ldx #$0000 : stx $2116
  lda $2139 : cmp #$16 : beq +
  jmp fail
+ lda $213a : cmp #$17 : beq +
  jmp fail
+

;*** test 3 ***
;test VRAM read buffer caching behavior
;during writes to $2116/$2116
  ldx #$0000 : stx $2116
  lda #$20 : sta $2118
  lda #$21 : sta $2119
  ldx #$0100 : stx $2116
  lda #$22 : sta $2118
  lda #$23 : sta $2119

  lda #$00 : sta $2117
  lda #$00 : sta $2116 ;should cache #$2120 to $2139/$213a
  lda $2139 : cmp #$20 : beq +
  jmp fail
+ lda $213a : cmp #$21 : beq +
  jmp fail
+
  lda #$00 : sta $2116 ;should cache #$2120 to $2139/$213a
  lda #$01 : sta $2117 ;should cache #$2322 to $2139/$213a
  lda $2139 : cmp #$22 : beq +
  jmp fail
+ lda $213a : cmp #$23 : beq +
  jmp fail
+

;*** end of tests ***
  lda.b #0 : sta !test_number
  jmp pass

pass() {
  sep #$20
  stz $420c
  stz $2121
  lda #$00 : sta $2122
  lda #$7c : sta $2122
  lda #$0f : sta $2100
  stp
}

fail() {
  sep #$20
  stz $420c
  stz $2121
  lda #$1f : sta $2122
  lda #$00 : sta $2122
  lda #$0f : sta $2100
  stp
}
