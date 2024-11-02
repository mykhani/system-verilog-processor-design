## Required Instructions

### ADD
```
+---------------------+-----------+-----------+
| 4-bit opcode (0000) | 2-bit src | 2-bit dst |
+---------------------+-----------+-----------+
```
ADD instruction adds two registers and stores the result into destination register.
For example:
```
 ADD RD, RS results RD = RD + RS
```

### SUB
```
+---------------------+-----------+-----------+
| 4-bit opcode (0001) | 2-bit src | 2-bit dst |
+---------------------+-----------+-----------+
```
SUB instruction subtracts two registers and stores the result into destination register.
For example:
```
 SUB RD, RS results RD = RD - RS
```

### AND
```
+---------------------+-----------+-----------+
| 4-bit opcode (0010) | 2-bit src | 2-bit dst |
+---------------------+-----------+-----------+
```
AND instruction computes bitwise-AND of two registers and stores the result into
destination register.
For example:
```
 AND RD, RS results RD = RD & RS
```

### OR
```
+---------------------+-----------+-----------+
| 4-bit opcode (0011) | 2-bit src | 2-bit dst |
+---------------------+-----------+-----------+
```
OR instruction computes bitwise-OR of two registers and stores the result into
destination register.
For example:
```
 SUB RD, RS results RD = RD | RS
```

### XOR
```
+---------------------+-----------+-----------+
| 4-bit opcode (0100) | 2-bit src | 2-bit dst |
+---------------------+-----------+-----------+
```
XOR instruction computes bitwise-XOR of two registers and stores the result into
destination register.
For example:
```
 XOR RD, RS results RD = RD ^ RS
```

### LD
```
+---------------------+-----------+-----------+
| 4-bit opcode (0101) | 2-bit src | 2-bit dst |
+---------------------+-----------+-----------+
```
LD instruction copies the data stored at memory address contained in src register
and stores the result into destination register.
For example:
```
 LD RD, RS results RD = mem[RS value]
```

### ST
```
+---------------------+-----------+-----------+
| 4-bit opcode (0110) | 2-bit src | 2-bit dst |
+---------------------+-----------+-----------+
```
ST instruction stores the data contained in src register to the memory address
contained inside dst register.
For example:
```
 ST RD, RS results mem[RD val] = RS
```

### JMP
```
+---------------------+-----------------------+
| 4-bit opcode (0111) | 4-bit immediate val   |
+---------------------+-----------------------+
```
JMP instruction changes the program counter to the current PC value plus
the 4-bit immediate offset.
For example:
```
 JMP 4'b1010 results new PC = curr PC + 4'b1010
```

### BEQ
```
+---------------------+-----------------------+
| 4-bit opcode (1000) | 4-bit immediate val   |
+---------------------+-----------------------+
```
BEQ is similar to JMP add changes the program counter to the current PC value plus
the 4-bit immediate offset, but only if the zero flag is set.
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
BNE is similar to BEQ add changes the program counter to the current PC value plus
the 4-bit immediate offset, but only if the zero flag is unset.
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
+---------------------+-----------+-----------+
| 4-bit opcode (1010) | 2-bit src | 2-bit dst |
+---------------------+-----------+-----------+
```
MOV instruction stores the data from src register to the dst register.
For example:
```
MOV RD, RS results RD = RS
```

### MOVI
```
+---------------------+-----------+-----------+
| 4-bit opcode (1011) | 2-bit imm | 2-bit dst |
+---------------------+-----------+-----------+
```
MOVI instruction stores the 2-bit immediate value bit-extended to 4
bits into the dst register.
For example:
```
MOVI RD, #1 results RD = 4'b0001
```

### ADDI
```
+---------------------+-----------+-----------+
| 4-bit opcode (1100) | 2-bit imm | 2-bit dst |
+---------------------+-----------+-----------+
```
ADDI instruction adds the 2-bit immediate value bit-extended to 4
bits to the dst register.
For example:
```
RD = 4'd3;
ADDI RD, #1 results RD = 4'd4
```

### SUBI
```
+---------------------+-----------+-----------+
| 4-bit opcode (1101) | 2-bit imm | 2-bit dst |
+---------------------+-----------+-----------+
```
SUBI instruction subtracts the 2-bit immediate value bit-extended to 4
bits from the dst register.
For example:
```
RD = 4'd3;
SUBI RD, #1 results RD = 4'd2
```

### LSLI
```
+---------------------+-----------+-----------+
| 4-bit opcode (1110) | 2-bit imm | 2-bit dst |
+---------------------+-----------+-----------+
```
LSLI instruction left shifts the dst register value by 2-bit immediate
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
|2.   | SUB         | :white_large_square: |
|3.   | AND         | :white_large_square: |
|4.   | OR          | :white_large_square: |
|5.   | XOR         | :white_large_square: |
|6.   | LD          | :white_check_mark:   |
|7.   | ST          | :white_check_mark:   |
|8.   | JMP         | :white_check_mark:   |
|9.   | BEQ         | :white_large_square: |
|10.  | BNE         | :white_check_mark:   |
|11.  | MOV         | :white_large_square: |
|12.  | MOVI        | :white_check_mark:   |
|13.  | ADDI        | :white_check_mark:   |
|14.  | SUBI        | :white_check_mark:   |
|15.  | LSLI        | :white_check_mark:   |
