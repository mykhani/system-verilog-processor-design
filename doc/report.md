# 4-bit CPU design in System Verilog
## Objective
The task is to design and implement a 4-bit CPU in System Verilog. For detailed instructions, please
see the `doc/project.pdf`. 


## Proposed Design
The proposed design is based on datapath and control unit for a FSM based multi-cyle CPU.

Datapath refers to all the components of the CPU which handle data flow i.e. perform some operations
and maintain state. For this project, the datapath consists of an 8-bit program counter, a 16x8
instruction memory, a register file consisting of four 4-bit registers, 

where each instruction goes through the following 5-steps, each step happening on the positive
edge of the CPU clock:

1. Fetch: CPU reads an instruction from the memory containing CPU instructions/program code.
2. Decode: CPU decodes the instruction read in the fetch step and asserts corresponding control
signals via the control unit to enable the required parts of the datapath.


