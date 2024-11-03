# Simple 4-bit CPU design in System Verilog

## Installation instructions (Linux)
1. Follow the instructions at https://steveicarus.github.io/iverilog/usage/installation.html
to Install the Icarus simulator
```
git clone https://github.com/steveicarus/iverilog.git
cd iverilog
./configure
make -j 16 && sudo make install
```
2. Install the gtkwave to view signal waveforms.
```
sudo apt install gtkwave
```

## Running the CPU testbench
```
git clone https://github.com/mykhani/system-verilog-processor-design.git
cd system-verilog-processor-design
make view
```

## CPU Block Diagram
See the [CPU Block Diagram](doc/cpu_block.png).

## Required Instructions

### ADD
```
+---------------------+----------+----------+
| 4-bit opcode (0000) | 2-bit rs | 2-bit rd |
+---------------------+----------+----------+
```
ADD instruction adds two registers and stores the result into destination register.
For example:
```
 ADD RD, RS results RD = RD + RS
```

### SUB
```
+---------------------+----------+----------+
| 4-bit opcode (0001) | 2-bit rs | 2-bit rd |
+---------------------+----------+----------+
```
SUB instruction subtracts two registers and stores the result into destination register.
For example:
```
 SUB RD, RS results RD = RD - RS
```

### AND
```
+---------------------+----------+----------+
| 4-bit opcode (0010) | 2-bit rs | 2-bit rd |
+---------------------+----------+----------+
```
AND instruction computes bitwise-AND of two registers and stores the result into
destination register.
For example:
```
 AND RD, RS results RD = RD & RS
```

### OR
```
+---------------------+----------+----------+
| 4-bit opcode (0011) | 2-bit rs | 2-bit rd |
+---------------------+----------+----------+
```
OR instruction computes bitwise-OR of two registers and stores the result into
destination register.
For example:
```
 SUB RD, RS results RD = RD | RS
```

### XOR
```
+---------------------+----------+----------+
| 4-bit opcode (0100) | 2-bit rs | 2-bit rd |
+---------------------+----------+----------+
```
XOR instruction computes bitwise-XOR of two registers and stores the result into
destination register.
For example:
```
 XOR RD, RS results RD = RD ^ RS
```

### LD
```
+---------------------+----------+----------+
| 4-bit opcode (0101) | 2-bit rs | 2-bit rd |
+---------------------+----------+----------+
```
LD instruction copies the data stored at memory address contained in rs register
and stores the result into destination register.
For example:
```
 LD RD, RS results RD = mem[RS value]
```

### ST
```
+---------------------+-----------+-----------+
| 4-bit opcode (0110) | 2-bit rs1 | 2-bit rs2 |
+---------------------+-----------+-----------+
```
ST instruction stores the data contained in rs2 register to the memory address
contained inside rs1 register.

For example:
```
 ST RS1, RS2 results mem[RS1] = RS2
```

### JMP
```
+---------------------+-----------------------+
| 4-bit opcode (0111) | 4-bit immediate val   |
+---------------------+-----------------------+
```
JMP instruction changes the program counter to the absolute address specified by
the 4-bit immediate value.
For example:
```
 JMP 4'b1010 results new PC = 4'b1010
```

### BEQ
```
+---------------------+-----------------------+
| 4-bit opcode (1000) | 4-bit immediate val   |
+---------------------+-----------------------+
```
BEQ changes the program counter to the address of next instruction plus the
4-bit immediate offset, only if the zero flag is set.

For example:
```
R0 = 2;
R1 = 2;
SUB R0, R1 // sets zero flag
BEQ 4'b1010 results new PC = curr PC + 4'b1010
```

### BNE
```
+---------------------+-----------------------+
| 4-bit opcode (1001) | 4-bit immediate val   |
+---------------------+-----------------------+
```
BNE changes the program counter to the address of next instruction plus the
4-bit immediate offset, only if the zero flag is not set.

For example:
```
R0 = 4;
R1 = 2;
SUB R0, R1 // zero flag not set
BNE 4'b1010 results new PC = curr PC + 4'b1010
```

# Extra Instructions

### MOV
```
+---------------------+----------+----------+
| 4-bit opcode (1010) | 2-bit rs | 2-bit rd |
+---------------------+----------+----------+
```
MOV instruction stores the data from rs register to the rd register.
For example:
```
MOV RD, RS results RD = RS
```

### MOVI
```
+---------------------+-----------+----------+
| 4-bit opcode (1011) | 2-bit imm | 2-bit rd |
+---------------------+-----------+----------+
```
MOVI instruction stores the 2-bit immediate value bit-extended to 4
bits into the rd register.
For example:
```
MOVI RD, #1 results RD = 4'b0001
```

### ADDI
```
+---------------------+-----------+----------+
| 4-bit opcode (1100) | 2-bit imm | 2-bit rd |
+---------------------+-----------+----------+
```
ADDI instruction adds the 2-bit immediate value bit-extended to 4
bits to the rd register.
For example:
```
RD = 4'd3;
ADDI RD, #1 results RD = 4'd4
```

### SUBI
```
+---------------------+-----------+----------+
| 4-bit opcode (1101) | 2-bit imm | 2-bit rd |
+---------------------+-----------+----------+
```
SUBI instruction subtracts the 2-bit immediate value bit-extended to 4
bits from the rd register.
For example:
```
RD = 4'd3;
SUBI RD, #1 results RD = 4'd2
```

### LSLI
```
+---------------------+-----------+----------+
| 4-bit opcode (1110) | 2-bit imm | 2-bit rd |
+---------------------+-----------+----------+
```
LSLI instruction left shifts the rd register value by 2-bit immediate
bit positions
For example:
```
RD = 4'b0011;
LSLI RD, #2 results RD = 4'b1100
```

### Instructions Verified
The following instructions have been verified via the cpu testbench.

| No. | Instruction | Verified             |
|-----|-------------|----------------------|
|1.   | ADD         | :white_check_mark:   |
|2.   | SUB         | :white_check_mark:   |
|3.   | AND         | :white_check_mark:   |
|4.   | OR          | :white_check_mark:   |
|5.   | XOR         | :white_check_mark:   |
|6.   | LD          | :white_check_mark:   |
|7.   | ST          | :white_check_mark:   |
|8.   | JMP         | :white_check_mark:   |
|9.   | BEQ         | :white_check_mark:   |
|10.  | BNE         | :white_check_mark:   |
|11.  | MOV         | :white_check_mark:   |
|12.  | MOVI        | :white_check_mark:   |
|13.  | ADDI        | :white_check_mark:   |
|14.  | SUBI        | :white_check_mark:   |
|15.  | LSLI        | :white_check_mark:   |
