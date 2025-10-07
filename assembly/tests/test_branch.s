; branch because true, check if it properly discards the following instructions, especially the next 3
LDI R7 0x3C ; store port address
LDI R1 0x00 ; reset 0x01

ADD R0 R0 R0 ; equals zero
BEQ 0x0A ; so branch ahead
ADI R1 1 ; FLUSHED
ADI R1 1 ; FLUSHED
ADI R1 1 ; FLUSHED
ADI R1 1
ADI R1 1
ADI R1 1 ; ignore all of these
; branch here
ADI R1 0x0A
MST R1 R7 ; output should be 00001010
HLT