.include "snes.inc"
.smart

.export tell_ly

; 7654 3210  WRIO
; |+-------- 0: pull 1P pin 6 low; 1: let pin 6 float (high)
; +--------- 0: pull 2P pin 6 low; 1: let pin 6 float (high)

; read SLHV while WRIO.D7 is true: populate OPHCT/OPVCT and set
; STAT78 bit 6

; OPVCT first read: Y bits 7-0; second read: garbage and Y bit 8

; 7654 3210  STAT78
; || | ++++- PPU2 (BG and color math) version (1-3)
; || +------ 0: 60 Hz; 1: 50 Hz
; |+-------- OPHCT/OPVCT have been populated since last STAT78 read
; +--------- 0: first interlace frame; 1: second interlace frame
; side effect: clear bit 6 and the OPHCT/OPVCT first/second read

;;
; Spin-waits for a button to be pressed.
; @param DBR $00-$3F or $80-$BF
; @return A = pressed keys (16 bit); Y = vertical coordinate
.proc tell_ly
cur_keys_lo = $00
cur_keys_hi = $01

  seta8
  lda #$C0
  sta WRIO
  chkloop:
    lda #1
    sta $4016
    sta cur_keys_lo
    stz cur_keys_hi
    stz $4016
    bitloop:
      lda $4016
      lsr a
      rol cur_keys_lo
      rol cur_keys_hi
      bcc bitloop
    lda cur_keys_hi
    ora cur_keys_lo
    beq chkloop

  bit STAT78
  bit SLHV
  lda OPVCT
  xba
  lda OPVCT
  and #$01
  xba
  tay
  seta16
  lda cur_keys_lo
  rtl
.endproc
