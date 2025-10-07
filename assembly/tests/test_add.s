; load immediates, add them, store into register, then store into port/memory
LDI R7 0x3C ; store port address

LDI R1 0x05
LDI R2 0x03
ADD R3 R1 R2

MST R3 R7 ; store result into port (should be 0000 1000)
HLT