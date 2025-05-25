# Copyright © 2025 artefox
# Licensed under the MIT License

asmcode = open('asm.sb', 'r')
mccode = open('output.mc', 'w')

output = []

opcodes = ['nop', 'hlt', 'add', 'adc', 'adi', 'sub', 'sbb', 'and', 'bor', 'nor', 'xor', 'rsh', 'ash', 'mov', 'ldi', 'jmp', 'bge', 'blt', 'bng', 'bps', 'beq', 'bne', 'mld', 'mst', 'psh', 'pop', 'cal', 'ret']
regs0   = ['r0', 'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7']
regs1   = ['reg0', 'reg1', 'reg2', 'reg3', 'reg4', 'reg5', 'reg6', 'reg7']
regs2   = ['A', 'B', 'C', 'D', 'E', 'F', 'G']

symbols = {}
for index, value in enumerate(opcodes):
    symbols[value] = index
for index, value in enumerate(regs0):
    symbols[value] = index
for index, value in enumerate(regs1):
    symbols[value] = index
for index, value in enumerate(regs2):
    symbols[value] = index

lines = [line.lower().strip() for line in asmcode] # remove nl
for comments in ['/', ';', '#']:
    lines = [line.split(comments)[0] for line in lines] # divide comments and keep part before them
lines = [line for line in lines if line.strip()] # comments will be blank so remove them and also removes regular bl

lines = [line.split() for line in lines] # turn into elements per line

# OP    C      A   B
# 00000 000 00 000 000

offset0 = pow(2, 11)
offset1 = pow(2, 8)
offset2 = pow(2, 3)

def evaluateImmediate(imm):
    return int(imm, 0)

def interpretZeroOperands(l):
    return (symbols[l[0]] * offset0) # OP

def interpretTwoOperands0(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset1) + (symbols[l[2]] * offset2) # C A

def interpretTwoOperands1(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset2) + (symbols[l[2]]) # A B

def interpretThreeOperands(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset1) + (symbols[l[2]] * offset2) + (symbols[l[3]]) # C A B

def interpretZeroImmediate(l):
    return (symbols[l[0]] * offset0) + (evaluateImmediate(l[1])) # IMM not in my isa but can be useful

def interpretOneImmediate(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset1) + (evaluateImmediate(l[2])) # C IMM

for line in lines:
    if line[0] == 'nop':
        output.append(interpretZeroOperands(line))
    elif line[0] == 'hlt':
        output.append(interpretZeroOperands(line))
    elif line[0] == 'add':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'sub':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'and':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'ior':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'nor':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'xor':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'adc':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'rsh':
        output.append(interpretTwoOperands0(line))
    elif line[0] == 'jid':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'jmp':
        output.append(interpretOneImmediate(line))
    elif line[0] == 'mld':
        output.append(interpretTwoOperands0(line))
    elif line[0] == 'mst':
        output.append(interpretTwoOperands1(line))
    elif line[0] == 'ldi':
        output.append(interpretOneImmediate(line))
    elif line[0] == 'pld':
        output.append(interpretTwoOperands0(line))
    elif line[0] == 'pst':
        output.append(interpretTwoOperands1(line))
    

mccode.write(f"{output}")