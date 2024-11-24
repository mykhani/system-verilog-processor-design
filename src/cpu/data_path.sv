import custom_types::*;

module data_path (
    input logic clk, reset,
    input logic ir_write, pc_write, reg_write, mem_write, zero_write,
    input logic [1:0] alu_sel1, alu_sel2,
    input alu_operation_t alu_op,
    input logic [1:0] result_sel,
    output logic zero,
    output opcode_t opcode
);
    logic [3:0] rd1, rd2, ignore;
    logic [3:0] read_data;
    logic [3:0] op1, op2, extended_imm2;
    logic [3:0] alu_result, result, next_pc, pc, mem_addr;
    logic zero_result;
    instruction_t next_instr, instr;
    logic mem_reset;

    register_custom_width #(.WIDTH(4)) program_counter(clk, reset,
            pc_write, next_pc, pc);

    register_custom_width #(.WIDTH(8)) instr_reg(clk, reset,
            ir_write, next_instr, instr);

    register_custom_width #(.WIDTH(1)) zero_reg(clk, reset,
            zero_write, zero_result, zero);

    register_file reg_file(clk, reset, reg_write,
            instr.operand.rtype.rd, instr.operand.rtype.rs,
            instr.operand.rtype.rd, result, rd1, rd2);

    /* data memory to be accessed by LD, ST instructions */
    memory #(.WIDTH(4)) data_mem(clk, mem_reset, mem_write, mem_addr, rd1, read_data);

    /* instruction memory */
    memory #(.WIDTH(8)) instr_mem(clk, mem_reset, 1'b0, pc, 8'd0, next_instr);

    /* mux to allow a single ALU to be shared by different operands i.e. PC,
    * registers */
    mux_4to1 #(.BUS_WIDTH(4)) alu_op1_mux(pc, rd1, 4'b0000, 4'bxxxx,
            alu_sel1, op1);

    mux_4to1 #(.BUS_WIDTH(4)) alu_op2_mux(rd2, 4'b0001, extended_imm2, 4'bxxxx,
            alu_sel2, op2);

    mux_4to1 #(.BUS_WIDTH(4)) result_mux(read_data, alu_result, instr.operand.btype.imm4, 4'bxxxx,
            result_sel, result);

    alu alu_inst(op1, op2, alu_op, alu_result, zero_result);

    assign opcode = instr.opcode;
    assign next_pc = result;
    assign extended_imm2 = {2'b00, instr.operand.itype.imm2};
    //assign mem_reset = reset;
    assign mem_reset = 0; /* don't reset memory to retain contents between cpu resets */
    assign mem_addr = rd2;

endmodule
