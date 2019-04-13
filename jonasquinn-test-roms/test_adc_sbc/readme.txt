SNES 8-bit ADC/SBC tests
------------------------
These tests verify 8-bit ADC and SBC operation for binary and decimal
modes. Each takes about 15 seconds. Failure codes:

	2: binary
	3: binary, carry set
	4: decimal
	5: decimal, carry set
	6: decimal, other flags set

Each tests with the indicated flags over all 65536 combinations of A and
the operand, and verifies the resulting A and flags (all 8 flags). The
final test has various other flags set which shouldn't affect operation,
just in case an emulator incorrectly uses them.

The main source is included, but not the libraries. Contact me for full
sources.

-- 
Shay Green <gblargg@gmail.com>
