seek_frame:
  phb; phd; php; rep #$30; pha

  jml .normal_speed
  .normal_speed:

  pea $0000; plb; plb
  pea $0000; pld
  sep #$20; sei

  lda.b #seek_frame_irq>>0;  sta {irq_vector}+0
  lda.b #seek_frame_irq>>8;  sta {irq_vector}+1
  lda.b #seek_frame_irq>>16; sta {irq_vector}+2

  stz $4207; stz $4208
  lda #$05; sta $4209
  lda #$01; sta $420a
  lda #$30; sta $4200
  cli; wai

  lda $213f; lda $2137; lda $213c; xba
  lda $213f; lda $2137; lda $213c

  //A is now equal to one of these three values:
  //#$4561 { 254, 364 }; #$4661 { 256, 366 }; #$4662 { 258, 368 }

  cmp #$62; bne +; jmp .phase3
  +; xba; cmp #$46; bne +; jmp .phase2
  +; jmp .phase1

  .phase1:; nop #38; wdm #$00; wdm #$00; jmp .end
  .phase2:; nop #36; wdm #$00; wdm #$00; wdm #$00; wdm #$00; jmp .end
  .phase3:; nop #40; wdm #$00; wdm #$00; wdm #$00; wdm #$00; jmp .end

  .end:
  rep #$30; pla; plp; pld; plb; rtl

seek_frame_irq:
  lda $4211; rti
