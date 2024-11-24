import custom_types::*;

module control_unit (
    input logic clk,
    input logic reset,
    input opcode_t opcode,
    input logic zero,
    output logic ir_write, pc_write, reg_write, mem_write, zero_write,
    output logic [1:0] alu_sel1, alu_sel2,
    output alu_operation_t alu_op,
    output logic [1:0] result_sel
);
    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= FETCH;
        else state <= next_state;
    end

    /* compute next state */
    always_comb begin
        case (state)
            FETCH: next_state = DECODE;
            DECODE: begin
                case (opcode)
                    OPCODE_ADD, OPCODE_SUB, OPCODE_AND, OPCODE_OR, OPCODE_XOR, OPCODE_MOV, OPCODE_MOVI, OPCODE_ADDI, OPCODE_SUBI, OPCODE_LSLI: begin
                        next_state = EXECUTE;
                    end
                    OPCODE_LD, OPCODE_ST: begin
                        next_state = MEMORY_ACCESS;
                    end
                    OPCODE_JMP, OPCODE_BEQ, OPCODE_BNE: begin
                        next_state = FETCH;
                    end
                endcase
            end
            EXECUTE: next_state = WRITE_BACK;
            MEMORY_ACCESS: begin
                if (opcode == OPCODE_LD) begin
                    next_state = WRITE_BACK;
                end else begin
                    next_state = FETCH;
                end
            end
            WRITE_BACK: next_state = FETCH;
        endcase
    end

    /* compute control signals */
    always_comb begin
        pc_write = 0;
        ir_write = 0;
        reg_write = 0;
        mem_write = 0;
        zero_write = 0;

        case (state)
            FETCH: begin
                pc_write = 1;
                ir_write = 1;
                alu_sel1 = 2'b00;
                alu_sel2 = 2'b01;
                alu_op = ALU_ADD;
                result_sel = 2'b01;
            end
            DECODE: begin
                if (opcode == OPCODE_JMP || opcode == OPCODE_BEQ || opcode == OPCODE_BNE) begin
                    result_sel = 2'b10;
                    if (opcode == OPCODE_JMP) begin
                        pc_write = 1;
                    end else if (opcode == OPCODE_BEQ) begin
                        pc_write = zero;
                    end else if (opcode == OPCODE_BNE) begin
                        pc_write = !zero;
                    end
                end
            end
            EXECUTE: begin
                case (opcode)
                    OPCODE_ADD, OPCODE_SUB, OPCODE_AND, OPCODE_OR, OPCODE_XOR: begin
                        alu_sel1 = 2'b01;
                        alu_sel2 = 2'b00;
                        if (opcode == OPCODE_ADD) alu_op = ALU_ADD;
                        else if (opcode == OPCODE_SUB) begin
                            alu_op = ALU_SUB;
                            zero_write = 1;
                        end else if (opcode == OPCODE_AND) begin
                            alu_op = ALU_AND;
                            zero_write = 1;
                        end else if (opcode == OPCODE_OR) alu_op = ALU_OR;
                        else if (opcode == OPCODE_XOR) alu_op = ALU_XOR;
                    end
                    OPCODE_ADDI, OPCODE_SUBI, OPCODE_LSLI: begin
                        alu_sel1 = 2'b01;
                        alu_sel2 = 2'b10;
                        if (opcode == OPCODE_ADDI) alu_op = ALU_ADD;
                        else if (opcode == OPCODE_SUBI) begin
                            alu_op = ALU_SUB;
                            zero_write = 1;
                        end else if (opcode == OPCODE_LSLI) alu_op = ALU_LSL;
                    end
                    OPCODE_MOVI: begin
                        alu_sel1 = 2'b10;
                        alu_sel2 = 2'b10;
                        alu_op = ALU_ADD;
                    end
                    OPCODE_MOV: begin
                        alu_sel1 = 2'b10;
                        alu_sel2 = 2'b00;
                        alu_op = ALU_ADD;
                    end
                endcase
            end
            MEMORY_ACCESS: begin
                if (opcode == OPCODE_ST) begin
                    mem_write = 1; /* enable writing to memory */
                end
            end
            WRITE_BACK: begin
                reg_write = 1; /* write to register file */
                if (opcode == OPCODE_LD) result_sel = 2'b00;
                else result_sel = 2'b01;
            end
        endcase
    end

    endmodule
