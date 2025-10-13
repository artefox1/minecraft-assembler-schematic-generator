; test number 4

; reset port
LDI R7 0x3F
MST R0 R7

; STACK operations (0x3D = 0x04)
CAL dstack
MST R5 R7
HLT
NOP
NOP
NOP

@dstack
LDI R3 0x04 ; load r3 with 4
PSH R3
POP R5 ; put it into r5 for a change
RET