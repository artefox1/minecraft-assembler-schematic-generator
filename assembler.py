# Copyright © 2025 artefox

asmcode = open('assembly/tests/test_labels.s', 'r') # CHANGE TO YOUR ASSEMBLY FILE
mccode = open('machine/output.mc', 'w') # CHANGE TO YOUR MACHINE CODE FILE

opcodes = ['nop', 'hlt', 'add', 'adc', 'adi', 'sub', 'sbb', 'and', 'bor', 'nor', 'xor', 'rsh', 'ash', 'mov', 'ldi', 'jmp', 'bge', 'blt', 'bng', 'bps', 'beq', 'bne', 'mld', 'mst', 'psh', 'pop', 'cal', 'ret']
regs0   = ['r0', 'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7']
regs1   = ['reg0', 'reg1', 'reg2', 'reg3', 'reg4', 'reg5', 'reg6', 'reg7']
regs2   = ['A', 'B', 'C', 'D', 'E', 'F', 'G']

symbols = {} # dictionary to hold symbols and their corresponding values
for index, value in enumerate(opcodes):
    symbols[value] = index
for index, value in enumerate(regs0):
    symbols[value] = index
for index, value in enumerate(regs1):
    symbols[value] = index
for index, value in enumerate(regs2):
    symbols[value] = index


# preprocess lines and remove comments / whitespace
lines = [line.lower().strip() for line in asmcode] # remove nl
for comments in ['/', ';', '#']:
    lines = [line.split(comments)[0] for line in lines] # divide comments and keep part before them
lines = [line for line in lines if line.strip()] # comments will be blank so remove them and also removes regular bl

lines = [line.split() for line in lines] # turn into elements per line

# collect labels
labels = {}
pc = 0
for line in lines:
    if line[0].startswith('@'):
        label_name = line[0][1:] # remove @
        labels[label_name] = pc
    else:
        pc += 1

# OP    C      A   B
# 00000 000 00 000 000
#     0   1      2

offset0 = pow(2, 11)
offset1 = pow(2, 8)
offset2 = pow(2, 3)

def evaluateImmediate8(imm):
    return int(imm, 0) % offset1

def evaluateImmediate11(imm):
    return int(imm, 0) % offset0 # if its more, then like wrap around lol

def interpretZeroOperands(l):
    return (symbols[l[0]] * offset0) # OP

def interpretOneOperandA(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset2) # A

def interpretOneOperandC(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset1) # C

def interpretTwoOperandsCA(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset1) + (symbols[l[2]] * offset2) # C A

def interpretTwoOperandsCB(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset1) + (symbols[l[2]]) # C B

def interpretTwoOperandsAB(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset2) + (symbols[l[2]]) # A B

def interpretThreeOperands(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset1) + (symbols[l[2]] * offset2) + (symbols[l[3]]) # C A B

def interpretZeroImmediate(l):
    return (symbols[l[0]] * offset0) + (evaluateImmediate11(l[1])) # IMM like 11 bit or something

def interpretOneImmediate(l):
    return (symbols[l[0]] * offset0) + (symbols[l[1]] * offset1) + (evaluateImmediate8(l[2])) # C IMM

output = []
for line in lines:
    if line[0].startswith('@'):
        continue # skip label lines

    # replace label references with values
    for i, token in enumerate(line):
        if token in labels:
            line[i] = str(labels[token])

    if line[0] == 'nop':
        output.append(interpretZeroOperands(line))
    elif line[0] == 'hlt':
        output.append(interpretZeroOperands(line))
    elif line[0] == 'add':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'adc':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'adi':
        output.append(interpretOneImmediate(line))
    elif line[0] == 'sub':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'sbb':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'and':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'bor':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'nor':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'xor':
        output.append(interpretThreeOperands(line))
    elif line[0] == 'rsh':
        output.append(interpretTwoOperandsCA(line))
    elif line[0] == 'ash':
        output.append(interpretTwoOperandsCA(line))
    elif line[0] == 'mov':
        output.append(interpretTwoOperandsCA(line))
    elif line[0] == 'ldi':
        output.append(interpretOneImmediate(line))
    elif line[0] == 'jmp':
        output.append(interpretZeroImmediate(line))
    elif line[0] == 'bge':
        output.append(interpretZeroImmediate(line))
    elif line[0] == 'blt':
        output.append(interpretZeroImmediate(line))
    elif line[0] == 'bng':
        output.append(interpretZeroImmediate(line))
    elif line[0] == 'bps':
        output.append(interpretZeroImmediate(line))
    elif line[0] == 'beq':
        output.append(interpretZeroImmediate(line))
    elif line[0] == 'bne':
        output.append(interpretZeroImmediate(line))
    elif line[0] == 'mld':
        output.append(interpretTwoOperandsCB(line))
    elif line[0] == 'mst':
        output.append(interpretTwoOperandsAB(line))
    elif line[0] == 'psh':
        output.append(interpretOneOperandA(line))
    elif line[0] == 'pop':
        output.append(interpretOneOperandC(line))
    elif line[0] == 'cal':
        output.append(interpretZeroImmediate(line))
    elif line[0] == 'ret':
        output.append(interpretZeroOperands(line))
    else:
        raise ValueError(f"Unknown instruction: {line[0]}")

for value in output:
    mccode.write(format(value, f"0{16}b") + '\n')

remaining_lines = 2048 - len(output)
zero_line = '0' * 16 + '\n'
mccode.writelines([zero_line] * remaining_lines)

mccode.write(f"{output}")