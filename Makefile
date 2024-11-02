define SRC_FILES
	src/common/custom_types.sv
	src/lib/mux/mux.sv
	src/lib/register/register.sv
	src/lib/register_file/register_file.sv
	src/lib/alu/alu.sv
	src/lib/memory/memory.sv
	src/cpu/control_unit.sv
	src/cpu/data_path.sv
	src/cpu/cpu.sv
	src/cpu/cpu_tb.sv
endef

# Strip whitespace added before filenames. := is for immediate
# assignment i.e. the value SRC_FILES to the right of the assignment
# is expanded immediately, instead of being expanded later, when
# $SRC_FILES is referenced later in the Makefile (causing recursive
# expansion failure)
SRC_FILES := $(strip $(SRC_FILES))

all: cpu_test

cpu_test: $(SRC_FILES)
	iverilog -Wall -g2012 ${SRC_FILES} -o cpu_test

cpu.vcd: cpu_test
	./cpu_test

view: cpu.vcd
	gtkwave cpu.vcd
