# PPU Bus Activity Traces

Posted by lidnariq [on the nesdev forum][p].

[p]: https://forums.nesdev.com/viewtopic.php?t=14467

> Tried to get all of AWJ's requests.
>
> Rather than a separate trace for each PPU mode, I used HDMA to switch to the
> next mode every 32 scanlines. Layer 1 is using 16x16 tiles, layers 2-4 are
> using 8x8 tiles. Sprites #0-95 are 16x16, sprites #96-127 are 8x8.
>
> Every sixteenth word of the nametable for layer 1 has the "flipped
> horizontally" bit set.
>
> Sample rate is now 12MHz, so the aliasing will be a bit more annoying
> (alternating between 167ns and 250ns instead of the true value of 186ns)
>
> I couldn't get all the logic analyzer clips on one RAM, so this is a random
> mixture of lines on U5 and U4.
>
> Pertinent details: BGnSC of $70, $74, $78, $7C; BGnNBA of 0, 3, 5, 6;
> OBSEL=$0A. HDMA changes BGMODE from $10...$16, each value lasting for 32
> scanlines. HDMA changes BG3VOFS to get offset-per-tile to be visible.

There were three attachments to that post:

  - [`cooked.csv`](./cooked.csv):
    "first column is CSYNC, other column is PPU
    bus address in hexadecimal"
  - [`ppubusact.sfc`](./ppubusact.sfc):
    "just for reference"
  - [`ppubusactivity_rev2_sr`](./ppubusactivity_rev2.sr):
    "open with sigrok pulseview"

Then, a summary:

> Well, let's try to recapitulate [AWJ's previous analysis][a], with the extra
> data:
>
> Mode 0: no new insights.
>
> Modes 1 & 3: Lower-addressed bitplane is fetched first
>
> Mode 2: Also lower-addressed OPT row is fetched first
>
> Mode 5: Fetch cadence appears to be completely identical to mode 3. Horizontal
> flip flag does reverse left-right fetch order.
>
> Modes 4,6: No new insights beyond above.
>
> Sprites: Lower-addressed bitplane is fetched first. Horizontally flipped
> sprites reverse sliver fetch order.
>
> Each scanline fetches 33 slivers for tiles (taking 8 cycles per tile, for 264
> total cycles), followed by 8 idle cycles (bus unchanging), followed by 34
> slivers for sprites (taking 2 cycles per sliver, 68 total cycles). That's only
> 340 cycles, but there's 341 usually; two extra half-cycles appear to be be
> inserted during hsync and immediately after it ends.
>
> Hsync timing is not obviously aligned to sprite fetch cycles. It's hard to
> tell anything more precise with the comparatively low sample rate.

[a]: https://forums.nesdev.com/viewtopic.php?f=12&t=14281&p=173458#p173458
