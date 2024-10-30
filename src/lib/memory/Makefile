all: memory_test

memory_test: memory.sv memory_tb.sv
	iverilog  -Wall -g2012 memory.sv memory_tb.sv -o memory_test

memory.vcd: memory_test
	./memory_test

view: memory.vcd
	gtkwave memory.vcd
