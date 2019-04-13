lorom

org $008000 : fill $020000

org $ffc0
  db 'CYCLE DEMO ROM       '
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

!wram_read_pos    = $80
!wram_read_mirror = $84
!temp             = $88
!temp0            = $8a
!joy_low          = $8c
!joy_high         = $8e

org $008c00
rti
  lda $4210
  lda $2137

  lda $213c : xba
  lda $213c : xba
  rep #$20 : and #$01ff : sta $7ec000 : sep #$20
  lda $213d : xba
  lda $213d : xba
  rep #$20 : and #$01ff : sta $7ec002 : sep #$20

  rep #$20
  tsx : txa : sta $7ec004
  lda $7ec006 : inc : sta $7ec006
  sep #$20
; lda $02,s : sta $7ec006
; lda $03,s : sta $7ec007

  rti

org $008000
  clc : xce
  rep #$10
  ldx #$01ff : txs

  lda #$01 : sta $420d
  jml next+$800000
next:

  lda #$01   : sta $4300 : sta $4310 ; sta $4320 : sta $4330 : sta $4340 : sta $4350 : sta $4360 : sta $4370
  lda #$18   : sta $4301 : sta $4311 ; sta $4321 : sta $4331 : sta $4341 : sta $4351 : sta $4361 : sta $4371
  lda #$00   : sta $4302 : sta $4312 ; sta $4322 : sta $4332 : sta $4342 : sta $4352 : sta $4362 : sta $4372
  lda #$00   : sta $4303 : sta $4313 ; sta $4323 : sta $4333 : sta $4343 : sta $4353 : sta $4363 : sta $4373
  lda #$7e   : sta $4304 : sta $4314 ; sta $4324 : sta $4334 : sta $4344 : sta $4354 : sta $4364 : sta $4374
  ldx.w #6   : stx $4305 : stx $4315 ; stx $4325 : stx $4335 : stx $4345 : stx $4355 : stx $4365 : stx $4375
  ldx #$0000 : stx $2116

  rep 10 : { lda $0000 }
  rep 10 : { lda $2100 }

  lda #$03 : sta $420b
  lda $2137

  lda $213c : xba
  lda $213c : xba
  rep #$20 : and #$01ff : sta $7ec000 : sep #$20
  lda $213d : xba
  lda $213d : xba
  rep #$20 : and #$01ff : sta $7ec002 : sep #$20

  jmp intro

table font.tbl,ltr

string0: db 'SNES Cycle Tester - byuu',$ff
string1: db 'Test:  scanline timing',$ff
string2: db '       xpos  ypos',$ff
string3: db 'Base:  xxxx  xxxx',$ff
string4: db 'Full:  xxxx  xxxx',$ff
string5: db 'Diff:  xxxx  xxxx',$ff

intro() {
  clc : xce

  rep #$10
  ldx #$01ff : txs
  sep #$20
  lda #$01 : sta $420d
  lda #$00 : sta $4200
  lda #$00 : sta $2133
  lda #$01 : sta $2105
  lda #$0f : sta $2100

; --- initialize
  sep #$30

  lda #$8f : sta $2100
  lda #$00
  ldx #$01
- sta $2100,x : inx : cpx #$0d : bcc -
- sta $2100,x : sta $2100,x : inx : cpx #$15 : bcc -
  ldx #$16
- sta $2100,x : inx : cpx #$1b : bcc -
- sta $2100,x : sta $2100,x : inx : cpx #$21 : bcc -
- sta $2100,x : inx : cpx #$34 : bcc -
  ldx #$02
- sta $4200,x : inx : cpx #$0e : bcc -

  lda #$80 : sta $2115 ;increment on $2119 write
  lda #$01 : sta $4200 ;enable joypad, not nmi
  lda #$81 : sta $4212 ;bit7=in vblank, bit0=joypad ready

  lda #$00 : sta $2105 ;mode0 [bg1-4: 4]
  lda #$00 : sta $2107 ;bg1 tilemap  [$0000]
  lda #$01 : sta $210b ;bg1 tiledata [$1000]
  lda #$01 : sta $212c ;enable bg1

  jsr write_tiledata
  jsr write_tilemap
  jsr write_palette

  rep #$30

  ldx.w #32*1+1 : stx $2116 : ldx.w #string0 : jsr write_str
  ldx.w #32*2+1 : stx $2116 : ldx.w #string1 : jsr write_str
  ldx.w #32*3+1 : stx $2116 : ldx.w #string2 : jsr write_str
  ldx.w #32*4+1 : stx $2116 : ldx.w #string3 : jsr write_str
  ldx.w #32*5+1 : stx $2116 : ldx.w #string4 : jsr write_str
  ldx.w #32*6+1 : stx $2116 : ldx.w #string5 : jsr write_str

  ldx.w #32*4+8  : stx $2116 : lda $7ec000 : jsr write_word
  ldx.w #32*4+14 : stx $2116 : lda $7ec002 : jsr write_word
  ldx.w #32*5+8  : stx $2116 : lda $7ec004 : jsr write_word
  ldx.w #32*5+14 : stx $2116 : lda $7ec006 : jsr write_word
  ldx.w #32*6+8  : stx $2116 : lda $7ec004 : sec : sbc $7ec000 : jsr write_word
  ldx.w #32*6+14 : stx $2116 : lda $7ec006 : sec : sbc $7ec002 : jsr write_word

  sep #$20
  lda #$0f : sta $2100

- bra -

;setup initial wram read position
  sep #$20
  lda #$00 : sta !wram_read_pos
  lda #$00 : sta !wram_read_pos+1
  lda #$7e : sta !wram_read_pos+2

  jsr render_memory
  lda #$0f : sta $2100

.main_loop {
    sep #$20 : rep #$10

-   lda $4212 : and #$01 : beq -
-   lda $4212 : and #$01 : bne - ;wait for joypad to be ready

    lda $4218 : sta !joy_low
    lda $4219 : sta !joy_high

    lda !joy_high : and #$08 ;see if up was pressed
    beq + : ldx #$0008 : jsr dec_wrampos : jmp .redraw
+   lda !joy_high : and #$04 ;see if down was pressed
    beq + : ldx #$0008 : jsr inc_wrampos : jmp .redraw
+   lda !joy_high : and #$02 ;see if left was pressed
    beq + : ldx #$0080 : jsr dec_wrampos : jmp .redraw
+   lda !joy_high : and #$01 ;see if right was pressed
    beq + : ldx #$0080 : jsr inc_wrampos : jmp .redraw
+   lda !joy_high : and #$40 ;see if Y was pressed
    beq + : ldx #$1000 : jsr dec_wrampos : jmp .redraw
+   lda !joy_high : and #$80 ;see if B was pressed
    beq + : ldx #$1000 : jsr inc_wrampos : jmp .redraw
+   lda !joy_low : and #$40  ;see if X was pressed
    beq + : jsr reset_all_memory : jmp .redraw
+   lda !joy_low : and #$80  ;see if A was pressed
    beq + : jsr inc_all_memory : jmp .redraw
+   jmp .main_loop

.redraw
    jsr render_memory

    jmp .main_loop
  }

- bra -
}

reset_all_memory() {
  php : rep #$30
  lda #$0200 : sta !wram_read_mirror
  lda #$007e : sta !wram_read_mirror+2

- lda #$1212 : sta [!wram_read_mirror]
  inc !wram_read_mirror : inc !wram_read_mirror : bne +
  inc !wram_read_mirror+2
+ lda !wram_read_mirror+2 : and #$00ff
  cmp #$0080 : bcs +
  bra -

+ plp : rts
}

inc_all_memory() {
  php : rep #$30
  lda #$0200 : sta !wram_read_mirror
  lda #$007e : sta !wram_read_mirror+2

- sep #$20
  lda [!wram_read_mirror] : inc : sta [!wram_read_mirror]
  rep #$20
  inc !wram_read_mirror : bne +
  inc !wram_read_mirror+2
+ lda !wram_read_mirror+2 : and #$00ff
  cmp #$0080 : bcs +
  bra -

+ plp : rts
}

dec_wrampos() {
  php : rep #$30 : pha
- {
    dec !wram_read_pos
    lda !wram_read_pos
    cmp #$ffff : bne +
    dec !wram_read_pos+2
+   dex : bne -
  }
  lda !wram_read_pos+2 : and #$00ff
  cmp #$007e : bcs +
  lda #$007e : sta !wram_read_pos+2 ;prevent going before $7e0000
  lda #$0000 : sta !wram_read_pos
+ pla : plp : rts
}

inc_wrampos() {
  php : rep #$30 : pha
- {
    inc !wram_read_pos : bne +
    inc !wram_read_pos+2
+   dex : bne -
  }
  lda !wram_read_pos+2 : and #$00ff
  cmp #$0080 : bcc +
  lda #$007f : sta !wram_read_pos+2 ;prevent going above $7fffff
  lda #$ff80 : sta !wram_read_pos
+ pla : plp : rts
}

;set the position to write the memory location (" xxxxxx:")
set_rm_linevramptr() {
  pha
  tya
  asl #5
  inc
  clc : adc.w #64
  sta $2116
  pla : rts
}

;set the position to write one hex number ("xx ")
set_rm_vramptr() {
  pha
  tya
;y * 32 (line width)
  asl #5
  sta !temp

;+ x * 3 (hex code is 'xx xx ' etc.)
  txa : sta !temp0
  asl : clc : adc !temp0

  clc : adc !temp

;+ 8 (' xxxxxx:' -- for address)
  clc : adc.w #8
;+ 64 (skip two lines)
  clc : adc.w #64

  sta $2116

  pla : rts
}

;y=line #, x=row #
render_memory() {
  php
  rep #$30
  ldy #$0000
;mirror the wram_read_pos, as we will need it again
  lda !wram_read_pos   : sta !wram_read_mirror
  lda !wram_read_pos+2 : sta !wram_read_mirror+2

.y_loop {
    cpy #$0010 : bcs .end_y_loop

    jsr set_rm_linevramptr
    lda !wram_read_mirror+2
    and #$00ff
    jsr write_byte
    lda !wram_read_mirror
    jsr write_word
    ldx #$0000
  .x_loop {
      jsr set_rm_vramptr
      cpx.w #8 : bcs .end_x_loop
      lda [!wram_read_mirror]
      inc !wram_read_mirror : bne +
      inc !wram_read_mirror+2
+     jsr write_byte
      inx : bra .x_loop
    }
  .end_x_loop
    iny : bra .y_loop
  }
.end_y_loop

  plp : rts
}

write_str() {
  php
  rep #$30
- {
    lda $0000,x : and #$00ff
    cmp #$00ff : beq +
    sta $2118
    inx : bra -
  }
+ plp : rts
}

write_byte() {
  php
  rep #$30 : sta $20

  lsr #4
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++
  pha : sep #$20 : lda $4212 : bpl $fb : rep #$20 : pla
  sta $2118

  lda $20
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++
  pha : sep #$20 : lda $4212 : bpl $fb : rep #$20 : pla
  sta $2118

  plp : rts
}

write_word() {
  php
  rep #$30 : sta $20

  xba : lsr #4
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++
  pha : sep #$20 : lda $4212 : bpl $fb : rep #$20 : pla
  sta $2118

  lda $20 : xba
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++
  pha : sep #$20 : lda $4212 : bpl $fb : rep #$20 : pla
  sta $2118

  lda $20 : lsr #4
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++
  pha : sep #$20 : lda $4212 : bpl $fb : rep #$20 : pla
  sta $2118

  lda $20
  and #$000f
  cmp #$000a : bcs +
  clc : adc #$0035
  bra ++
+ clc : adc.w #$0001-$0a
++
  pha : sep #$20 : lda $4212 : bpl $fb : rep #$20 : pla
  sta $2118

  plp : rts
}

write_tiledata() {
  lda #$00 : sta $2116
  lda #$10 : sta $2117

  lda #$01 : sta $4300
  lda #$18 : sta $4301

  lda.b #tiledata     : sta $4302
  lda.b #tiledata>>8  : sta $4303
  lda.b #tiledata>>16 : sta $4304

  rep #$20
  lda #end_tiledata-tiledata : sta $4305
  sep #$20

  lda #$01 : sta $420b
  rts
}

write_tilemap() {
  rep #$30
  lda #$0000 : sta $2116 : tax
- {
    sta $2118
    inx : cpx.w #32*28 : bcc -
  }
  sep #$30
  rts
}

write_palette() {
  lda #$00 : sta $2121
  tax
- lda.l palette,x : sta $2122 : inx
  lda.l palette,x : sta $2122 : inx
  cpx #$08 : bcc -
  rts
}

org $018000
palette:
  dw $0000,$1ce7,$0000,$7fff
org $018200
tiledata: incbin font8.bin
end_tiledata:
