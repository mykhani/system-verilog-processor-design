import custom_types::*;

module control_unit (
    input logic clk,
    input logic reset,
    input opcode_t opcode,
    input logic zero,
    output logic ir_write, pc_write, reg_write, mem_write, alu_write, zero_write,
    output logic [1:0] alu_sel1, alu_sel2,
    output alu_operation_t alu_op,
    output logic addr_sel,
    output logic [1:0] result_sel
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
                    OPCODE_ADD, OPCODE_SUB, OPCODE_AND, OPCODE_OR,
                    OPCODE_XOR, OPCODE_LSLI, OPCODE_MOVI, OPCODE_SUBI,
                    OPCODE_ADDI: begin
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

    always_comb begin
        pc_write = 0;
        ir_write = 0;
        reg_write = 0;
        mem_write = 0;
        alu_write = 0;
        zero_write = 0;

        case (state)
            FETCH: begin
                /* select signals to calculate next PC */
                alu_sel1 = 2'b10; /* select 1 */
                alu_sel2 = 2'b01; /* select curr PC */
                alu_op = ALU_ADD;
                result_sel = 2'b10; /* select alu_result */
                pc_write = 1;
                /* Read the current PC to write current instruction to
                * instruction register */
                ir_write = 1;
            end
            DECODE: begin
                /* In the decode step, we try to utilize ALU and calculate
                 * the next possible branching address in case the current
                 * instruction is branching instruction e.g either of BEQ, BNE
                 * or JMP. For non-branching instruction, the result
                 * calculated (and stored in alu_out) is discarded.
                 *
                 * For BEQ and BNE, the potential new PC is current PC (already
                 * incremented during fetch) + offset (immediate operand)
                 *    
                 * For JMP, the new PC is the absolute address contained
                 * in the operand's immediate value. Hence we do 0 + imm value */
                if (opcode == OPCODE_BEQ || opcode == OPCODE_BNE) begin
                    alu_sel1 = 2'b01; /* select imm4 */
                    alu_sel2 = 2'b01; /* select current PC */
                end else if (opcode == OPCODE_JMP) begin
                    alu_sel1 = 2'b01; /* select imm4 */
                    alu_sel2 = 2'b11; /* select 0 */
                end
                alu_op = ALU_ADD;
                alu_write = 1; /* store ALU result to be used in the next step */
            end
            EXECUTE: begin
                case (opcode)
                    OPCODE_ADD: begin
                        alu_sel1 = 2'b00; /* select rd2 as op1 */
                        alu_sel2 = 2'b10; /* select rd1 as op2 */
                        alu_op = ALU_ADD;
                        alu_write = 1; /* store ALU result to be used in the next step */
                    end
                    OPCODE_ADDI: begin
                        alu_sel1 = 2'b00; /* select rd2 as op1 */
                        alu_sel2 = 2'b00; /* select imm2 value as op2 */
                        alu_op = ALU_ADD;
                        alu_write = 1; /* store ALU result to be used in the next step */
                    end
                    OPCODE_SUB: begin
                        alu_sel1 = 2'b00; /* select rd2 as op1 */
                        alu_sel2 = 2'b10; /* select rd1 as op2 */
                        alu_op = ALU_SUB;
                        alu_write = 1; /* store ALU result to be used in the next step */
                        zero_write = 1; /* store (rd2 - rd1 == 0) */
                    end
                    OPCODE_SUBI: begin
                        alu_sel1 = 2'b00; /* select rd2 as op1 */
                        alu_sel2 = 2'b00; /* select imm2 value as op2 */
                        alu_op = ALU_SUB;
                        alu_write = 1; /* store ALU result to be used in the next step */
                        zero_write = 1;
                    end
                    OPCODE_AND: begin
                        alu_sel1 = 2'b00; /* select rd2 as op1 */
                        alu_sel2 = 2'b10; /* select rd1 as op2 */
                        alu_op = ALU_AND;
                        alu_write = 1; /* store ALU result to be used in the next step */
                    end
                    OPCODE_OR: begin
                        alu_sel1 = 2'b00; /* select rd2 as op1 */
                        alu_sel2 = 2'b10; /* select rd1 as op2 */
                        alu_op = ALU_OR;
                        alu_write = 1; /* store ALU result to be used in the next step */
                    end
                    OPCODE_XOR: begin
                        alu_sel1 = 2'b00; /* select rd2 as op1 */
                        alu_sel2 = 2'b10; /* select rd1 as op2 */
                        alu_op = ALU_XOR;
                        alu_write = 1; /* store ALU result to be used in the next step */
                    end
                    OPCODE_LSLI: begin
                        alu_sel1 = 2'b00; /* select rd2 as op1 */
                        alu_sel2 = 2'b00; /* select imm2 value as op2 */
                        alu_op = ALU_LSL;
                        alu_write = 1; /* store ALU result to be used in the next step */
                    end
                    OPCODE_MOVI: begin
                        alu_sel1 = 2'b11; /* select 0 value as op1 */
                        alu_sel2 = 2'b00; /* select imm2 value as op2 */
                        alu_op = ALU_ADD; /* adding 0 effectively means result is immediate value */
                        alu_write = 1; /* store ALU result to be used in the next step */
                    end
                    OPCODE_MOV: begin
                        alu_sel1 = 2'b11; /* select 0 value as op1 */
                        alu_sel2 = 2'b10; /* select rd1 as op2 */
                        alu_op = ALU_ADD; /* adding 0 effectively means result is rd1 value */
                        alu_write = 1; /* store ALU result to be used in the next step */
                    end
                    OPCODE_BEQ: begin
                        /* if zero flag is set, update PC */
                        if (zero) begin
                            pc_write = 1;
                        end
                        result_sel = 2'b01; /* select alu_out (from decode step) as result */
                    end
                    OPCODE_BNE: begin
                        /* if zero flag is not set, update PC */
                        if (!zero) begin
                            pc_write = 1;
                        end
                        result_sel = 2'b01; /* select alu_out (from decode step) as result */
                    end
                    OPCODE_JMP: begin
                        /* update next PC unconditionally */
                        pc_write = 1;
                        result_sel = 2'b01; /* select alu_out (from decode step) as result */
                    end
                endcase
            end
            MEMORY_ACCESS: begin
                /* select memory address source */
                if (opcode == OPCODE_LD) begin
                    /* load instruction */
                    addr_sel = 0; /* rd1 contains memory address to read */
                                  /* rd2 contains data to write */
                    result_sel = 2'b00; /* select read data */
                end else begin
                    /* store instruction */
                    addr_sel = 1; /* rd2 contains memory address to write */
                                  /* rd1 contains data to write */
                    mem_write = 1; /* enable writing to memory */
                end
            end
            WRITE_BACK: begin
                reg_write = 1; /* write to register file */
                if (opcode == OPCODE_LD) begin
                    result_sel = 2'b00; /* select data read in memory access step */
                end else begin
                    result_sel = 2'b01; /* select alu_out (updated in execute step) */
                end
            end
        endcase
    end

    endmodule
