// Constantly writes 0x0f00 to $20ff (0x00 to $20ff, 0x0f to $2100)
//
// Copyright (c) 2021, Marcus Rowe <undisbeliever@gmail.com>.
// Distributed under The MIT License: https://opensource.org/licenses/MIT


define ROM_NAME = "INIDISP HAMMER TEST"
define VERSION = 1

include "_inidisp_d7_common.inc"


au()
iu()
code()
function Main {
    rep     #$30
    sep     #$20
a8()
i16()
    sei

    SetupPpu()


    // ::TODO remove BG/OAM and replace with a white screen::

    ldx.w   #0x0f00
    MainLoop:
        stx.w   INIDISP - 1

        bra     MainLoop
}

