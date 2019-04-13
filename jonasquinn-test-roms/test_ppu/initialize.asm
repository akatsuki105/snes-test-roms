initialize:
  sei; clc; xce
  rep #$10
  ldx #$01ff; txs

  lda #$8f; sta $2100
  stz $2101
  stz $2102
  stz $2103
  stz $2104
  stz $2105
  stz $2106
  stz $2107
  stz $2108
  stz $2109
  stz $210a
  stz $210b
  stz $210c
  stz $210d; stz $210d
  stz $210e; stz $210e
  stz $210f; stz $210f
  stz $2110; stz $2110
  stz $2111; stz $2111
  stz $2112; stz $2112
  stz $2113; stz $2113
  stz $2114; stz $2114
  lda #$80; sta $2115
  stz $2116
  stz $2117
  stz $211a
  stz $211b; stz $211b
  stz $211c; stz $211c
  stz $211d; stz $211d
  stz $211e; stz $211e
  stz $211f; stz $211f
  stz $2120; stz $2120
  stz $2121
  stz $2122
  stz $2123
  stz $2124
  stz $2125
  stz $2126
  stz $2127
  stz $2128
  stz $2129
  stz $212a
  stz $212b
  stz $212c
  stz $212d
  stz $212e
  stz $212f
  stz $2130
  stz $2131
  lda #$e0; sta $2132
  stz $2133

  stz $2181
  stz $2182
  stz $2183

  stz $4200
  lda #$ff; sta $4201
  stz $4202
  stz $4203
  stz $4204
  stz $4205
  stz $4206
  stz $4207
  stz $4208
  stz $4209
  stz $420a
  stz $420c
  lda #$01; sta $420d

  //clear VRAM
  lda #$00; sta $7fffff
  lda #$09; sta $4300
  lda #$18; sta $4301
  lda #$ff; sta $4302
  lda #$ff; sta $4303
  lda #$7f; sta $4304
  ldx #$0000; stx $4305
  lda #$01; sta $420b

  //clear OAM
  ldx #$0080
  -;stz $2104
    lda #$e0; sta $2104
    stz $2104
    stz $2104
    dex; bne -
  ldx #$0020
  -;stz $2104
    dex; bne -

  //clear CGRAM
  ldx #$0200
  -;stz $2122
    dex; bne -
