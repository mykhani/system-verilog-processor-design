import custom_types::*;

module cpu_tb;
    logic cpu_reset;
    logic cpu_clk;
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
            cpu.datapath.instr_mem.mem[addr] = prog_data;
        end
    endtask

    task cpu_step(input logic [3:0] count);
        begin
            for (int i = 0; i < count; i++) begin
                #5; cpu_clk=1; #5; cpu_clk=0;
            end
        end
    endtask

    cpu_4bit cpu(cpu_clk, cpu_reset);
/*
    always begin
        #5; cpu_clk = ~cpu_clk;
    end
*/
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);

        /* initialize clocks */
        cpu_clk=0;

        /* The data memory is completely empty, first example program
         * populates some values in it
         *
         * NOTE: it was later found out that the data memory can be
         * manipulated directly from the testbench. Neverthesless, the first
         * program makes up a good test and resembles a real world program.
         *
         * NOTE: since registers are 4-bit, the maximum counter value 
         * possible is 15 so it is not possible to run a loop more than
         * 15 times */

        $display("Writing program 1");

        /* R3 contains the loop count value
         * R0 contains the data memory address to write
         * R1 contains the value to be written to the address
         * R2 is used for intermediate calculations
         * 
         * This program tests MOVI, LSLI, ADD, ST, ADDI, SUBI, BNE, and JMP
         * instructions 
         *          MOVI R3, 2'b11
         *          MOVI R2, 2'b11
         *          LSLI R3, 2
         *          ADD R3, R2  -> R3 = 15
         *          MOVI R0, 2'b00
         *          MOVI R1, 2'b00
         * loop:    ST R0, R1 -> mem[R0] = R1
         *          ADDI R0, 1
         *          ADDI R1, 1
         *          SUBI R3, 1
         *          BNE loop
         *          JMP here
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
        operand.btype.imm4 = 4'b1011; /* get stuck here */
        program_instruction(4'b1011);

        /* Reset CPU while we program the program memory */
        cpu_reset=1;
        cpu_step(1);
        cpu_reset = 0;

        /* MOVI R3, 2'b11 */
        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R3] == 4'b0011) else 
                $error("Expected 4'b0011, actual %b", cpu.datapath.reg_file.regs[R3]);

        /* MOVI R2, 2'b11 */
        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R2] == 4'b0011) else 
                $error("Expected 4'b0011, actual %b", cpu.datapath.reg_file.regs[R2]);

        /* LSLI R3, 2 */
        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R3] == 4'b1100) else 
                $error("Expected 4'b1100, actual %b", cpu.datapath.reg_file.regs[R3]);

        /* ADD R3, R2  -> R3 = 15 */
        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R3] == 4'b1111) else 
                $error("Expected 4'b1111, actual %b", cpu.datapath.reg_file.regs[R3]);

        /*  MOVI R0, 2'b00 */
        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R0] ==4'b0000) else 
                $error("Expected 4'b0000, actual %b", cpu.datapath.reg_file.regs[R0]);

        /*  MOVI R1, 2'b00 */
        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R1] == 4'b0000) else 
                $error("Expected 4'b0000, actual %b", cpu.datapath.reg_file.regs[R1]);

        /* loop should execute 15 times */
        for (logic [3:0] i = 0; i < 15; i++) begin
            /* ST R0, R1 -> mem[R0] = R1 */
            cpu_step(4);
            assert(cpu.datapath.data_mem.mem[i] == i) else 
                    $error("Expected %b, actual %b", i, cpu.datapath.data_mem.mem[i]);

            /* ADDI R0, 1 */
            cpu_step(4);
            assert(cpu.datapath.reg_file.regs[R0] == i + 1) else 
                    $error("Expected %b, actual %b", i + 1, cpu.datapath.reg_file.regs[R0]);

            /* ADDI R1, 1 */
            cpu_step(4);
            assert(cpu.datapath.reg_file.regs[R1] == i + 1) else 
                    $error("Expected %b, actual %b", i + 1, cpu.datapath.reg_file.regs[R1]);

            /* SUBI R3, 1 */
            cpu_step(4);
            assert(cpu.datapath.reg_file.regs[R3] == 15 - i - 1) else 
                    $error("Expected %b, actual %b", 15 - i - 1, cpu.datapath.reg_file.regs[R3]);
            
            /* BNE loop */
            cpu_step(3);
            if (i < 14) begin
                assert(cpu.datapath.program_counter.stored_value == 4'b0110) else 
                        $error("Expected %b, actual %b", 4'b0110, cpu.datapath.program_counter.stored_value);
            end
        end

        /* JMP here */
        assert(cpu.datapath.program_counter.stored_value == 4'b1011) else 
                    $error("Expected %b, actual %b", 4'b1011, cpu.datapath.program_counter.stored_value);
       
        cpu_step(3);
        assert(cpu.datapath.program_counter.stored_value == 4'b1011) else 
                $error("Expected %b, actual %b", 4'b1011, cpu.datapath.program_counter.stored_value);

        /* Write another program to test the remaining instructions */
        
        $display("Writing program 2");

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

        /* Test ADD instruction
         * Store value 2 in R0, 5 in R1, -8 in R2. 
         * Do ADD R0, R1 -> R0 = 7
         * Do ADD R0, R2 -> R0 = -1
         */ 
        opcode = OPCODE_ADD;
        operand.rtype.rd = R0;
        operand.rtype.rs = R1;
        program_instruction(4'b0000);

        opcode = OPCODE_ADD;
        operand.rtype.rd = R0;
        operand.rtype.rs = R2;
        program_instruction(4'b0001);

        cpu_reset = 1; cpu_step(1); cpu_reset = 0; cpu_step(1);

        /* inject values in register file */
        cpu.datapath.reg_file.regs[R0] = 4'd2;
        cpu.datapath.reg_file.regs[R1] = 4'd5;
        cpu.datapath.reg_file.regs[R2] = -4'd7;

        cpu_step(3);
        assert(cpu.datapath.reg_file.regs[R0] == 4'd7) else 
                    $error("Expected %b, actual %b", 4'd7, cpu.datapath.reg_file.regs[R0]);

        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R0] == 4'd0) else 
                    $error("Expected %b, actual %b", 4'd0, cpu.datapath.reg_file.regs[R0]);

        /* Test SUB instruction
         * Store value 11 in R0, 9 in R1, 5 in R2. 
         * Do SUB R0, R1 -> R0 = 2
         * Do SUB R0, R2 -> R0 = -3 */ 
        opcode = OPCODE_SUB;
        operand.rtype.rd = R0;
        operand.rtype.rs = R1;
        program_instruction(4'b0000);

        opcode = OPCODE_SUB;
        operand.rtype.rd = R0;
        operand.rtype.rs = R2;
        program_instruction(4'b0001);

        cpu_reset = 1; cpu_step(1); cpu_reset = 0; cpu_step(1);

        /* inject values in register file */
        cpu.datapath.reg_file.regs[R0] = 4'd11;
        cpu.datapath.reg_file.regs[R1] = 4'd9;
        cpu.datapath.reg_file.regs[R2] = 4'd5;

        cpu_step(3);
        assert(cpu.datapath.reg_file.regs[R0] == 4'd2) else 
                    $error("Expected %b, actual %b", 4'd2, cpu.datapath.reg_file.regs[R0]);

        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R0] == -4'd3) else 
                    $error("Expected %b, actual %b", -4'd3, cpu.datapath.reg_file.regs[R0]);

        /* Test AND, OR, XOR instruction
         * Inject values, R0 = 1011, R1 = 1100, R2 = 0101, R3=1111 
         * Do AND R0, R1 -> R0 = 1000
         * Do OR R0, R2 -> R0 = 1101
         * Do XOR R0, R3 -> R0 = 0010 */ 
        opcode = OPCODE_AND;
        operand.rtype.rd = R0;
        operand.rtype.rs = R1;
        program_instruction(4'b0000);

        opcode = OPCODE_OR;
        operand.rtype.rd = R0;
        operand.rtype.rs = R2;
        program_instruction(4'b0001);

        opcode = OPCODE_XOR;
        operand.rtype.rd = R0;
        operand.rtype.rs = R3;
        program_instruction(4'b0010);

        cpu_reset = 1; cpu_step(1); cpu_reset = 0;

        /* inject values in register file */
        cpu.datapath.reg_file.regs[R0] = 4'b1011;
        cpu.datapath.reg_file.regs[R1] = 4'b1100;
        cpu.datapath.reg_file.regs[R2] = 4'b0101;
        cpu.datapath.reg_file.regs[R3] = 4'b1111;

        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R0] == 4'b1000) else 
                    $error("Expected %b, actual %b", 4'b1000, cpu.datapath.reg_file.regs[R0]);

        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R0] == 4'b1101) else 
                    $error("Expected %b, actual %b", 4'b1101, cpu.datapath.reg_file.regs[R0]);

        cpu_step(4);
        assert(cpu.datapath.reg_file.regs[R0] == 4'b0010) else 
                    $error("Expected %b, actual %b", 4'b0010, cpu.datapath.reg_file.regs[R0]);

        /* Test LD instruction
        *  Store address 10 in R0, load the value from this address into R1.
        *  R1 should contain value 10 after LD instruction */
        opcode = OPCODE_LD;
        operand.rtype.rd = R1;
        operand.rtype.rs = R0;
        program_instruction(4'b0000);

        cpu_reset = 1; cpu_step(1); cpu_reset = 0;

        /* inject value in R0 */
        cpu.datapath.reg_file.regs[R0] = 4'd10;

        cpu_step(5);
        assert(cpu.datapath.reg_file.regs[R1] == 4'd10) else 
                    $error("Expected %b, actual %b", 4'd10, cpu.datapath.reg_file.regs[R1]);
        
        /* Test MOV instruction
        *  Inject values R0=1, R1=10. Store the value of R1 into R0
        *  i.e. MOV R0, R1 -> R0 = 10 */
        opcode = OPCODE_MOV;
        operand.rtype.rd = R0;
        operand.rtype.rs = R1;
        program_instruction(4'b0000);

        cpu_reset = 1; cpu_step(1); cpu_reset = 0;

        /* inject value in R0 */
        cpu.datapath.reg_file.regs[R0] = 4'd1;
        cpu.datapath.reg_file.regs[R1] = 4'd10;

        cpu_step(4);

        assert(cpu.datapath.reg_file.regs[R0] == 4'd10) else 
                    $error("Expected %b, actual %b", 4'd10, cpu.datapath.reg_file.regs[R0]);

        /* Test BEQ and BNE
        *  Inject values R0=5, R1=5, R2=1, R3=10
        */
        opcode = OPCODE_SUB;
        operand.rtype.rd = R0;
        operand.rtype.rs = R1;
        program_instruction(4'b0000);

        opcode = OPCODE_BEQ;
        operand.btype.imm4 = 4'b0011;
        program_instruction(4'b0001);

        opcode = OPCODE_SUB;
        operand.rtype.rd = R2;
        operand.rtype.rs = R3;
        program_instruction(4'b0101);

        opcode = OPCODE_BNE;
        operand.btype.imm4 = 4'b0010;
        program_instruction(4'b0110);

        cpu_reset = 1; cpu_step(1); cpu_reset = 0;

        /* inject value in R0 */
        cpu.datapath.reg_file.regs[R0] = 4'd5;
        cpu.datapath.reg_file.regs[R1] = 4'd5;
        cpu.datapath.reg_file.regs[R2] = 4'd1;
        cpu.datapath.reg_file.regs[R3] = 4'd10;

        cpu_step(4);
 
        assert(cpu.datapath.reg_file.regs[R0] == 4'd0) else 
                    $error("Expected %b, actual %b", 4'd0, cpu.datapath.reg_file.regs[R0]);

        assert(cpu.datapath.zero_reg.stored_value == 1'b1) else 
                    $error("Expected %b, actual %b", 1'b1, cpu.datapath.zero_reg.stored_value);

        cpu_step(3);

        assert(cpu.datapath.program_counter.stored_value == 4'b0101) else 
                    $error("Expected %b, actual %b", 4'b0101, cpu.datapath.program_counter.stored_value);

        cpu_step(4);
 
        assert(cpu.datapath.reg_file.regs[R2] == -4'd9) else 
                    $error("Expected %b, actual %b", -4'd9, cpu.datapath.reg_file.regs[R2]);

        assert(cpu.datapath.zero_reg.stored_value == 1'b0) else 
                    $error("Expected %b, actual %b", 1'b0, cpu.datapath.zero_reg.stored_value);

        cpu_step(3);

        assert(cpu.datapath.program_counter.stored_value == 4'b1001) else 
                    $error("Expected %b, actual %b", 4'b1001, cpu.datapath.program_counter.stored_value);

        $finish;
    end
endmodule
