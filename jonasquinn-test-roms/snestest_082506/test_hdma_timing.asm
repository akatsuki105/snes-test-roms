;test_hdma_timing
;version 1.0 ~byuu (10/15/05)

;this test was used to verify when HDMA init occurred on
;both a 1/1/1 SNES and a 2/1/3 SNES. only non-interlace
;mode was tested.
;results:
;  1/1/1 : 12 + 8 - dma_counter() { 20, 16 }
;  2/1/3 : 12 + dma_counter() { 12, 16 }

lorom
org $008000 : fill $020000

!ctr0min = 0 : !ctr0max = 32000
!ctr1min = 0 : !ctr1max = 32000
!ctr2min = 0 : !ctr2max = 32000
!ctr3min = 0 : !ctr3max = 32000
!ctr4min = 0 : !ctr4max = 32000
!ctr5min = 0 : !ctr5max = 32000
!ctr6min = 0 : !ctr6max =  1023
!ctr7min = 0 : !ctr7max =     1

incsrc libtestmenu.asm

org $00c000
run_test() {
  sep #$20

;by default, seek to V=0,HC=0,IF=0,DC=4
- jsl seek_frame
  jsr get_dma_counter
  cmp #$00 : beq -

;if !ctr7 set, seek to V=0,HC=0,IF=0,DC=0
  lda !ctr7 : beq +
  jsl seek_frame
+

;seek to IF=1
- bit $213f : bpl -

;now seek to V=225, below code should invert
;IF back to 0, and toggle DC (^=4).
- bit $4212 : bpl -

;setup HDMA
  lda #$00 : sta $4300
  lda #$ff : sta $4301
  lda #$00 : sta $4302
  lda #$00 : sta $4303
  lda #$7f : sta $4304
  lda #$ff : sta $7f0000 : sta $7f0001 : sta $7f0002 : sta $7f0003
  lda #$00 : sta $7f0004
  lda #$01 : sta $420c

- bit $4212 : bmi -

- bit $4212 : bvc -
- bit $4212 : bvs -
- bit $4212 : bvc -
- bit $4212 : bvs -
- bit $4212 : bvc -
- bit $4212 : bvs -

  rep #$20
  lda !ctr0 : clc : adc.w #320 : asl : jsl seek_cycles
  sep #$20

  lda $2137
  nop #8
  stz $420c
  lda $213c : sta !res0
  lda $213c : and #$01 : sta !res0+1
  lda $213d : sta !res1
  lda $213d : and #$01 : sta !res1+1

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
image_desc:   db 'HDMA Timing Test',$00
image_ctr0:   db '                  CTR0:-----',$00
image_ctr1:   db '                  CTR1:-----',$00
image_ctr2:   db '                  CTR2:-----',$00
image_ctr3:   db '                  CTR3:-----',$00
image_ctr4:   db '                  CTR4:-----',$00
image_ctr5:   db '                  CTR5:-----',$00
image_ctr6:   db '             Line Skip:-----',$00
image_ctr7:   db '       DMA Counter Pos:-----',$00
image_resctr: db '        Result Counter:-----',$00
image_ophvct: db 'OPVCT:--- OPHCT:--- STA78:--',$00
image_res01:  db 'R0:-----,----  R1:-----,----',$00
image_res23:  db 'R2:-----,----  R3:-----,----',$00
image_res45:  db 'R4:-----,----  R5:-----,----',$00
image_res67:  db 'R6:-----,----  R7:-----,----',$00
