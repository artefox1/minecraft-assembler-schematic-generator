; call stack test
; call to add then return back

LDI R7 0x3F
MST R0 R7  ; reset address

LDI R1 0x03
LDI R2 0x05
CAL 0x07    ; add
MST R3 R7   ; 3f = 0x08
HLT

; add
ADD R3 R1 R2
RET