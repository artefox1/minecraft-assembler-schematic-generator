# Copyright © 2025 artefox

# memory map:
# real, imag: 4, 5
# x, y: 7:6, 9:8
# x2, y2: 11:10, 13:12
# iterations, imag_loop, real_loop: 16, 17, 18
# real    0b000100
# imag    0b000101
# xh      0b000111
# xl      0b000110
# yh      0b001001
# yl      0b001000
# x2h     0b001011
# x2l     0b001010
# y2h     0b001101
# y2l     0b001100
# iter    0b010000
# im_loop 0b010001
# re_loop 0b010010

jmp start

# product in r7:r6:r5, unsigned in 000003:000002:000001, uses 000000
# does not reset product memory!
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
# start at 0b10011000,0b10111010 (0b000100, 0b000101) but 0b000100 + 6 for aesthetics
# step by 3
# 0b000101 is 18 loops, 0b000100 is 35, 0b010000 is 24
ldi r1 0b010001 # reset 0b000101
ldi r2 23
mst r2 r1

ldi r1 0b000101
ldi r2 0b10111010
mst r2 r1

@imag_loop
ldi r1 0b010010 # reset 0b000100 at start of every 0b000101 loop
ldi r2 45
mst r2 r1

ldi r1 0b000100
ldi r2 0b10011110
mst r2 r1

@real_loop
# mandelbrot here
ldi r1 0b010000
ldi r2 24
mst r2 r1

# reset x, y
ldi r1 0b000111
mst r0 r1
ldi r1 0b000110
mst r0 r1
ldi r1 0b001001
mst r0 r1
ldi r1 0b001000
mst r0 r1

@iterations
# get x^2 y^2 xy products
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1
# load A B with x
ldi r7 0b000111
mld r2 r7
mov r4 r2
ldi r7 0b000110
mld r1 r7
mov r3 r1
cal signed_multiply_16 # we care about r7:r6
ldi r5 0b001011
mst r7 r5
ldi r5 0b001010
mst r6 r5 # store x^2

ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r7 0b001001
mld r2 r7
mov r4 r2
ldi r7 0b001000
mld r1 r7
mov r3 r1
cal signed_multiply_16
ldi r5 0b001101
mst r7 r5
ldi r5 0b001100
mst r6 r5 # store y^2

# test if break (x^2 + y^2 >= 4)
# y2 is in r7:r6 already
# get x2 in r5:r4
ldi r3 0b001011
mld r5 r3
ldi r3 0b001010
mld r4 r3

# add them to r3:r2
add r2 r4 r6
adc r3 r5 r7

# compare to 4 (0b00000100.00000000)
ldi r1 0x04
sub r0 r3 r1 # if high - 4 >= 0, then l >= 4
bps break

# do xy
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r7 0b000111
mld r2 r7
ldi r7 0b000110
mld r1 r7
ldi r7 0b001001
mld r4 r7
ldi r7 0b001000
mld r3 r7
cal signed_multiply_16 # dont needa store xy use it instantly

# do 2xy + 0b000101 first to avoid storing xy
# lsh xy (already 8.8 sign extended)
add r6 r6 r6
adc r7 r7 r7

# load 0b000101 to r4 and lsh 2 into r5 to be 8.8
ldi r4 0b000101
mld r4 r4
ldi r5 r0 # make sure h is 0
add r4 r4 r4 # if this goes into carry, sign extend
blt skip_imag_sign # skip if not
adi r5 0xFF
@skip_imag_sign
add r4 r4 r4
adc r5 r5 r5 # then do normally already sign extended

# 2xy is r7:r6 and 0b000101 is r5:r4, add to r7:r6
add r6 r4 r6
adc r7 r5 r7 # newy is now in r7:r6, and can store it bc no use for y
# store new y into y
ldi r5 0b001001
mst r7 r5
ldi r5 0b001000
mst r6 r5

# do x2 - y2 + 0b000100, put it in x
# put x2 into r5:r4 and y2 into r7:r6
ldi r3 0b001011
mld r5 r3
ldi r3 0b001010
mld r4 r3
ldi r3 0b001101
mld r7 r3
ldi r3 0b001100
mld r6 r3

# do x2 - y2 put into r7:r6
sub r6 r4 r6
sbb r7 r5 r7

# load 0b000100 into r4 and lsh 2 into r5
ldi r4 0b000100
mld r4 r4
ldi r5 r0
add r4 r4 r4
blt skip_real_sign
adi r5 0xFF
@skip_real_sign
add r4 r4 r4
adc r5 r5 r5

# add 0b000100 to x2 - y2
add r6 r4 r6
adc r7 r5 r7
# store x
ldi r5 0b000111
mst r7 r5
ldi r5 0b000110
mst r6 r5

ldi r1 0b010000
mld r2 r1
adi r2 0xFF
mst r2 r1
bne iterations
# END OF ITERATION LOOP
@break
# output 0b010010, 0b010001, and 0b010000 to p0, p1, p2
# gotta output 45 - 0b010010 and 23 - 0b010001
ldi r1 0b010010
mld r2 r1
ldi r3 45
sub r2 r3 r2
ldi r1 0x3C
mst r2 r1

# 22 - y
ldi r1 0b010001
mld r2 r1
ldi r3 23
sub r2 r3 r2
ldi r1 0x3D
mst r2 r1

ldi r4 0b010000
mld r5 r4
ldi r4 0x3E
mst r5 r4

# flip and plot again
# 22 - (22 - y) + 21 = y + 21
sub r2 r3 r2
adi r2 21
mst r2 r1
mst r5 r4

ldi r1 0b000100 # add 3 to 0b000100
mld r2 r1
adi r2 0x03
mst r2 r1

ldi r1 0b010010
mld r2 r1
adi r2 0xFF
mst r2 r1
bne real_loop 
# END OF 0b000100 LOOP

ldi r1 0b000101 # add 3 to 0b000101
mld r2 r1
adi r2 0x03
mst r2 r1

ldi r1 0b010001
mld r2 r1
adi r2 0xFF
mst r2 r1
bne imag_loop 
# END OF 0b000101 LOOP

hlt