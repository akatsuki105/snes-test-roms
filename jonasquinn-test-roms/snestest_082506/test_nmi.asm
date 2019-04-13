;test_nmi
;version 1.1 ~byuu (07/25/06)
;this test demonstrates that the last cycle check occurs at the first
;clock cycle of the last bus cycle of each opcode. it is the same no
;matter what the next bus cycle is: be it an i/o cycle, or a read / write
;to a fast / slow / xslow memory area.
;it also shows that NMI itself goes low at HC=6, so if the last cycle
;check occurs at HC=4, the NMI won't trigger until after the next opcode,
;but if it occurs at HC=6 or above, the NMI will trigger immediately after
;the current opcode.
;this test also verifies that $4210.d7 is set at HC=2, and that reading
;$4210 at HC=2 or HC=4 will leave $4210.d7 set for the next read as well.
;reading $4210 at HC>=6 will clear it for the next read.
;this test also verifies that the latest you can write to $4200 and clear
;the NMI enable bit and still prevent the interrupt from firing is when
;the $4200 write bus cycle begins at V=224,HC=1362 (+6 hold -> V=225,HC=4).
;any later, and the NMI will still fire. this is because the last_cycle
;logic will test whether NMI is enabled before the last cycle of the opcode,
;before the $4200 write clears the NMI enabled bit.
;[1.1+]
;verify writes to $4200 that enable NMI and cause an NMI to trigger
;(eg $4210 not read, V>=225, $4200.d7=0->1) that end at the exact same time
;NMI is tested (last_cycle event) will not trigger NMI at the end of opcode
;writing to $4200, but on the next opcode after it. eg :
;"lda #$ff80 : sta $4200 : inc $00"
;will trigger NMI after inc $00, and not before it
;this could be due to a delay after enabling NMIs and then firing, or due to
;a race condition as the bus write cycle ends immediately as the last bus cycle
;of the opcode begins.

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

!nmi_vector  = $0080
!test_number = $700000

org $00f000
  jmp [!nmi_vector]

;basic interrupt
nmi_vector1() {
  rti
}

;latch timing interrupt
nmi_vector2() {
  pha : lda $2137 : pla
  rti
}

;trigger verification interrupt
nmi_vector3() {
  inc $00
  rti
}

;trigger point verification interrupt
nmi_vector4() {
  pha : phy
  ldy #$0000
  lda ($05,s),y
  sta $00
  ply : pla : rti
}

!nmi_test_inc  = "stz $4200 : lda !test_number : inc : sta !test_number"
!nmi_test_init = "lda !test_number : inc : sta !test_number : jsl seek_frame : lda #$80 : sta $4200 : rep #$20 : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles : lda #$0000 : jsl seek_cycles"

org $008000
  incsrc libinit.asm

  stz !nmi_vector+2

  lda.b #0 : sta !test_number
  ldx.w #nmi_vector4 : stx !nmi_vector

;******************
; 1, 2: i/o
; 3, 4: read  fast
; 5, 6: read  slow
; 7, 8: read  xslow
; 9,10: write fast
;11,12: write slow
;13,14: write xslow
;15-18: read  $4210
;19-26: write $4200
;******************

;*** test 1 ***
;sec
;[1] V=224,HC=1360 <8>
;[2] V=225,HC=   4 <6>
test1() {
  !nmi_test_init
  lda.w #35232 : jsl seek_cycles

  sep #$20
  sec : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 2 ***
;sec
;[1] V=224,HC=1362 <8>
;[2] V=225,HC=   6 <6>
test2() {
  !nmi_test_init
  lda.w #35234 : jsl seek_cycles

  sep #$20
  sec : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 3 ***
;lda $4212
;[1] V=224,HC=1344 <8>
;[2] V=224,HC=1352 <8>
;[3] V=224,HC=1360 <8>
;[4] V=224,HC=   4 <6>
test3() {
  !nmi_test_init
  lda.w #35216 : jsl seek_cycles

  sep #$20
  lda $4212 : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 4 ***
;lda $4212
;[1] V=224,HC=1346 <8>
;[2] V=224,HC=1354 <8>
;[3] V=224,HC=1362 <8>
;[4] V=224,HC=   6 <6>
test4() {
  !nmi_test_init
  lda.w #35218 : jsl seek_cycles

  sep #$20
  lda $4212 : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 5 ***
;lda $1000
;[1] V=224,HC=1344 <8>
;[2] V=224,HC=1352 <8>
;[3] V=224,HC=1360 <8>
;[4] V=224,HC=   4 <8>
test5() {
  !nmi_test_init
  lda.w #35216 : jsl seek_cycles

  sep #$20
  lda $1000 : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 6 ***
;lda $1000
;[1] V=224,HC=1346 <8>
;[2] V=224,HC=1354 <8>
;[3] V=224,HC=1362 <8>
;[4] V=224,HC=   6 <8>
test6() {
  !nmi_test_init
  lda.w #35218 : jsl seek_cycles

  sep #$20
  lda $1000 : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 7 ***
;lda $4000
;[1] V=224,HC=1344 < 8>
;[2] V=224,HC=1352 < 8>
;[3] V=224,HC=1360 < 8>
;[4] V=224,HC=   4 <12>
test7() {
  !nmi_test_init
  lda.w #35216 : jsl seek_cycles

  sep #$20
  lda $4000 : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 8 ***
;lda $4000
;[1] V=224,HC=1346 < 8>
;[2] V=224,HC=1354 < 8>
;[3] V=224,HC=1362 < 8>
;[4] V=224,HC=   6 <12>
test8() {
  !nmi_test_init
  lda.w #35218 : jsl seek_cycles

  sep #$20
  lda $4000 : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 9 ***
;sta $4212
;[1] V=224,HC=1344 <8>
;[2] V=224,HC=1352 <8>
;[3] V=224,HC=1360 <8>
;[4] V=224,HC=   4 <6>
test9() {
  !nmi_test_init
  lda.w #35216 : jsl seek_cycles

  sep #$20
  sta $4212 : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 10 ***
;sta $4212
;[1] V=224,HC=1346 <8>
;[2] V=224,HC=1354 <8>
;[3] V=224,HC=1362 <8>
;[4] V=224,HC=   6 <6>
test10() {
  !nmi_test_init
  lda.w #35218 : jsl seek_cycles

  sep #$20
  sta $4212 : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 11 ***
;sta $1000
;[1] V=224,HC=1344 <8>
;[2] V=224,HC=1352 <8>
;[3] V=224,HC=1360 <8>
;[4] V=224,HC=   4 <8>
test11() {
  !nmi_test_init
  lda.w #35216 : jsl seek_cycles

  sep #$20
  sta $1000 : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 12 ***
;sta $1000
;[1] V=224,HC=1346 <8>
;[2] V=224,HC=1354 <8>
;[3] V=224,HC=1362 <8>
;[4] V=224,HC=   6 <8>
test12() {
  !nmi_test_init
  lda.w #35218 : jsl seek_cycles

  sep #$20
  sta $1000 : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 13 ***
;sta $4000
;[1] V=224,HC=1344 < 8>
;[2] V=224,HC=1352 < 8>
;[3] V=224,HC=1360 < 8>
;[4] V=224,HC=   4 <12>
test13() {
  !nmi_test_init
  lda.w #35216 : jsl seek_cycles

  sep #$20
  sta $4000 : nop : clc

  lda $00 : cmp #$18 : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 14 ***
;sta $4000
;[1] V=224,HC=1346 < 8>
;[2] V=224,HC=1354 < 8>
;[3] V=224,HC=1362 < 8>
;[4] V=224,HC=   6 <12>
test14() {
  !nmi_test_init
  lda.w #35218 : jsl seek_cycles

  sep #$20
  sta $4000 : nop : clc

  lda $00 : cmp #$ea : beq +
  sta $700001 : jmp fail
+ stz $4200
}

;*** test 15 ***
;lda $4210
;[1] V=224,HC=1338 <8>
;[2] V=224,HC=1346 <8>
;[3] V=224,HC=1354 <8>
;[4] V=224,HC=1362 <6>
test15() {
  ldx.w #nmi_vector1 : stx !nmi_vector
  !nmi_test_init
  lda.w #35210 : jsl seek_cycles

  sep #$20
  lda $4210 : sta $00
  lda $4210 : sta $02

  lda $00 : bpl +
  jmp fail
+ lda $02 : bmi +
  jmp fail
+ stz $4200
}

;*** test 16 ***
;lda $4210
;[1] V=224,HC=1340 <8>
;[2] V=224,HC=1348 <8>
;[3] V=224,HC=1356 <8>
;[4] V=224,HC=   0 <6>
test16() {
  !nmi_test_init
  lda.w #35212 : jsl seek_cycles

  sep #$20
  lda $4210 : sta $00
  lda $4210 : sta $02

  lda $00 : bmi +
  jmp fail
+ lda $02 : bmi +
  jmp fail
+ stz $4200
}

;*** test 17 ***
;lda $4210
;[1] V=224,HC=1342 <8>
;[2] V=224,HC=1350 <8>
;[3] V=224,HC=1358 <8>
;[4] V=224,HC=   2 <6>
test17() {
  !nmi_test_init
  lda.w #35214 : jsl seek_cycles

  sep #$20
  lda $4210 : sta $00
  lda $4210 : sta $02

  lda $00 : bmi +
  jmp fail
+ lda $02 : bmi +
  jmp fail
+ stz $4200
}

;*** test 18 ***
;lda $4210
;[1] V=224,HC=1344 <8>
;[2] V=224,HC=1352 <8>
;[3] V=224,HC=1360 <8>
;[4] V=224,HC=   4 <6>
test18() {
  !nmi_test_init
  lda.w #35216 : jsl seek_cycles

  sep #$20
  lda $4210 : sta $00
  lda $4210 : sta $02

  lda $00 : bmi +
  jmp fail
+ lda $02 : bpl +
  jmp fail
+ stz $4200
}

;*** test 19 ***
;stz $4200
;[1] V=224,HC=1334 <8>
;[2] V=224,HC=1342 <8>
;[3] V=224,HC=1350 <8>
;[4] V=224,HC=1358 <6>
test19() {
  ldx.w #nmi_vector3 : stx !nmi_vector
  stz $00
  !nmi_test_init
  lda.w #35206 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : beq +
  jmp fail
+ lda $4210 : bmi +
  jmp fail
+ stz $4200
}

;*** test 20 ***
;stz $4200
;[1] V=224,HC=1336 <8>
;[2] V=224,HC=1344 <8>
;[3] V=224,HC=1352 <8>
;[4] V=224,HC=1360 <6>
test20() {
  stz $00
  !nmi_test_init
  lda.w #35208 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : beq +
  jmp fail
+ lda $4210 : bmi +
  jmp fail
+ stz $4200
}

;*** test 21 ***
;stz $4200
;[1] V=224,HC=1338 <8>
;[2] V=224,HC=1346 <8>
;[3] V=224,HC=1354 <8>
;[4] V=224,HC=1362 <6>
test21() {
  stz $00
  !nmi_test_init
  lda.w #35210 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : beq +
  jmp fail
+ lda $4210 : bmi +
  jmp fail
+ stz $4200
}

;*** test 22 ***
;stz $4200
;[1] V=224,HC=1340 <8>
;[2] V=224,HC=1348 <8>
;[3] V=224,HC=1356 <8>
;[4] V=225,HC=   0 <6>
test22() {
  stz $00
  !nmi_test_init
  lda.w #35212 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : cmp #$01 : beq +
  jmp fail
+ lda $4210 : bmi +
  jmp fail
+ stz $4200
}

;*** test 23 ***
;stz $4200
;[1] V=224,HC=1342 <8>
;[2] V=224,HC=1350 <8>
;[3] V=224,HC=1358 <8>
;[4] V=225,HC=   2 <6>
test23() {
  stz $00
  !nmi_test_init
  lda.w #35214 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : cmp #$01 : beq +
  jmp fail
+ lda $4210 : bmi +
  jmp fail
+ stz $4200
}

;*** test 24 ***
;stz $4200
;[1] V=224,HC=1344 <8>
;[2] V=224,HC=1352 <8>
;[3] V=224,HC=1360 <8>
;[4] V=225,HC=   4 <6>
test24() {
  stz $00
  !nmi_test_init
  lda.w #35216 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : cmp #$01 : beq +
  jmp fail
+ lda $4210 : bmi +
  jmp fail
+ stz $4200
}

;*** test 25 ***
;stz $4200
;[1] V=224,HC=1346 <8>
;[2] V=224,HC=1354 <8>
;[3] V=224,HC=1362 <8>
;[4] V=225,HC=   6 <6>
test25() {
  stz $00
  !nmi_test_init
  lda.w #35218 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : cmp #$01 : beq +
  jmp fail
+ lda $4210 : bmi +
  jmp fail
+ stz $4200
}

;*** test 26 ***
;stz $4200
;[1] V=224,HC=1348 <8>
;[2] V=224,HC=1356 <8>
;[3] V=225,HC=   0 <8>
;[4] V=225,HC=   8 <6>
test26() {
  stz $00
  !nmi_test_init
  lda.w #35220 : jsl seek_cycles

  sep #$20
  stz $4200
  nop #2

  lda $00 : cmp #$01 : beq +
  jmp fail
+ lda $4210 : bmi +
  jmp fail
+ stz $4200
}

;***
;*** [1.1+] ***
;***

;*** test 27 ***
;this should cause the stx $00 to occur before
;NMI fires due to the edge case explained at the
;top of this source file, thusly the NMI routine
;will increment $00 from 2 to 3.
;if NMI fires after sta $4200, but before stx $00,
;then the stx $00 will set $00 to 2, effectively
;overwriting the NMI routine's inc $00, and will
;cause this test to fail.
;if NMI fails to fire, then $00 will only be set
;to 2, and the test will fail.
test27() {
  !nmi_test_inc
  stz $00
  ldx.w #nmi_vector3 : stx !nmi_vector
- bit $4212 : bpl -
- bit $4212 : bmi -
- bit $4212 : bpl -
- bit $4212 : bmi -
- bit $4212 : bpl -
  rep #$20
  ldx #$0002
  lda #$ff80
  sta $4200
  stx $00
  sep #$20
  lda $00 : cmp #$03 : beq +
  jmp fail
+ stz $4200
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
