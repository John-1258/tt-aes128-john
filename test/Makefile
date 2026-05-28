# Makefile
# Verilog testbench for AES128 design

SIM ?= iverilog
VVP ?= vvp
VERILOG_STANDARD ?= -g2009

# Source directory
SRC_DIR = $(PWD)/../src

# Verilog sources
VERILOG_SOURCES = $(SRC_DIR)/tt_AES128.v \
                  $(SRC_DIR)/addroundkey.v \
                  $(SRC_DIR)/mixcolumns_one_column.v \
                  $(SRC_DIR)/rcon.v \
                  $(SRC_DIR)/rotword.v \
                  $(SRC_DIR)/sbox.v \
                  $(SRC_DIR)/shiftrows.v \
                  $(SRC_DIR)/subbyte.v \
                  $(SRC_DIR)/subword.v

TB_VERILOG = $(PWD)/AES128_tb.v

# Test vectors directory
VECTORS_DIR = $(PWD)/vectors

# Output directory
SIM_DIR = sim_build

# Default target
all: compile run

compile:
	@echo "Compiling Verilog files..."
	$(SIM) $(VERILOG_STANDARD) -o $(SIM_DIR)/tb $(VERILOG_SOURCES) $(TB_VERILOG)

run: compile
	@echo "Running simulation..."
	$(VVP) $(SIM_DIR)/tb

clean:
	@echo "Cleaning up..."
	rm -rf $(SIM_DIR)

.PHONY: all compile run clean
