module mux_2to1 #(BUS_WIDTH = 4) (
    input logic [BUS_WIDTH-1: 0] input_a,
    input logic [BUS_WIDTH-1: 0] input_b,
    input logic sel,
    output logic [BUS_WIDTH-1: 0] out
);
    assign out = sel ? input_b : input_a;

endmodule

module mux_4to1 #(BUS_WIDTH = 4) (
    input logic [BUS_WIDTH-1: 0] input_a,
    input logic [BUS_WIDTH-1: 0] input_b,
    input logic [BUS_WIDTH-1: 0] input_c,
    input logic [BUS_WIDTH-1: 0] input_d,
    input logic [1:0] sel,
    output logic [BUS_WIDTH-1: 0] out
);
    always_comb begin
        case (sel)
            2'b00: out = input_a;
            2'b01: out = input_b;
            2'b10: out = input_c;
            2'b11: out = input_d;
            default: out = 4'b0000;
        endcase
    end
endmodule
