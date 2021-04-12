; Doesn't really test anything, it just dumps some irq trigger points to sram

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

org $00f800
irq_vector:
  lda $4211
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
 
  lda #$20 : sta $00
--
  jsl seek_frame
  lda #$FF : sta $4209
             stz $420A ; V=#$FF
  lda #$20 : sta $4200 ; V-IRQ
  lda $00 : sta $4209
            stz $420A ; V=#$20 to #$2F
- nop 
  bit $4212 : bpl -
- bit $4212 : bmi -
  stz $4200 ; disable V-IRQ
  lda $00 : inc : sta $00
  cmp #$30 : bcs +
  jmp --
+ ldx #$0000
- lda $7F0000,X : sta $700000,X
  inx : cpx #$0800 : bcc -
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
