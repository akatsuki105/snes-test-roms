;test_dmavalid
;version 1.0 ~byuu (2008-03-03)

;note: this test is intentionally very lenient to timing,
;as this is designed to be a general purpose DMA validation test
;test will pass so long as emulated time is within ~4 scanlines of real hardware

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm

org $008000
  incsrc libinit.asm
  sep #$20
  rep #$10

;ROM->WRAM transfers are valid
test1:
  lda #$00 : sta $2181
  lda #$08 : sta $2182
  lda #$7e : sta $2183 ;to $7e0800

  lda #$00 : sta $4300 ;to $21xx
  lda #$80 : sta $4301 ;to $2180
  lda.b #data : sta $4302
  lda.b #data>>8 : sta $4303
  lda.b #data>>16 : sta $4304
  ldx #$0002 : stx $4305
  lda #$01 : sta $420b

  lda $7e0800 : cmp #$aa : beq + : jmp fail
+ lda $7e0801 : cmp #$55 : beq + : jmp fail
+

;WRAM->$2180 transfers are not valid
test2:
- bit $4212 : bpl -
- bit $4212 : bmi -
  jsr clear_wram

  lda #$00 : sta $2181
  lda #$08 : sta $2182
  lda #$7e : sta $2183 ;to $7e0800

  lda #$00 : sta $4300
  lda #$80 : sta $4301
  lda #$00 : sta $4302
  lda #$10 : sta $4303
  lda #$7e : sta $4304 ;from $7e1000
  ldx #$0400 : stx $4305 ;~6 scanlines of time (1024*8/1324)
  lda #$01 : sta $420b
  nop #2
  ;$7e1000+ -> $2180[$7e0800]+

  ;poke value into $2180 to verify location
  lda #$3f : sta $2180
  lda $7e0800 : sta $700000
  lda $7e0c00 : sta $700001

  ;cache WRAM dest value to test if write occurred
  lda $7e08ff : sta $700002

  ;cache DMA registers
  lda $4302 : sta $700003
  lda $4303 : sta $700004
  lda $4304 : sta $700005
  lda $4305 : sta $700006
  lda $4306 : sta $700007

  ;cache scanline register positions
  lda $2137
  lda $213c : sta $700008
  lda $213c : and #$01 : sta $700009
  lda $213d : sta $70000a
  lda $213d : and #$01 : sta $70000b

  ;$7e0000 =
  ;[3f 55] $2180 not incremented (would be [?? 3f] if so)
  ;[55] DMA write did not occur (would be [aa] if so, or at least not [55] if eg MDR was written)
  ;[00 14 7e] $43x2 incremented (would be [00 10 7e] if not)
  ;[00 00] $43x5 decremented (would be [00 04] if not)
  ;[ce 00] htime
  ;[36 00] vtime -- consumes DMA time (would be < [33 00] if not)

  lda $700000 : cmp #$3f : beq + : jmp fail
+ lda $700001 : cmp #$55 : beq + : jmp fail
+ lda $700002 : cmp #$55 : beq + : jmp fail
+ lda $700003 : cmp #$00 : beq + : jmp fail
+ lda $700004 : cmp #$14 : beq + : jmp fail
+ lda $700005 : cmp #$7e : beq + : jmp fail
+ lda $700006 : cmp #$00 : beq + : jmp fail
+ lda $700007 : cmp #$00 : beq + : jmp fail
+ lda $70000a : cmp #$33 : bcs + : jmp fail
+

;$2180->WRAM transfers are not valid
test3:
- bit $4212 : bpl -
- bit $4212 : bmi -
  jsr clear_wram

  lda #$00 : sta $2181
  lda #$08 : sta $2182
  lda #$7e : sta $2183 ;from $7e0800

  lda #$80 : sta $4300
  lda #$80 : sta $4301
  lda #$00 : sta $4302
  lda #$10 : sta $4303
  lda #$7e : sta $4304 ;to $7e1000
  ldx #$0400 : stx $4305
  lda #$01 : sta $420b
  nop #2
  ;$2180[$7e0800]+ -> $7e1000+

  ;poke value into $2180 to verify location
  lda #$3f : sta $2180
  lda $7e0800 : sta $700010
  lda $7e0c00 : sta $700011

  ;cache WRAM dest value to test if write occurred
  lda $7e10ff : sta $700012

  ;cache DMA registers
  lda $4302 : sta $700013
  lda $4303 : sta $700014
  lda $4304 : sta $700015
  lda $4305 : sta $700016
  lda $4306 : sta $700017

  ;cache scanline register positions
  lda $2137
  lda $213c : sta $700018
  lda $213c : and #$01 : sta $700019
  lda $213d : sta $70001a
  lda $213d : and #$01 : sta $70001b

  ;$7e0010 =
  ;[3f 55] $2180 not incremented
  ;[00] DMA write did occur, but wrote unknown value (not MDR, which would be #$ea)
  ;[00 14 7e] $43x2 incremented
  ;[00 00] $43x5 decremented
  ;[ce 00] htime
  ;[36 00] vtime -- consumes DMA time

  lda $700010 : cmp #$3f : beq + : jmp fail
+ lda $700011 : cmp #$55 : beq + : jmp fail
  ;exact value unknown; must not be original value (#$aa), as write does occur
+ lda $700012 : cmp #$aa : bne + : jmp fail
+ lda $700013 : cmp #$00 : beq + : jmp fail
+ lda $700014 : cmp #$14 : beq + : jmp fail
+ lda $700015 : cmp #$7e : beq + : jmp fail
+ lda $700016 : cmp #$00 : beq + : jmp fail
+ lda $700017 : cmp #$00 : beq + : jmp fail
+ lda $70001a : cmp #$33 : bcs + : jmp fail
+

endtests:
  jmp pass

data:
  db $aa,$55

clear_wram() {
  ldx #$0000
  lda #$55
- sta $7e0800,x : inx
  cpx #$0800 : bcc -

  ldx #$0000
  lda #$aa
- sta $7e1000,x : inx
  cpx #$0800 : bcc -

  rts
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
