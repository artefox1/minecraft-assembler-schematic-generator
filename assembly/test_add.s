; load immediates, add them, store into register, then store into port/memory
LDI R7 0x3C ; store port address

LDI R0 0x05
LDI R1 0x03
ADD R2 R0 R1

MST R2 R7 ; store result into port (should be 0000 1000)
HLT