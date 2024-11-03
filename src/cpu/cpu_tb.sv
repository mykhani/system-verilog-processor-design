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
         * R0 contains the data memory address to write
         * R1 contains the value to be written to the address
         * R2 is used for intermediate calculations
         */
        opcode = OPCODE_MOVI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0000);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R2;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0001);

        opcode = OPCODE_LSLI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'd2;
        program_instruction(4'b0010);

        opcode = OPCODE_ADD;
        operand.rtype.rd = R3;
        operand.rtype.rs = R2;
        program_instruction(4'b0011);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R0;
        operand.itype.imm2 = 2'b00;
        program_instruction(4'b0100);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R1;
        operand.itype.imm2 = 2'b00;
        program_instruction(4'b0101);

/*loop*/opcode = OPCODE_ST;
        operand.stype.rs1 = R0;
        operand.stype.rs2 = R1;
        program_instruction(4'b0110);

        /* increment address in R0 */
        opcode = OPCODE_ADDI;
        operand.itype.rd = R0;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b0111);

        /* increment the value in R1 */
        opcode = OPCODE_ADDI;
        operand.itype.rd = R1;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b1000);

        /* decrement loop count */
        opcode = OPCODE_SUBI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b1001);

        /* continue loop if count is not 0 */
        opcode = OPCODE_BNE;
        /* branch to address 0110 (offset -5 from next instruction)
        * -5 = 1011 */
        operand.btype.imm4 = 4'b1011;
        program_instruction(4'b1010);

        opcode = OPCODE_JMP;
        operand.btype.imm4 = 4'b1001; /* get stuck here */
        program_instruction(4'b1011);

        /* stop programming and release CPU from Reset after delay */
        prog_enable=0; prog_data=0; #10; cpu_reset=0;

        /* wait for the program to run */
        #3000;

        /* Reset CPU to write another program to read the populated data memory */
        cpu_reset=1; #10; prog_enable=1;

        $display("Writing program 2 to read data memory");

        /* Data memory must have the following contents by now
        *
        * +---------+----------+
        * | Address |   Data   |
        * +---------+----------+
        * | 4'b0000 | 4'b0000  |
        * | 4'b0001 | 4'b0001  |
        * | 4'b0010 | 4'b0010  |
        * | 4'b0011 | 4'b0011  |
        * | 4'b0100 | 4'b0100  |
        * | 4'b0101 | 4'b0101  |
        * | 4'b0110 | 4'b0110  |
        * | 4'b0111 | 4'b0111  |
        * | 4'b1000 | 4'b1000  |
        * | 4'b1001 | 4'b1001  |
        * | 4'b1010 | 4'b1010  |
        * | 4'b1011 | 4'b1011  |
        * | 4'b1100 | 4'b1100  |
        * | 4'b1101 | 4'b1101  |
        * | 4'b1110 | 4'b1110  |
        * +---------+----------+
        */

        /* R3 contains the loop count value
         * R0 contains the data memory address to read
         * R1 contains the value read from the address
         * R2 is used for intermediate calculations
         */
        opcode = OPCODE_MOVI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0000);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R2;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0001);

        opcode = OPCODE_LSLI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'd2;
        program_instruction(4'b0010);

        opcode = OPCODE_ADD;
        operand.rtype.rd = R3;
        operand.rtype.rs = R2;
        program_instruction(4'b0011);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R0;
        operand.itype.imm2 = 2'b00;
        program_instruction(4'b0100);

/*loop*/opcode = OPCODE_LD;
        operand.rtype.rd = R1;
        operand.rtype.rs = R0;
        program_instruction(4'b0101);

        /* increment address in R0 */
        opcode = OPCODE_ADDI;
        operand.itype.rd = R0;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b0110);

        /* decrement loop count */
        opcode = OPCODE_SUBI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b0111);

        /* continue loop if count is not 0 */
        opcode = OPCODE_BNE;
        /* branch to address 0101 (offset -4 from the next instruction)
        * -4 = 1100 */
        operand.btype.imm4 = 4'b1100;
        program_instruction(4'b1000);

        opcode = OPCODE_JMP;
        operand.btype.imm4 = 4'b1001; /* get stuck here */
        program_instruction(4'b1001);

        /* stop programming and release CPU from Reset after delay */
        prog_enable=0; prog_data=0; #10; cpu_reset=0;

        /* wait for the program to run */
        #3000;

        /* Reset CPU to write another program */
        cpu_reset=1; #10; prog_enable=1;

        $display("Writing program 3 to test AND, XOR, and BEQ instructions");

        /* Test
        *
        * Run a loop 15 times
        * Find even values by taking AND with 0001
        * Make even values odd by taking XOR with 0001
        *
        * R3 is loop counter;
        * R0 contains address index to read
        * R1 contains value read from address
        * R2 = 0001
        */
        opcode = OPCODE_MOVI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0000);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R2;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0001);

        opcode = OPCODE_LSLI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'd2;
        program_instruction(4'b0010);

        opcode = OPCODE_ADD;
        operand.rtype.rd = R3;
        operand.rtype.rs = R2;
        program_instruction(4'b0011);

        /* R2=2'b11 at this point, subtract 2 to make R2=1 */
        opcode = OPCODE_SUBI;
        operand.itype.rd = R2;
        operand.itype.imm2 = 2'd2;
        program_instruction(4'b0100);

/*loop*/opcode = OPCODE_LD;
        operand.rtype.rd = R1;
        operand.rtype.rs = R0;
        program_instruction(4'b0101);

        opcode = OPCODE_AND;
        operand.rtype.rd = R1;
        operand.rtype.rs = R2;
        program_instruction(4'b0110);

        opcode = OPCODE_BEQ;
        operand.btype.imm4 = 4'b0001; /* offset from PC */
        program_instruction(4'b0111);

        opcode = OPCODE_JMP;
        operand.btype.imm4 = 4'b1100; /* loop end */
        program_instruction(4'b1000);

/*XOR*/ opcode = OPCODE_LD;
        operand.rtype.rd = R1;
        operand.rtype.rs = R0;
        program_instruction(4'b1001);

        opcode = OPCODE_XOR;
        operand.rtype.rd = R1;
        operand.rtype.rs = R2;
        program_instruction(4'b1010);

        opcode = OPCODE_ST;
        operand.stype.rs1 = R0;
        operand.stype.rs2 = R1;
        program_instruction(4'b1011);

/*end*/ opcode = OPCODE_ADDI;
        operand.itype.rd = R0;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b1100);

        opcode = OPCODE_SUBI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b1101);

        opcode = OPCODE_BNE;
        /* offset to loop start from PC is -10 = 0110*/
        operand.btype.imm4 = 4'b0110;
        program_instruction(4'b1110);

        opcode = OPCODE_JMP;
        operand.btype.imm4 = 4'b1111;
        program_instruction(4'b1111); /* get stuck here */

        /* stop programming and release CPU from Reset after delay */
        prog_enable=0; prog_data=0; #10; cpu_reset=0;

        /* wait for the program to run */
        #6000;

        /* Reset CPU to write another program to read the populated data memory */
        cpu_reset=1; #10; prog_enable=1;

        $display("Writing program 4 to read data memory");

        /* Data memory must have the following contents by now
        *
        * +---------+----------+
        * | Address |   Data   |
        * +---------+----------+
        * | 4'b0000 | 4'b0001  |
        * | 4'b0001 | 4'b0001  |
        * | 4'b0010 | 4'b0011  |
        * | 4'b0011 | 4'b0011  |
        * | 4'b0100 | 4'b0101  |
        * | 4'b0101 | 4'b0101  |
        * | 4'b0110 | 4'b0111  |
        * | 4'b0111 | 4'b0111  |
        * | 4'b1000 | 4'b1001  |
        * | 4'b1001 | 4'b1001  |
        * | 4'b1010 | 4'b1011  |
        * | 4'b1011 | 4'b1011  |
        * | 4'b1100 | 4'b1101  |
        * | 4'b1101 | 4'b1101  |
        * | 4'b1110 | 4'b1111  |
        * +---------+----------+
        */

        /* R3 contains the loop count value
         * R0 contains the data memory address to read
         * R1 contains the value read from the address
         * R2 is used for intermediate calculations
         */
        opcode = OPCODE_MOVI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0000);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R2;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0001);

        opcode = OPCODE_LSLI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'd2;
        program_instruction(4'b0010);

        opcode = OPCODE_ADD;
        operand.rtype.rd = R3;
        operand.rtype.rs = R2;
        program_instruction(4'b0011);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R0;
        operand.itype.imm2 = 2'b00;
        program_instruction(4'b0100);

/*loop*/opcode = OPCODE_LD;
        operand.rtype.rd = R1;
        operand.rtype.rs = R0;
        program_instruction(4'b0101);

        /* increment address in R0 */
        opcode = OPCODE_ADDI;
        operand.itype.rd = R0;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b0110);

        /* decrement loop count */
        opcode = OPCODE_SUBI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'd1;
        program_instruction(4'b0111);

        /* continue loop if count is not 0 */
        opcode = OPCODE_BNE;
        /* branch to address 0101 (offset -4 from the next instruction)
        * -4 = 1100 */
        operand.btype.imm4 = 4'b1100;
        program_instruction(4'b1000);

        opcode = OPCODE_JMP;
        operand.btype.imm4 = 4'b1001; /* get stuck here */
        program_instruction(4'b1001);

        /* stop programming and release CPU from Reset after delay */
        prog_enable=0; prog_data=0; #10; cpu_reset=0;

        /* wait for the program to run */
        #3000;

        /* Reset CPU to write another program instructions */
        cpu_reset=1; #10; prog_enable=1;

        $display("Writing program 5 to test MOV, SUB, and BEQ and OR instructions");

        opcode = OPCODE_MOVI;
        operand.itype.rd = R1;
        operand.itype.imm2 = 2'b10;
        program_instruction(4'b0000);

        opcode = OPCODE_MOVI;
        operand.itype.rd = R2;
        operand.itype.imm2 = 2'b10;
        program_instruction(4'b0001);

        opcode = OPCODE_LSLI;
        operand.itype.rd = R1;
        operand.itype.imm2 = 2'd2;
        program_instruction(4'b0010);

        opcode = OPCODE_ADD;
        operand.rtype.rd = R1;
        operand.rtype.rs = R2;
        program_instruction(4'b0011);

        /* R1 = 1010, R2=0010 at this point */

        /* R3 = R1 */
        opcode = OPCODE_MOV;
        operand.rtype.rd = R3;
        operand.rtype.rs = R1;
        program_instruction(4'b0100);

        /* R3 = R3 - R2 i.e. 1010 - 0010 = 1000 */
        opcode = OPCODE_SUB;
        operand.rtype.rd = R3;
        operand.rtype.rs = R2;
        program_instruction(4'b0101);

        /* R3 = R3 + 3 = 1011 */
        opcode = OPCODE_ADDI;
        operand.itype.rd = R3;
        operand.itype.imm2 = 2'b11;
        program_instruction(4'b0110);

        /* R1 = R1 | R3 = 1010 | 1011 = 1011 */
        opcode = OPCODE_OR;
        operand.rtype.rd = R1;
        operand.rtype.rs = R3;
        program_instruction(4'b0111);

        /* R1 = R1 - R3 = 1011 - 1011 = 0000 */
        opcode = OPCODE_SUB;
        operand.rtype.rs = R1;
        operand.rtype.rs = R3;
        program_instruction(4'b1000);

        /* stop programming and release CPU from Reset after delay */
        prog_enable=0; prog_data=0; #10; cpu_reset=0;

        /* wait for the program to run */
        #2000;

        $finish;
    end
endmodule
