# Custom Python Assembler and Minecraft Barrel ROM Schematic Generator for 1.21.8

The assembler compiles programs written for the [SB CPU 3 ISA](https://docs.google.com/spreadsheets/d/145FgBEBUMqR2AwzehXJ7kyqvEKSq50dz7CUwtCOcKwo/edit?usp=sharing) into a .mc file, and the schematic generator turns the machine code into a Minecraft barrel ROM compatible for SB CPU 3.

Thanks to [Sloimay](https://github.com/Sloimayyy/mcschematic) for the WorldEdit schematic generator.

## Instructions
Write your assembly code in `asm.s`, or create a new file and make sure to reference it in `assembly.py` under `asmcode = open('YOURFILE.s', 'r')`

Then, run `assembly.py` and you should see a file named `output.mc` in the machine folder. Once you have that, run `schem.py`, which will read the `output.mc` machine code and turn it into a Minecraft schematic full of barrels with items in them.

If `schem.py` doesn't work, you might need to install mcschematic using pip.
```py
pip install mcschematic
```

Then find the schematic in `schems/` and drag it into your WorldEdit schematic folder. (Under `.minecraft/config/worldedit/schematics` by default)

Then, go in-game and load the schematic with `//schem load rom`, or use whatever you named the schematic. Stand underneath the glass that says "paste here" and run `//paste -a`.

![image](https://github.com/user-attachments/assets/0accb93e-b015-42aa-95df-72150c6c8230)

## Features
- Multiple expressions per line are automatically logically OR'ed together
- Case-insensitive (MOV, mov, and MoV all work)
- Comments can use `;`, `#`, or `/`
- Flexible immediates
- Labels for jumps, calls, and branches (resolved automatically) using `@`

### Comments
You can use any of these to start a comment:
```
; this is a comment
# also a comment
/ same idea
```   

Comments can appear inline too:
```
LDI R6 5   ; load 5 into r6
```

### Immediates
Immediate values are flexible and support:
- decimal `42`
- hexadecimal `0x2A`
- binary `0b101010`

### Labels
Labels let you name specific program counter (PC) locations.
They're declared with `@name` and can be referenced anywhere using just `name`.

Example:
```asm
@start
LDI R1 0x05
JMP loop

@loop
SUB R1 R1 R2
BNE start
HLT
```

## Program ROM
For a brief explanation on how the barrel ROM works, each barrel has a different amount of items in them, which in turn allow them to produce a redstone signal strength which represent binary machine code in hexadecimal. SB CPU 3 automatically converts the hexadecimal signal strength into binary when loading the ROM into the cache.

Barrels can hold items that represent a signal strength from 0-15. This gives barrels half a byte (nibble) of storage (4 bits).

Each instruction is 2 bytes (16 bits) long with a High (H) byte and Low (L) byte.

When assorted into columns of 8, each column can hold 4 bytes (32 bits per column), and each barrel holds 4 bits of different bytes with the same place value.

|  | Byte 0 | Byte 1 | Byte 2 | Byte 3 |
| :---: | :---: | :---: | :---: | :---: |
| Barrel 7 | Bit 7 | Bit 7 | Bit 7 | Bit 7 |
| Barrel 6 | Bit 6 | Bit 6 | Bit 6 | Bit 6 |
| Barrel 5 | Bit 5 | Bit 5 | Bit 5 | Bit 5 |
| Barrel 4 | Bit 4 | Bit 4 | Bit 4 | Bit 4 |
| Barrel 3 | Bit 3 | Bit 3 | Bit 3 | Bit 3 |
| Barrel 2 | Bit 2 | Bit 2 | Bit 2 | Bit 2 |
| Barrel 1 | Bit 1 | Bit 1 | Bit 1 | Bit 1 |
| Barrel 0 | Bit 0 | Bit 0 | Bit 0 | Bit 0 |

The table above represents one column of barrels, where each row represents one barrel. The number represents the place value of the bit in binary, so 7 would be the MSB (Most Significant Bit). The rows are the binary representations of the barrels stored in hex (signal strength, e.g. 13 \-\> 1101\)

These columns are placed in a grid with alternating order of H bytes and L bytes.

| 0 |  | 1 |  | 2 |  | 3 |  |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| High Bytes | Low Bytes | Low Bytes | High Bytes | High Bytes | Low Bytes | Low Bytes | High Bytes |

The table above represents the higher-level view of barrel columns, where each pair of high and low bytes represent one instruction, and alternate in order. These barrel columns are 64 wide and then stacked by 16 for a total of 4 KiB (4096 bytes) or 2048 instructions.  

For more details on how the ROM is setup: [Program ROM Specification](https://docs.google.com/document/d/1EYDpcNFcqlE6iPf35c7rxj5VtfZCbD8b9FlhQ1oX37A/edit?usp=sharing)

## CPU
SB CPU 3 is my 8-bit pipelined redstone CPU built in Minecraft over the course of 10 months. The instruction set and pipelining layout is fully custom built for SB CPU 3.
### SB CPU 3 Specs:
- **Architecture:** 4-stage pipeline (fetch, decode, execute, writeback)
- **Hazards:** Handles hazards by forwarding
- **Clock speed:** 0.33Hz / 30 ticks (for now...)
- **Instruction set (ISA):** 28 opcodes and many more pseudo-instructions
- **Memory and cache:** 
   - 4096 bytes of program ROM (2048 2-byte instructions)
   - 128 bytes of instruction cache 
   - 64 bytes of memory with indirect addressing and 4 reserved memory-mapped I/O ports
   - 7 general purpose registers and a dedicated zero register (R0)
- **ALU:** A fully-featured CCA-based ALU including a right/arithmetic shifter. Includes 3 flags (carry, negative, zero)
- **Stack:** 16-deep, 11-bit general stack supporting call/return, push, and pop functions
- **Branching:** 11-bit address jumping and 6 branch conditions which cover the entire range of the program memory for jumps (no relative jumps/branches)

![image](https://github.com/user-attachments/assets/88832381-2905-4b52-818c-f5074f950f85)

