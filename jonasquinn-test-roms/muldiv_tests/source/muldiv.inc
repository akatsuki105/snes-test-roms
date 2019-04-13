.include "shell.inc"

; Synchronizes with refresh delay
; Preserved: A, X, X
sync_refresh:
	pha
	
	lda #110
	sta HTIMEL
	stz HTIMEH
	
	lda #$10
	sta NMITIMEN
	
	pla
	
	bit TIMEUP
	wai
	bit TIMEUP
	wai
	
	rts

.macro delayed_instr n, instr, addr
	.if (n) = 3
		instr addr + ADDR
	.else
		delay (n) - 2
		instr <(addr) + ADDR
	.endif
.endmacro

.macro wr_delay_read write, n, read
	jsr begin
	sta <write
	delayed_instr n, lda, read
	jsr end
.endmacro
