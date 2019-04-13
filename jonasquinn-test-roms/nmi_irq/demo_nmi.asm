lorom : header

org $008000 : fill $020000

org $ffc0
  db 'NMI TEST ROM         '
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

!nmi_vector  = $1000
!test_number = $700000

org $8c00
  jmp [!nmi_vector]

org $8000
  clc : xce
  rep #$10
  ldx #$01ff : txs

  sei : stz $4200

  stz !nmi_vector
  stz !nmi_vector+1
  stz !nmi_vector+2

  stz $2105
  stz $212c
  stz $212d
  lda #$8f : sta $2100

  lda #$01 : sta !test_number : jsr test1
  lda #$02 : sta !test_number : jsr test2
  lda #$03 : sta !test_number : jsr test3
  lda #$04 : sta !test_number : jsr test4

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
;test initial $4210 read at reset
;test $4210 without NMI enabled
;test if $4210 is still set after frame crossed, should not be
test1:
  lda $4210 : bpl +
  jmp fail
+ jsr wait_for_vblank
  lda $4210 : bmi +
  jmp fail
+ lda $4210 : bpl +
  jmp fail
+ jsr wait_for_frame
  lda $4210
  jsr wait_for_frame
  lda $4210 : bpl +
  jmp fail
+ rts

;*** test 2***
;test basic NMI firing
nmi_test2:
  inc $00
  rti

test2:
  ldx.w #nmi_test2 : stx !nmi_vector
  jsr wait_for_frame
  stz $00
  lda #$80 : sta $4200
  jsr wait_for_vblank
  lda $4210 : bmi +
  jmp fail
+ jsr wait_for_scanline
  jsr wait_for_scanline
  jsr wait_for_scanline
  jsr wait_for_scanline
  lda $00 : cmp #$01 : beq +
  jmp fail
+ jsr wait_for_frame
  stz $00
  ldx #$0020
- jsr wait_for_frame
  dex : bne -
  lda $00 : cmp #$20 : beq +
  jmp fail
+ stz $4200 : rts

;*** test 3 ***
;test if NMI still triggers when enabled at line >225, it should
;test if NMI still triggers at start of next frame, it should not
;test if strobing (lowering and raising) $4200 triggers an NMI after vblank, it should
nmi_test3:
  inc $00
  rti

test3:
  ldx.w #nmi_test3 : stx !nmi_vector
  jsr wait_for_frame
  lda $4210
  jsr wait_for_vblank
  jsr wait_for_scanline
  jsr wait_for_scanline
  jsr wait_for_scanline
  stz $00
  lda #$80 : sta $4200
  stz $4200
  lda $00 : bne +
  jmp fail
+ jsr get_vcounter
  cpx.w #228 : beq +
  jmp fail
+ jsr wait_for_frame
  lda $4210
  jsr wait_for_frame
  stz $00
  lda #$80 : sta $4200
  stz $4200
  lda $00 : beq +
  jmp fail
+ stz $00
  jsr wait_for_vblank
  lda #$80 : sta $4200
  stz $4200
  lda #$80 : sta $4200
  stz $4200
  lda $00 : cmp #$02 : beq +
  jmp fail
+ stz $00
  jsr wait_for_vblank
  lda #$80 : sta $4200
  stz $4200
  stz $4200
  stz $4200
  lda $00 : cmp #$01 : beq +
  jmp fail
+ stz $00
  jsr wait_for_vblank
  lda #$80 : sta $4200
  stz $4200
  lda #$80 : sta $4200
  lda #$80 : sta $4200
  lda #$80 : sta $4200
  stz $4200
  lda $00 : cmp #$02 : beq +
  jmp fail
+ stz $00
  jsr wait_for_vblank
  lda #$80 : sta $4200
  lda #$80 : sta $4200
  lda #$80 : sta $4200
  stz $4200
  lda $00 : cmp #$01 : beq +
  jmp fail
+ rts

;*** test 4 ***
;see if reading $4210 will prevent an NMI from firing, it should
;then see if we can get an NMI to fire anyway by strobing $4200
;repeatedly, it should not fire again since $4210 was read...
nmi_test4:
  inc $00
  rti

test4:
  ldx.w #nmi_test4 : stx !nmi_vector
  jsr wait_for_frame
  stz $00
  stz $4200
  jsr wait_for_vblank
  nop #8
  lda $4210
  lda #$80 : sta $4200
  stz $4200
  lda $00 : beq +
  jmp fail
+ stz $00
  lda #$00 : sta $4200
  lda #$80 : sta $4200
  lda #$00 : sta $4200
  lda #$80 : sta $4200
  lda #$00 : sta $4200
  lda #$80 : sta $4200
  lda #$00 : sta $4200
  lda $00 : beq +
  jmp fail
+ rts
