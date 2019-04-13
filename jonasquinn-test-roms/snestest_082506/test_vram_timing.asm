;test_vram_timing
;version 1.0 ~byuu (10/18/05)

;0 = fail (no read/write)
;o = fail (open bus write)
;1 = pass (valid read/write)

;[read]
;21138 = 1; 21139 = 0
;32000,32000,32000,32000,32000,10088 = 0; 10089 = 1
;Invalid range: {last_scanline_of_frame,1362} - {224/239,1360}

;[write]
;21172 = 1; 21173 = o, 21174 = 0
;32000,32000,32000,32000,32000,10122 = 0; 10123 = 1
;Invalid range: {  0,   6} - {225/240,   4}
;Exception: {  0,   6} writes CPU MDR (open bus) to VRAM

;VRAM read/write requests outside of valid range will
;still update read/write positions. Writes will not write
;any data, and reads return presently unknown data. This
;data is usually $00, $01, or $ff.
;VRAM read/write requests always happen when display
;disable ($2100.d7) is set.

lorom
org $008000 : fill $020000

!ctr0min = 0 : !ctr0max = 32000
!ctr1min = 0 : !ctr1max = 32000
!ctr2min = 0 : !ctr2max = 32000
!ctr3min = 0 : !ctr3max = 32000
!ctr4min = 0 : !ctr4max = 32000
!ctr5min = 0 : !ctr5max = 32000
!ctr6min = 0 : !ctr6max = 32000
!ctr7min = 0 : !ctr7max = 32000

incsrc libtestmenu.asm

org $00c000
run_test() {
  sep #$20

  jsl seek_frame

;make sure write is always valid
- bit $4212 : bpl -

  lda #$80 : sta $2115
  ldx #$7800 : stx $2116
  lda #$55 : sta $2118

+ rep #$20
  lda !ctr0 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr1 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr2 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr3 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr4 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr5 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr6 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr7 : clc : adc.w #320 : asl : jsl seek_cycles
  sep #$20

  lda #$aa : sta $2118

;force update read buffer
  ldx #$7800 : stx $2116
  lda $2139 : sta !res3

  lda $2137
  lda $213d : sta !res0
  lda $213d : and #$01 : sta !res0+1
  lda $213c : sta !res1
  lda $213c : and #$01 : sta !res1+1

;make sure read is always valid
- bit $4212 : bmi -
- bit $4212 : bpl -

  ldx #$7800 : stx $2116
  lda $2139 : sta !res2

  rep #$20
  rts
}

get_dma_counter() {
  nop
  stz $4300
  lda #$ff : sta $4301
  stz $4302
  stz $4303
  stz $4304
  lda #$01 : sta $4305
  stz $4306
  lda #$01 : sta $420b
  lda $2137
  lda $213c
  cmp #$65 : beq +
;else, a=#$67
  lda #$04 : rts
+ lda #$00 : rts
}

image_title:  db $f2,'SNES Test Program ~byuu',$00
image_desc:   db 'VRAM Timing Test',$00
image_ctr0:   db '                  CTR0:-----',$00
image_ctr1:   db '                  CTR1:-----',$00
image_ctr2:   db '                  CTR2:-----',$00
image_ctr3:   db '                  CTR3:-----',$00
image_ctr4:   db '                  CTR4:-----',$00
image_ctr5:   db '                  CTR5:-----',$00
image_ctr6:   db '                  CTR6:-----',$00
image_ctr7:   db '                  CTR7:-----',$00
image_resctr: db '        Result Counter:-----',$00
image_ophvct: db 'OPVCT:--- OPHCT:--- STA78:--',$00
image_res01:  db 'R0:-----,----  R1:-----,----',$00
image_res23:  db 'R2:-----,----  R3:-----,----',$00
image_res45:  db 'R4:-----,----  R5:-----,----',$00
image_res67:  db 'R6:-----,----  R7:-----,----',$00
