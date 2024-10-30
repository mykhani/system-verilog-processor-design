define SRC_FILES
	common/custom_types.sv
	lib/mux/mux.sv
	lib/register/register.sv
	lib/register_file/register_file.sv
	lib/alu/alu.sv
	lib/memory/memory.sv
endef

# Strip whitespace added before filenames. := is for immediate
# assignment i.e. the value SRC_FILES to the right of the assignment
# is expanded immediately, instead of being expanded later, when
# $SRC_FILES is referenced later in the Makefile (causing recursive
# expansion failure)
SRC_FILES := $(strip $(SRC_FILES))

all: cpu_test

cpu_test: $(SRC_FILES) cpu/control_unit.sv cpu/data_path.sv cpu/cpu.sv cpu/cpu_tb.sv
	iverilog -Wall -g2012 ${SRC_FILES} cpu/control_unit.sv cpu/data_path.sv cpu/cpu.sv cpu/cpu_tb.sv -o cpu_test

cpu.vcd: cpu_test
	./cpu_test

view: cpu.vcd
	gtkwave cpu.vcd
