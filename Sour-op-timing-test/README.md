# PPU Bus Activity Traces

Posted by Sour [on the nesdev forum][p].

[p]: https://forums.nesdev.com/viewtopic.php?f=12&t=18658&p=240342#p240342

> I finished working on my CPU timing test and the results from a sd2snes are
> available here: [https://www.youtube.com/watch?v=3myuKodnw_k][video]
> (thanks to koitsu for recording this!)
> 
> The test goes through almost every single op code on the 65816, runs a small
> benchmark and displays a value representing the number of PPU dots it took to
> perform the test. The actual values are meaningless - the important part is
> that the results should match the hardware values (+/- 1, or sometimes +/- 10
> when dram refresh gets in the way)
> 
> The rom goes through 54 separate screens (27 without fastrom, and then the
> same tests, with fastrom turned on), testing most op codes with various
> combinations of the X/M flags. It takes about 2 minutes to run. Might try to
> add a few more test cases into it eventually, but this is a pretty decent
> start - hopefully this is useful to someone else making a SNES core at some
> point!
> 
> I've found and fixed a few timing issues thanks to this, but it still hasn't
> been enough to fix the games that freeze. Will have to start looking at other
> stuff (DMA timing, IRQ timing, etc) to see if I can find more issues.

[video](,/op_timing_test_v2-GPM-02-NTSC-2019_06_30-3myuKodnw_k.mp4)
