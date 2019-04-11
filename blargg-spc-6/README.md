# blargg's missing SPC test ROMs

Posted by qwertymodo [on the nesdev forum][p].

[p]: https://forums.nesdev.com/viewtopic.php?f=12&t=18005

> Apparently byuu managed to find blargg's long-lost SPC test ROMs on an old
> thumb drive.

Later in the thread, byuu explains:

> Yes, they were work-in-progress test ROMs. The 6 in the filename is because
> blargg would send me a new version periodically, and that was the final
> version I received back at the time.
>
> There are a huge amount of variations in real-world SNES consoles. Indeed,
> passing these tests are not a proof of correctness as such.
>
> What they are, to me, is a proof of correctness of blargg's DSP core. Which
> is invaluable. I need to make an extremely drastic DSP core change due to
> recently discovered peculiarities in Magical Drop: it seems the initial
> register values are non-deterministic and yet reading from the register ports
> are. But blargg shared the RAM and registers as a 128-byte array. I've been
> very afraid to attempt rewriting the core to split the two, because without
> these invaluable test ROMs, I could not be certain I hadn't introduced a
> painful regression.
