# Makefile
# VHDL testbench for AES128 design

SIM ?= ghdl
VHDL_STANDARD ?= 08

# Source directory
SRC_DIR = $(PWD)/../src

# VHDL sources
VHDL_SOURCES = $(SRC_DIR)/tt_AES128.vhd
TB_VHDL = $(PWD)/AES128_tb.vhd

# Test vectors directory
VECTORS_DIR = $(PWD)/vectors

# Output directory
SIM_DIR = sim_build

# GHDL flags
GHDL_FLAGS = --std=$(VHDL_STANDARD) -g

# Default target
all: compile run

compile:
	@echo "Compiling VHDL files..."
	ghdl analyze $(GHDL_FLAGS) $(VHDL_SOURCES) $(TB_VHDL)

elaborate:
	@echo "Elaborating design..."
	ghdl elaborate $(GHDL_FLAGS) aes128_top_test -o $(SIM_DIR)/tb

run: elaborate
	@echo "Running simulation..."
	ghdl run $(GHDL_FLAGS) aes128_top_test \
		--vcd=$(SIM_DIR)/tb.vcd \
		--stop-time=10ms

view:
	@echo "Opening waveform viewer..."
	gtkwave $(SIM_DIR)/tb.vcd &

clean:
	@echo "Cleaning up..."
	rm -rf $(SIM_DIR)
	ghdl clean

.PHONY: all compile elaborate run view clean
