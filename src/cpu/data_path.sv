import custom_types::*;

module data_path (
    input logic clk, reset,
    input instruction_t next_instr,
    input logic ir_write, pc_write, reg_write, data_write, alu_write, zero_write,
    input logic [1:0] alu_src1, alu_src2,
    input alu_operation_t alu_op,
    input logic [1:0] result_src,
    output logic zero,
    output opcode_t opcode,
    output logic [3:0] pc
);
    logic [3:0] rd1, rd2, ignore;
    logic [3:0] read_data;
    logic [3:0] op1, op2, extended_imm2;
    logic [3:0] alu_result, alu_out, result, next_pc;
    logic zero_result;
    instruction_t instr;

    register_custom_width #(.WIDTH(4)) program_counter(clk, reset,
            pc_write, next_pc, pc);

    register_custom_width #(.WIDTH(8)) instr_reg(clk, reset,
            ir_write, next_instr, instr);

    register_custom_width #(.WIDTH(4)) alu_reg(clk, reset,
            alu_write, alu_result, alu_out);

    register_custom_width #(.WIDTH(1)) zero_reg(clk, reset,
            zero_write, zero_result, zero);

    register_file reg_file(clk, reset, reg_write,
            instr.operand.regs.src, instr.operand.regs.dst,
            instr.operand.regs.dst, result, rd1, rd2);

    /* data memory to be accessed by LD, ST instrs
    *  the read/write address is inside the src register of the instr
    *  the data to write is inside dst register of the instr */
    memory #(.WIDTH(4)) data_mem(clk, reset, data_write, rd1, rd2, read_data);

    /* mux to allow a single ALU to be shared by different operands i.e. PC,
    * registers */
    mux_4to1 #(.BUS_WIDTH(4)) alu_op_mux1(pc, rd1, 4'd0, extended_imm2,
            alu_src1, op1);

    mux_4to1 #(.BUS_WIDTH(4)) alu_op_mux2(rd2, instr.operand.imm4, 4'd1, 4'd0,
            alu_src2, op2);

    mux_4to1 #(.BUS_WIDTH(4)) result_mux(alu_out, read_data, alu_result, instr.operand.imm4,
            result_src, result);

    alu alu_inst(op1, op2, alu_op, alu_result, zero_result);

    assign opcode = instr.opcode;
    assign next_pc = result;
    assign extended_imm2 = {2'b00, instr.operand.imm2.val};

endmodule
