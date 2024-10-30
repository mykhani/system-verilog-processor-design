import custom_types::*;

module cpu_4bit (
    input logic clk, reset,
    input instruction_t instruction,
    output logic [3:0] instruction_addr
);
    logic ir_write, pc_write, reg_write, data_write, alu_write, zero_write;
    logic [1:0] alu_src1, alu_src2;
    opcode_t opcode;
    alu_operation_t alu_op;
    logic [1:0] result_src;
    logic zero;

    control_unit control(clk, reset, opcode, zero,
            ir_write, pc_write, reg_write, data_write, alu_write, zero_write,
            alu_src1, alu_src2, alu_op, result_src);

    data_path datapath(clk, reset, instruction, 
            ir_write, pc_write, reg_write, data_write, alu_write, zero_write,
            alu_src1, alu_src2, alu_op, result_src,
            zero, opcode, instruction_addr);

endmodule
