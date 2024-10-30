module memory_tb;
    logic clk, reset, mem_write;
    logic [3:0] addr;
    logic [7:0] write_data, read_data;

    memory #(.WIDTH(8)) data_mem(clk, reset, mem_write, addr, write_data, read_data);

    always begin
        #5;  clk = ~clk;
    end

    initial begin
 ;
        $dumpfile("memory.vcd");
        $dumpvars(1, memory_tb);
        $monitor("time: %1t, write_enable: %b, addr: %b, write_data: %b, read_data: %b",
            $time, mem_write, addr, write_data, read_data);

        clk=0; mem_write=0; reset=1; #10; reset=0;

        mem_write = 1;
        for (int i = 0; i < 16; i++) begin
            addr = i;
            write_data = i;
            #15;
        end

        mem_write = 0; write_data = 0;
        for (int i = 0; i < 16; i++) begin
            addr = i;
            #15;
        end

        $finish;
    end
endmodule
