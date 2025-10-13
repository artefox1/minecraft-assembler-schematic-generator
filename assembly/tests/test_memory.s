; testing memory load specifically

; reset port
LDI R7 0x3E
MST R0 R7

; MEMORY operations (0x3E = 0x03)
LDI R6 0b110101 ; address
LDI R5 0x03 ; value
MST R5 R6 ; store 0x03 into 110101
MLD R4 R6 ; load it into r4

MST R4 R7 ; store 0x03 into port

HLT