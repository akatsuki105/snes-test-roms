;test_oam
;version 1.0 ~byuu (08/23/06)

lorom
org $008000 : fill $020000

!ctr0min = 0 : !ctr0max = 7
!ctr1min = 0 : !ctr1max = 1
!ctr2min = 0 : !ctr2max = 255
!ctr3min = 0 : !ctr3max = 1
!ctr4min = 0 : !ctr4max = 1
!ctr5min = 0 : !ctr5max = 7
!ctr6min = 0 : !ctr6max = 255
!ctr7min = 0 : !ctr7max = 255

incsrc libtestmenu.asm

org $00c000
run_test() {
  jsl seek_frame

  php : sep #$20
- bit $4212 : bpl -

;i didn't initially add an init function to my testmenu library,
;therefore just set up all of oam on each test call for now...

  lda #$11  : sta $212c : sta $212d ;enable bg1+oam
  lda #$80  : sta $2121
  stz $2122 : stz $2122
  lda #$ff  : sta $2122 : sta $2122

  lda !ctr0 : asl #5 : ora #$03 : sta $2101
  stz $2102 : stz $2103
  lda #$10  : sta $2104 ;x
  lda #$27  : sta $2104 ;y
  lda !ctr2 : sta $2104 ;character
;vflip,hflip,000000
  lda !ctr3 : asl : ora !ctr4 : asl #6 : sta $2104
  stz $2102 : lda #$01 : sta $2103
  lda !ctr1 : asl : sta $2104 ;size

  lda !ctr5 : sta $2105
  lda !ctr6 : sta $2133
; lda !ctr7 : sta $2100

;menu only works in mode0, turn off BG1 in mode1-7
  lda !ctr5 : beq +
  lda #$10  : sta $212c : sta $212d
+

  plp : rts
}

image_title:  db $f2,'SNES Test Program ~byuu',$00
image_desc:   db 'OAM Size Test',$00
image_ctr0:   db '                  Base:-----',$00
image_ctr1:   db '                  Size:-----',$00
image_ctr2:   db '                  Char:-----',$00
image_ctr3:   db '                 VFlip:-----',$00
image_ctr4:   db '                 HFlip:-----',$00
image_ctr5:   db '                  2105:-----',$00
image_ctr6:   db '                  2133:-----',$00
image_ctr7:   db '                      :-----',$00
image_resctr: db '        Result Counter:-----',$00
image_ophvct: db 'OPVCT:--- OPHCT:--- STA78:--',$00
image_res01:  db 'R0:-----,----  R1:-----,----',$00
image_res23:  db 'R2:-----,----  R3:-----,----',$00
image_res45:  db 'R4:-----,----  R5:-----,----',$00
image_res67:  db 'R6:-----,----  R7:-----,----',$00
