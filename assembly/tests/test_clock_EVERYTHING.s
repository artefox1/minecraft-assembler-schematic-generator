; going through basically every instruction
; useful for testing max clock speed
; skipping instructions that are obviously not the bottleneck
; the tests shouldn't pass if not all instructions passed

; reset ports
LDI R7 0x3C
MST R0 R7
ADI R7 1
MST R0 R7
ADI R7 1
MST R0 R7
ADI R7 1
MST R0 R7

; ALU operations (0x3C = 0x01)
LDI R7 0x3C
LDI R1 0b00001010
LDI R2 0b00000010
LDI R3 0x00

XOR R3 R1 R2 ; xor should be 0x08
ADI R3 0b11111001 ; sub 7
MST R3 R7 ; store 1 and forwarding test

ADI R7 0x01 ; add 1 to address and value
MOV R1 R3
ADI R1 0x01

; BRANCH operations (0x3D = 0x02)
JMP branch
HLT ; halt if doesn't work
NOP
NOP
NOP

@branch
LDI R2 0x00
LDI R3 0x08
SUB R0 R2 R3 ; -8
BNG condition ; branch if negative
NOP
HLT

@condition
MST R1 R7 ; store 2

ADI R7 0x01 ; add 1 to address

@memory
; MEMORY operations (0x3E = 0x03)
LDI R6 0b110101 ; address
LDI R5 0x03 ; value
MST R5 R6
MLD R4 R6 ; load it into r4

MST R4 R7 ; store 3

ADI R7 0x01 ; add 1 to address

; STACK operations (0x3D = 0x04)
CAL dstack
MST R5 R7
HLT

@dstack
LDI R3 0x04 ; load r3 with 4
PSH R3
POP R5 ; put it into r5 for a change
RET