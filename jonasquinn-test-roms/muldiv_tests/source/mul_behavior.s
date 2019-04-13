; Verifies MPY behavior edge cases. Requires proper timing.

.include "muldiv.inc"

.macro begin ma, mb
	jsr sync_refresh
	ldx #(mb)*$100 + (ma)
	stx WRMPYA
.endmacro

main:
	set_test 2,"Basic operation is wrong"
	begin $A3, $81
	phd
	pld
	ldx RDMPYL
	cpx #$5223
	jne test_failed
	
	set_test 3,"RDDIVH should hold $00 after multiply"
	begin $A3, $81
	phd
	pld
	lda RDDIVH
	jne test_failed
	
	set_test 4,"RDDIVL should hold RDMPYB after multiply"
	begin $A3, $81
	phd
	pld
	lda RDDIVL
	cmp #$81
	jne test_failed
	
	set_test 5,"WRMPYA write during mul should be saved for next mul"
	lda #$55
	begin $A3, $81
	sta WRMPYA
	phd
	pld
	lda #$11
	sta WRMPYB
	phd
	pld
	ldx RDMPYL
	cpx #$5A5
	jne test_failed
	ldx RDDIVL
	cpx #$0011
	jne test_failed
	
	set_test 6,"WRMPYA write during mul shouldn't affect result"
	lda #$55
	begin $A3, $81
	sta WRMPYA
	phd
	pld
	ldx RDMPYL
	cpx #$5223
	jne test_failed
	ldx RDDIVL
	cpx #$0081
	jne test_failed
	
	set_test 7,"WRMPYB write during mul should clear intermediate result"
	lda #$00
	begin $A3, $81
	sta WRMPYB
	phd
	pld
	ldx RDMPYL
	cpx #$50A0
	jne test_failed
	ldx RDDIVL
	cpx #$0081
	jne test_failed
	
	set_test 8,"Value of RMPYB write during mul is ignored"
	lda #$34
	begin $A3, $81
	sta WRMPYB
	phd
	pld
	ldx RDMPYL
	cpx #$50A0
	jne test_failed
	ldx RDDIVL
	cpx #$0081
	jne test_failed
	
	jmp tests_passed
