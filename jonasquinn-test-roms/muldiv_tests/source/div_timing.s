; Verifies timing and intermediate WRDIV results

.include "muldiv.inc"

dividend = $AA55
divisor  = $07

begin:
	; Get $FFFF into RDDIV
	ldx #$FFFF
	stx WRDIVL
	lda #$01
	sta WRDIVB
	
	; Setup
	jsr sync_refresh
	ldx #dividend
	stx WRDIVL
	lda #divisor
	
	; Allow d-page addressing
	pea WRDIVL & $FF00
	pld
	
	rts

end:
	; Restore d-page
	pea 0
	pld
	
	jsr print_hex
	rts

.macro test n
	lda #n
	jsr print_a
	jsr print_space
	wr_delay_read WRDIVB, n, RDDIVH
	wr_delay_read WRDIVB, n, RDDIVL
	jsr print_space
	jsr print_space
	wr_delay_read WRDIVB, n, RDMPYH
	wr_delay_read WRDIVB, n, RDMPYL
	jsr print_newline
.endmacro

main:
	print_str "CLK RDDIV RDMPY",newline
	test 2
	test 3
	test 4
	test 5
	test 6
	test 7
	test 8
	test 9
	test 10
	test 11
	test 12
	test 13
	test 14
	test 15
	test 16
	test 17
	
	check_crc $6E3C695D
	jmp tests_passed
