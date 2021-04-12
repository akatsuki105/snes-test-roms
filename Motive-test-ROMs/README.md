# Motive's test ROMs

Posted by user Motive in the Mesen-S thread on the nesdev forum.

Motive originally [posted HblankEmuTest.sfc with the description for
SplitScreen.sfc](https://forums.nesdev.com/viewtopic.php?p=237178#p237178)
by accident, then later [corrected their
mistake](https://forums.nesdev.com/viewtopic.php?p=237217#p237217).

## SplitScreen.sfc

> This demo has two different modes beside each other on the same screen.
> Currently no emulator gets it perfect, the most common issue being that the
> right mode flickers.
> 
> In Mesen-S, the mode on the right does indeed bounce about (It's stationary on
> hardware) but the more interesting part is that there appears to be a mode 5
> background behind the mode 3 one on the left.
> 
> In this one I've also used windows to hide the middle section: on hardware
> it's a mess.

## HblankEmuTest.sfc

> The test I accidentally attached is actually one to test what happens to
> sprites as you force blank during h-blank. It should not load them, causing
> them to disappear and show the correct emulator screen. However there are many
> quirks surrounding this and that test doesn't really show those. I'll come up
> with a better one later.

There's more discussion of this test ROM in [the H-blank emulator inaccuracy
thread](https://forums.nesdev.com/viewtopic.php?f=12&t=18216).
