.include "snes.inc"
.smart
.export unpb16, unpb16_to_vram_y, unpb16_to_vram_y_mode_x
.exportzp ciSrc

.zeropage
ciSrc: .res 3

.segment "BSS7F"
pb16buffer: .res 8192

.segment "CODE1"

.i16
;;
; @param ciSrc source address in ROM
; @param DBR:x destination address in RAM (does not cross banks)
; @param A length of decompressed data in 32-byte units
.proc unpb16
bits = $03
tilesleft = $04

  seta8
  sta tilesleft
  ldy #0
  tya
  xba
  tya
  packetloop:
    jsr onepacket
    jsr onepacket
    jsr onepacket
    jsr onepacket
    dec tilesleft
    bne packetloop
  rtl

onepacket:
  ; Get 
  pha
  lda [ciSrc],y
  iny
  ; Ring counter: Once this 1 bit reaches carry and A empties out,
  ; the packet is done
  sec
  rol a
  sta bits
  pla
  byteloop:
    xba
    bcs isrepeat
      lda [ciSrc],y
      iny
    isrepeat:
    sta a:$0000,x
    inx
    asl bits
    bne byteloop
  rts
.endproc

;;
; @param ciSrc source address in ROM
; @param Y VRAM address
; @param A[7:0] length of decompressed data in 16-byte units
.proc unpb16_to_vram_y
  ldx #DMAMODE_PPUDATA
  ; fall through
.endproc

;;
; @param ciSrc source address in ROM
; @param Y VRAM address
; @param X (usually DMAMODE_PPUDATA)
; @param A[7:0] length of decompressed data in 16-byte units
.proc unpb16_to_vram_y_mode_x
  seta8

  ; Set most DMA parameters
  ph2banks 0, pb16buffer
  plb  ; DBR = system area
  sty PPUADDR
  stx DMAMODE
  ldx #.loword(pb16buffer)
  stx DMAADDR

  ; Do the decompression
  plb  ; DBR:X = pb16buffer
  pha
  jsl unpb16

  ; Finish the DMA destination
  phb
  pla  ; A = .bankbyte(pb16buffer)
  sta f:DMAADDRBANK

  ; Set the DMA length
  pla  ; A = length/32 (1 means 16, 128 means 4K, 0 means 8K)
  xba
  lda #0
  seta16
  lsr a
  lsr a
  lsr a
  bne :+
    lda #8192
  :
  sta f:DMALEN

  ; Move ciSrc to end of buffer
;  clc
  tya
  adc ciSrc
  sta ciSrc
  seta8
  bcc :+
    inc ciSrc+2
  :

  ; Run the copy
  lda #%00000001
  sta f:COPYSTART
  rtl
.endproc
