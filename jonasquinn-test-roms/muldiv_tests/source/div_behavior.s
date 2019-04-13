; Verifies DIV behavior edge cases. Requires proper timing.

.include "muldiv.inc"

.macro begin num, den
	jsr sync_refresh
	ldx #num
	stx WRDIVL
	ldx #(den)*$100 + >num
	stx WRDIVH
.endmacro

main:
	set_test 2,"RDDIV result is wrong"
	begin $A359, $81
	phd
	pld
	phd
	pld
	ldx RDDIVL
	cpx #$0144
	jne test_failed
	
	set_test 3,"RDMPY result is wrong"
	begin $A359, $81
	phd
	pld
	phd
	pld
	ldx RDMPYL
	cpx #$0015
	jne test_failed
	
	set_test 4,"WRDIV write during div should be saved for next div"
	ldy #$9876
	begin $A359, $81
	sty WRDIVL
	phd
	pld
	phd
	pld
	lda #$11
	sta WRDIVB
	phd
	pld
	phd
	pld
	ldx RDDIVL
	cpx #$08F7
	jne test_failed
	ldx RDMPYL
	cpx #$000F
	jne test_failed
	
	set_test 5,"WRDIV write during div shouldn't affect result"
	ldy #$9876
	begin $A359, $81
	sty WRDIVL
	phd
	pld
	phd
	pld
	ldx RDDIVL
	cpx #$0144
	jne test_failed
	ldx RDMPYL
	cpx #$0015
	jne test_failed
	
	set_test 6,"WRDIVB write during div should reload WRDIV into RDMPY"
	lda #$81
	begin $A359, $81
	nop
	nop
	nop
	sta WRDIVB
	phd
	pld
	phd
	pld
	ldx RDDIVL
	cpx #$017F
	jne test_failed
	ldx RDMPYL
	cpx #$839A
	jne test_failed
	
	set_test 7,"WRDIVB write during div should use last written WRDIV value"
	lda #$81
	ldy #$08AF
	begin $A359, $81
	sty WRDIVL
	sta WRDIVB
	phd
	pld
	phd
	pld
	ldx RDDIVL
	cpx #$0111
	jne test_failed
	ldx RDMPYL
	cpx #$001E
	jne test_failed
	
	set_test 8,"Value of WRDIVB write during div is ignored"
	lda #$00
	begin $A359, $81
	nop
	nop
	nop
	sta WRDIVB
	phd
	pld
	phd
	pld
	ldx RDDIVL
	cpx #$017F
	jne test_failed
	ldx RDMPYL
	cpx #$839A
	jne test_failed
	
	jmp tests_passed
