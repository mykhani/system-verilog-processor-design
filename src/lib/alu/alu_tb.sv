import custom_types::*;

module alu_tb;

    logic [3:0] op1;
    logic [3:0] op2;
    logic [3:0] result;
    logic zero;

    alu_operation_t operation;

    alu alu1(op1, op2, operation, result, zero);

    initial begin
        $dumpfile("alu.vcd"); /* vcd -> value change dump */
        $dumpvars(1, alu_tb);

        op1=5; op2=5; operation=ALU_ADD; #10;
        op1=10; op2=5; operation=ALU_SUB; #10;
        op1=4'b1111; op2=4'b1100; operation=ALU_AND; #10;
        op1=4'b1010; op2=4'b0101; operation=ALU_OR; #10;
        op1=4'b1111; op2=4'b1010; operation=ALU_XOR; #10;
        op1=5; op2=10; operation=ALU_LT; #10;
        op1=10; op2=5; operation=ALU_LT; #10;
        op1=10; op2=10; operation=ALU_SUB; #10;
    end

endmodule
