; Checks if some combination of H/V-IRQs fire at all

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

macro checkirq(a,b,c,d)
  jsl seek_frame
- bit $4212 : bvc -
- bit $4212 : bvs -
  nop #2
  stz $4200
  lda.b <a> : sta $4200
  nop #2
  stz $4200
  lda.b <b> : sta $4200
  nop #2
  stz $4200
  lda.b <c> : sta $4200
  nop #2
  stz $4200
  lda.b <d> : sta $4200
  nop #2
  stz $4200
  lda #$FF : sta $2180
endmacro

org $00f800
irq_vector:
  pha
  lda $4211
  pla
  sta $2180
  rti

org $008000
  incsrc libinit.asm
  sep #$20
  rep #$10

  ldx #$0000
  lda #$00
- sta $7F0000,X
  inx : cpx #$8000 : bcc -
  lda #$00 : sta $2181
  lda #$00 : sta $2182
  lda #$7F : sta $2183

  cli

; check if H/V-IRQs fire
  ldx #$0000 : stx $4207 ; H
  ldx #$0001 : stx $4209 ; V
  %checkirq(#$00,#$00,#$00,#$00)
  %checkirq(#$00,#$10,#$00,#$10)
  %checkirq(#$00,#$20,#$00,#$20)
  %checkirq(#$00,#$30,#$00,#$30)
  %checkirq(#$10,#$10,#$10,#$10)
  %checkirq(#$10,#$20,#$10,#$20)
  %checkirq(#$10,#$30,#$10,#$30)
  %checkirq(#$20,#$20,#$20,#$20)
  %checkirq(#$20,#$30,#$20,#$30)
  %checkirq(#$30,#$30,#$30,#$30)

  ldx #$0152 : stx $4207 ; H
  ldx #$0001 : stx $4209 ; V
  %checkirq(#$00,#$00,#$00,#$00)
  %checkirq(#$00,#$10,#$00,#$10)
  %checkirq(#$00,#$20,#$00,#$20)
  %checkirq(#$00,#$30,#$00,#$30)
  %checkirq(#$10,#$10,#$10,#$10)
  %checkirq(#$10,#$20,#$10,#$20)
  %checkirq(#$10,#$30,#$10,#$30)
  %checkirq(#$20,#$20,#$20,#$20)
  %checkirq(#$20,#$30,#$20,#$30)
  %checkirq(#$30,#$30,#$30,#$30)

  ldx #$0000
- lda $7F0000,X : sta $700000,X
  inx : cpx #$0800 : bcc -

  ldx #$0000
- lda $7F0000,X
  cmp check,X : bne +
  inx  : cpx #$0028 : bcc -

  jmp pass
+ jmp fail

check:
  db #$FF
  db #$FF
  db #$20, #$20, #$FF
  db #$FF
  db #$FF
  db #$20, #$20, #$FF
  db #$FF
  db #$20, #$20, #$20, #$20, #$FF
  db #$20, #$20, #$FF
  db #$FF

  db #$FF
  db #$FF
  db #$20, #$20, #$FF
  db #$FF
  db #$FF
  db #$20, #$20, #$FF
  db #$FF
  db #$20, #$20, #$20, #$20, #$FF
  db #$20, #$20, #$FF
  db #$FF

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
