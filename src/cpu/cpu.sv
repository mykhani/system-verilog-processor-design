import custom_types::*;

module cpu_4bit (
    input logic clk, reset
);
    logic ir_write, pc_write, reg_write, data_write, alu_write, zero_write;
    logic [1:0] alu_sel1, alu_sel2;
    opcode_t opcode;
    alu_operation_t alu_op;
    logic [1:0] result_sel;
    logic zero;

    control_unit control(clk, reset, opcode, zero, ir_write, pc_write, reg_write,
            data_write, alu_write, zero_write, alu_sel1, alu_sel2, alu_op, result_sel);

    data_path datapath(clk, reset, ir_write, pc_write, reg_write, data_write,
            alu_write, zero_write, alu_sel1, alu_sel2, alu_op, result_sel,
            zero, opcode);

endmodule
