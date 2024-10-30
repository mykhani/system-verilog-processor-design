all: register_test

register_test: register.sv register_tb.sv
	iverilog  -Wall -g2012 register.sv register_tb.sv -o register_test

register.vcd: register_test
	./register_test

view: register.vcd
	gtkwave register.vcd
