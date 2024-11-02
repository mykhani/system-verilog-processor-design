import custom_types::*;

module cpu_tb;
    logic cpu_reset, prog_reset;
    logic prog_we;
    logic prog_clk;
    logic cpu_clk;
    logic prog_enable;
    logic [3:0] prog_addr, cpu_addr, addr;
    instruction_t prog_data, cpu_instr;
    logic prog_flash;
    opcode_t opcode;
    operand_t operand;

    task program_instruction(input [3:0] addr);
        begin
            prog_addr = addr;
            prog_data.opcode = opcode;
            prog_data.operand = operand;
            #5; prog_we=1; prog_clk=1; #5; prog_we=0; prog_clk=0;
            prog_addr += 1;
        end
    endtask

    mux_2to1 #(.BUS_WIDTH(4)) addr_mux(cpu_addr, prog_addr,
            prog_enable, addr);

    memory #(.WIDTH(8)) instr_mem(prog_clk, prog_reset, prog_we, addr, prog_data, cpu_instr);

    cpu_4bit cpu(cpu_clk, cpu_reset, cpu_instr, cpu_addr);

    always begin
        #5; cpu_clk = ~cpu_clk;
    end

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);

        $monitor("at time:%t, addr:%b, write: %b, read: %b", $time, addr, prog_data, cpu_instr);

        /* initialize clocks */
        cpu_clk=0; prog_clk=0;

        /* Reset CPU while we program the program memory */
        cpu_reset=1;

        /* reset program memory */
        prog_we=0; prog_reset=1; #5;
       
        /* The data memory is completely empty, first example program
         * populates some values in it
         *
         * NOTE: since registers are 4-bit, the maximum counter value 
         * possible is 15 so it is not possible to run a loop more than
         * 15 times */

        /* program instructions */
        prog_reset=0; prog_enable = 1;
        $display("Writing program 1 to populate data memory");

        /* R3 contains the loop count value
         * R0 contains the data memory address
         * R1 contains the value to be written to the address
         * R2 is used as intermediate calculations
         */
        opcode = OPCODE_MOVI;
        operand.imm2.dst = R3;
        operand.imm2.val = 2'b11;
        program_instruction(4'b0000);

        opcode = OPCODE_MOVI;
        operand.imm2.dst = R2;
        operand.imm2.val = 2'b11;
        program_instruction(4'b0001);

        opcode = OPCODE_LSLI;
        operand.imm2.dst = R3;
        operand.imm2.val = 2'd2;
        program_instruction(4'b0010);

        opcode = OPCODE_ADD;
        operand.regs.dst = R3;
        operand.regs.src = R2;
        program_instruction(4'b0011);

        opcode = OPCODE_MOVI;
        operand.imm2.dst = R0;
        operand.imm2.val = 2'b00;
        program_instruction(4'b0100);

        opcode = OPCODE_MOVI;
        operand.imm2.dst = R1;
        operand.imm2.val = 2'b00;
        program_instruction(4'b0101);

/*loop*/opcode = OPCODE_ST;
        operand.regs.dst = R0;
        operand.regs.src = R1;
        program_instruction(4'b0110);

        /* increment address in R0 */
        opcode = OPCODE_ADDI;
        operand.imm2.dst = R0;
        operand.imm2.val = 2'd1;
        program_instruction(4'b0111);

        /* update value in R1 */
        opcode = OPCODE_ADDI;
        operand.imm2.dst = R1;
        operand.imm2.val = 2'd1;
        program_instruction(4'b1000);

        /* decrement loop count */
        opcode = OPCODE_SUBI;
        operand.imm2.dst = R3;
        operand.imm2.val = 2'd1;
        program_instruction(4'b1001);

        /* continue loop if count is not 0 */
        opcode = OPCODE_BNE;
        /* branch to address 0110 (offset -5 from next instruction)
        * -5 = 1011 */
        operand.imm4 = 4'b1011;
        program_instruction(4'b1010);

        opcode = OPCODE_JMP;
        operand.imm4 = 4'b1001; /* get stuck here */
        program_instruction(4'b1011);

        /* stop programming and release CPU from Reset after delay */
        prog_enable=0; prog_data=0; #10; cpu_reset=0;

        /* wait for the program to run */
        #3000;

        /* Reset CPU to write another program to read the populated data memory */
        cpu_reset=1; #10; prog_enable=1;

        $display("Writing program 2 to read data memory");

        /* R3 contains the loop count value
         * R0 contains the data memory address
         * R1 contains the value read from the address
         * R2 is used as intermediate calculations
         */
        opcode = OPCODE_MOVI;
        operand.imm2.dst = R3;
        operand.imm2.val = 2'b11;
        program_instruction(4'b0000);

        opcode = OPCODE_MOVI;
        operand.imm2.dst = R2;
        operand.imm2.val = 2'b11;
        program_instruction(4'b0001);

        opcode = OPCODE_LSLI;
        operand.imm2.dst = R3;
        operand.imm2.val = 2'd2;
        program_instruction(4'b0010);

        opcode = OPCODE_ADD;
        operand.regs.dst = R3;
        operand.regs.src = R2;
        program_instruction(4'b0011);

        opcode = OPCODE_MOVI;
        operand.imm2.dst = R0;
        operand.imm2.val = 2'b00;
        program_instruction(4'b0100);

/*loop*/opcode = OPCODE_LD;
        operand.regs.dst = R1;
        operand.regs.src = R0;
        program_instruction(4'b0101);

        /* increment address in R0 */
        opcode = OPCODE_ADDI;
        operand.imm2.dst = R0;
        operand.imm2.val = 2'd1;
        program_instruction(4'b0110);

        /* decrement loop count */
        opcode = OPCODE_SUBI;
        operand.imm2.dst = R3;
        operand.imm2.val = 2'd1;
        program_instruction(4'b0111);

        /* continue loop if count is not 0 */
        opcode = OPCODE_BNE;
        /* branch to address 0101 (offset -4 from the next instruction)
        * -4 = 1100 */
        operand.imm4 = 4'b1100;
        program_instruction(4'b1000);

        opcode = OPCODE_JMP;
        operand.imm4 = 4'b1001; /* get stuck here */
        program_instruction(4'b1001);

        /* stop programming and release CPU from Reset after delay */
        prog_enable=0; prog_data=0; #10; cpu_reset=0;

        /* wait for the program to run */
        #3000;

        $finish;
    end
endmodule
