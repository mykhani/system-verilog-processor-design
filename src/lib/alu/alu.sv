import custom_types::*;

module alu (
    input logic [3:0] op1,
    input logic [3:0] op2,
    input alu_operation_t operation,
    output logic [3:0] result,
    output logic zero
);
    always_comb begin
        case (operation)
        ALU_ADD: result = op1 + op2;
        ALU_SUB: result = op1 - op2;
        ALU_AND: result = op1 & op2;
        ALU_OR: result = op1 | op2;
        ALU_XOR: result = op1 ^ op2;
        ALU_LT: result = op1 < op2;
        ALU_LSL: result = op1 << op2;
        default: result = 0;
        endcase
    end

    assign zero = (result == 0);

endmodule
