module register_custom_width_tb;

    logic clk;
    logic reset;
    logic we;
    logic [3:0] next_val;
    logic [3:0] val;

    register_custom_width #(.WIDTH(4)) register_4bit(clk, reset, we, next_val, val);

    always begin
        #5; clk = ~clk;
    end

    initial begin
        $dumpfile("register.vcd");
        $dumpvars(1, register_custom_width_tb);
        clk=0; reset=1; #15;
        reset=0; #10;
        next_val=1; #10; we=1; #10; we=0;
        next_val=2; #10; we=1; #10; we=0;
        next_val=3; #10;
        $finish;
    end

endmodule
