;test_dmasync
;version 1.2 ~byuu (10/04/06)

lorom
org $008000 : fill $020000

incsrc header_lorom.asm

org $018000 : incsrc libx816.asm
org $028000 : incsrc libclock.asm
org $038000 : incsrc libmenu.asm

org $008000
  incsrc libinit.asm

  lda #$8f : sta $2100
  lda #$80 : sta $2115
  stz $420c

;*** test 1 ***
  lda #$00 : sta $4300 : sta $4310 : sta $4320 : sta $4330 : sta $4350 : sta $4360 : sta $4370
  lda #$c0 : sta $4301 : sta $4311 : sta $4321 : sta $4331 : sta $4351 : sta $4361 : sta $4371
  lda #$00 : sta $4302 : sta $4312 : sta $4322 : sta $4332 : sta $4352 : sta $4362 : sta $4372
  lda #$c0 : sta $4303 : sta $4313 : sta $4323 : sta $4333 : sta $4353 : sta $4363 : sta $4373
  lda #$00 : sta $4304 : sta $4314 : sta $4324 : sta $4334 : sta $4354 : sta $4364 : sta $4374
  lda #$08 : sta $4305 : sta $4315 : sta $4325 : sta $4335 : sta $4355 : sta $4365 : sta $4375
  lda #$00 : sta $4306 : sta $4316 : sta $4326 : sta $4336 : sta $4356 : sta $4366 : sta $4376

  lda #$80 : sta $4340
  lda #$37 : sta $4341
  lda #$00 : sta $4342
  lda #$c0 : sta $4343
  lda #$00 : sta $4344
  lda #$01 : sta $4345
  lda #$00 : sta $4346

  jsl seek_frame
  lda #$ff : sta $420b

  lda $213c : sta $700000
  lda $213c : and #$01 : sta $700001
  lda $213d : sta $700002
  lda $213d : and #$01 : sta $700003

  lda $2137
  lda $213c : sta $700004
  lda $213c : and #$01 : sta $700005
  lda $213d : sta $700006
  lda $213d : and #$01 : sta $700007

;SRAM = #$0059, #$0000, #$00f0, #$0000

;*** end of tests ***
endtest:
  jmp pass

pass() {
  sep #$20
  stz $420c
  stz $2121
  lda #$00 : sta $2122
  lda #$7c : sta $2122
  lda #$0f : sta $2100
  stp
}

fail() {
  sep #$20
  stz $420c
  stz $2121
  lda #$1f : sta $2122
  lda #$00 : sta $2122
  lda #$0f : sta $2100
  stp
}
