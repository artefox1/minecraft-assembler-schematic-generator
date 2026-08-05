# port addresses
define port0 0x3C
define port1 0x3D
define port2 0x3E
define port3 0x3F

# P1 P2 P3 P4 = X, YH, YL, COLOUR

# memory addresses
# coefficients
# a: 000005:000004
define aH 0x05
define aL 0x04
# b: 000007:000006
define bH 0x07
define bL 0x06
# c: 000009:000008
define cH 0x08
define cL 0x09
# d: 00000B:00000A
define dH 0x0B
define dL 0x0A
# e: 00000D:00000C
define eH 0x0D
define eL 0x0C
# f: 00000F:00000E
define fH 0x0F
define fL 0x0E

# x values (0x10, 0x11 are reserved, not 0x11 but too late)
define x1H 0x13
define x1L 0x12

define x2H 0x15
define x2L 0x14

define x3H 0x17
define x3L 0x16

define x4H 0x19
define x4L 0x18

define x5H 0x1B
define x5L 0x1A

define yH 0x1D
define yL 0x1C

define lastyH 0x1F
define lastyL 0x1E

# to align with vcb program
nop
nop

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
# LOOK AT PORT TO DETERMINE WHICH GRAPH
# 0 = CUBIC, 1 = W SHAPE, 2 = M SHAPE, 3 = X^5 CURVE, 4 = QUADRATIC

ldi r1 1
ldi r2 2
ldi r3 3
ldi r4 4

ldi r7 0x3C
mld r7 r7

# compare with each number
sub r0 r7 r0
beq graph_0
sub r0 r7 r1
beq graph_1
sub r0 r7 r2
beq graph_2
sub r0 r7 r3
beq graph_3
sub r0 r7 r4
beq graph_4
hlt # otherwise halt

@graph_0
# a = +0.00000000 = 00000000 00000000
# b = +0.00000000 = 00000000 00000000
# c = -1.00000000 = 11111111 00000000
# d = +0.00000000 = 00000000 00000000
# e = +2.00000000 = 00000010 00000000
# f = +0.00000000 = 00000000 00000000

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 aH
ldi r3 aL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 bH
ldi r3 bL
mst r2 r4
mst r1 r3

ldi r2 0b11111111
ldi r1 0b00000000
ldi r4 cH
ldi r3 cL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 dH
ldi r3 dL
mst r2 r4
mst r1 r3

ldi r2 0b00000010
ldi r1 0b00000000
ldi r4 eH
ldi r3 eL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 fH
ldi r3 fL
mst r2 r4
mst r1 r3

jmp actual_start

@graph_1
# a = +0.00000000 = 00000000 00000000
# b = +0.60156250 = 00000000 10011010
# c = +0.00000000 = 00000000 00000000
# d = -2.00000000 = 11111110 00000000
# e = +0.00000000 = 00000000 00000000
# f = +0.50000000 = 00000000 10000000

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 aH
ldi r3 aL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b10011010
ldi r4 bH
ldi r3 bL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 cH
ldi r3 cL
mst r2 r4
mst r1 r3

ldi r2 0b11111110
ldi r1 0b00000000
ldi r4 dH
ldi r3 dL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 eH
ldi r3 eL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b10000000
ldi r4 fH
ldi r3 fL
mst r2 r4
mst r1 r3

jmp actual_start

@graph_2
# a = -1.89843750 = 11111110 00011010
# b =-10.00000000 = 11110110 00000000
# c = -9.00000000 = 11110111 00000000
# d = +4.80078125 = 00000100 11001101
# e = +5.39843750 = 00000101 01100110
# f = -0.50000000 = 11111111 10000000

ldi r2 0b11111110 
ldi r1 0b00011010
ldi r4 aH
ldi r3 aL
mst r2 r4
mst r1 r3

ldi r2 0b11110110 
ldi r1 0b00000000
ldi r4 bH
ldi r3 bL
mst r2 r4
mst r1 r3

ldi r2 0b11110111 
ldi r1 0b00000000
ldi r4 cH
ldi r3 cL
mst r2 r4
mst r1 r3

ldi r2 0b00000100 
ldi r1 0b11001101
ldi r4 dH
ldi r3 dL
mst r2 r4
mst r1 r3

ldi r2 0b00000101 
ldi r1 0b01100110
ldi r4 eH
ldi r3 eL
mst r2 r4
mst r1 r3

ldi r2 0b11111111 
ldi r1 0b10000000
ldi r4 fH
ldi r3 fL
mst r2 r4
mst r1 r3

jmp actual_start

@graph_3
# a = +1.00000000 = 00000001 00000000
# b = +0.00000000 = 00000000 00000000
# c = -4.00000000 = 11111100 00000000
# d = +0.00000000 = 00000000 00000000
# e = +2.69921875 = 00000010 10110011
# f = +0.00000000 = 00000000 00000000

ldi r2 0b00000001
ldi r1 0b00000000
ldi r4 aH
ldi r3 aL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 bH
ldi r3 bL
mst r2 r4
mst r1 r3

ldi r2 0b11111100
ldi r1 0b00000000
ldi r4 cH
ldi r3 cL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 dH
ldi r3 dL
mst r2 r4
mst r1 r3

ldi r2 0b00000010
ldi r1 0b10110011
ldi r4 eH
ldi r3 eL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 fH
ldi r3 fL
mst r2 r4
mst r1 r3

jmp actual_start

@graph_4
# a = +0.00000000 = 00000000 00000000
# b = +0.00000000 = 00000000 00000000
# c = +0.00000000 = 00000000 00000000
# d = -1.00000000 = 11111111 00000000
# e = +0.00000000 = 00000000 00000000
# f = +1.00000000 = 00000001 00000000

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 aH
ldi r3 aL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 bH
ldi r3 bL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 cH
ldi r3 cL
mst r2 r4
mst r1 r3

ldi r2 0b11111111
ldi r1 0b00000000
ldi r4 dH
ldi r3 dL
mst r2 r4
mst r1 r3

ldi r2 0b00000000
ldi r1 0b00000000
ldi r4 eH
ldi r3 eL
mst r2 r4
mst r1 r3

ldi r2 0b00000001
ldi r1 0b00000000
ldi r4 fH
ldi r3 fL
mst r2 r4
mst r1 r3

# ACTUAL START
@actual_start

# store iterations in 0x10, make sure it does 128
ldi r1 0b10000000
ldi r2 0x10
mst r1 r2

# start at -2 and iterate by 0.03125 (8.8 fixed point)
# so 11111110.00000000 and iterate by 00000000.00001000
ldi r1 0b11111110
ldi r2 x1H
mst r1 r2
ldi r1 0b00000000
ldi r2 x1L
mst r1 r2

# START OF LOOP
@loop
# GET ALL X DEGREES
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 x1H
ldi r1 x1L
mld r2 r2
mld r1 r1 # put x into r2:r1
mov r4 r2
mov r3 r1 # put x into r4:r3
cal signed_multiply_16
ldi r2 x2H
ldi r1 x2L
mst r7 r2
mst r6 r1 # store x2

# put x into r2:r1 and x2 into r4:r3
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 x1H
ldi r1 x1L
mld r2 r2
mld r1 r1 # put x into r2:r1
mov r4 r7
mov r3 r6 # move r7:r6 to r4:r3
cal signed_multiply_16
ldi r2 x3H
ldi r1 x3L
mst r7 r2
mst r6 r1 # store x3

# put x into r2:r1 and x3 into r4:r3
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 x1H
ldi r1 x1L
mld r2 r2
mld r1 r1 # put x into r2:r1
mov r4 r7
mov r3 r6 # move r7:r6 to r4:r3
cal signed_multiply_16
ldi r2 x4H
ldi r1 x4L
mst r7 r2
mst r6 r1 # store x4

# put x into r2:r1 and x4 into r4:r3
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 x1H
ldi r1 x1L
mld r2 r2
mld r1 r1 # put x into r2:r1
mov r4 r7
mov r3 r6 # move r7:r6 to r4:r3
cal signed_multiply_16
ldi r2 x5H
ldi r1 x5L
mst r7 r2
mst r6 r1 # store x5 (TECHNICALLY WE DON'T NEED TO BUT IDC)
# END OF GETTING DEGREES

# MULTIPLY BY COEFFICIENTS AND ACCUMULATE
# multiply x5 by a and put it in y
# x5 is already in r7:r6
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 aH
ldi r1 aL
mld r2 r2
mld r1 r1 # get a into r2:r1
mov r4 r7
mov r3 r6 # put x5 in r4:r3
cal signed_multiply_16
ldi r2 yH
ldi r1 yL
mst r7 r2
mst r6 r1 # put straight into y (no accumulating yet)

# multiply x4 by b and add to y
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 bH
ldi r1 bL
mld r2 r2
mld r1 r1 # get b into r2:r1
ldi r4 x4H
ldi r3 x4L
mld r4 r4
mld r3 r3 # get x4 into r4:r3
cal signed_multiply_16
ldi r4 yH
ldi r3 yL
mld r2 r4
mld r1 r3 # get y into r2:r1
add r1 r1 r6
adc r2 r2 r7 # add bx4 to y
mst r2 r4
mst r1 r3 # put y back

# multiply x3 by c and add to y
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 cH
ldi r1 cL
mld r2 r2
mld r1 r1 # get c into r2:r1
ldi r4 x3H
ldi r3 x3L
mld r4 r4
mld r3 r3 # get x3 into r4:r3
cal signed_multiply_16
ldi r4 yH
ldi r3 yL
mld r2 r4
mld r1 r3 # get y into r2:r1
add r1 r1 r6
adc r2 r2 r7 # add cx3 to y
mst r2 r4
mst r1 r3 # put y back

# multiply x2 by d and add to y
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 dH
ldi r1 dL
mld r2 r2
mld r1 r1 # get d into r2:r1
ldi r4 x2H
ldi r3 x2L
mld r4 r4
mld r3 r3 # get x2 into r4:r3
cal signed_multiply_16
ldi r4 yH
ldi r3 yL
mld r2 r4
mld r1 r3 # get y into r2:r1
add r1 r1 r6
adc r2 r2 r7 # add dx2 to y
mst r2 r4
mst r1 r3 # put y back

# multiply x1 by e and add to y
ldi r1 0b000001 # reset product
mst r0 r1
adi r1 0x01
mst r0 r1
adi r1 0x01
mst r0 r1

ldi r2 eH
ldi r1 eL
mld r2 r2
mld r1 r1 # get e into r2:r1
ldi r4 x1H
ldi r3 x1L
mld r4 r4
mld r3 r3 # get x1 into r4:r3
cal signed_multiply_16
ldi r4 yH
ldi r3 yL
mld r2 r4
mld r1 r3 # get y into r2:r1
add r1 r1 r6
adc r2 r2 r7 # add ex1 to y
mst r2 r4
mst r1 r3 # put y back

# add f to y
ldi r7 fH
ldi r6 fL
mld r7 r7
mld r6 r6 # get f into r7:r6
ldi r4 yH
ldi r3 yL
mld r2 r4
mld r1 r3 # get y into r2:r1
add r1 r1 r6
adc r2 r2 r7 # add f to y
mst r2 r4
mst r1 r3 # put y back
# END OF CALCULATING Y

# INCREMENT BY 00000000.00001000
# PERSONAL CHOICE AS RANGE IS -2 to 2 AND USING 8.8 SO USE 00.00000 (7-bit, 128)

# y is already in r2:r1

ldi r7 0x10
mld r6 r7
ldi r7 0x3C
mst r6 r7 # put iterations in port1

# CONNECT THE DOTS, NEED YH AND YL FOR CLIPPING

# mask lower bits in resolution of pixel display (00000000.00000XXX)
ldi r5 0b11111000
and r1 r1 r5

# y is already in r2:r1
# load last y into r4:r3
ldi r5 lastyH
ldi r6 lastyL
mld r4 r6
mld r3 r5
mst r2 r6 # update lasty
mst r1 r5

# if iterations is 128 then set last y to y
ldi r7 0x10
mld r6 r7
ldi r7 0x80
sub r0 r6 r7 # check if = 128
bne not_first_time
mov r4 r2 # store y into lasty
mov r3 r1
@not_first_time

# NO A > B
# SO CHECK A = B BEFORE SO DOESNT GET CAUGHT IN A >= B
# I MIGHT HAVE BEEN ABLE TO DO B - A SINCE IM REPEATING THE OPERATIONS ANYWAY BUT THIS WORKS

# DO LASTY - Y
# CHECK NEGATIVE: H < 0 THEN LASTY < Y
# CHECK ZERO: check L, if !0 break, otherwise check H, if 0 then LASTY = Y
# CHECK POSITIVE: only other option, just jump

sub r0 r3 r1
sbb r0 r4 r2 # H
bng cond1 # LASTY < Y

sub r0 r3 r1
bne cond2 # LASTY > Y, only other option, just jump
sbb r0 r4 r2
beq cond3 # LASTY = Y
jmp cond2 # LASTY > Y OTHERWISE (need this after checking L, think of 00000001.00000000)

# LASTY < Y
@cond1
# connect from last y + 1 to y
ldi r7 0b00001000
add r3 r3 r7 # add 1 to last y and store temp counter into r4:r3 (don't need lasty anymore)
adc r4 r4 r0

@loop1
# set pixel
ldi r5 0x3D
mst r4 r5 # store YH
ldi r5 0x3E
mst r3 r5 # store YL
ldi r5 0x3F
mst r0 r5 # store COLOUR

# check if temp counter >= y (basically not negative)
# only need to check H but still calculate both
sub r0 r3 r1
sbb r0 r4 r2
bps end_line
# this process is required because need to increment tempy after checking (what if lasty = y-1)
adi r3 0b00001000
adc r4 r4 r0
jmp loop1
# END OF LASTY < Y

# LASTY > Y
@cond2
# connect from y to lasty - 1
ldi r7 0b00001000
sub r3 r3 r7 # sub 1 from last y
sbb r4 r4 r0

# use y (r2:r1) as temp counter (as opposed to lasty)

@loop2
# set pixel
ldi r5 0x3D
mst r2 r5 # store YH
ldi r5 0x3E
mst r1 r5 # store YL
ldi r5 0x3F
mst r0 r5 # store COLOUR

# check if temp counter >= lasty - 1 (basically not negative)
# only need to check H but still calculate both
sub r0 r1 r3
sbb r0 r2 r4
bps end_line

adi r1 0b00001000
adc r2 r2 r0
jmp loop2
# END OF LASTY > Y

# LASTY = Y
@cond3
# just place at y
ldi r5 0x3D
mst r4 r5 # store YH
ldi r5 0x3E
mst r3 r5 # store YL
ldi r5 0x3F
mst r0 r5 # store COLOUR

# END OF CONNECTING DOTS

@end_line

# iterate x by 00000000.00001000
ldi r2 x1H
ldi r1 x1L
mld r4 r2
mld r3 r1 # put x into r4:r3
ldi r5 0b00001000 # increment val
add r3 r3 r5
adc r4 r4 r0
mst r4 r2
mst r3 r1

# get iterations, subtract and check if zero
ldi r2 0x10
mld r1 r2
adi r1 0b11111111
mst r1 r2
bne loop
# END OF LOOP

hlt