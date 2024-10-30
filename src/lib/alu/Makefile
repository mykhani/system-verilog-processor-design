all: alu_test

alu_test: ../../common/custom_types.sv alu.sv alu_tb.sv
	iverilog  -Wall -g2012 ../../common/custom_types.sv alu.sv alu_tb.sv -o alu_test

alu.vcd: alu_test
	./alu_test

view: alu.vcd
	gtkwave alu.vcd
