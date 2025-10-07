; Sample code
; Supports capitals, comments using ; # //, hexadecimal, binary, decimal numbers
; Example of numbers: 0x55, 0b1001, 125

; Port addresses:
; 0x3C, 0x3D, 0x3E, 0x3F

# Code start

aDd r1 R2 r3 ; Address registers using r1 - r7, A - G, reg0 - reg7 (case does not matter)
LDI r4 213 # code code
; more code
// even more code
HLT // gaga

bge 0b11010101111111 ; jump if greater or equal and automatically detects overflow cuts off higher bits

xor r5 r0 r4
jmp spot ; labels!!!

ldi r1 56
   mst r5 r2 ; whitespace doesn't matter either

@spot ; declare with @
ADD R5 REG2 r5
SuB r1 r7 ReG4 ; ok whaAAT

nop ;idk
xor r4 r5 reg3