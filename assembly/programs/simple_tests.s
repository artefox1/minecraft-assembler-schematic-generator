jmp start

@addition
add r3 r1 r2
bne skip
hlt
@skip
ret

@start
ldi r2 0b00000011
ldi r1 0b00001001

cal addition

# display product
ldi r4 0x3C
mst r3 r4

# rest is 0
adi r4 0x01
mst r0 r4
adi r4 0x01
mst r0 r4
adi r4 0x01
mst r0 r4

hlt