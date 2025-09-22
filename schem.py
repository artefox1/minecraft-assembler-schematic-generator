# Copyright © 2025 artefox

import mcschematic
schem = mcschematic.MCSchematic()

# HAS TO BE 2048 LINES
mccode = open('machine/output.mc', 'r') # CHANGE OUTPUT.MC TO YOUR MACHINE CODE FILE

barrels = [
    'minecraft:barrel[facing=up]{Items:[]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:59b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:54b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:50b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:45b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:41b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:36b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:31b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:64b},{Slot:14b,id:"minecraft:redstone",count:64b},{Slot:15b,id:"minecraft:redstone",count:27b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:64b},{Slot:14b,id:"minecraft:redstone",count:64b},{Slot:15b,id:"minecraft:redstone",count:64b},{Slot:16b,id:"minecraft:redstone",count:64b},{Slot:17b,id:"minecraft:redstone",count:22b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:64b},{Slot:14b,id:"minecraft:redstone",count:64b},{Slot:15b,id:"minecraft:redstone",count:64b},{Slot:16b,id:"minecraft:redstone",count:64b},{Slot:17b,id:"minecraft:redstone",count:64b},{Slot:18b,id:"minecraft:redstone",count:64b},{Slot:19b,id:"minecraft:redstone",count:18b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:64b},{Slot:14b,id:"minecraft:redstone",count:64b},{Slot:15b,id:"minecraft:redstone",count:64b},{Slot:16b,id:"minecraft:redstone",count:64b},{Slot:17b,id:"minecraft:redstone",count:64b},{Slot:18b,id:"minecraft:redstone",count:64b},{Slot:19b,id:"minecraft:redstone",count:64b},{Slot:20b,id:"minecraft:redstone",count:64b},{Slot:21b,id:"minecraft:redstone",count:13b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:64b},{Slot:14b,id:"minecraft:redstone",count:64b},{Slot:15b,id:"minecraft:redstone",count:64b},{Slot:16b,id:"minecraft:redstone",count:64b},{Slot:17b,id:"minecraft:redstone",count:64b},{Slot:18b,id:"minecraft:redstone",count:64b},{Slot:19b,id:"minecraft:redstone",count:64b},{Slot:20b,id:"minecraft:redstone",count:64b},{Slot:21b,id:"minecraft:redstone",count:64b},{Slot:22b,id:"minecraft:redstone",count:64b},{Slot:23b,id:"minecraft:redstone",count:9b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:64b},{Slot:14b,id:"minecraft:redstone",count:64b},{Slot:15b,id:"minecraft:redstone",count:64b},{Slot:16b,id:"minecraft:redstone",count:64b},{Slot:17b,id:"minecraft:redstone",count:64b},{Slot:18b,id:"minecraft:redstone",count:64b},{Slot:19b,id:"minecraft:redstone",count:64b},{Slot:20b,id:"minecraft:redstone",count:64b},{Slot:21b,id:"minecraft:redstone",count:64b},{Slot:22b,id:"minecraft:redstone",count:64b},{Slot:23b,id:"minecraft:redstone",count:64b},{Slot:24b,id:"minecraft:redstone",count:64b},{Slot:25b,id:"minecraft:redstone",count:4b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:64b},{Slot:14b,id:"minecraft:redstone",count:64b},{Slot:15b,id:"minecraft:redstone",count:64b},{Slot:16b,id:"minecraft:redstone",count:64b},{Slot:17b,id:"minecraft:redstone",count:64b},{Slot:18b,id:"minecraft:redstone",count:64b},{Slot:19b,id:"minecraft:redstone",count:64b},{Slot:20b,id:"minecraft:redstone",count:64b},{Slot:21b,id:"minecraft:redstone",count:64b},{Slot:22b,id:"minecraft:redstone",count:64b},{Slot:23b,id:"minecraft:redstone",count:64b},{Slot:24b,id:"minecraft:redstone",count:64b},{Slot:25b,id:"minecraft:redstone",count:64b},{Slot:26b,id:"minecraft:redstone",count:63b}]}',
    'minecraft:barrel[facing=up]{Items:[{Slot:0b,id:"minecraft:redstone",count:64b},{Slot:1b,id:"minecraft:redstone",count:64b},{Slot:2b,id:"minecraft:redstone",count:64b},{Slot:3b,id:"minecraft:redstone",count:64b},{Slot:4b,id:"minecraft:redstone",count:64b},{Slot:5b,id:"minecraft:redstone",count:64b},{Slot:6b,id:"minecraft:redstone",count:64b},{Slot:7b,id:"minecraft:redstone",count:64b},{Slot:8b,id:"minecraft:redstone",count:64b},{Slot:9b,id:"minecraft:redstone",count:64b},{Slot:10b,id:"minecraft:redstone",count:64b},{Slot:11b,id:"minecraft:redstone",count:64b},{Slot:12b,id:"minecraft:redstone",count:64b},{Slot:13b,id:"minecraft:redstone",count:64b},{Slot:14b,id:"minecraft:redstone",count:64b},{Slot:15b,id:"minecraft:redstone",count:64b},{Slot:16b,id:"minecraft:redstone",count:64b},{Slot:17b,id:"minecraft:redstone",count:64b},{Slot:18b,id:"minecraft:redstone",count:64b},{Slot:19b,id:"minecraft:redstone",count:64b},{Slot:20b,id:"minecraft:redstone",count:64b},{Slot:21b,id:"minecraft:redstone",count:64b},{Slot:22b,id:"minecraft:redstone",count:64b},{Slot:23b,id:"minecraft:redstone",count:64b},{Slot:24b,id:"minecraft:redstone",count:64b},{Slot:25b,id:"minecraft:redstone",count:64b},{Slot:26b,id:"minecraft:redstone",count:64b}]}'
]

# remove newlines
instructions = [line.strip() for line in mccode]

# list of all barrels (4096 bytes, 2048 instructions, 4 bits per barrel, 8 high column, 16 width, 64 length)
# 2048 instructions * 8 bits per byte * 2 bytes per instruction / 4 bits per barrel = 8192 barrels
output = [0] * (2048 * 8 * 2 // 4)

offset0 = pow(2, 3) # cache row 3
offset1 = pow(2, 2) # cache row 2
offset2 = pow(2, 1) # cache row 1
offset3 = pow(2, 0) # cache row 0

# go through every barrel in order of length, width, layer/height
for k in range(8): # bits in column
    for j in range(16): # width
        for i in range(32): # length in pairs
            # get position in rom of 4 bytes (line numbers)
            # each width/row has 64 bytes, so increment length by 64
            # width is 16 bytes wide, so offset by 16 for each byte
            byte0 = i * 64 + j
            byte1 = i * 64 + j + 16
            byte2 = i * 64 + j + 32
            byte3 = i * 64 + j + 48

            # start with L bytes
            # if row is odd then use H L order 
            if i % 2 == 1:
                # H L
                # get barrel pos in list of both H and L barrel (LAYER, WIDTH, LENGTH)
            
                # new layer every 1024 barrels, (16 wide * 64 long = 1024)
                # new width every 64 barrels (16 wide * 2 per length * 2 alternating pairs = 32)   have to go by 2x more because LH before HL again
                # new length every 1 barrel

                # barrel index is 1024layer + 64width + 2length (+1 for second half of bytes)

                barrelH = 1024 * k + 64 * j + 2 * i
                barrelL = 1024 * k + 64 * j + 2 * i + 1

                # set barrel values in hex (0-15), k is character in line (0-7 for L, 8-15 for H)
                output[barrelH] = int(instructions[byte0][k]) * offset0 + int(instructions[byte1][k]) * offset1 + int(instructions[byte2][k]) * offset2 + int(instructions[byte3][k]) * offset3
                output[barrelL] = int(instructions[byte0][k + 8]) * offset0 + int(instructions[byte1][k + 8]) * offset1 + int(instructions[byte2][k + 8]) * offset2 + int(instructions[byte3][k + 8]) * offset3
            else:
                # L H
                barrelL = 1024 * k + 64 * j + 2 * i
                barrelH = 1024 * k + 64 * j + 2 * i + 1

                output[barrelL] = int(instructions[byte0][k + 8]) * offset0 + int(instructions[byte1][k + 8]) * offset1 + int(instructions[byte2][k + 8]) * offset2 + int(instructions[byte3][k + 8]) * offset3
                output[barrelH] = int(instructions[byte0][k]) * offset0 + int(instructions[byte1][k]) * offset1 + int(instructions[byte2][k]) * offset2 + int(instructions[byte3][k]) * offset3

# set blocks, layer, width, length
for k in range(8):
    for j in range(16):
        for i in range(64):
            # x = 2 * j because every other block
            # y = (2 * -k) - 1 because relative to player feet
            # z = 2 * i because every other block

            # barrel position is 1024layer + 64width + length
            schem.setBlock((2 * j, (2 * -k)-1, 2 * i), barrels[output[1024 * k + 64 * j + i]])

#out.write(f"{output}")
schem.save("schems", "rom", mcschematic.Version.JE_1_21_5)