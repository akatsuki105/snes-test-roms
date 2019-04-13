;nmi timing test v1.0 ~byuu
lorom

org $008000 : fill $020000

org $ffc0
  db 'NMI TIMING TEST ROM  '
  db $30   ;lorom ($31 = hirom)
  db $02   ;rom+save ram
  db $08   ;2mbit rom
  db $02   ;4kb sram
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

org $8c00
  pha
  lda $2137
  lda $213c : xba
  lda $213c : and #$01 : xba
  rep #$20
  ora #$8000
  sta $700000,x
  sep #$20
  inx : inx
  lda $213d : xba
  lda $213d : and #$01 : xba
  rep #$20
  sta $700000,x
  sep #$20
  inx : inx
  cpx #$1000 : bcc +
  jmp endtest
+ pla
  rti

org $8000
  clc : xce
  rep #$10
  ldx #$01ff : txs
  ldx #$0000

  lda #$80 : sta $4200

loop:
- lda $4210 : bpl -
  lda $2137
  lda $213c : xba
  lda $213c : and #$01 : xba
  rep #$20
  sta $700000,x
  sep #$20
  inx : inx
  lda $213d : xba
  lda $213d : and #$01 : xba
  rep #$20
  sta $700000,x
  sep #$20
  inx : inx
  cpx #$1000 : bcc +
  jmp endtest
+ jmp loop

endtest:
  lda #$00 : sta $4200
  stz $2105 : stz $212c : stz $212d
  lda #$00 : sta $2121

  ldx #$0000
- lda $018000,x
  cmp $700000,x
  bne .fail
  inx : cpx #$1000 : bcc -
  lda #$00 : sta $2122
  lda #$7c : sta $2122
  jmp .end
.fail
  lda #$1f : sta $2122
  lda #$00 : sta $2122
.end
  lda #$0f : sta $2100
- bra -

org $018000
;log of results captured from real hardware
  incbin nmi_data.bin
