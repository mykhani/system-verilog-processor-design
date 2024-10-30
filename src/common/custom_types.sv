package custom_types;
    typedef enum logic [1:0] {
        R0,
        R1,
        R2,
        R3
    } regs_t;

    typedef enum logic [3:0] {
        OPCODE_ADD,
        OPCODE_SUB,
        OPCODE_AND,
        OPCODE_OR,
        OPCODE_XOR,
        OPCODE_LD,
        OPCODE_ST,
        OPCODE_JMP,
        OPCODE_BEQ,
        OPCODE_BNE,
        OPCODE_MOV,
        OPCODE_MOVI,
        OPCODE_ADDI,
        OPCODE_SUBI,
        OPCODE_LSLI
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
