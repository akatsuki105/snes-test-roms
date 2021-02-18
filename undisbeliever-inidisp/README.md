# Undisbeliever's INIDISP tests

This is a `git subtree` mirror of [the original repository][r].
Run `./update-sources` to update the mirror to the latest version.
Note that the original repository includes a git submodule which is *not*
included here.

[r]: https://github.com/undisbeliever/snes-test-roms

They described these tests in [a NESdev post][p]:

> The tests for the INIDISP glitch are `hdma-2100-*.sfc`, `hdma-21ff-*.sfc`,
> `inidisp_d7_glitch_test.sfc` and `inidisp_hammer_*.sfc`.
>
> The following tests do not glitch: `hdma-2100-glitch-2ch-0a.sfc`,
> `hdma-21ff-glitch.sfc` and `inidisp_hammer_0f0f.sfc`.
>
> The `hdma-21ff-2100-0f-glitch.sfc` test glitches due to the fxpack firmware
> bug Near mentioned above.
>
> You may need to reset your console a few times for the glitches to appear on
> the `hdma-2100-*.sfc` and `hdma-21ff-*.sfc` tests (they appear ~40% on the
> time on my console)
>
> The `hdma-2100-*` and `hdma-21ff-*` tests require the "Reset patch for clock
> phase" setting off on an FXPAK.
>
> I have been able to trigger a sprite glitch on my 3-chip console with:
>
>    - A HDMA write that has bit 7 set, immediately followed by a HDMA write to
>      INIDISP (`hdma-21ff-2100-glitch.sfc`)
>    - A HDMA write to INIDISP on the first active HDMA channel, after the CPU
>      has read/written a byte with the 7th bit set. (`hdma-2100-glitch.sfc`,
>      the bit 7 is set by a `bra` spinloop)
>
>    - `ldx.w #$0f80 ; stx.w $20ff`. Writes $80 to $20ff, $0f to $2100
>      (`inidisp_d7_glitch_test.sfc`)
>    - `lda.b #$0f ; sta.l $802100`. The data bus $80 before the write to $2100
>      (`inidisp_hammer_0f_long.sfc`)
>
> I have been able to trigger a brightness glitch on my 3-chip and 1-chip
> consoles with:
>    - `ldx.w #$0f00 ; stx.w $20ff`. Writes $00 to $20ff, $0f to $2100
>      (`inidisp_hammer_0f00.sfc`)
>    - `lda.b #$0f ; sta.w $2100`. The data bus $21 before the write to $2100
>      (`inidisp_hammer_0f.sfc`)
>
> This glitch also affects the inverse. Accidentally activating the display for
> about a dot while in force-blank if the data-bus had bit 7 clear before the
> INIDISP write (on my 3-chip console).
> 
>    - `ldx.w #$8f0f ; stx.w $20ff`. Writes $0f to $20ff, $8f to $2100
>      (`inidisp_hammer_0f8f.sfc`)

[p]: https://forums.nesdev.com/viewtopic.php?p=265225#p265225

("Expected result" screenshots come from Undisbeliever's 3-chip 2/1/3 Super
Famicom)
