arch snes.cpu; lorom

define seek_frame $028000
org $0080c0; jsl main+$800000

main:
  sep #$20; rep #$10
  pea $4200; pld

  lda #$ff; sta $0000
  lda #$01; sta $0001
  ldx #$0000; txy

  //14 cycles
  //w4203: 0, 136
  //r4216: 0, 150

  jsl {seek_frame}
  lda #$01; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  lda $16
  sta $700000,x; inx

  //16 cycles
  //unknown how to step by this amount

  lda #$00
  sta $700000,x; inx

  //18 cycles
  //w4203: 0, 160
  //r4216: 0, 178

  jsl {seek_frame}
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  lda $16
  sta $700000,x; inx

  //20 cycles
  //w4203: 0, 146
  //r4216: 0, 166

  jsl {seek_frame}
  lda #$01; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  lda $4216
  sta $700000,x; inx

  //22 cycles
  //w4203: 0, 242
  //r4216: 0, 264

  jsl {seek_frame}
  phx; tsx; txy
  ldx #$4215; txs
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  pla
  tyx; txs; plx
  sta $700000,x; inx

  //24 cycles
  //w4203: 0, 224
  //r4216: 0, 248

  jsl {seek_frame}
  phx; ldx #$0000
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  lda $16,x
  plx
  sta $700000,x; inx

  //26 cycles
  //w4203: 0, 170
  //r4216: 0, 196

  jsl {seek_frame}
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  lda $4216
  sta $700000,x; inx

  //28 cycles
  //w4203: 0, 266
  //r4216: 0, 294

  jsl {seek_frame}
  phx; tsx; txy
  ldx #$4214; txs
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  plx; rep #$20; txa; xba; sep #$20
  tyx; txs; plx
  sta $700000,x; inx

  //30 cycles
  //w4203: 0, 238
  //r4216: 0, 268

  jsl {seek_frame}
  phx; ldx #$0000; txy
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  ldx $15,y; rep #$20; txa; xba; sep #$20
  plx
  sta $700000,x; inx

  //32 cycles
  //w4203: 0, 170
  //r4216: 0, 202

  jsl {seek_frame}
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  nop; lda $16
  sta $700000,x; inx

  //34 cycles
  //w4203: 0, 170
  //r4216: 0, 204

  jsl {seek_frame}
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  wdm #$00; lda $16
  sta $700000,x; inx

  //36 cycles
  //w4203: 0, 266
  //r4216: 0, 302

  jsl {seek_frame}
  phx; tsx; txy
  ldx #$4215; txs
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  nop; pla
  tyx; txs; plx
  sta $700000,x; inx

  //38 cycles
  //w4203: 0, 146
  //r4216: 0, 184

  jsl {seek_frame}
  lda #$01; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  nop; nop; lda $16
  sta $700000,x; inx

  //40 cycles
  //w4203: 0, 206
  //r4216: 0, 246

  jsl {seek_frame}
  phx; ldx #$0000
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  wdm #$00; lda $16,x
  plx
  sta $700000,x; inx

  //42 cycles
  //w4203: 0, 170
  //r4216: 0, 212

  jsl {seek_frame}
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  wdm #$00; lda $4216
  sta $700000,x; inx

  //44 cycles
  //w4203: 0, 200
  //r4216: 0, 244

  jsl {seek_frame}
  phx; ldx #$0000
  lda #$01; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  nop; nop; lda $16,x
  plx
  sta $700000,x; inx

  //46 cycles
  //w4203: 0, 160
  //r4216: 0, 206

  jsl {seek_frame}
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  nop; nop; lda $16
  sta $700000,x; inx

  //48 cycles
  //w4203: 0, 170
  //r4216: 0, 218

  jsl {seek_frame}
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  nop; wdm #$00; lda $16
  sta $700000,x; inx

  //50 cycles
  //w4203: 0, 170
  //r4216: 0, 220

  jsl {seek_frame}
  lda #$00; sta $420d
  lda $0000; sta $4202
  lda $0001; sta $4203
  wdm #$00; wdm #$00; lda $16
  sta $700000,x; inx

finish:
  stz $2121
  lda #$00; sta $2122
  lda #$7c; sta $2122
  lda #$0f; sta $2100
  stp
