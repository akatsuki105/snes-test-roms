lorom
org $008000 : fill $020000

!ctr0min = 0 : !ctr0max = 32000
!ctr1min = 0 : !ctr1max = 32000
!ctr2min = 0 : !ctr2max = 32000
!ctr3min = 0 : !ctr3max = 32000
!ctr4min = 0 : !ctr4max = 32000
!ctr5min = 0 : !ctr5max = 32000
!ctr6min = 0 : !ctr6max = 32000
!ctr7min = 0 : !ctr7max =     1

incsrc libtestmenu.asm

org $00c000
run_test() {
  jsl seek_frame

  lda !ctr7 : beq +
- bit $213e : bpl -

+ lda !ctr0 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr1 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr2 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr3 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr4 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr5 : clc : adc.w #320 : asl : jsl seek_cycles
  lda !ctr6 : clc : adc.w #320 : asl : jsl seek_cycles

  rts
}

image_title:  db $f2,'SNES Test Program ~byuu',$00
image_desc:   db 'Dot Timing Test',$00
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
