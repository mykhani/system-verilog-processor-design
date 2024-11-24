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

## Project Report
Read the detailed [project report](doc/report.md).

### Instructions Verified
The following instructions have been verified via the cpu testbench.

| No. | Instruction | Verified           |
| --- | ----------- | ------------------ |
| 1.  | ADD         | :white_check_mark: |
| 2.  | SUB         | :white_check_mark: |
| 3.  | AND         | :white_check_mark: |
| 4.  | OR          | :white_check_mark: |
| 5.  | XOR         | :white_check_mark: |
| 6.  | LD          | :white_check_mark: |
| 7.  | ST          | :white_check_mark: |
| 8.  | JMP         | :white_check_mark: |
| 9.  | BEQ         | :white_check_mark: |
| 10. | BNE         | :white_check_mark: |
| 11. | MOV         | :white_check_mark: |
| 12. | MOVI        | :white_check_mark: |
| 13. | ADDI        | :white_check_mark: |
| 14. | SUBI        | :white_check_mark: |
| 15. | LSLI        | :white_check_mark: |
