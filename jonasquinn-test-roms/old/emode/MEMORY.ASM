;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; SNES ROM Bank Map
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

.MEMORYMAP
                 
SLOTSIZE $10000   
DEFAULTSLOT 0    
SLOT 0 $0000     
.ENDME

.ROMBANKSIZE $10000
.ROMBANKS 1

.BANK 0 

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;  Cartridge Header                                                             
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

.ORG    $FFC0 
.DB     "DIRECT PAGE E=1      "
;       "123456789012345678901"

.ORG    $FFD5 
.DB     $21             ; Memory Mode
.DB     $02             ; ROM Type
.DB     $09             ; ROM Size
.DB     $05             ; SRAM Size
.DB     $02             ; Country 
.DB     $00             ; Licensee Code
.DB     $01             ; Version
.DW     $FFFF           ; Checksum Complement
.DW     $0000          	; Checksum

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Interrupt Vector Table
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

.ORG    $FFE4 			; === Native Mode ===
.DW     EmptyHandler 	   	; COP
.DW     EmptyHandler   		; BRK
.DW     EmptyHandler	    	; ABORT
.DW     VBlank			; NMI
.DW     $0000 	     		; (Unused)
.DW     EmptyHandler   		; IRQ

.ORG    $FFF4 			; === Emulation Mode ===
.DW     EmptyHandler    	; COP
.DW     $0000           	; (Unused)
.DW     EmptyHandler    	; ABORT
.DW     EmptyHandler    	; NMI
.DW     Reset 			; RESET
.DW     EmptyHandler    	; IRQ/BRK

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
