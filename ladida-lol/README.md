# Ladida's test ROM

Posted by byuu [on the nesdev forum][p].

[p]: https://forums.nesdev.com/viewtopic.php?f=12&t=16330

> Test code: [lol.asm](lol.asm)
> 
> Test ROM: [Ladida_lol.sfc](Ladida_lol.sfc)
> 
> How it should look: [expected-result.webm](expected-result.webm)
> 
> I've come up with an initial solution that matches hardware for this test ROM,
> and also doesn't seem to break any of the most HDMA intensive SNES games I'm
> aware of (Energy Breaker, Dai Kaijuu Monogatari, etc.) But it's possible it's
> not correct.
>
> What looks to be happening is that only when HDMA init runs (eg there are
> channels enabled at the start of a frame when HDMA init triggers), it
> initially sets the DoTransfer flag to true (see anomie's documentation for
> an explanation of DoTransfer.) It does this even if the specific channel is
> disabled. Then, if the channel is enabled, it will perform an hdmaUpdate(),
> which will fetch the line counter for you.
>
> So if you try to enable an HDMA channel halfway through the frame, that
> DoTransfer flag will still be set, and on the very next HDMA, it will perform
> a transfer anyway, but without the line fetch. This will most likely cause
> a read offset against your HDMA table, and things will go very badly. It
> essentially runs a line sooner than you'd expect (which is why there's no
> extra white line in the test ROM, and why the color is green instead of a red
> gradient.)
>
> Interestingly, if you do not have any HDMA channels enabled at the start of a
> frame, and the true HDMA init is skipped entirely, then the DoTransfer flag is
> most likely cleared, but possibly left alone. As a result, when you enable the
> HDMA later, it won't do an HDMA transfer on the next Hblank, it will instead
> do a line counter fetch, and will start the actual transfer one scanline later
> (this is the reason for the white line in the test ROM.)
>
> Obviously, the hard part will be now devising a test ROM to run on real
> hardware to ensure this is really what's going on. I'm thinking I'll push it
> temporarily to a WIP release (not an official release) to gather feedback
> and see if anyone can quickly confirm my solution wrong by finding a game
> regression. If that does happen (and it's quite likely), then we'll be back to
> the drawing board on this one.
>
> But regardless, I'm about 95% confident the cause of the issue is DoTransfer
> being set in one case, and not in the other, in said test ROM.
> 
> My solution:
>
>     auto CPU::hdmaInitReset() -> void {
>       for(auto n : range(8)) {
>         channel[n].hdmaCompleted = false;
>         channel[n].hdmaDoTransfer = false;  //***** this is now under debate, may not be necessary *****
>       }
>     }
>
>     auto CPU::hdmaInit() -> void {
>       dmaStep(8);
>       dmaWrite(false);
>
>       for(auto n : range(8)) {
>         channel[n].hdmaDoTransfer = true;  //***** ADD THIS LINE *****
>         if(!channel[n].hdmaEnabled) continue;
>         channel[n].dmaEnabled = false;  //HDMA init during DMA will stop DMA mid-transfer
>
>         channel[n].hdmaAddress = channel[n].sourceAddress;
>         channel[n].lineCounter = 0;
>         hdmaUpdate(n);
>       }
>
>       status.irqLock = true;
>     }
