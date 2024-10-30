module register_file (
    input logic clk, reset, write_enable,
    input logic [1:0] read_addr1, read_addr2, write_addr,
    input logic [3:0] data_in,
    output logic [3:0] data_out1,
    output logic [3:0] data_out2
);

    logic [3:0] regs [0:3]; /* 4 4-bit registers */

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 4; i++) begin
                regs[i] <= 0;
            end
        end else begin
            if (write_enable) regs[write_addr] <= data_in;
        end
    end

    assign data_out1 = regs[read_addr1];
    assign data_out2 = regs[read_addr2];

endmodule
