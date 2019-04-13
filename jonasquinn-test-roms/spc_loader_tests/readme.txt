SNES SPC file loader tests
--------------------------
These verify basic operation of an SPC player on SNES hardware.

They report the result via a series of beeps:

	Beeps			Result
	- - - - - - - - - - - - - - - - - - - - - - - - -
	low				Passed
	low high		General failure
	low high low	Failure code 2
	low high high	Failure code 3
	etc.

Only the first failure is reported. Sub-tests are run in the order of their codes. Once a test is done, it re-runs the bootloader, so the SNES doesn't have to be reset before loading another SPC file.


initial_regs.spc
----------------
Verifies initial register values. Failure codes:

	2: CPU registers
	3: $F0-$FF registers
	4: DSP registers


initial_in_ports.spc
--------------------
Reads $F4-$F7 IMMEDIATELY at the beginning, and verifies that they all have the proper values. At least one SPC file actually does read one of these immediately like this. It's a good idea to run this test multiple times, because timing can differ slightly from one run to the next.


full_ram.spc
------------
Verifies that all RAM is restored properly. Takes 20 SECONDS to complete. Failure codes indicate region not properly restored:

	2: $00-$EF
	3: $100-$1FF (ignores three bytes just under sp)
	4: $200-$FFFF (excluding echo buffer)
	5: Echo buffer
	6: Three bytes just under sp

-- 
Shay Green <gblargg@gmail.com>
