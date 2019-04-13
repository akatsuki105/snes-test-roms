lorom : header

org $008000 : fill $020000

org $ffc0
  db 'IRQ TEST ROM         '
  db $30   ;lorom ($31 = hirom)
  db $02   ;rom+save ram
  db $08   ;2mbit rom
  db $03   ;64kb sram
  db $00   ;japan
  db $00   ;no developer
  db $01   ;version 1.1
  dw $0000 ;inverse checksum
  dw $ffff ;checksum

  dw $ffff,$ffff,$ffff
  dw $ffff ;brk
  dw $ffff
  dw $8c00 ;nmi
  dw $ffff
  dw $8800 ;irq
  dw $ffff,$ffff
  dw $ffff ;cop
  dw $ffff,$ffff,$ffff
  dw $8000 ;reset
  dw $ffff

!irq_vector  = $1000
!test_number = $700000

org $8800
  jmp [!irq_vector]

org $8000
  clc : xce
  rep #$10
  ldx #$01ff : txs

  sei : stz $4200
  ldx #$0000 : stx $4207 : stx $4209

  stz !irq_vector
  stz !irq_vector+1
  stz !irq_vector+2

  stz $2105
  stz $212c
  stz $212d
  lda #$8f : sta $2100

  lda #$01 : sta !test_number : jsr test1
  lda #$02 : sta !test_number : jsr test2
  lda #$03 : sta !test_number : jsr test3
  lda #$04 : sta !test_number : jsr test4
  lda #$05 : sta !test_number : jsr test5
  lda #$06 : sta !test_number : jsr test6

  stz $2121
  lda #$00 : sta $2122
  lda #$7c : sta $2122
  lda #$0f : sta $2100
- bra -

fail:
  sep #$20
  stz $4200
  sei
  stz $2121
  lda #$1f : sta $2122
  lda #$00 : sta $2122
  lda #$0f : sta $2100
- bra -

wait_for_frame:
- lda $4212 : bpl -
- lda $4212 : bmi -
  rts

wait_for_vblank:
- lda $4212 : bmi -
- lda $4212 : bpl -
  rts

wait_for_scanline:
- lda $4212 : bit #$40 : beq -
- lda $4212 : bit #$40 : bne -
  rts

get_vcounter:
  lda $2137
  lda $213d : xba : lda $213d : and #$01 : xba
  rep #$20 : tax : sep #$20
  rts

get_hcounter:
  lda $2137
  lda $213c : xba : lda $213c : and #$01 : xba
  rep #$20 : tax : sep #$20
  rts

;*** test 1 ***
;test $4211 value at reset, should be clear
;test $4211 value at start of next frame, should be clear
test1:
  lda $4211 : bpl +
  jsr fail
+ jsr wait_for_frame
  lda $4211 : bpl +
  jsr fail
+ rts

;*** test 2 ***
;test $4211 readability with IRQs disabled ***
;test to see if $4211 is still set after an entire frame has passed
;test $4207-$4209 writes. writing ANY value to these registers should
;not clear $4211.
;test $4200 writes. writing (n & #$30) == #$00 should clear $4211,
;writing (n & #$30) != #$00 should not clear $4211.
test2:
  jsr wait_for_frame     ;V=0

  ldx #$0004 : stx $4209 ;VIRQ=4
  lda #$20   : sta $4200 ;VIRQ enable

- lda $4211 : bpl -      ;V=4
  jsr get_vcounter
  cpx #$0004 : beq +
  jmp fail

+ ldx #$0008 : stx $4209 ;VIRQ=8
- lda $4211 : bpl -      ;V=8
  jsr get_vcounter
  cpx #$0008 : beq +
  jmp fail

+ ldx #$0010 : stx $4209 ;VIRQ=16
  jsr wait_for_frame     ;V=0 (V passes through 16 first)
  lda $4211 : bmi +
  jmp fail

+ jsr wait_for_frame     ;V=0,     $4211 should now be set...
  ldx #$0010 : stx $4209 ;VIRQ=16, wrote same value to VIRQPOS again, should *not* clear $4211
  lda $4211 : bmi +
  jmp fail

+ jsr wait_for_frame     ;V=0,     $4211 should now be set...
  ldx #$0011 : stx $4209 ;VIRQ=17, wrote NEW value to VIRQPOS, should *not* clear $4211
  lda $4211 : bmi +
  jmp fail

+ jsr wait_for_frame     ;V=0, $4211 should now be set...
  lda #$20 : sta $4200   ;     $4211 should still be set...
  lda $4211 : bmi +
  jmp fail

+ jsr wait_for_frame     ;V=0, $4211 should now be set...
  stz $4200              ;     $4211 should now be CLEAR...
  lda $4211 : bpl +
  jmp fail

+ rts

;*** test 3 ***
;test basic IRQ triggering
;test $4207-$420a writes, when written, IRQ should trigger
;again, even if on the same scanline
;ex: VIRQ=#$0020, VIRQ enabled only.
;scanline hits $20, calls IRQ handler, returns, write $20 to
;$4209, IRQ should trigger again since scanline is still $20
irq_test3:
  inc $00
  lda $4211
  rti

test3:
  ldx.w #irq_test3 : stx !irq_vector
  jsr wait_for_frame
  ldx #$0020 : stx $4209
  lda #$20   : sta $4200
  stz $00
  cli
- lda $00 : beq -
  jsr get_vcounter
  cpx #$0020 : beq +
  jmp fail
+ stz $00
- lda $00 : beq -
  ldx #$0020 : stx $4209
;IRQ should *not* trigger again here...
  nop #8
  lda $00 : cmp #$01 : beq +
  jmp fail
+ stz $00
- lda $00 : beq -
  ldx #$0021 : stx $4209
  jsr wait_for_scanline
;IRQ should trigger again here...
  nop #8
  lda $00 : cmp #$02 : beq +
  jmp fail
+ sei : stz $4200
  rts

;*** test 4 ***
;test refiring when $4211 is not cleared. IRQs should refire instantly, never
;giving any time back to original routine.
irq_test4:
  inc $00
  lda $00 : cmp #$ff : bne +
  stz $4200
+ rti

test4:
  ldx.w #irq_test4 : stx !irq_vector
  stz $00
  jsr wait_for_frame
  ldx #$0020 : stx $4209
  lda #$20   : sta $4200
  cli
- lda $00 : beq -
  stz $4200
;if value < #$ff, then the loop code above was given a small amount of time
;to run between IRQ triggers... this is not supposed to happen.
  lda $00 : cmp #$ff : beq +
  jmp fail
+ rts

;*** test 5 ***
;see if WAI will break when an actual IRQ doesn't trigger
;see if /IRQ is raised during last cycle of current opcode,
;and not first cycle of next opcode
;exploits SNES pipeline issues...
;also go ahead and test all of the special case opcodes,
;namely, cli, sei, plp, rep #$04, and sep #$04
;thanks to anomie for initial research of this
irq_test5:
  stz $4200
  cmp #$02 : beq +
  jmp fail
+ rti

irq_test5a:
  stz $4200
  rep #$20
  lda $02,s : tax
  sep #$20
  dex #2
  lda $0000,x
;should be a plp here...
  cmp #$28 : beq +
  jmp fail
+ rti

irq_test5b:
  stz $4200
  jmp fail

irq_test5c:
  stz $4200
  cmp #$01 : beq +
  jmp fail
+ rti

test5:
  sei
  jsr wait_for_frame
  ldx.w #irq_test5 : stx !irq_vector
  ldx #$0020 : stx $4209
  lda #$20   : sta $4200
  wai
;simply reaching this point indicates that the test passed...
;now let's try another test
  lda #$01
  cli
  lda #$02
  lda #$03
  nop #8
;let's try that with another opcode now...
  jsr wait_for_frame
  sei
  lda #$20 : sta $4200
  wai
  lda #$01
  rep #$04
  lda #$02
  lda #$03
  nop #8
;still working? hmm... how about plp?
  jsr wait_for_frame
  sei
  ldx.w #irq_test5a : stx !irq_vector
  lda #$20 : sta $4200
  wai
  php
  pla
  and #$fb ;~#$04
  pha
  plp
  nop
;IRQ should fire here...
  nop #8
;ok... a harder test, then
  jsr wait_for_frame
  sei
  ldx.w #irq_test5b : stx !irq_vector
  lda #$20 : sta $4200
  wai
;simulate an /IRQ
  lda #$00 : pha
  ldx.w #.l0 : phx
  php ;I is set in P at this moment...
;clearing I may be the last cycle of cli...
  cli
;but setting P (and thusly setting I)
;isn't the last cycle of rti...
  rti
;therefore, no interrupt should ever fire
.l0
;ok, one last test...
  jsr wait_for_frame
  sei
  ldx.w #irq_test5c : stx !irq_vector
  lda #$20 : sta $4200
  wai
;simulate an /IRQ
print pc
  lda #$00 : pha
  ldx.w #.l1 : phx
;make sure I is clear for this...
  php : pla : and #$fb : pha
  lda #$01
  rti
.l1
  lda #$02
  rts

;*** test 6 ***
;test unlatchable positions:
;V=240,H=339,I=0,IF=1
;V=261,H=339,I=0
;V=262,I=0
;H=340
;V=263,I=1
;V=262,I=1,IF=1
;test latchable positions:
;V=240,H=339,I=1,IF=1
;V=262,I=1
;H=339
;V=261,I=0
test6:
  sei
;get to an odd frame
- lda $213f : bmi -
- lda $213f : bpl -
  ldx.w #240 : stx $4209
  ldx.w #339 : stx $4207
  lda #$30   : sta $4200
  lda $4211
  jsr wait_for_frame
  lda $4211 : bpl +
  jmp fail
+ ldx.w #261 : stx $4209
  ldx.w #339 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bpl +
  jmp fail
+ ldx.w #262 : stx $4209
  ldx.w   #0 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bpl +
  jmp fail
+ ldx.w  #20 : stx $4209
  ldx.w #340 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bpl +
  jmp fail
+ lda #$01 : sta $2133
  jsr wait_for_frame
  jsr wait_for_frame
  ldx.w #263 : stx $4209
  ldx.w   #0 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bpl +
  jmp fail
+
;get to an odd frame
- lda $213f : bmi -
- lda $213f : bpl -
  ldx.w #262 : stx $4209
  ldx.w   #0 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bpl +
  jmp fail
+
;get to an odd frame
- lda $213f : bmi -
- lda $213f : bpl -
  ldx.w #240 : stx $4209
  ldx.w #339 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bmi +
  jmp fail
+
;get to an even frame
- lda $213f : bpl -
- lda $213f : bmi -
  ldx.w #262 : stx $4209
  ldx.w   #0 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bmi +
  jmp fail
+ lda #$00 : sta $2133
  jsr wait_for_frame
  jsr wait_for_frame
  ldx.w  #20 : stx $4209
  ldx.w #339 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bmi +
  jmp fail
+ ldx.w #261 : stx $4209
  ldx.w   #0 : stx $4207
  lda $4211
  jsr wait_for_frame
  lda $4211 : bmi +
  jmp fail
+ rts
