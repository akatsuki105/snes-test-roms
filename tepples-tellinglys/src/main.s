;
; Simple sprite demo for NES
; Copyright 2011-2014 Damian Yerrick
;
; Copying and distribution of this file, with or without
; modification, are permitted in any medium without royalty provided
; the copyright notice and this notice are preserved in all source
; code copies.  This file is offered as-is, without any warranty.
;

.include "snes.inc"
.include "global.inc"
.smart

.segment "ZEROPAGE"
nmis:          .res 1
test_progress: .res 1
ly_values:     .res 12
cur_keys:      .res 2
accum_keys:    .res 2

.bss
OAM: .res 512
OAMHI: .res 32

.segment "CODE"
;;
; This NMI handler is good enough for a simple "has NMI occurred?"
; vblank-detect loop.
.proc nmi_handler
  sep #$20
  pha
  lda f:nmis
  inc a
  sta f:nmis
  pla
  rti
.endproc

; A null IRQ handler that just does RTI is useful to add breakpoints
; on $00FFE6 that survive a recompile.
.proc irq_handler
  rti
.endproc

.proc main
  ; Configure the PPU for a single mode 0 plane
  seta8
  lda #FORCEBLANK
  sta PPUBRIGHT
  lda #%0001
  sta BLENDMAIN
  stz BLENDSUB
  stz WINDOWMAIN
  stz WINDOWSUB
  lda #3
  stz PPURES
  stz BGMODE
  stz MOSAIC
  stz BG12WINDOW
  stz BG34WINDOW
  stz BGSCROLLX
  stz BGSCROLLX
  lda #$07
  sta BGSCROLLY
  sta BGSCROLLY
  lda #VBLANK_NMI
  sta PPUNMI

  ; Set the first sprite palette
  lda #129
  sta CGADDR
  lda #$1C
  sta CGDATA
  stz CGDATA

  ; Load the background palette
  stz CGADDR
  ph2banks initial_bg_palette, *
  plb
  setaxy16
  ldx #.loword(initial_bg_palette)
  ldy #initial_bg_palette_end-initial_bg_palette
  lda #DMAMODE_CGDATA
  jsl ppu_copy
  plb

  ; Load tilemaps for title screen and failure message
  setxy16
  ldy #$0000
  ldx #$7800
  jsl ppu_clear_nt
  ldy #$0000
  ldx #$7C00
  jsl ppu_clear_nt

  seta8
  stz VMAIN
  ldy #.loword(titlenam)
  sty ciSrc
  lda #.bankbyte(titlenam)
  sta ciSrc+2
  ldy #$7900  ; "telling LYs?"
  lda #4
  ldx #DMAMODE_PPULODATA
  jsl unpb16_to_vram_y_mode_x
  ldy #$79C0  ; Copyright
  lda #2
  ldx #DMAMODE_PPULODATA
  jsl unpb16_to_vram_y_mode_x
  ldy #$7A80  ; Press button
  lda #2
  ldx #DMAMODE_PPULODATA
  jsl unpb16_to_vram_y_mode_x
  ldy #$7D80  ; Failure message
  lda #6
  ldx #DMAMODE_PPULODATA
  jsl unpb16_to_vram_y_mode_x

  ; Load tiles for title screen, conversation, and failure message
  lda #$80
  sta f:VMAIN
  ldy #.loword(text_chr)
  sty ciSrc
  lda #.bankbyte(text_chr)
  sta ciSrc+2
  ldy #$0000
  lda #84
  jsl unpb16_to_vram_y
  ldy #.loword(convo_chr)
  sty ciSrc
  lda #.bankbyte(convo_chr)
  sta ciSrc+2
  ldy #$0800
  lda #84
  jsl unpb16_to_vram_y
  ldy #.loword(arrowtile_chr)
  sty ciSrc
  lda #.bankbyte(arrowtile_chr)
  sta ciSrc+2
  ldy #$4000 + CONVO_ARROW_TILE * 16
  lda #1
  jsl unpb16_to_vram_y

  ; Turn on rendering
  phk
  plb
  jsr wait_keys_up
  jsl ppu_vsync

  seta8
  lda #$7800 >> 8
  sta NTADDR
  stz BGCHRADDR
  lda #$0F
  sta PPUBRIGHT
  lda #$4000 >> 13
  sta OBSEL

  ; Set up OAM for first sprite
  lda #CONVO_ARROW_TILE
  sta OAM+2
  lda #$30  ; no flip, front prio, palette 0
  sta OAM+3
  lda #224
  sta OAM+0
  
  ; Clear the rest
  ldx #$04
  :
    sta OAM+1,x
    inx
    inx
    inx
    inx
    cpx #512
    bne :-
  lda #0
  :
    sta OAM,x
    inx
    cpx #544
    bne :-

  ; Read the first Y position and save it
  jsl tell_ly
  sta accum_keys
  seta8
  tya
  sta ly_values+0
  sec
  sbc #4
  sta OAM+1
  lda #1
  sta test_progress
  
  ; Title screen is over.  Clear the conversation tilemap
  jsl ppu_vsync
  lda #$80
  sta f:PPUBRIGHT
  ldy #$0100
  ldx #$7800
  jsl ppu_clear_nt

  ; Set most rows' attribute to an invisible palette
  lda #$05
  sta $00
  ldx #$78C0  ; dst
  stx PPUADDR
  ldx #$0000  ; src
  ldy #32*18  ; len: 9 lines of text * 2 tilemap rows/line * 32 bytes/row
  seta16
  lda #DMAMODE_PPUHIFILL
  jsl ppu_copy
  seta8

  ; Load the used parts of the conversation tilemap
  phk
  plb
  stz VMAIN
  ldy #.loword(convo_nam)
  sty ciSrc
  lda #.bankbyte(convo_nam)
  sta ciSrc+2
  ldy #$78C0
  lda #20  ; 9 lines of text + 1 buttons, 2 tile rows per line
  ldx #DMAMODE_PPULODATA
  jsl unpb16_to_vram_y_mode_x

  ; Fill bottom of video memory
  phk
  plb
  lda #CONVO_BLACK_TILE
  ldx #128
  :
    sta PPUDATA
    dex
    bne :-

  lda #%00010001
  sta BLENDMAIN
  jsr convo_update

  seta8
  lda #$0F
  sta f:PPUBRIGHT


testloop:
  jsr convo_update
testloop_not_new_key:
  jsl ppu_vsync
  jsl ppu_copy_oam
  jsr wait_keys_up
  jsl tell_ly
  .a16
  sta cur_keys
  setxy8
  dey
  dey
  dey
  dey
  sty OAM+1
  setxy16
  ; reject if repress
  bit accum_keys
  bne testloop_not_new_key
  ; reject if more than one key pressed
  sec
  sbc #1
  and cur_keys
  bne testloop_not_new_key

  lda accum_keys
  ora cur_keys
  sta accum_keys

  ; save value
  setxy8
  ldx test_progress
  sty ly_values,x
  inx
  stx test_progress
  cpx #12
  bcc testloop

  ; Evaluate whether test passed
minimum = $00
maximum = $01
  setaxy8
  lda ly_values
  sta minimum
  sta maximum
  ldx #11
  getminmaxloop:
    lda ly_values,x
    cmp minimum
    bcs :+
      sta minimum
    :
    cmp maximum
    bcc :+
      sta maximum
    :
    dex
    bne getminmaxloop

  ; If all are within 2 of the minimum or maximum, it's a failure
  ldx #7
  checkminmaxloop:
    sec
    lda ly_values,x
    sbc minimum
    cmp #3
    bcc checkminmaxloop_continue
    lda maximum
    sbc ly_values,x
    cmp #3
    bcs not_all_near_min_max
  checkminmaxloop_continue:
    dex
    bpl checkminmaxloop
  jmp failed
not_all_near_min_max:

  ; If not at least 5 bits of difference between low and high values,
  ; it's also a failure
  lda ly_values
  sta minimum
  sta maximum
  ldx #11
  getbitsloop:
    lda ly_values,x
    and minimum
    sta minimum
    lda ly_values,x
    ora maximum
    sta maximum
    dex
    bne getbitsloop
  lda maximum
  eor minimum
  ;ldx #0  ; already true after untaken DEX BNE
  stx $4444
  countbitsloop:
    lsr a
    bcc :+
      inx
    :
    bne countbitsloop
  cpx #5
  bcs show_pass_animation

  ; Show failure message
failed:
  jsl ppu_vsync
  lda #$7C
  bne have_final_NTADDR

show_pass_animation:
  ; At this point we passed. Animate the ending
  jsr convo_update_2000_ms
  inc test_progress  ; show final row
  jsr convo_update_2000_ms

  ; Show PASS graphic
  lda #$80
  sta PPUBRIGHT
  setxy16
  ldy #$0000
  ldx #$7800
  jsl ppu_clear_nt
  seta8
  stz VMAIN
  ldy #.loword(pass_nam)
  sty ciSrc
  lda #.bankbyte(pass_nam)
  sta ciSrc+2
  ldy #$7980  ; "Pass!"
  lda #6
  ldx #DMAMODE_PPULODATA
  jsl unpb16_to_vram_y_mode_x
  lda #$80
  sta f:VMAIN
  ldy #.loword(pass_chr)
  sty ciSrc
  lda #.bankbyte(pass_chr)
  sta ciSrc+2
  ldy #$0000
  lda #84
  jsl unpb16_to_vram_y


  jsl ppu_vsync
  lda #$78
have_final_NTADDR:
  sta NTADDR
  lda #$0F
  sta PPUBRIGHT
  lda #%00000001
  sta BLENDMAIN
:
  bra :-
.endproc

CONVO_BLACK_TILE = $77
CONVO_ARROW_TILE = $96

;;
; Reveal line test_progress*2/3-1 (0-8) through attribute
.proc convo_update
  setxy16
  jsl ppu_vsync
  jsl ppu_copy_oam
  seta8
  lda #$80
  sta VMAIN
  lda #$01  ; New attribute value
  sta $00

  ; calculate destination address
  lda test_progress
  and #$0F
  beq no_line
    dec a
    cmp #9
    bcc :+
      dec a
    :
    cmp #6
    bcc :+
      dec a
    :
    cmp #3
    bcc :+
      dec a
    :
    xba
    lda #0
    seta16
    lsr a
    lsr a
    adc #$78C0-$40
    sta PPUADDR

    ; DMA that byte there
    ldx #$0000  ; src
    ldy #32*2   ; len
    seta16
    lda #DMAMODE_PPUHIFILL
    jsl ppu_copy
  no_line:

  ; Erase keys that have been pressed
  seta8
  stz VMAIN
  ldy #$7B04
  jsr write_accum_once
  ldy #$7B24
  jsr write_accum_once
  rts

write_accum_once:
  sty PPUADDR
  setxy8
  ldx #0
  seta16
  keyloop:
    lda key_at_each_position,x
    and accum_keys
    bne is_pressed
      ldy PPUDATARD
      ldy PPUDATARD
      jmp nextkey
    is_pressed:
      ldy #CONVO_BLACK_TILE
      sty PPUDATA
      sty PPUDATA
    nextkey:
    inx
    inx
    cpx #12*2
    bcc keyloop
  setxy16
  rts
.endproc


.proc convo_update_2000_ms
  jsr convo_update
  seta8
  lda #120
  sta $00
  :
    jsl ppu_vsync
    dec $00
    bne :-
  rts
.endproc

;;
; Wait for vblank then wait for all keys to be released
.proc wait_keys_up
  ; Wait for all keys to be released, then turn on screen
  sta f:$4444
  phk
  plb
  jsl ppu_vsync
  seta8
  lda #1
  sta $4016
  ldx #16
  stz $4016
  bitloop:
    lda $4016
    lsr a
    bcs wait_keys_up
    dex
    bne bitloop
  rts
.endproc

.if 0

.proc ppu_screen_on_xy0_noobj
  clc
.endproc
.proc ppu_screen_on_xy0
  ldx #0
  ldy #0
  jmp ppu_screen_on
.endproc

.proc unpb53_xtiles_to_ay
  sta PPUADDR
  sty PPUADDR
  jmp unpb53_xtiles
.endproc


.proc load_main_palette
  ; seek to the start of palette memory ($3F00-$3F1F)
  ldx #$3F
  stx PPUADDR
  ldx #$00
  stx PPUADDR
copypalloop:
  lda initial_palette,x
  sta PPUDATA
  inx
  cpx #18
  bcc copypalloop
  rts
.endproc
.endif

.segment "RODATA"
initial_bg_palette:
  .word 31*$421, 22*$421, 13*$421, 0
  .word 31*$421, 31*$421, 31*$421, 31*$421
initial_bg_palette_end:

key_at_each_position:
  .word KEY_L, KEY_LEFT, KEY_DOWN, KEY_UP, KEY_RIGHT, KEY_SELECT
  .word KEY_START, KEY_Y, KEY_B, KEY_X, KEY_A, KEY_R

; Include the CHR ROM data
text_chr:
  .incbin "obj/snes/text.u.chr.pb16"
titlenam:
  .incbin "obj/snes/text.nam.pb16"
convo_chr:
  .incbin "obj/snes/convo.u.chr.pb16"
convo_nam:
  .incbin "obj/snes/convo.nam.pb16"
pass_chr:
  .incbin "obj/snes/pass.u.chr.pb16"
pass_nam:
  .incbin "obj/snes/pass.nam.pb16"
arrowtile_chr:
  .byte %01010101, $03,$0F,$3F,$FF
  .byte %01010101, $3F,$0F,$03,$00
  .byte $FF,$FF
