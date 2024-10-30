module memory #(parameter WIDTH = 8) (
    input logic clk, reset, write_enable,
    input logic [3:0] addr,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    logic [WIDTH-1:0] mem [0:15];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 16; i++) begin
                mem[i] <= 0;
            end
        end else begin
            if (write_enable) begin
                mem[addr] <= data_in;
            end
        end
    end

    assign data_out = mem[addr];

endmodule
