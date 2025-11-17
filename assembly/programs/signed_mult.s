# Copyright © 2025 artefox

jmp start

# product in r7:r6:r5, unsigned in 000003:000002:000001, uses 000000
@signed_multiply_16
# A: r2:r1 (little endian)
# B: r4:r3
# C: r7:r6:r5 (no one cares about higher byte)

# get absolute values of inputs
# store sign in 0b000000
ldi r5 0x00 # sign register
ldi r6 0x01 # one
ldi r7 0b000000 # address

adi r2 0x00 # test if A is negative
bps a_skip_abs
xor r5 r5 r6 # xor with 1
sub r1 r0 r1 # subtract and extend if negative
sbb r2 r0 r2
@a_skip_abs

adi r4 0x00
bps b_skip_abs
xor r5 r5 r6
sub r3 r0 r3
sbb r4 r0 r4
@b_skip_abs

mst r5 r7 # store sign (1 if negative)

# if lsb of B = 1, add A, then lsh A and rsh B
# A needs 3 bytes
# store product in 000003:000002:000001
# r7 = iterations, r6 = 1
# C = r7:r6:r5 (temporarily hijack then go back into memory)
# A = r3:r2:r1
# B = r5:r4
mov r5 r4
mov r4 r3 # move up B
ldi r3 0x00

ldi r7 16
@mult_loop

# test B lsb
and r0 r4 r6
beq skip_add
# add if not zero
psh r7 # temp store B, loop to load product
psh r6
psh r5
psh r4 # temp address
ldi r4 0b000001
mld r5 r4
adi r4 0x01
mld r6 r4
adi r4 0x01
mld r7 r4

add r5 r5 r1
adc r6 r6 r2
adc r7 r7 r3

# store product and recover values
mst r7 r4
adi r4 0xFF # subtract now
mst r6 r4
adi r4 0xFF
mst r5 r4
pop r4
pop r5
pop r6
pop r7

@skip_add
# lsh A and rsh B, then dec loop
add r1 r1 r1
adc r2 r2 r2
adc r3 r3 r3

# rsh with carry
rsh r4 r4
and r0 r5 r6 # test B lsb
beq skip_ror
adi r4 0x80
@skip_ror
rsh r5 r5

adi r7 0xFF # decrement loop
bne mult_loop # loop if still not zero

# load product
ldi r4 0b000001
mld r5 r4
adi r4 0x01
mld r6 r4
adi r4 0x01
mld r7 r4

# load sign to see if negate product
ldi r4 0b000000
mld r3 r4 # load sign into r3
add r0 r3 r0 # test sign
beq skip_negate

sub r5 r0 r5
sbb r6 r0 r6
sbb r7 r0 r7

@skip_negate
ret

@start
ldi r1 0b000001
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 0b11111111
ldi r1 0b11111110
ldi r4 0b00000000
ldi r3 0b00000101

cal signed_multiply_16

# display product
# p0:p1:p2
ldi r4 0x3C
mst r7 r4
adi r4 0x01
mst r6 r4
adi r4 0x01
mst r5 r4

# p4 is 0
adi r4 0x01
mst r0 r4

hlt