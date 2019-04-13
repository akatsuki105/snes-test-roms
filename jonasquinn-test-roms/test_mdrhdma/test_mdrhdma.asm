lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

org $008000
  incsrc libinit.asm

  stz $420c

  lda #$00 : sta $4300
  lda #$ff : sta $4301
  lda #$00 : sta $4302
  lda #$00 : sta $4303
  lda #$7f : sta $4304
  lda #$00 : sta $4308
  lda #$00 : sta $4309
  lda #$ff : sta $430a

  lda #$ff
  sta $7f0000
  sta $7f0001
  sta $7f0002
  sta $7f0003
  sta $7f0004
  sta $7f0005
  sta $7f0006
  sta $7f0007

  jsl seek_frame
- lda $4212 : bpl -
  lda #$01 : sta $420c
- lda $4212 : bmi -

  ldx #$0000
  rep #$20
- lda $21fc : sta $700000,x : inx : inx
  cmp #$2121 : beq -
  lda #$aaaa : sta $700000,x

  sep #$20
  stz $2121
  lda #$00 : sta $2122
  lda #$7c : sta $2122
  lda #$0f : sta $2100
- bra -
