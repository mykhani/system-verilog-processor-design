import custom_types::*;

module control_unit (
    input logic clk,
    input logic reset,
    input opcode_t opcode,
    input logic zero,
    output logic ir_write, pc_write, reg_write, data_write, alu_write, zero_write,
    output logic [1:0] alu_src1, alu_src2,
    output alu_operation_t alu_op,
    output logic [1:0] result_src
);
    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= FETCH;
        else state <= next_state;
    end

    always_comb begin
        case (state)
            FETCH: next_state = DECODE;
            DECODE: next_state = EXECUTE;
            EXECUTE: begin
                case (opcode)
                    OPCODE_ADD, OPCODE_SUB, OPCODE_AND, OPCODE_OR, OPCODE_XOR, OPCODE_LSLI, OPCODE_MOVI, OPCODE_SUBI, OPCODE_ADDI: begin
                        next_state = WRITE_BACK;
                    end
                    OPCODE_LD, OPCODE_ST: begin
                        next_state = MEMORY_ACCESS;
                    end
                    OPCODE_JMP, OPCODE_BEQ, OPCODE_BNE: begin
                        next_state = FETCH;
                    end
                endcase
            end
            MEMORY_ACCESS: next_state = WRITE_BACK;
            WRITE_BACK: next_state = FETCH;
        endcase
    end

    always_comb begin

        pc_write = 0;
        ir_write = 0;
        reg_write = 0;
        data_write = 0;
        /* we use ALU in decode state to calculate potential jump address
         * in case the instruction is JMP, BEQ, or BNE */
        alu_write = 0;
        zero_write = 0;

        case (state)
            FETCH: begin
                alu_src1 = 2'b00;
                alu_src2 = 2'b10;
                result_src = 2'b10;
                alu_op = ALU_ADD;
                pc_write = 1;
                ir_write = 1;
            end
            DECODE: begin
                /* For BEQ and BNE, the potential new PC is current PC (already
                * incremented during fetch) + offset (immediate operand)
                * For JMP, the new PC is the absolute address contained
                * in the operand's immediate value. Hence we do 0 + imm value */
                if (opcode == OPCODE_BEQ || opcode == OPCODE_BNE) begin
                    alu_src1 = 2'b00;
                end else begin
                    alu_src1 = 2'b10;
                end
                alu_src2 = 2'b01;
                alu_op = ALU_ADD;
                alu_write = 1;
            end
            EXECUTE: begin
                alu_src1 = 2'b01; /* select rd1 as op1 */
                alu_src2 = 2'b00; /* select rd2 as op1 */
                result_src = 2'b00;
                alu_write = 1;
                case (opcode)
                    OPCODE_ADD: begin
                        zero_write = 1;
                        alu_op = ALU_ADD;
                    end
                    OPCODE_ADDI: begin
                        zero_write = 1;
                        alu_src1 = 2'b11; /* select immediate2 value as op1 */
                        alu_src2 = 2'b00; /* select rd2 value as op2 */
                        alu_op = ALU_ADD;
                    end
                    OPCODE_SUB: begin
                        zero_write = 1;
                        alu_op = ALU_SUB;
                    end
                    OPCODE_SUBI: begin
                        zero_write = 1;
                        alu_src1 = 2'b11; /* select immediate2 value as op1 */
                        alu_src2 = 2'b00; /* select rd2 value as op2 */
                        alu_op = ALU_SUB;
                    end

                    OPCODE_AND: begin
                        alu_op = ALU_AND;
                    end
                    OPCODE_OR: begin
                        alu_op = ALU_OR;
                    end
                    OPCODE_XOR: begin
                        alu_op = ALU_XOR;
                    end
                    OPCODE_LSLI: begin
                        alu_op = ALU_LSL;
                        alu_src1 = 2'b11; /* select immediate2 value as op1 */
                        alu_src2 = 2'b00; /* select rd2 value as op2 */
                    end
                    OPCODE_MOVI: begin
                        alu_src1 = 2'b11; /* select immediate2 as op1 */
                        alu_src2 = 2'b11; /* select 0 value as op2 */
                        alu_op = ALU_ADD; /* adding 0 effectively means result is immediate value */
                    end
                    OPCODE_MOV: begin
                        alu_src1 = 2'b01; /* select rd1 as op1 */
                        alu_src2 = 2'b11; /* select 0 value as op2 */
                        alu_op = ALU_ADD; /* adding 0 effectively means result is rd1 value */
                    end
                                        OPCODE_BEQ: begin
                        result_src = 2'b11; /* select immediate4 as result */
                        if (zero) pc_write = 1;
                    end
                    OPCODE_BNE: begin
                        result_src = 2'b11; /* select immediate4 as result */
                        if (!zero) pc_write = 1;
                    end
                    OPCODE_JMP: begin
                        alu_src1 = 2'b00;
                        alu_src2 = 2'b01;
                        pc_write = 1;
                        alu_write = 0;
                    end
                endcase
            end
            MEMORY_ACCESS: begin
                result_src = 2'b01;
                if (opcode == OPCODE_ST) data_write = 1;
            end
            WRITE_BACK: begin
                reg_write = 1;
            end
        endcase
    end

    endmodule
