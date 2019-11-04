Telling LYs?
============

This program tests a Super NES emulator's input entropy.

The Super NES CPU can read the system's controller ports more often
than once per video frame, which is 50 or 60.1 Hz.  The state of
the controller ports can change at any time in the frame: top,
middle, bottom, or in the vertical blanking between frames.
A program can see exactly when the interrupt fired by polling the
controller repeatedly during a frame and latching the HV counter to
find the position in the frame.  For instance, a game could wait
for a press at its title screen and then seed a random number
generator from the time it took.

But simple emulators always change inputs at the same time each
frame, such as the start or end of vertical blanking.  The lack of
variance in timing is telling about whether an emulator was used;
hence the name.

How to use
----------
Starting at the title screen, press all four directions on the
Control Pad and all eight buttons (A, B, X, Y, L, R, Select, and
Start) of controller 1, one after another in any order.  The arrow
at the right side tells exactly when, relative to the PPU frame,
the last button changed from not pressed to pressed.  Once you have
pressed all eight keys, a screen for passing or failing appears.

Test results
------------
An NTSC Super NES (version 1/1/1) with SNES PowerPak passes.  Both
bsnes-plus 05 (November 2019, Compatibility profile) and Mesen-S
0.3 (October 2019) reach the "Incorrect behavior" screen, with the
arrow remaining usually just below the screen throughout the test.

Legal
-----
Copyright 2018, 2019 Damian Yerrick

Permission is granted to use this program under the terms of the
zlib License.
