arch snes.cpu; lorom

org $8000; fill $20000
org $ffc0; db "MATH TIMING TEST     "
org $ffd5; db $30
org $ffd6; db $02
org $ffd7; db $07
org $ffd8; db $05
org $ffdc; dw $5555,$aaaa
org $fffc; dw $8000

org $8000

main:
  clc; xce
  rep #$10
  ldx #$01ff; txs

  pea $4200; pld
  ldx #$0000

  lda #$ff; sta $0000
  lda #$01; sta $0001
  jsr multiply

  lda #$55; sta $0000
  lda #$07; sta $0001
  jsr multiply

  lda #$55; sta $0000
  lda #$aa; sta $0001
  jsr multiply

  lda #$00; sta $0000
  lda #$00; sta $0001
  jsr multiply

  lda #$ff; sta $0000
  lda #$ff; sta $0001
  lda #$01; sta $0002
  jsr divide

  lda #$55; sta $0000
  lda #$aa; sta $0001
  lda #$07; sta $0003
  jsr divide

  lda #$55; sta $0000
  lda #$55; sta $0001
  lda #$aa; sta $0002
  jsr divide

  lda #$55; sta $0000
  lda #$55; sta $0001
  lda #$00; sta $0002
  jsr divide

  jmp finish

multiply:
  //2 cycles
  lda $0000; sta $4202; lda $0001; sta $4203; lda $16; sta $700000,x; inx
  lda $0000; sta $4202; lda $0001; sta $4203; lda $17; sta $700000,x; inx

  //3 cycles
  lda $0000; sta $4202; lda $0001; sta $4203; lda $4216; sta $700000,x; inx
  lda $0000; sta $4202; lda $0001; sta $4203; lda $4217; sta $700000,x; inx

  //4 cycles
  lda $0000; sta $4202; lda $0001; sta $4203; nop; lda $16; sta $700000,x; inx
  lda $0000; sta $4202; lda $0001; sta $4203; nop; lda $17; sta $700000,x; inx

  //5 cycles
  lda $0000; sta $4202; lda $0001; sta $4203; nop; lda $4216; sta $700000,x; inx
  lda $0000; sta $4202; lda $0001; sta $4203; nop; lda $4217; sta $700000,x; inx

  //6 cycles
  lda $0000; sta $4202; lda $0001; sta $4203; nop #2; lda $16; sta $700000,x; inx
  lda $0000; sta $4202; lda $0001; sta $4203; nop #2; lda $17; sta $700000,x; inx

  //7 cycles
  lda $0000; sta $4202; lda $0001; sta $4203; nop #2; lda $4216; sta $700000,x; inx
  lda $0000; sta $4202; lda $0001; sta $4203; nop #2; lda $4217; sta $700000,x; inx

  //8 cycles
  lda $0000; sta $4202; lda $0001; sta $4203; nop #3; lda $16; sta $700000,x; inx
  lda $0000; sta $4202; lda $0001; sta $4203; nop #3; lda $17; sta $700000,x; inx

  //padding
  lda #$00
  sta $700000,x; inx
  sta $700000,x; inx

  rts

divide:
  //2 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; lda $14; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; lda $15; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; lda $16; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; lda $17; sta $700000,x; inx

  //3 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; lda $4214; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; lda $4215; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; lda $4216; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; lda $4217; sta $700000,x; inx

  //4 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop; lda $14; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop; lda $15; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop; lda $16; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop; lda $17; sta $700000,x; inx

  //5 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop; lda $4214; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop; lda $4215; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop; lda $4216; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop; lda $4217; sta $700000,x; inx

  //6 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #2; lda $14; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #2; lda $15; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #2; lda $16; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #2; lda $17; sta $700000,x; inx

  //7 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #2; lda $4214; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #2; lda $4215; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #2; lda $4216; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #2; lda $4217; sta $700000,x; inx

  //8 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #3; lda $14; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #3; lda $15; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #3; lda $16; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #3; lda $17; sta $700000,x; inx

  //9 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #3; lda $4214; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #3; lda $4215; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #3; lda $4216; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #3; lda $4217; sta $700000,x; inx

  //10 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #4; lda $14; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #4; lda $15; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #4; lda $16; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #4; lda $17; sta $700000,x; inx

  //11 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #4; lda $4214; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #4; lda $4215; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #4; lda $4216; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #4; lda $4217; sta $700000,x; inx

  //12 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #5; lda $14; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #5; lda $15; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #5; lda $16; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #5; lda $17; sta $700000,x; inx

  //13 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #5; lda $4214; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #5; lda $4215; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #5; lda $4216; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #5; lda $4217; sta $700000,x; inx

  //14 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #6; lda $14; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #6; lda $15; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #6; lda $16; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #6; lda $17; sta $700000,x; inx

  //15 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #6; lda $4214; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #6; lda $4215; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #6; lda $4216; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #6; lda $4217; sta $700000,x; inx

  //16 cycles
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #7; lda $14; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #7; lda $15; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #7; lda $16; sta $700000,x; inx
  lda $0000; sta $4204; lda $0001; sta $4205; lda $0002; sta $4206; nop #7; lda $17; sta $700000,x; inx

  //padding
  lda #$00
  sta $700000,x; inx
  sta $700000,x; inx
  sta $700000,x; inx
  sta $700000,x; inx

  rts

finish:
  stz $2121
  lda #$00; sta $2122
  lda #$7c; sta $2122
  lda #$0f; sta $2100
  stp
