lorom

org $8000; fill $020000

org $ffc0; db "HARDWARE TEST        "
org $ffd5; db $30
org $ffd6; db $02
org $ffd7; db $07
org $ffd8; db $05
org $ffdc; dw $5555
org $ffde; dw $aaaa
org $ffea; dw $ffaa  //NMI
org $ffee; dw $ffad  //IRQ
org $fffc; dw $8000  //Reset

define nmi_vector $1ffa
define irq_vector $1ffd

org $ffaa; jmp [{nmi_vector}]
org $ffad; jmp [{irq_vector}]