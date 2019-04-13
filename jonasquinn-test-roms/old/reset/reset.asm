lorom

org $008000 : fill $020000

org $ffc0
  db 'MEMORY DEMO ROM      '
  db $30 ;fastrom/lorom
  db $02 ;rom+save ram
  db $08 ;2mbit rom
  db $03 ;64kb sram
  db $00 ;japan
  db $33 ;nintendo
  db $01 ;version 1.1
  dw $0000 ;inverse checksum
  dw $0000 ;rom     checksum
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  dw $8800
  db $00,$00,$00,$00
  db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  dw $8000
  db $00,$00

org $008800
  rti

org $008000

!wram_read_pos    = $80
!wram_read_mirror = $84
!temp             = $88
!temp0            = $8a
!joy_low          = $8c
!joy_high         = $8e

intro() {
  clc : xce
  rep #$10 : ldx #$01ff : txs
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

  ldx.w #32*1+1 : stx $2116
  ldx.w #string0 : jsr write_str
  ldx.w #32*19+1 : stx $2116
  ldx.w #string1 : jsr write_str
  ldx.w #32*20+1 : stx $2116
  ldx.w #string2 : jsr write_str
  ldx.w #32*21+1 : stx $2116
  ldx.w #string3 : jsr write_str
  ldx.w #32*22+1 : stx $2116
  ldx.w #string4 : jsr write_str
  ldx.w #32*23+1 : stx $2116
  ldx.w #string5 : jsr write_str
  ldx.w #32*24+1 : stx $2116
  ldx.w #string6 : jsr write_str
  ldx.w #32*26+13 : stx $2116
  ldx.w #string7 : jsr write_str

;setup initial wram read position
  sep #$20
  lda #$00 : sta !wram_read_pos
  lda #$00 : sta !wram_read_pos+1
  lda #$7e : sta !wram_read_pos+2

  jsr render_memory
  lda #$0f : sta $2100

print pc
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

table font.tbl,ltr

string0: db 'SNES Memory Viewer,Tester:',$ff
string1: db 'Up:   Up    8 Down:  Down    8',$ff
string2: db 'Left: Up   80 Right: Down   80',$ff
string3: db 'Y:    Up 1000 B:     Down 1000',$ff
string4: db 'X: Reset all memory to 12,SLOW',$ff
string5: db 'A: Inc. all memory by 1,SLOWER',$ff
string6: db '-- 7E0000-7E01FF is excluded',$ff
string7: db '-- Written by:byuu',$ff

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
