# Copyright © 2025 artefox

# memory map:
# port0 0x3C
# port1 0x3D
# port2 0x3E
# port3 0x3F
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

@iterations

ldi r1 0b010000
ldi r2 0x0F
mst r2 r1
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