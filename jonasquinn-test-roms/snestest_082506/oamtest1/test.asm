;test_oamaddr
;version 1.0 ~byuu (08/23/06)

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm

org $008000 : jmp main

oam_clear() {
  php : rep #$30 : pha : phx

  sep #$20
  lda #$8f : sta $2100
  stz $2102 : stz $2103

  ldx.w #128
- lda #$00 : sta $2104
  lda #$f0 : sta $2104
  lda #$00 : sta $2104
  lda #$00 : sta $2104
  dex : bne -

  ldx.w #32
- stz $2104 : dex : bne -

  rep #$30 : plx : pla : plp : rts
}

oam_read() {
  php : rep #$30 : pha : phx

  sep #$20
  lda #$8f : sta $2100
  stz $2102 : stz $2103

  ldx #$0000
- lda $2138 : sta $7f0000,x
  inx : cpx #$0220 : bcc -

  rep #$30 : plx : pla : plp : rts
}

oam_save() {
  php : rep #$30 : pha : phx

  sep #$20

  ldx #$0000
- lda $7f0000,x
  cmp #$00 : beq +
  cmp #$f0 : beq +
  stx $20
  pha
  lda $20 : sta $2180
  lda $21 : sta $2180
  pla : sta $2180
+ inx : cpx #$0220 : bcc -

  lda #$ff : sta $2180 : sta $2180

  rep #$30 : plx : pla : plp : rts
}

sram_save() {
  php : rep #$30 : pha : phx

  sep #$20

  ldx #$0000
- lda $7f8000,x : sta $700000,x
  inx : cpx #$8000 : bcc -

  rep #$30 : plx : pla : plp : rts
}

;assume: m=1,x=0
;input: x (line to seek to)
line_seek() {
- bit $4212 : bvc -
- bit $4212 : bvs -

  stx $20

- lda $2137
  lda $213d : xba
  lda $213d : and #$01
  cmp $21 : bne -
  xba : cmp $20 : bne -

  rts
}

main() {
  incsrc libinit.asm

  sep #$20 : rep #$10
  lda #$8f : sta $2100
  lda #$01 : sta $420d

  jml fastmain
}

org $80c000
fastmain() {

;**********
;* test 1 *
;**********

;initialize test
  jsr oam_clear
  lda #$0f : sta $2100

  lda #$00 : sta $2181
  lda #$80 : sta $2182
  lda #$7f : sta $2183

  lda #$00 : sta $707ffe
  lda #$00 : sta $707fff

  ldx.w #48706 : stx $80

loop:
  sep #$20
  lda #$0f : sta $2100
- bit $213f : bpl -
- bit $213f : bmi -
- bit $4212 : bpl -
  ldx #$0000 : stx $2102
- bit $4212 : bmi -
- bit $4212 : bpl -

  jsl seek_frame
- bit $4212 : bpl -
  rep #$20
  lda $80 : jsl seek_cycles
  lda $80 : clc : adc #$0002 : sta $80
  sep #$20

  lda #$ea : sta $2104

;test complete, check results
  jsr oam_read
  jsr oam_save
  jsr oam_clear

  rep #$20
  lda $80 : cmp.w #48706+1324 : bcs end
  lda $707ffe : clc : adc #$0002 : sta $707ffe
  jmp loop

end:
  sep #$20

;clock accuracy verification
  jsl seek_frame
  rep #$20
  lda #$0800 : jsl seek_cycles
  sep #$20

  lda $2137
  lda $213c : sta $2180
  lda $213c : and #$01 : sta $2180
  lda $213d : sta $2180
  lda $213d : and #$01 : sta $2180

;half-dot clock accuracy verification
  jsl seek_frame
  rep #$20
  lda #$0802 : jsl seek_cycles
  sep #$20

  lda $2137
  lda $213c : sta $2180
  lda $213c : and #$01 : sta $2180
  lda $213d : sta $2180
  lda $213d : and #$01 : sta $2180

  jsr sram_save

  jmp pass
}

pass() {
  sei
  sep #$20
  stz $4200
  stz $2121
  lda #$00 : sta $2122
  lda #$7c : sta $2122
  lda #$0f : sta $2100
  stp
}

fail() {
  sei
  sep #$20
  stz $4200
  stz $2121
  lda #$1f : sta $2122
  lda #$00 : sta $2122
  lda #$0f : sta $2100
  stp
}
