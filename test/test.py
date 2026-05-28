# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


# AES-128 official known test vector
KEY = bytes.fromhex("000102030405060708090a0b0c0d0e0f")
PLAINTEXT = bytes.fromhex("00112233445566778899aabbccddeeff")
EXPECTED_CIPHERTEXT = bytes.fromhex("69c4e0d86a7b0430d8cdb78070b4c55a")


def make_uio(byte_index, we=0, start=0, output_sel=0):
    """
    uio_in[4:0] = byte_index
    uio_in[5]   = write enable
    uio_in[6]   = start
    uio_in[7]   = output select

    output_sel = 0 -> uo_out shows status
    output_sel = 1 -> uo_out shows ciphertext byte
    """
    return (
        (byte_index & 0x1F)
        | ((we & 1) << 5)
        | ((start & 1) << 6)
        | ((output_sel & 1) << 7)
    )


async def reset_dut(dut):
    dut._log.info("Resetting DUT")

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


async def write_byte(dut, index, value):
    """
    Write one byte into the wrapper.

    index 0-15  = key bytes
    index 16-31 = plaintext bytes
    """
    dut.ui_in.value = value
    dut.uio_in.value = make_uio(index, we=1, start=0, output_sel=0)
    await ClockCycles(dut.clk, 1)

    # deassert write enable
    dut.uio_in.value = make_uio(index, we=0, start=0, output_sel=0)
    await ClockCycles(dut.clk, 1)


async def pulse_start(dut):
    dut._log.info("Starting AES encryption")

    dut.uio_in.value = make_uio(0, we=0, start=1, output_sel=0)
    await ClockCycles(dut.clk, 1)

    dut.uio_in.value = make_uio(0, we=0, start=0, output_sel=0)
    await ClockCycles(dut.clk, 1)


async def wait_done(dut, max_cycles=1000):
    """
    When output_sel = 0, wrapper should output status:
    uo_out = {6'd0, done_q, busy_q}

    bit 0 = busy
    bit 1 = done
    """
    dut.uio_in.value = make_uio(0, we=0, start=0, output_sel=0)

    for cycle in range(max_cycles):
        await ClockCycles(dut.clk, 1)
        await Timer(1, units="ns")

        status = int(dut.uo_out.value)
        dut._log.info(f"cycle={cycle}, status=0x{status:02x}")

        if status == 0x01:
            dut._log.info("AES encryption completed")
            return

    raise AssertionError("AES did not finish within max_cycles")


async def read_ciphertext(dut):
    result = []

    for index in range(16):
        dut.uio_in.value = make_uio(index, we=0, start=0, output_sel=1)
        await ClockCycles(dut.clk, 1)
        await Timer(1, units="ns")

        byte_value = int(dut.uo_out.value)
        result.append(byte_value)

        dut._log.info(f"ciphertext[{index}] = 0x{byte_value:02x}")

    return bytes(result)


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start AES128 Tiny Tapeout cocotb test")

    # 10 ns clock = 100 MHz
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    dut._log.info("Loading AES key")
    for i, value in enumerate(KEY):
        await write_byte(dut, i, value)

    dut._log.info("Loading AES plaintext")
    for i, value in enumerate(PLAINTEXT):
        await write_byte(dut, 16 + i, value)

    await pulse_start(dut)
    await wait_done(dut, max_cycles=200)

    got = await read_ciphertext(dut)

    dut._log.info(f"Expected ciphertext: {EXPECTED_CIPHERTEXT.hex()}")
    dut._log.info(f"Got ciphertext:      {got.hex()}")

    assert got == EXPECTED_CIPHERTEXT, (
        f"AES ciphertext mismatch: "
        f"expected {EXPECTED_CIPHERTEXT.hex()}, got {got.hex()}"
    )

    dut._log.info("AES128 Tiny Tapeout wrapper test PASSED")
