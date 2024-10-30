import custom_types::*;

module cpu_tb;
    logic cpu_reset, prog_reset;
    logic prog_we;
    logic prog_clk;
    logic cpu_clk;
    logic prog_enable;
    logic [3:0] prog_addr, instr_addr, mem_addr;
    instruction_t prog_data, instr_data;
    logic prog_flash;

    mux_2to1 #(.BUS_WIDTH(4)) instr_addr_mux(instr_addr, prog_addr,
            prog_enable, mem_addr);

    memory #(.WIDTH(8)) instr_mem(prog_clk, prog_reset, prog_we, mem_addr, prog_data, instr_data);

    cpu_4bit cpu(cpu_clk, cpu_reset, instr_data, instr_addr);

    always begin
        #5; cpu_clk = ~cpu_clk;
    end

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);

        $monitor("at time:%t, addr:%b, write: %b, read: %b", $time, mem_addr, prog_data, instr_data);

        /* disable CPU while we program the program memory */
        cpu_reset = 1;

        prog_reset = 1; #10; prog_reset = 0;
        prog_enable = 1;
        cpu_clk = 0;
        prog_clk = 0;
        prog_we = 0;

        /* The data memory is completely empty, first example program
        * populates some values in it */

        /* program instructions */
        prog_addr=4'b0000;
        prog_data.opcode = OPCODE_MOVI;
        prog_data.operand.imm2.val = 2'b11;
        prog_data.operand.imm2.dst = R3;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        prog_addr=4'b0001;
        prog_data.opcode = OPCODE_MOVI;
        prog_data.operand.imm2.val = 2'b11;
        prog_data.operand.imm2.dst = R2;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        prog_addr=4'b0010;
        prog_data.opcode = OPCODE_LSLI;
        prog_data.operand.imm2.val = 2'd2;
        prog_data.operand.imm2.dst = R3;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        prog_addr=4'b0011;
        prog_data.opcode = OPCODE_ADD;
        prog_data.operand.regs.src = R2;
        prog_data.operand.regs.dst = R3;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        /* R3 = 4'b1111 */
        /* set R0 to address from 4'b0000 to 4'b1111 */
        /* write values from 4'b1111 to 4'b0000 to data mem */

        prog_addr=4'b0100;
        prog_data.opcode = OPCODE_MOVI;
        prog_data.operand.imm2.val = 2'b00;
        prog_data.operand.imm2.dst = R0;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        prog_addr=4'b0101;
        prog_data.opcode = OPCODE_ST;
        prog_data.operand.regs.src = R0;
        prog_data.operand.regs.dst = R3;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        prog_addr=4'b0110;
        prog_data.opcode = OPCODE_SUBI;
        prog_data.operand.imm2.val = 2'd1;
        prog_data.operand.imm2.dst = R3;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        /* increment address in R0 */
        prog_addr=4'b0111;
        prog_data.opcode = OPCODE_ADDI;
        prog_data.operand.imm2.val = 2'd1;
        prog_data.operand.imm2.dst = R0;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        prog_addr=4'b1000;
        prog_data.opcode = OPCODE_BNE;
        prog_data.operand.imm4 = 4'b0101;
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        prog_addr=4'b1001;
        prog_data.opcode = OPCODE_BEQ;
        prog_data.operand.imm4 = 4'b1001; /* get stuck here */
        #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;

        prog_enable = 0;
        prog_data  = 0;
        prog_addr = 0;

        #10; /* delay before releasing CPU from reset */
        cpu_reset = 0;

        #3000;
        $finish;
    end
endmodule
