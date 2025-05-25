# Custom Python Assembler and Minecraft Barrel ROM Schematic Generator

The assembler is written for the [SB CPU 3 ISA](https://docs.google.com/spreadsheets/d/145FgBEBUMqR2AwzehXJ7kyqvEKSq50dz7CUwtCOcKwo/edit?usp=sharing)

The assembler is not case sensitive, and comments can be written with ; # /

Multiple expressions on the same line get logically OR'ed together

Write your assembly code in asm.sb, or create a new file and make sure to reference it in `assembly.py` under `asmcode = open('YOURFILE.sb', 'r')`

Then, run `assembly.py` and you should see a file named `output.mc`. Once you have that, run `schem.py`, which will read the `output.mc` machine code and turn it into a Minecraft schematic full of barrels with items in them.

For a brief explanation on how the barrel ROM works, each barrel has a different amount of items in them, which in turn allow them to produce a redstone signal strength which represent binary machine code in hexadecimal. SB CPU 3 automatically converts the hexadecimal signal strength into binary when loading the ROM into the cache.

For more details on how the ROM is setup: [Program ROM Specification](https://docs.google.com/document/d/1EYDpcNFcqlE6iPf35c7rxj5VtfZCbD8b9FlhQ1oX37A/edit?usp=sharing)
