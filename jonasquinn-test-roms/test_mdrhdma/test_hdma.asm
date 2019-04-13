;test_hdma
;version 1.02 ~byuu (10/21/05)

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

;*** test 1 ***
;this test verifies what happens during HDMA init
test1() {
  !inc_test_number
  jsl seek_frame
  jsr get_dma_counter
  cmp #$00 : bne test1

;have to use DC=4 due to timing differences with
;HDMA init on 1/1/1 and 2/1/3 SNES units...

- bit $213f : bpl -
- bit $4212 : bpl -

  lda #$40 : sta $4300
  lda #$01 : sta $4301
  lda #$00 : sta $4302
  lda #$00 : sta $4303
  lda #$7f : sta $4304
  lda #$55 : sta $4305
  lda #$55 : sta $4306
  stz $4307 : stz $4308 : stz $4309 : stz $430a

  lda #$00 : sta $7f0000
  lda #$aa : sta $7f0001
  lda #$bb : sta $7f0002

  lda #$01 : sta $420c
- bit $4212 : bmi -
  nop #8
  stz $420c
  lda $2137

;indirect HDMA will move A1TxW into A2AxW, and
;then load NTRLx. if the value is zero, then it
;will load the next byte from the table into
;DASxH and clear DASxL. A2AxW is equal to A1TxW
;plus two. NTRLx equals zero.
;note that it won't actually read from the table
;three times -- only two reads actually occur,
;as determined by checking OPHCT.
;it's unknown if the zero in DASxL comes from NTRLx
;or is just cleared by the HDMA init handler, but
;the result is identical either way.
  lda $4305 : cmp #$00 : beq +
  jmp fail
+ lda $4306 : cmp #$aa : beq +
  jmp fail
+ lda $4308 : cmp #$02 : beq +
  jmp fail
+ lda $4309 : cmp #$00 : beq +
  jmp fail
+ lda $430a : cmp #$00 : beq +
  jmp fail
+ lda $213c : cmp #$38 : beq +
  jmp fail
+ lda $213c
;invert half-dot phase and test counters again
  nop
  lda $2137
  lda $213c : cmp #$bb : beq +
  jmp fail
+ lda $213c
}

;*** test 2 ***
;this test verifies that enabling HDMA mid-frame
;does not clear the transfer flag
test2() {
  !inc_test_number

  stz $420c
  stz $2121
  lda #$34 : sta $2122
  lda #$12 : sta $2122

  lda #$03 : sta $4300
  lda #$21 : sta $4301
  lda.b #hdma_test2     : sta $4302
  lda.b #hdma_test2>>8  : sta $4303
  lda.b #hdma_test2>>16 : sta $4304
- bit $4212 : bpl -
- bit $4212 : bmi -
;we're at the start of a new frame now...
  lda $4302 : sta $4308
  lda $4303 : sta $4309
  lda #$01  : sta $430a
  lda #$01  : sta $420c
;HDMA on, wait until first HDMA event
- bit $4212 : bvc -
- bit $4212 : bvs -
;ok, HDMA ran, now stop it
;clearing $420c bit won't clear the transfer flag
  stz $420c
;now wait a few scanlines
- bit $4212 : bvc -
- bit $4212 : bvs -
- bit $4212 : bvc -
- bit $4212 : bvs -
- bit $4212 : bvc -
- bit $4212 : bvs -
- bit $4212 : bvc -
- bit $4212 : bvs -
;clearing NTRLx won't clear the transfer flag
  stz $430a
  lda $4302 : inc : sta $4308
  lda $4303 : sta $4309
  lda #$01  : sta $430a
  lda #$01  : sta $420c
- bit $4212 : bvc -
- bit $4212 : bvs -
  stz $420c
;transfer will occur, verify that it has
  stz $2121
  lda $213b : cmp #$78 : beq +
  jmp fail
+ lda $213b : cmp #$56 : beq +
  jmp fail
+

  jmp end_test2
}

hdma_test2:
  db $01 : dw $0000,$5678
  db $00

end_test2:

;*** test 3 ***
;the HDMA transfer flag does get cleared during
;HDMA init, even if no channels are enabled
test3() {
  !inc_test_number

  stz $420c

  lda #$03 : sta $4300
  lda #$21 : sta $4301
  lda.b #hdma_test3a     : sta $4302
  lda.b #hdma_test3a>>8  : sta $4303
  lda.b #hdma_test3a>>16 : sta $4304

;seek to vblank
- bit $4212 : bmi -
- bit $4212 : bpl -
  lda #$01 : sta $420c

;now seek to next vblank
- bit $4212 : bmi -
- bit $4212 : bpl -

;channel 0's transfer flag should still be set,
;as continous HDMA ($88) is in progress.
;turn off HDMA to skip main HDMA init function
  stz $420c
- bit $4212 : bmi -
  lda.b #hdma_test3b     : sta $4308
  lda.b #hdma_test3b>>8  : sta $4309
  lda.b #hdma_test3b>>16 : sta $4304
  lda #$01 : sta $430a
  sta $420c

;wait for HDMA event
- bit $4212 : bvc -
- bit $4212 : bvs -
  stz $420c

;now see if HDMA actually happened, it should not have
  stz $2121
  lda $213b : cmp #$34 : beq +
  jmp fail
+ lda $213b : cmp #$12 : beq +
  jmp fail
+

  jmp end_test3
}

hdma_test3a:
  db 128 : dw $0000,$1234
  db  94 : dw $0000,$1234
  db $88
    dw $0000,$1234
    dw $0000,$1234
    dw $0000,$1234
    dw $0000,$1234
    dw $0000,$1234
    dw $0000,$1234
    dw $0000,$1234
    dw $0000,$1234
  db $00

hdma_test3b:
  db $01 : dw $0000,$5678
  db $00

end_test3:

;*** test 4 ***
;this test shows that if $43xa is 0 when an HDMA
;transfer begins (before the decrement), it will
;wrap to 0xff and begin a continuous transfer.
test4() {
  !inc_test_number
  stz $420c
  stz $2121
  lda #$34 : sta $2122
  lda #$12 : sta $2122

  lda #$03 : sta $4300
  lda #$21 : sta $4301
  lda.b #hdma_test4     : sta $4302
  lda.b #hdma_test4>>8  : sta $4303
  lda.b #hdma_test4>>16 : sta $4304
  lda $4302 : inc : sta $4308
  lda $4303 : sta $4309
  stz $430a

- bit $4212 : bpl -
- bit $4212 : bmi -
  lda #$01 : sta $420c
- bit $4212 : bvc -
- bit $4212 : bvs -
- bit $4212 : bvc -
- bit $4212 : bvs -
- bit $4212 : bvc -
- bit $4212 : bvs -
  stz $420c
  stz $2121

  lda $213b : cmp #$bc : beq +
  jmp fail
+ lda $213b : cmp #$9a : beq +
  jmp fail
+

  jmp end_test4
}

hdma_test4:
  db $00
    dw $0000,$5678
    dw $0000,$9abc
  db $00

end_test4:

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

;this only works in non-interlace mode
;due to the missing dot on scanline 240 odd frames,
;the dma counter toggles between 0 and 4 at the start
;of every even frame. the dma counter at V=0,HC=0 is
;what is used to determine when HDMA init begins, so
;it is necessary to know what value the dma counter is
;to test OPHCT against hardware.
;this test just uses the different results from performing
;a standard DMA transfer to determine what the dma counter
;was at the start of the frame.
;this must be called immediately after jsl seek_frame
get_dma_counter() {
  nop
  stz $4300
  lda #$ff : sta $4301
  stz $4302
  stz $4303
  stz $4304
  lda #$01 : sta $4305
  stz $4306
  lda #$01 : sta $420b
  lda $2137
  lda $213c
  cmp #$65 : beq +
;else, a=#$67
  lda #$04 : rts
+ lda #$00 : rts
}
