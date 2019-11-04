.ifndef GLOBAL_INC
.define GLOBAL_INC

; init.s
.global reset_handler

; main.s
.global main, nmi_handler, irq_handler
.globalzp nmis, cur_keys
.global OAM, OAMHI

; ppuclear.s
.global ppu_clear_nt, ppu_screen_on, ppu_vsync
.global ppu_pack_oamhi, ppu_copy_oam, ppu_copy

; unpb16.s
.global unpb16, unpb16_to_vram_y, unpb16_to_vram_y_mode_x
.global pb16buffer
.globalzp ciSrc

; telling.s
.global tell_ly

.endif
