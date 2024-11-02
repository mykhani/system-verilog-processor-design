package custom_types;
    typedef enum logic [1:0] {
        R0,
        R1,
        R2,
        R3
    } regs_t;

    typedef enum logic [3:0] {
        /* 0x0 */ OPCODE_ADD,
        /* 0x1 */ OPCODE_SUB,
        /* 0x2 */ OPCODE_AND,
        /* 0x3 */ OPCODE_OR,
        /* 0x4 */ OPCODE_XOR,
        /* 0x5 */ OPCODE_LD,
        /* 0x6 */ OPCODE_ST,
        /* 0x7 */ OPCODE_JMP,
        /* 0x8 */ OPCODE_BEQ,
        /* 0x9 */ OPCODE_BNE,
        /* 0xA */ OPCODE_MOV,
        /* 0xB */ OPCODE_MOVI,
        /* 0xC */ OPCODE_ADDI,
        /* 0xD */ OPCODE_SUBI,
        /* 0xE */ OPCODE_LSLI
    } opcode_t;

    typedef enum logic [2:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_LT,
        ALU_LSL
    } alu_operation_t;

    typedef enum logic [2:0] {
        FETCH,
        DECODE,
        EXECUTE,
        MEMORY_ACCESS,
        WRITE_BACK
    } state_t;

    typedef union packed {
        struct packed {
            logic [1:0] src;
            logic [1:0] dst;
        } regs;
        struct packed {
            logic [1:0] val;
            logic [1:0] dst;
        } imm2;
        logic [3:0] imm4;
    } operand_t;

    typedef struct packed {
        opcode_t opcode;
        operand_t operand;
    } instruction_t;
endpackage
