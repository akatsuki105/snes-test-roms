;test_dma
;version 1.2 ~byuu (07/27/06)

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
  lda #$8f : sta $2100
  lda #$80 : sta $2115

;*** test 1 ***
;verify that if HDMA run occurs on the same channel
;as an active DMA channel, the HDMA run will kill
;the DMA transfer, leaving $43x5 != 0, etc.
test1:
  stz $2121
  ldx #$0200
- stz $2122 : dex : bne -
  stz $2121

  lda #$00 : sta $4300
  lda #$22 : sta $4301
  lda.b #test1data     : sta $4302
  lda.b #test1data>>8  : sta $4303
  lda.b #test1data>>16 : sta $4304
  ldx #$0080 : stx $4305
  stz $4306 : stz $4307 : stz $4308
  stz $4309 : stz $430a : stz $430b
- bit $4212 : bmi -
- bit $4212 : bpl -
  lda #$01 : sta $420c
- bit $4212 : bmi -
  nop #24 ;wait 384 cycles into first scanline
  lda #$01 : sta $420b ;DMA will overlap HDMA on same channel
  stz $420c
;verify test results
;$4305 = ~#$37 on hardware
  lda $4305 : cmp #$20 : bcs +
  jmp fail
+ lda $4302 : cmp #$60 : bcc +
  jmp fail
+

;*** test 2 ***
;verify that if HDMA init occurs on the same channel
;as an active DMA channel, the HDMA init will kill
;the DMA transfer, leaving $43x5 != 0, etc.
test2:
  stz $2121
  ldx #$0200
- stz $2122 : dex : bne -
  stz $2121

  lda #$00 : sta $4300
  lda #$22 : sta $4301
  lda.b #test1data     : sta $4302
  lda.b #test1data>>8  : sta $4303
  lda.b #test1data>>16 : sta $4304
  ldx #$0080 : stx $4305
  stz $4306 : stz $4307 : stz $4308
  stz $4309 : stz $430a : stz $430b
- bit $4212 : bmi -
- bit $4212 : bpl -
  lda #$01 : sta $420c
  ldx.w #261-225
.loop
- bit $4212 : bvc -
- bit $4212 : bvs -
  dex : bne .loop
  nop #48 ;wait 768 cycles into last scanline
  lda #$01 : sta $420b ; DMA will overlap HDMA init on same channel
  stz $420c
;verify test results
;$4305 = ~#$41 on hardware
  lda $4305 : cmp #$20 : bcs +
  jmp fail
+ lda $4302 : cmp #$60 : bcc +
  jmp fail
+

;*** test 3 ***
;verify that whenever HDMA run occurs, it will kill
;any active DMA channels, even if a different DMA
;channel is currently in progress
;example:
;DMA 0+1 are on, 0 is currently in the middle of
;transferring. HDMA run occurs on 0+1. HDMA run
;will kill DMA on both channels, 0 *and* 1; not just 0
test3:
  stz $2121
  ldx #$0200
- stz $2122 : dex : bne -
  stz $2121

  lda #$00 : sta $4300 : sta $4310
  lda #$18 : sta $4301
  lda #$22 : sta $4311
  lda.b #test1data     : sta $4302 : sta $4312
  lda.b #test1data>>8  : sta $4303 : sta $4313
  lda.b #test1data>>16 : sta $4304 : sta $4314
  ldx #$0080 : stx $4305 : stx $4315
  stz $4306 : stz $4307 : stz $4308
  stz $4309 : stz $430a : stz $430b
  stz $4316 : stz $4317 : stz $4318
  stz $4319 : stz $431a : stz $431b
- bit $4212 : bmi -
- bit $4212 : bpl -
  lda #$03 : sta $420c
- bit $4212 : bmi -
  nop #24 ;wait 384 cycles into first scanline
  lda #$03 : sta $420b ;DMA will overlap HDMA on same channel
  stz $420c
;verify test results
;hardware results :
;opvct=$0000,ophct=$0133
;4300: 00 18 47 c0 00<39 00>00 03 c0 03 00
;4310: 00 22 00 c0 00<80 00>00 03 c0 03 00
  lda $4305 : cmp #$00 : bne +
  jmp fail
+ lda $4312 : cmp #$00 : beq +
  jmp fail
+ lda $4313 : cmp #$c0 : beq +
  jmp fail
+ lda $4315 : cmp #$80 : beq +
  jmp fail
+ lda $4316 : cmp #$00 : beq +
  jmp fail
+

;*** test 4 ***
;verify that whenever HDMA init occurs, it will kill
;any active DMA channels, even if a different DMA
;channel is currently in progress
;example:
;DMA 0+1 are on, 0 is currently in the middle of
;transferring. HDMA init occurs on 0+1. HDMA init
;will kill DMA on both channels, 0 *and* 1; not just 0
test4:
  stz $2121
  ldx #$0200
- stz $2122 : dex : bne -
  stz $2121

  lda #$00 : sta $4300 : sta $4310
  lda #$18 : sta $4301
  lda #$22 : sta $4311
  lda.b #test1data     : sta $4302 : sta $4312
  lda.b #test1data>>8  : sta $4303 : sta $4313
  lda.b #test1data>>16 : sta $4304 : sta $4314
  ldx #$0080 : stx $4305 : stx $4315
  stz $4306 : stz $4307 : stz $4308
  stz $4309 : stz $430a : stz $430b
  stz $4316 : stz $4317 : stz $4318
  stz $4319 : stz $431a : stz $431b
- bit $4212 : bmi -
- bit $4212 : bpl -
  lda #$03 : sta $420c
  ldx.w #261-225
.loop
- bit $4212 : bvc -
- bit $4212 : bvs -
  dex : bne .loop
  nop #48 ;wait 768 cycles into last scanline
  lda #$03 : sta $420b ; DMA will overlap HDMA init on same channel
  stz $420c
;verify test results
;hardware results :
;opvct=$0000,ophct=$001d
;4300: 00 18 43 c0 00<3d 00>00 44 c0 44 00
;4310: 00 22 00 c0 00<80 00>00 01 c0 01 00
  lda $4305 : cmp #$00 : bne +
  jmp fail
+ lda $4312 : cmp #$00 : beq +
  jmp fail
+ lda $4313 : cmp #$c0 : beq +
  jmp fail
+ lda $4315 : cmp #$80 : beq +
  jmp fail
+ lda $4316 : cmp #$00 : beq +
  jmp fail
+

;log registers to SRAM
;  ldx #$0000
;  lda $2137
;- lda $4300,x : sta $700000,x
;  inx : cpx #$0020 : bcc -
;  lda $213c : xba : lda $213c : and #$01 : xba
;  rep #$20 : sta $700020 : sep #$20
;  lda $213d : xba : lda $213d : and #$01 : xba
;  rep #$20 : sta $700022 : sep #$20

;*** end of tests ***
endtest:
  lda.b #0 : sta !test_number
  jmp pass

org $c000
test1data:
  db $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10
  db $11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f,$20
  db $21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f,$30
  db $31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f,$40
  db $41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$50
  db $51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f,$60
  db $61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f,$70
  db $71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f,$00

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
