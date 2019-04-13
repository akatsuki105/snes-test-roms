;test_irq
;version 1.0 ~byuu (10/01/05)
;test when IRQ trigger occurs:
;V=VTIME,H=(HTIME)?(HTIME*4+18):(14)
;test when $4211.d7 is set:
;V=VTIME,H=(HTIME)?(HTIME*4+14):(10)
;verify that reading $4211.d7 immediately at above position,
;or two clock cycles after (HC+0,HC+2), will leave $4211.d7
;set -- whereas reading any later will clear $4211.d7.
;verify the latest a $4200 write can prevent an IRQ from
;firing is when HC is less than the IRQ trigger position.
;if they are equal or above, the IRQ still triggers.

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

!irq_vector  = $0080
!test_number = $700000

org $00f800
  jmp [!irq_vector]

;basic interrupt
irq_vector1() {
  pha : lda $4211 : pla
  rti
}

;latch timing interrupt
irq_vector2() {
  pha : lda $4211 : lda $2137 : pla
  rti
}

;trigger verification interrupt
irq_vector3() {
  pha : lda $4211 : pla
  inc $00
  rti
}

;trigger point verification interrupt
irq_vector4() {
  pha : phy
  lda $4211
  ldy #$0000
  lda ($05,s),y
  sta $00
  ply : pla : rti
}

!irq_test_init        = "lda !test_number : inc : sta !test_number : lda $4211 : jsl seek_frame : lda #$20 : sta $4200 : cli : rep #$20 : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles"
!irq_test_init_sei    = "lda !test_number : inc : sta !test_number : lda $4211 : jsl seek_frame : lda #$20 : sta $4200 : sei : rep #$20 : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles"
!irq_test_init_hv     = "lda !test_number : inc : sta !test_number : lda $4211 : jsl seek_frame : lda #$30 : sta $4200 : cli : rep #$20 : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles"
!irq_test_init_hv_sei = "lda !test_number : inc : sta !test_number : lda $4211 : jsl seek_frame : lda #$30 : sta $4200 : sei : rep #$20 : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles"

org $008000
  incsrc libinit.asm

  stz !irq_vector+2

  lda.b #0 : sta !test_number
  ldx.w #0 : stx $4207
  ldx.w #225 : stx $4209

;*** test 1 ***
;sec
;[1] V=224,HC=   4 <8>
;[2] V=225,HC=  12 <6>
test1() {
  ldx.w #irq_vector4 : stx !irq_vector
  !irq_test_init
  lda.w #35226 : jsl seek_cycles

  sep #$20
  sec : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ sei : stz $4200
}

;*** test 2 ***
;sec
;[1] V=224,HC=   6 <8>
;[2] V=225,HC=  14 <6>
test2() {
  !irq_test_init
  lda.w #35228 : jsl seek_cycles

  sep #$20
  sec : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ sei : stz $4200
}

;*** test 3 ***
;sec
;[1] V=224,HC=  12 <8>
;[2] V=225,HC=  20 <6>
test3() {
  ldx.w #1 : stx $4207
  !irq_test_init_hv
  lda.w #35234 : jsl seek_cycles

  sep #$20
  sec : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ sei : stz $4200
}

;*** test 4 ***
;sec
;[1] V=224,HC=  14 <8>
;[2] V=225,HC=  22 <6>
test4() {
  !irq_test_init_hv
  lda.w #35236 : jsl seek_cycles

  sep #$20
  sec : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ sei : stz $4200
  ldx.w #0 : stx $4207
}

;*** test 5 ***
;lda $4211
;[1] V=224,HC=1346 <8>
;[2] V=224,HC=1354 <8>
;[3] V=224,HC=1362 <8>
;[4] V=224,HC=   6 <6>
test5() {
  !irq_test_init_sei
  lda.w #35204 : jsl seek_cycles

  sep #$20
  lda $4211 : sta $00
  lda $4211 : sta $02

  lda $00 : bpl +
  jmp fail
+ lda $02 : bmi +
  jmp fail
+ sei : stz $4200
}

;*** test 6 ***
;lda $4211
;[1] V=224,HC=1348 <8>
;[2] V=224,HC=1356 <8>
;[3] V=224,HC=   0 <8>
;[4] V=224,HC=   8 <6>
test6() {
  !irq_test_init_sei
  lda.w #35206 : jsl seek_cycles

  sep #$20
  lda $4211 : sta $00
  lda $4211 : sta $02

  lda $00 : bmi +
  jmp fail
+ lda $02 : bmi +
  jmp fail
+ sei : stz $4200
}

;*** test 7 ***
;lda $4211
;[1] V=224,HC=1350 <8>
;[2] V=224,HC=1358 <8>
;[3] V=224,HC=   2 <8>
;[4] V=224,HC=  10 <6>
test7() {
  !irq_test_init_sei
  lda.w #35208 : jsl seek_cycles

  sep #$20
  lda $4211 : sta $00
  lda $4211 : sta $02

  lda $00 : bmi +
  jmp fail
+ lda $02 : bmi +
  jmp fail
+ sei : stz $4200
}

;*** test 8 ***
;lda $4211
;[1] V=224,HC=1352 <8>
;[2] V=224,HC=1360 <8>
;[3] V=224,HC=   4 <8>
;[4] V=224,HC=  12 <6>
test8() {
  !irq_test_init_sei
  lda.w #35210 : jsl seek_cycles

  sep #$20
  lda $4211 : sta $00
  lda $4211 : sta $02

  lda $00 : bmi +
  jmp fail
+ lda $02 : bpl +
  jmp fail
+ sei : stz $4200
}

;*** test 9 ***
;stz $4200
;[1] V=224,HC=1352 <8>
;[2] V=224,HC=1360 <8>
;[3] V=224,HC=   4 <8>
;[4] V=224,HC=  12 <6>
test9() {
  ldx.w #irq_vector3 : stx !irq_vector
  stz $00
  !irq_test_init
  lda.w #35210 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : beq +
  jmp fail
+ sei : stz $4200
}

;*** test 10 ***
;stz $4200
;[1] V=224,HC=1354 <8>
;[2] V=224,HC=1362 <8>
;[3] V=224,HC=   6 <8>
;[4] V=224,HC=  14 <6>
test10() {
  stz $00
  !irq_test_init
  lda.w #35212 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : cmp #$01 : beq +
  jmp fail
+ sei : stz $4200
}

;*** end of tests ***
  lda.b #0 : sta !test_number
  jmp pass

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
