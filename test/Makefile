# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

# Cocotb Makefile for AES128 Tiny Tapeout wrapper

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Source directory
SRC_DIR = $(PWD)/../src

# Verilog sources
VERILOG_SOURCES += $(PWD)/tb.v
VERILOG_SOURCES += $(SRC_DIR)/tt_um_AES128.v
VERILOG_SOURCES += $(SRC_DIR)/addroundkey.v
VERILOG_SOURCES += $(SRC_DIR)/mixcolumns_one_column.v
VERILOG_SOURCES += $(SRC_DIR)/rcon.v
VERILOG_SOURCES += $(SRC_DIR)/rotword.v
VERILOG_SOURCES += $(SRC_DIR)/sbox.v
VERILOG_SOURCES += $(SRC_DIR)/shiftrows.v
VERILOG_SOURCES += $(SRC_DIR)/subbyte.v
VERILOG_SOURCES += $(SRC_DIR)/subword.v
VERILOG_SOURCES += $(SRC_DIR)/main.v

# Top-level Verilog testbench module
TOPLEVEL = tb

# Cocotb Python test file name without .py
# This means cocotb will run test/test.py
MODULE = test

# Extra compile arguments for Icarus Verilog
COMPILE_ARGS += -g2009

include $(shell cocotb-config --makefiles)/Makefile.sim
