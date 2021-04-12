; Seems to be some other timing tests.
; Some code is uploaded to the smp to make the comm ports always return #$18

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

org $00f800
irq_vector:
  lda $4211
  lda $213C : sta $2180
  lda $213C : and #$01 : sta $2180
  lda $213D : sta $2180
  lda $213D : and #$01 : sta $2180
  lda #$FF : sta $4201
  nop : nop
  lda $2137
  lda $213C : sta $2180
  lda $213C : and #$01 : sta $2180
  lda $213D : sta $2180
  lda $213D : and #$01 : sta $2180
  lda $2137
  lda $213C : sta $2180
  lda $213C : and #$01 : sta $2180
  lda $213D : sta $2180
  lda $213D : and #$01 : sta $2180
  stz $4200
  pla : pla : pla : pla
  cli
  ldx #$01FF : txs
  jmp [$0000]

org $008000
  incsrc libinit.asm

  sep #$20
  rep #$10
  jsr smp_return_0x18

  ldx #$0000
  lda #$00
- sta $7F0000,X
  inx : cpx #$8000 : bcc -
  lda #$00 : sta $2181
  lda #$00 : sta $2182
  lda #$7F : sta $2183

  cli

test1:
  lda.b #test1_check>>0 : sta $00
  lda.b #test1_check>>8 : sta $01
  lda.b #test1_check>>16 : sta $02
  jsl seek_frame
  lda $2137
  lda #$01 : sta $4209
  stz $420A
  lda #$20 : sta $4200
  nop #$54
  jmp $2137

test1_check:
  lda $7F0000
  cmp #$07 : beq +
  jmp fail
+ lda $7F0001
  cmp #$00 : beq +
  jmp fail
+ lda $7F0002
  cmp #$01 : beq +
  jmp fail
+ lda $7F0003
  cmp #$00 : beq +
  jmp fail
+ lda $7F0004
  cmp #$7A : beq +
  jmp fail
+ lda $7F0008
  cmp #$D0 : beq test2
  jmp fail

test2:
  lda.b #test2_check>>0 : sta $00
  lda.b #test2_check>>8 : sta $01
  lda.b #test2_check>>16 : sta $02
  jsl seek_frame
  lda $2137
  lda #$01 : sta $4209
  stz $420A
  lda #$20 : sta $4200
  nop #$54
  jmp $2136

test2_check:
  lda $7F000C
  cmp #$06 : beq +
  jmp fail
+ lda $7F000D
  cmp #$00 : beq +
  jmp fail
+ lda $7F000E
  cmp #$00 : beq +
  jmp fail
+ lda $7F000F
  cmp #$00 : beq +
  jmp fail
+ lda $7F0010
  cmp #$7A : beq +
  jmp fail
+ lda $7F0014
  cmp #$D0 : beq test3
  jmp fail

test3:
  lda.b #test3_check>>0 : sta $00
  lda.b #test3_check>>8 : sta $01
  lda.b #test3_check>>16 : sta $02
  jsl seek_frame
  lda $2137
  lda #$01 : sta $4209
  stz $420A
  lda #$20 : sta $4200
  nop #$54
  lda $2137

test3_check:
  lda $7F0018
  cmp #$07 : beq +
  jmp fail
+ lda $7F0019
  cmp #$00 : beq +
  jmp fail
+ lda $7F001A
  cmp #$01 : beq +
  jmp fail
+ lda $7F001B
  cmp #$00 : beq +
  jmp fail
+ lda $7F001C
  cmp #$7C : beq +
  jmp fail
+ lda $7F0020
  cmp #$D2 : beq test4
  jmp fail

test4:
  lda.b #test4_check>>0 : sta $00
  lda.b #test4_check>>8 : sta $01
  lda.b #test4_check>>16 : sta $02
  jsl seek_frame
  lda $2137
  ldx #$4203 : txs 
  lda #$01 : sta $4209
  stz $420A
  lda #$20 : sta $4200
  nop #$50
  jmp $000000

test4_check:
  lda $7F0024
  cmp #$10 : beq +
  jmp fail
+ lda $7F0025
  cmp #$00 : beq +
  jmp fail
+ lda $7F0026
  cmp #$01 : beq +
  jmp fail
+ lda $7F0027
  cmp #$00 : beq +
  jmp fail
+ lda $7F0028
  cmp #$7A : beq +
  jmp fail
+ lda $7F002C
  cmp #$D0 : beq test5
  jmp fail

test5:
  lda.b #test5_check>>0 : sta $00
  lda.b #test5_check>>8 : sta $01
  lda.b #test5_check>>16 : sta $02
  jsl seek_frame
  lda $2137
  lda #$01 : sta $4209
  stz $420A
  lda #$20 : sta $4200
  nop #$53
  jmp $217F

test5_check:
  lda $7F0030
  cmp #$00 : beq +
  jmp fail
+ lda $7F0031
  cmp #$00 : beq +
  jmp fail
+ lda $7F0032
  cmp #$06 : beq +
  jmp fail
+ lda $7F0033
  cmp #$00 : beq +
  jmp fail
+ lda $7F0034
  cmp #$00 : beq +
  jmp fail
+ lda $7F0035
  cmp #$00 : beq +
  jmp fail
+ lda $7F0036
  cmp #$7A : beq +
  jmp fail
+ lda $7F003A
  cmp #$CF : beq pass
  jmp fail

org $008499
pass() {
  sei
  sep #$20
  stz $4200
  stz $2121
  lda #$00 : sta $2122
  lda #$7c : sta $2122
  lda #$0f : sta $2100
  ldx #$0000
- lda $7F0000,X : sta $700000,X
  inx : cpx #$0800 : bcc -
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
  ldx #$0000
- lda $7F0000,X : sta $700000,X
  inx : cpx #$0800 : bcc -
  stp
}

smp_return_0x18:
- ldx $2140 : cpx #$BBAA : bne -
  ldx #$0800 : stx $2142
  ldx #$01CC : stx $2140
- lda $2140 : cmp #$CC : bne -

  ldx #$0000
--
  lda smp,X : sta $2141
  txa  : sta $00 : sta $2140
- lda $2140 : cmp $00 : bne -
  inx : cpx #$000E : bne --

  rep #$20
  txa : inc : and #$00FF
  ldx #$0800 : stx $2142
  sta $2140
  sep #$20
  nop #64
  rts
smp:
db #$8F, #$18, #$F4; mov $f4, #$18
db #$8F, #$18, #$F5; mov $f5, #$18
db #$8F, #$18, #$F6; mov $f6, #$18
db #$8F, #$18, #$F7; mov $f7, #$18
db #$2F, #$F2;       bra smp
