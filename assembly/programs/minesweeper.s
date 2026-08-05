# Copyright © 2026 artefox
# the biggest program so far :')
# 10x10 board, 15 mines
# completely custom algorithm tailored to this cpu's restrictions

# rows 0-4 dedicated to LOW byte
# rows 5-9 dedicated to HIGH byte

# MEMORY MAP:
#  0 0000 zero
#  1 0001 one
#  2 0010 two
#  3 0011 three
#  4 0100 four
#  5 0101 five
#  6 0110 six
#  7 0111 seven
#  8 1000 eight
#  9 1001 closed
# 10 1010 flagged bomb
# 11 1011 flagged wrong
# 12 1100 bomb
# 13 1101
# 14 1110
# 15 1111 marked zero for processing

# TEXTURE MAP:
#  0 0000 zero
#  1 0001 one
#  2 0010 two
#  3 0011 three
#  4 0100 four
#  5 0101 five
#  6 0110 six
#  7 0111 seven
#  8 1000 eight
#  9 1001 closed
# 10 1010 flag
# 11 1011 hit
# 12 1100 bomb
# 13 1101 wrong
# 14 1110
# 15 1111

# FACES:
#  0 0000 happy (default)
#  1 0001 lose
#  2 0010 win
#  3 0100 shocked (processing)
#  4 1000 pressed (resetting)

# PORTS:
# make sure no code references an i coord for o or vice versa because they wont match up
# input:
define i_coord   0x3c # coordinate
define i_control 0x3d # reset (LSB) & flag (2LSB) signal, call it controls
define i_input   0x3e # input signal
define i_rng     0x3f # rng (reroll on every read, saves an output port)

# output:
define o_output  0x3c # acknowledge input
define o_texture 0x3d # texture
define o_coord   0x3e # coordinate
define o_hud     0x3f # happy face (high) & flag counter (low), call it hud

nop # align with vcb temporary
jmp reset

# bookmark Replace Bomb Subroutine
# replace bomb on first click, checking if not bomb nor temp 1111, affects r5, r6, r7
# generate location, rsh and store LSB for H/L,
# check if < 50, then make sure it's not bomb or temp (1111)
@replace
ldi r5 i_rng
mld r5 r5 # get random number
ldi r6 0b00000001
and r7 r5 r6 # test lsb for L/H, will use later
rsh r5 r5

# now check if number < 50 (x-50 < 0)
ldi r6 50
sub r0 r5 r6
bps replace # if not, try again

# now check if already bomb (12)
mld r6 r5 # load location into r6

# if r7 is 1, check H, if 0, check L
add r0 r7 r0
beq checkL1
# check H part of location
# 1001 if empty, 1100 if bomb, 1111 if temp, so check 01000000
ldi r7 0b01000000
and r0 r6 r7 # if one, then bomb/temp
bne replace
# if not, store it in H
ldi r7 0b00001111
and r6 r6 r7 # clear H
adi r6 0b11000000 # put into preexisting location
mst r6 r5 # send back
ret

@checkL1
ldi r7 0b00000100
and r0 r6 r7
bne replace
ldi r7 0b11110000
and r6 r6 r7
adi r6 0b00001100
mst r6 r5

ret

# bookmark Replace Singular Temp
# replace cell with 1111 (for first time click)
# uses r3 as natural index, affects r4, r5, r6
@replace_temp
# temporarily sub 50 if >= 50 to r6
ldi r5 50
sub r6 r3 r5 # subtracted ver in r6
bng lowcheck1
# high
mld r4 r6 # subtracted version
ldi r5 0b11110000
bor r4 r4 r5 # replace with 15
mst r4 r6
jmp done9
@lowcheck1
mld r4 r3
ldi r5 0b00001111
bor r4 r4 r5 # replace with 15
mst r4 r3
@done9
ret

# bookmark Replace Singular Closed
# replace cell with 1001 (for first time click)
# uses r3 as natural index, affects r4, r5, r6
@replace_closed
# temporarily sub 50 if >= 50 to r6
ldi r5 50
sub r6 r3 r5 # subtracted ver in r6
bng lowcheck3
# high
mld r4 r6 # subtracted version
ldi r5 0b00001111
and r4 r4 r5 # clear upper half
adi r4 0b10010000 # set to closed
mst r4 r6
jmp done10
@lowcheck3
mld r4 r3
ldi r5 0b11110000
and r4 r4 r5 # clear lower half
adi r4 0b00001001 # set to closed
mst r4 r3
@done10
ret

# bookmark Count Singular Mine
# count singular mine
# uses r3 as index, affects r5, r6
@check_mine
adi r4 1 # count mine then uncount if pass both (easiest way i could think of to pass two in row)
# temporarily sub 50 if >= 50 to r6, load data to r5
ldi r5 50
sub r6 r3 r5 # subtracted ver in r6
bng lowcheck
# high, use subtracted ver
mld r5 r6
ldi r6 0b11110000
and r5 r5 r6 # isolate high half
ldi r6 0b10100000 # check flagged bomb
sub r0 r5 r6
beq donecheck
ldi r6 0b11000000 # check bomb
sub r0 r5 r6
beq donecheck
adi r4 255 # uncount mine if neither
jmp donecheck
@lowcheck
mld r5 r3
ldi r6 0b00001111
and r5 r5 r6 # isolate low half
ldi r6 0b00001010 # check flagged bomb
sub r0 r5 r6
beq donecheck
ldi r6 0b00001100 # check bomb
sub r0 r5 r6
beq donecheck
adi r4 255 # uncount mine if neither
@donecheck
ret

# bookmark Count Mines Subroutine
# count mines
# gonna use r1 r2 as x, y and r3 as index. output to r4. affects r3 r5 r6 r7
# assumes index is in natural mode 0-99!
# RESET X,Y,INDEX AFTER, but keep index in natural mode no H/L shit
# DOESNT OUTPUT OR SAVE VALUE
@open
ldi r4 0 # start with zero bombs
ldi r7 9 # bound

# for x or y:
# -1, check < 0
#  0, don't check
# +1, check > 9

# start at -1 -1
adi r3 0b11110101 # (-1y - 1x = -11)
adi r1 255 # x -= 1
adi r2 255 # y -= 1
sub r0 r1 r0
bng done1 # if x < 0
sub r0 r2 r0
bng done1 # if y < 0
cal check_mine
@done1

# step x (now 0 -1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r2 r0
bng done2 # if y < 0
cal check_mine
@done2

# step x (now 1 -1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r1
bng done3 # if 9 < x
sub r0 r2 r0
bng done3 # if y < 0
cal check_mine
@done3

# step y and reset x (now -1 0)
adi r3 0b00001000 # (+1y - 2x = 8)
adi r1 254 # x -= 2
adi r2 1 # y += 1
sub r0 r1 r0
bng done4 # if x < 0
cal check_mine
@done4

# double step x (now 1 0)
adi r3 0b00000010 # (+2x = 2)
adi r1 2 # x += 2
sub r0 r7 r1
bng done5 # if 9 < x
cal check_mine
@done5

# step y and reset x (now -1 1)
adi r3 0b00001000 # (+1y - 2x = 8)
adi r1 254 # x -= 2
adi r2 1 # y += 1
sub r0 r1 r0
bng done6 # if x < 0
sub r0 r7 r2
bng done6 # if 9 < y
cal check_mine
@done6

# step x (now 0 1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r2
bng done7 # if 9 < y
cal check_mine
@done7

# step x (now 1 1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r1
bng done8 # if 9 < x
sub r0 r7 r2
bng done8 # if 9 < y
cal check_mine
@done8

# MINE COUNT IS NOW IN R4, NOW DO -1 -1 TO RESET COORD & INDEX (0, 0)
adi r3 0b11110101 # (-1y - 1x = -11)
adi r1 255 # x -= 1
adi r2 255 # y -= 1

ret

# bookmark Mark Zero for Floodfill
# IF CLOSED: open, store & output to display, then mark if it's zero
@zero_floodfill
# test if closed
# temporarily sub 50 if >= 50 to r6, load data to r5
ldi r5 50
sub r6 r3 r5 # subtracted ver in r6
bng lowcheck6
# high, use subtracted ver
mld r5 r6
ldi r6 0b11110000
and r5 r5 r6 # isolate high half
ldi r6 0b10010000
sub r0 r5 r6 # check closed
bne notclosed1
jmp donecheck2
@lowcheck6
mld r5 r3
ldi r6 0b00001111
and r5 r5 r6
ldi r6 0b00001001
sub r0 r5 r6
bne notclosed1
@donecheck2

cal open

# SEND OUTPUT SIGNAL TO DISPLAY
# CONVERT R1,R2 BACK INTO FULL COORD IN R5
add r5 r2 r2
add r5 r5 r5
add r5 r5 r5
add r5 r5 r5 # y << 4
add r5 r5 r1 # put back into one coord
ldi r6 o_coord
mst r5 r6
ldi r6 o_texture
mst r4 r6

# if 0 neighbours then change it to 1111 to store
sub r0 r4 r0
bne notzero
ldi r4 0b1111
@notzero

# STORE RESULT IN MEMORY
# uses r3 as natural index, loads preexisting into r5 and ORs r4
# temporarily sub 50 if >= 50 to r6
ldi r5 50
sub r6 r3 r5 # subtracted ver in r6
bng lowcheck67
# high
mld r5 r6 # subtracted version
ldi r7 0b00001111
and r5 r5 r7 # clear upper half
add r4 r4 r4
add r4 r4 r4
add r4 r4 r4
add r4 r4 r4 # shift data up 4
bor r5 r5 r4 # add to result
mst r5 r6
jmp done13
@lowcheck67
mld r5 r3
ldi r7 0b11110000
and r5 r5 r7 # clear lower half
bor r5 r5 r4 # add new result
mst r5 r3
@done13
ldi r7 9 # for continuity
@notclosed1
ret

# CLEAR BOARD
# bookmark Start
@reset
ldi r1 0b10001111 # pressed face
ldi r2 o_hud
mst r1 r2

# sub_bookmark Optimized Clear
ldi r1 0b00000000 # coordinate for the first half
ldi r2 0b01010000 # coordinate for the second half
ldi r3 0b11110110 # test if = 9
ldi r4 0b10011001 # memory data, can also be used as texture since only reads bottom half
ldi r5 49 # index
ldi r6 o_coord
ldi r7 o_texture

@clear
mst r4 r5 # store data in index
mst r1 r6 # store first half
mst r4 r7 # store color
mst r2 r6 # store second half
mst r4 r7 # store color

nor r0 r1 r3 # test, most genius moment of 2026
bne skip_reset_y
adi r1 6 # another genius 2026 moment but not that genius (-10 x and +1 y = 6), 
adi r2 6 # -10 bexause increment right after

@skip_reset_y
adi r1 1
adi r2 1 # increment coordinates' x

adi r5 0xFF # decrement
bps clear # include 0 in loop

# sub_bookmark Generate Random Mines
# GENERATE RANDOM MINES
ldi r7 15 # 15 random mines

# rng just has to give number from 0-99 or 0b1100011 well kinda
# so, generate 7-bit number, use last bit for L/H, and rsh for a number from 0-49
# rsh, store last bit as L (0) or H (1), and check if number < 50
# if out of bounds, retry until in bounds
# then check in mem if there is already bomb, if so try again

@random
ldi r1 i_rng
mld r1 r1 # get random number
ldi r2 0b00000001
and r3 r1 r2 # test lsb for L/H, will use later
rsh r1 r1

# now check if number < 50 (x-50 < 0)
ldi r2 50
sub r0 r1 r2
bps random # if not, try again

# now check if already bomb (12)
mld r2 r1 # load location into r2

# if r3 is 1, check H, if 0, check L
add r0 r3 r0
beq checkL
# check H part of location
# 1001 if empty, 1100 if bomb, so check 00010000
ldi r4 0b00010000
and r0 r2 r4
beq random # if bomb, try again
# if not, store it in H
ldi r4 0b00001111
and r2 r2 r4 # clear H
ldi r4 0b11000000
bor r2 r2 r4 # put into preexisting location
mst r2 r1 # send back
jmp valid

@checkL
ldi r4 0b00000001
and r0 r2 r4
beq random
ldi r4 0b11110000
and r2 r2 r4
ldi r4 0b00001100
bor r2 r2 r4
mst r2 r1

@valid # location is valid
adi r7 0xFF # decrement
bne random

ldi r1 15 # store counter
ldi r2 50
mst r1 r2

# set 51 as "first time" flag
ldi r7 51
mst r7 r7 # just put any bullshit in there as long as its not zero

#mst r0 r7 # TEMPORARILY DEBUG

# bookmark Listen for Input
# LISTENING LOOP
@listen
ldi r3 50
mld r3 r3 # flag counter in r3
ldi r4 o_hud
mst r3 r4 # set to happy face

ldi r1 i_input
@listen_loop
mld r2 r1 # check if there is input
add r0 r2 r0
beq listen_loop # nothing

# shocked face
adi r3 0b01000000
mst r3 r4

# oh shit there is, what is it?
ldi r3 i_coord
mld r1 r3 # put unprocessed coord in r1

# sub_bookmark Process Coordinate
# UNPROCESSED COORDINATE IN R1,R2(X,Y), PROCESS COORDINATE IN R3 AND PUT DATA IN R4
# COORDINATE MSB IS 0 if LOW and 1 if HIGH
# perfect because can load mem using it and it wont check msb

# n = (y << 3) + (y << 1) + x
# if >= 50, subtract 50, set HIGH and rsh after loading data

# put y in r2 and turn r1 to x
rsh r2 r1
rsh r2 r2
rsh r2 r2
rsh r2 r2 # put y in r2
ldi r3 0b00001111
and r1 r1 r3 # isolate x in r1

# r3 = (y << 3) + (y << 1) + x
add r3 r2 r2
add r3 r3 r3
add r3 r3 r3 # y<<3 now in r3
add r3 r3 r2 # add y to r3
add r3 r3 r2 # add y to r3, now y<<3+y<<1 is in r3
add r3 r3 r1 # add x to r3 done

ldi r4 50 # check if n >= 50 (n - 50 >= 0)
sub r0 r3 r4
mld r4 r3 # get data without rsh, only for LOW, not in LOW so doesn't overwrite HIGH
bng low
# it's high so sub 50 and 1 in msb and rsh 4
adi r3 0b11001110 # can't use r4 for 50 cuz got replaced
adi r3 0b10000000

mld r4 r3 # get data
rsh r4 r4 # right shift by 4
rsh r4 r4
rsh r4 r4
rsh r4 r4
@low
ldi r5 0b00001111 # remove upper 4 bits, does nothing if was high
and r4 r4 r5

# DONE PROCESSING COORDINATE

# fetch reset/flag
ldi r6 i_control
mld r5 r6 # put in r5

ldi r6 o_output
mst r0 r6 # RESET INPUTS

# see if reset or flag
ldi r6 0b00000010
and r0 r5 r6 # test reset
bne reset
ldi r6 0b00000001
and r0 r5 r6 # test flag
bne flagroutine

# bookmark Left Click
# left click routine
# first time?
ldi r7 51
mld r6 r7
add r0 r6 r0
beq notfirsttime

# sub_bookmark First Click
mst r0 r7 # not first time anymore :(

# see if we hittin a bomb (12) to replace THIS cell, do it after setting to 15
ldi r6 0 # reset first
ldi r5 12
sub r0 r4 r5
bne notfirstbomb
ldi r6 1
@notfirstbomb

# SET THE CELL TO 15 SO IT DOESN'T GET REBOMBED
mld r4 r3 # load full coord into r4
add r0 r3 r0 # check if high or low
bps low5
# high
ldi r5 0b11110000
bor r4 r4 r5 # replace with 15
mst r4 r3
jmp done
@low5
ldi r5 0b00001111
bor r4 r4 r5 # replace with 15
mst r4 r3
@done

add r0 r6 r0
beq dontreplace
cal replace # replace this location (it doesn't "know" the location, but now it's 1111)
@dontreplace

# NOW deal with neighbours
# count neighbours, set ALL neighbours to 1111, then run replacement that many times
# then replace neighbours back to closed, and keep as 1111 for floodfill to handle

# turn index into proper 0-99, should have always done this but oh well
ldi r7 0b01111111
and r3 r3 r7 # clean MSB
# add 50 if 4 < y (4 - y < 0)
ldi r7 4
sub r0 r7 r2
bps nah
adi r3 50
@nah

cal open # now neighbours are in r4 and natural index in r3 (0-99)

# push it for now because we need r4
psh r4

# sub_bookmark Set All Neighbours to Temp
##############################
# SET ALL NEIGHBOURS TO 1111 #
##############################

ldi r7 9 # bound

# start at -1 -1
adi r3 0b11110101 # (-1y - 1x = -11)
adi r1 255 # x -= 1
adi r2 255 # y -= 1
sub r0 r1 r0
bng done01 # if x < 0
sub r0 r2 r0
bng done01 # if y < 0
cal replace_temp
@done01

# step x (now 0 -1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r2 r0
bng done02 # if y < 0
cal replace_temp
@done02

# step x (now 1 -1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r1
bng done03 # if 9 < x
sub r0 r2 r0
bng done03 # if y < 0
cal replace_temp
@done03

# step y and reset x (now -1 0)
adi r3 0b00001000 # (+1y - 2x = 8)
adi r1 254 # x -= 2
adi r2 1 # y += 1
sub r0 r1 r0
bng done04 # if x < 0
cal replace_temp
@done04

# double step x (now 1 0)
adi r3 0b00000010 # (+2x = 2)
adi r1 2 # x += 2
sub r0 r7 r1
bng done05 # if 9 < x
cal replace_temp
@done05

# step y and reset x (now -1 1)
adi r3 0b00001000 # (+1y - 2x = 8)
adi r1 254 # x -= 2
adi r2 1 # y += 1
sub r0 r1 r0
bng done06 # if x < 0
sub r0 r7 r2
bng done06 # if 9 < y
cal replace_temp
@done06

# step x (now 0 1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r2
bng done07 # if 9 < y
cal replace_temp
@done07

# step x (now 1 1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r1
bng done08 # if 9 < x
sub r0 r7 r2
bng done08 # if 9 < y
cal replace_temp
@done08

# DO -1 -1 TO RESET COORD & INDEX (0, 0) BECAUSE NEED COORDINATE FOR FLOODFILL
adi r3 0b11110101 # (-1y - 1x = -11)
adi r1 255 # x -= 1
adi r2 255 # y -= 1

# sub_bookmark Replace Amount of Mines
################################
# REPLACE THAT AMOUNT OF MINES #
################################
# load value back into r4
pop r4

@replace_mine_loop
add r0 r4 r0
beq finish # check first in case it's zero
cal replace
adi r4 255 # decrement
jmp replace_mine_loop
@finish

# sub_bookmark Set To Zero
# SET TO ZERO
# ONLY NEED TO SEND TO DISPLAY, IN MEMORY CAN LEAVE AS 1111 FOR FLOODFILL TO HANDLE

# SEND OUTPUT SIGNAL TO DISPLAY
# CONVERT R1,R2 BACK INTO FULL COORD IN R4
add r4 r2 r2
add r4 r4 r4
add r4 r4 r4
add r4 r4 r4 # y << 4
add r4 r4 r1 # put back into one coord

ldi r5 o_coord
mst r4 r5
ldi r5 o_texture
mst r0 r5

# sub_bookmark Set All Neighbours to Closed
#####################################
# SET ALL NEIGHBOURS BACK TO CLOSED #
#####################################

ldi r7 9 # bound

# start at -1 -1
adi r3 0b11110101 # (-1y - 1x = -11)
adi r1 255 # x -= 1
adi r2 255 # y -= 1
sub r0 r1 r0
bng done001 # if x < 0
sub r0 r2 r0
bng done001 # if y < 0
cal replace_closed
@done001

# step x (now 0 -1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r2 r0
bng done002 # if y < 0
cal replace_closed
@done002

# step x (now 1 -1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r1
bng done003 # if 9 < x
sub r0 r2 r0
bng done003 # if y < 0
cal replace_closed
@done003

# step y and reset x (now -1 0)
adi r3 0b00001000 # (+1y - 2x = 8)
adi r1 254 # x -= 2
adi r2 1 # y += 1
sub r0 r1 r0
bng done004 # if x < 0
cal replace_closed
@done004

# double step x (now 1 0)
adi r3 0b00000010 # (+2x = 2)
adi r1 2 # x += 2
sub r0 r7 r1
bng done005 # if 9 < x
cal replace_closed
@done005

# step y and reset x (now -1 1)
adi r3 0b00001000 # (+1y - 2x = 8)
adi r1 254 # x -= 2
adi r2 1 # y += 1
sub r0 r1 r0
bng done006 # if x < 0
sub r0 r7 r2
bng done006 # if 9 < y
cal replace_closed
@done006

# step x (now 0 1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r2
bng done007 # if 9 < y
cal replace_closed
@done007

# step x (now 1 1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r1
bng done008 # if 9 < x
sub r0 r7 r2
bng done008 # if 9 < y
cal replace_closed
@done008

# DO -1 -1 TO RESET COORD & INDEX (0, 0) BECAUSE NEED COORDINATE FOR FLOODFILL
adi r3 0b11110101 # (-1y - 1x = -11)
adi r1 255 # x -= 1
adi r2 255 # y -= 1

jmp floodfill # jump to skip the checks we already know it's zero

@notfirsttime
# sub_bookmark Lose
# lose when clicking a bomb
# then test if closed
# then open and test zero

ldi r5 12
sub r0 r4 r5
bne notlose
# You lost the game.
# Keep counter as-is, set face to dead,
# Reveal all BOMBS (keep flags as-is),
# Reveal all WRONGLY FLAGGED,
# Lastly, replace hit square with red bomb (1011) (after everything so it doesn't get replaced)
add r2 r2 r2
add r2 r2 r2
add r2 r2 r2
add r2 r2 r2
add r2 r2 r1
psh r2 # coord for last

ldi r1 9
ldi r2 4
ldi r3 49 # reset positions as low half

# 1100 bomb memory
# 1011 wrong memory

# 1100 bomb texture
# 1101 wrong texture

@scan_lose
# only need to replace BOMB if win (flagged already flagged) so push just bombs
mld r4 r3
ldi r6 0b11110000
and r5 r4 r6
ldi r6 0b11000000
sub r0 r5 r6
bne nothighbomb # test high half bomb
add r6 r2 r2
add r6 r6 r6
add r6 r6 r6
add r6 r6 r6 # y << 4
add r6 r6 r1 # += x
adi r6 80 # add 5 to y (5 << 4 = 80)
ldi r7 0b1100
ldi r5 o_coord
mst r6 r5
ldi r5 o_texture
mst r7 r5
jmp nothighwrong
@nothighbomb
ldi r6 0b10110000
sub r0 r5 r6
bne nothighwrong # test high half wrong
add r6 r2 r2
add r6 r6 r6
add r6 r6 r6
add r6 r6 r6 # y << 4
add r6 r6 r1 # += x
adi r6 80 # add 5 to y (5 << 4 = 80)
ldi r7 0b1101
ldi r5 o_coord
mst r6 r5
ldi r5 o_texture
mst r7 r5
@nothighwrong
ldi r6 0b00001111
and r5 r4 r6
ldi r6 0b00001100
sub r0 r5 r6
bne notlowbomb # test low half bomb
add r6 r2 r2
add r6 r6 r6
add r6 r6 r6
add r6 r6 r6 # y << 4
add r6 r6 r1 # += x
ldi r7 0b1100
ldi r5 o_coord
mst r6 r5
ldi r5 o_texture
mst r7 r5
@notlowbomb
ldi r6 0b00001011
sub r0 r5 r6
bne done_lose # test low half wrong
add r6 r2 r2
add r6 r6 r6
add r6 r6 r6
add r6 r6 r6 # y << 4
add r6 r6 r1 # += x
ldi r7 0b1101
ldi r5 o_coord
mst r6 r5
ldi r5 o_texture
mst r7 r5
@done_lose

adi r3 255 # (-1x = 255)
adi r1 255 # decrement x
sub r0 r1 r0
bps scan_lose # if not -1 continue

# if it is -1 then set back to 9 (+10) and decrement y)
# (-1y + 10x = 0) huh nice dont change index
adi r1 10
adi r2 255
sub r0 r2 r0
bps scan_lose # if not -1 continue

pop r1
ldi r2 o_coord
ldi r3 0b1011
ldi r4 o_texture
mst r1 r2
mst r3 r4 # store red hit

ldi r1 50
mld r1 r1 # flag count in r1
adi r1 0b00010000 # lose
ldi r2 o_hud
mst r1 r2

jmp listen_end
@notlose

# sub_bookmark Closed Check
# CLOSED CHECK
ldi r5 9
sub r0 r4 r5
bne listen # go back if not closed

# sub_bookmark Open & Zero Check
# turn index into proper 0-99, already did if first time but not now
ldi r7 0b01111111
and r3 r3 r7 # clean MSB
# add 50 if 4 < y (4 - y < 0)
ldi r7 4
sub r0 r7 r2
bps nah1
adi r3 50
@nah1

cal open # now we can open to see if zero

# STORE RESULT IN MEMORY
# uses r3 as natural index, loads preexisting into r5 and ORs r4
# temporarily sub 50 if >= 50 to r6
ldi r5 50
sub r6 r3 r5 # subtracted ver in r6
bng lowcheck4
# high
mld r5 r6 # subtracted version
ldi r7 0b00001111
and r5 r5 r7 # clear upper half
psh r4 # temporarily
add r4 r4 r4
add r4 r4 r4
add r4 r4 r4
add r4 r4 r4 # shift data up 4
bor r5 r5 r4 # add new result
pop r4 # retrieve
mst r5 r6
jmp done11
@lowcheck4
mld r5 r3
ldi r7 0b11110000
and r5 r5 r7 # clear lower half
bor r5 r5 r4 # add new result
mst r5 r3
@done11

# SEND OUTPUT SIGNAL TO DISPLAY
# CONVERT R1,R2 BACK INTO FULL COORD IN R5
add r5 r2 r2
add r5 r5 r5
add r5 r5 r5
add r5 r5 r5 # y << 4
add r5 r5 r1 # put back into one coord
ldi r6 o_coord
mst r5 r6
ldi r6 o_texture
mst r4 r6

# NOW CHECK IF NOT ZERO: JUMP TO WIN CHECK, OTHERWISE GO INTO FLOODFILL
sub r0 r4 r0
bne win

# sub_bookmark Flood Fill
@floodfill # assuming it's already opened and zero, going straight to floodfill
# r4 r5 r6 r7 is available
# also r3 is in natural 0-99 mode

# sub_bookmark Unmark Itself
#########################
# STEP 1: UNMARK ITSELF #
#########################

ldi r5 50
sub r6 r3 r5 # subtracted ver in r6
bng lowcheck2
# high
mld r4 r6 # subtracted version
ldi r5 0b00001111
and r4 r4 r5 # clear top half
mst r4 r6
jmp done12
@lowcheck2
mld r4 r3
ldi r5 0b11110000
and r4 r4 r5 # clear bottom half
mst r4 r3
@done12

# sub_bookmark Mark Zeros
##############################################
# STEP 2: GO AROUND CELL AND FOR EACH:       #
# IF CLOSED: OPEN & STORE, THEN MARK IF ZERO #
##############################################

ldi r7 9 # bound

# start at -1 -1
adi r3 0b11110101 # (-1y - 1x = -11)
adi r1 255 # x -= 1
adi r2 255 # y -= 1
sub r0 r1 r0
bng done0001 # if x < 0
sub r0 r2 r0
bng done0001 # if y < 0
cal zero_floodfill
@done0001

# step x (now 0 -1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r2 r0
bng done0002 # if y < 0
cal zero_floodfill
@done0002

# step x (now 1 -1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r1
bng done0003 # if 9 < x
sub r0 r2 r0
bng done0003 # if y < 0
cal zero_floodfill
@done0003

# step y and reset x (now -1 0)
adi r3 0b00001000 # (+1y - 2x = 8)
adi r1 254 # x -= 2
adi r2 1 # y += 1
sub r0 r1 r0
bng done0004 # if x < 0
cal zero_floodfill
@done0004

# double step x (now 1 0)
adi r3 0b00000010 # (+2x = 2)
adi r1 2 # x += 2
sub r0 r7 r1
bng done0005 # if 9 < x
cal zero_floodfill
@done0005

# step y and reset x (now -1 1)
adi r3 0b00001000 # (+1y - 2x = 8)
adi r1 254 # x -= 2
adi r2 1 # y += 1
sub r0 r1 r0
bng done0006 # if x < 0
sub r0 r7 r2
bng done0006 # if 9 < y
cal zero_floodfill
@done0006

# step x (now 0 1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r2
bng done0007 # if 9 < y
cal zero_floodfill
@done0007

# step x (now 1 1)
adi r3 0b00000001 # (+1x = 1)
adi r1 1 # x += 1
sub r0 r7 r1
bng done0008 # if 9 < x
sub r0 r7 r2
bng done0008 # if 9 < y
cal zero_floodfill
@done0008

# no need to reset position to -1 -1

# sub_bookmark Scan Display for Marks
################################################
# STEP 3: SCAN ENTIRE SCREEN UNTIL HIT MARKED: #
# JUMP TO FLOODFILL AND REPEAT                 #
################################################

ldi r1 9
ldi r2 4
ldi r3 49 # reset positions as low half

@scan_marks
# test if marked
# load into r4
mld r4 r3
ldi r5 0b00001111
nor r0 r4 r5
bne nothighhalf # test high half, NOR 00001111 = 0 means top half is 1111
adi r2 5
adi r3 50 # convert to high half
jmp floodfill
@nothighhalf
ldi r5 0b11110000
nor r0 r4 r5
beq floodfill # test low half without changing coords

adi r3 255 # (-1x = 255)
adi r1 255 # decrement x
sub r0 r1 r0
bps scan_marks # if not -1 continue

# if it is -1 then set back to 9 (+10) and decrement y)
# (-1y + 10x = 0) huh nice dont change index
adi r1 10
adi r2 255
sub r0 r2 r0
bps scan_marks # if not -1 continue

# DONE FLOODFILL!!!!!!!!!!

# sub_bookmark Win?
@win
# TEST WIN AFTER FLOODFILL OR OPEN
# scan entire display, jump to listen as soon as hit closed (9) / wrongly flagged (11)
# start with 11111111 in stack and push each bomb along the way, in case win
ldi r1 0b11111111
psh r1

ldi r1 9
ldi r2 4
ldi r3 49 # reset positions as low half

@scan_win
# test if closed/wrongly flagged
# load into r4
mld r4 r3
ldi r6 0b11110000
and r5 r4 r6 # clear bottom half into r5 for testing
ldi r6 0b10010000
sub r0 r5 r6
beq listen # high half was closed
ldi r6 0b10110000
sub r0 r5 r6
beq listen # high half was wrongly flagged
ldi r6 0b00001111
and r5 r4 r6
ldi r6 0b00001001
sub r0 r5 r6
beq listen
ldi r6 0b00001011
sub r0 r5 r6
beq listen

# only need to replace BOMB if win (flagged already flagged) so push just bombs
ldi r6 0b11110000
and r5 r4 r6
ldi r6 0b11000000
sub r0 r5 r6
bne nothighhalf1 # test high half
add r6 r2 r2
add r6 r6 r6
add r6 r6 r6
add r6 r6 r6 # y << 4
add r6 r6 r1 # += x
adi r6 80 # add 5 to y (5 << 4 = 80)
psh r6
@nothighhalf1
ldi r6 0b00001111
and r5 r4 r6
ldi r6 0b00001100
sub r0 r5 r6
bne done14 # test low half
add r6 r2 r2
add r6 r6 r6
add r6 r6 r6
add r6 r6 r6 # y << 4
add r6 r6 r1 # += x
psh r6
@done14

adi r3 255 # (-1x = 255)
adi r1 255 # decrement x
sub r0 r1 r0
bps scan_win # if not -1 continue

# if it is -1 then set back to 9 (+10) and decrement y)
# (-1y + 10x = 0) huh nice dont change index
adi r1 10
adi r2 255
sub r0 r2 r0
bps scan_win # if not -1 continue

# sub_bookmark Win!
# YOU WIN! NOW GO BACK AND TURN EVERY BOMB INTO FLAG
# THEN SET FACE TO COOL (0010) AND ZERO ON COUNTER (00100000)
ldi r2 0b11111111
ldi r3 10 # texture
ldi r4 o_coord
ldi r5 o_texture
@replace_win
pop r1
sub r0 r1 r2
bne notdonehere
ldi r6 0b00100000
ldi r7 o_hud
mst r6 r7
jmp listen_end
@notdonehere
mst r1 r4
mst r3 r5
jmp replace_win

# bookmark Right Click
@flagroutine
# FLAG:
# if bomb (12) or closed (9):
# set bomb (12) to flagged (10) and closed (9) to wrongly flagged (11)
# decrement counter
# UNFLAG:
# if flagged (10) or wrongly flagged (11):
# set flagged (10) to bomb (12) and wrongly flagged (11) to closed (9)
# increment counter
# ELSE DO NOTHING

# CONVERT R1,R2 BACK INTO FULL COORD R1
add r2 r2 r2
add r2 r2 r2
add r2 r2 r2
add r2 r2 r2 # y << 4
add r1 r1 r2 # put back into one coord

ldi r7 o_hud

# sub_bookmark If Bomb
ldi r5 12
sub r0 r4 r5 # check bomb
bne notbomb
# decrement counter
ldi r6 50
mld r5 r6
adi r5 255
mst r5 r6
adi r5 0b01000000 # add shocked
mst r5 r7
# output flag texture (10) to display
ldi r5 10
ldi r6 o_coord
mst r1 r6
ldi r6 o_texture
mst r5 r6
# flag right
mld r4 r3 # load full coord into r4
add r0 r3 r0 # check if high or low
bps low1
# high
ldi r5 0b00001111
and r4 r4 r5 # clear upper bits
adi r4 0b10100000 # replace with flag
mst r4 r3
jmp listen
@low1
ldi r5 0b11110000
and r4 r4 r5 # clear lower bits
adi r4 0b00001010 # replace with flag
mst r4 r3
jmp listen

# sub_bookmark If Closed
@notbomb
ldi r5 9
sub r0 r4 r5 # check closed
bne notclosed
# decrement counter
ldi r6 50
mld r5 r6
adi r5 255
mst r5 r6
adi r5 0b01000000 # add shocked
mst r5 r7
# output flag texture (10) to display
ldi r5 10
ldi r6 o_coord
mst r1 r6
ldi r6 o_texture
mst r5 r6
# flag wrong
mld r4 r3 # load full coord into r4
add r0 r3 r0 # check if high or low
bps low2
# high
ldi r5 0b00001111
and r4 r4 r5 # clear upper bits
adi r4 0b10110000 # replace with flagged wrong
mst r4 r3
jmp listen
@low2
ldi r5 0b11110000
and r4 r4 r5 # clear lower bits
adi r4 0b00001011 # replace with flagged wrong
mst r4 r3
jmp listen

# sub_bookmark If Flagged Bomb
@notclosed
ldi r5 10
sub r0 r4 r5 # check flagged
bne notflagged
# increment counter
ldi r6 50
mld r5 r6
adi r5 1
mst r5 r6
adi r5 0b01000000 # add shocked
mst r5 r7
# output closed texture (9) to display
ldi r5 9
ldi r6 o_coord
mst r1 r6
ldi r6 o_texture
mst r5 r6
# unflag right (set to bomb)
mld r4 r3 # load full coord into r4
add r0 r3 r0 # check if high or low
bps low3
# high
ldi r5 0b00001111
and r4 r4 r5 # clear upper bits
adi r4 0b11000000 # replace with bomb
mst r4 r3
jmp listen
@low3
ldi r5 0b11110000
and r4 r4 r5 # clear lower bits
adi r4 0b00001100 # replace with bomb
mst r4 r3
jmp listen

# sub_bookmark If Flagged Wrong
@notflagged
ldi r5 11
sub r0 r4 r5 # check flagged wrong
bne notwrong
# increment counter
ldi r6 50
mld r5 r6
adi r5 1
mst r5 r6
adi r5 0b01000000 # add shocked
mst r5 r7
# output closed texture (9) to display
ldi r5 9
ldi r6 o_coord
mst r1 r6
ldi r6 o_texture
mst r5 r6
# unflag wrong (set to closed)
mld r4 r3 # load full coord into r4
add r0 r3 r0 # check if high or low
bps low4
# high
ldi r5 0b00001111
and r4 r4 r5 # clear upper bits
adi r4 0b10010000 # replace with closed
mst r4 r3
jmp listen
@low4
ldi r5 0b11110000
and r4 r4 r5 # clear lower bits
adi r4 0b00001001 # replace with closed
mst r4 r3

@notwrong
jmp listen

# bookmark Listen for Reset
# only listen for reset button, during win/loss
@listen_end
ldi r1 i_control
ldi r2 0b00000010 # reset bit
@listen_end_loop
mld r3 r1 # check bit (dont have to check input because we did when coord couldve been 0 but not)
sub r0 r3 r2
bne listen_end_loop # nothing
jmp reset