import custom_types::*;

module cpu_4bit (
    input logic clk, reset,
    input instruction_t instruction,
    output logic [3:0] instruction_addr
);
    logic ir_write, pc_write, reg_write, data_write, alu_write, zero_write;
    logic [1:0] alu_sel1, alu_sel2;
    opcode_t opcode;
    alu_operation_t alu_op;
    logic [1:0] result_sel;
    logic zero;
    logic addr_sel;

    control_unit control(clk, reset, opcode, zero,
            ir_write, pc_write, reg_write, data_write, alu_write, zero_write,
            alu_sel1, alu_sel2, alu_op, addr_sel, result_sel);

    data_path datapath(clk, reset, instruction, 
            ir_write, pc_write, reg_write, data_write, alu_write, zero_write,
            alu_sel1, alu_sel2, alu_op, addr_sel, result_sel,
            zero, opcode, instruction_addr);

endmodule
