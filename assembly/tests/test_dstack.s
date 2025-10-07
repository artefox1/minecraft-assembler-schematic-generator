; data stack test
; push, change reg, push, change reg, pop, pop

LDI R1 0x0A ; 1010
LDI R7 0x3C ; 3c
PSH R1      ; push 1010
ADI R1 0x01 ; 1011
MST R1 R7   ; 3c = 1011
PSH R1
ADI R1 0x01 ; 1100
ADI R7 0x01 ; 3d
MST R1 R7   ; 3d = 1100
POP R1
POP R1
ADI R7 0x01 ; 3e
MST R1 R7   ; 3e = 1010  recovered number
HLT