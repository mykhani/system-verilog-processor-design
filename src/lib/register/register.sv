module register_custom_width #(parameter WIDTH = 4) (
    input logic clk,
    input logic reset,
    input logic write_enable,
    input [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
);
    logic [WIDTH-1:0] stored_value;

    always_ff @(posedge clk) begin
        if (reset) stored_value <= 0;
        else if (write_enable) stored_value <= data_in;
    end

    assign data_out = stored_value;

endmodule
