; Verifies timing and intermediate RDMPY and RDDIV

.include "muldiv.inc"

mula = $A5
mulb = $81

begin:
	; Setup
	jsr sync_refresh
	lda #mula
	sta WRMPYA
	lda #mulb
	
	; Allow d-page addressing
	pea WRMPYB & $FF00
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
	wr_delay_read WRMPYB, n, RDMPYH
	wr_delay_read WRMPYB, n, RDMPYL
	jsr print_space
	jsr print_space
	wr_delay_read WRMPYB, n, RDDIVH
	wr_delay_read WRMPYB, n, RDDIVL
	
	jsr print_newline
.endmacro

main:
	print_str "CLK RDMPY RDDIV",newline
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
	
	check_crc $8DA8D65E
	jmp tests_passed
