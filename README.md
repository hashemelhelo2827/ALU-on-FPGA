# 🖥️ ALU on FPGA — Logic Design Project

> An 8-bit Arithmetic Logic Unit (ALU) implemented in Verilog and deployed on an FPGA board.  
> Supports **Add**, **Subtract**, **Multiply**, and **Move** operations with a register file and real-time 7-segment display output.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Hardware Setup](#hardware-setup)
- [How to Use](#how-to-use)
- [Switch Mapping](#switch-mapping)
- [Output Indicators](#output-indicators)
- [Module Breakdown](#module-breakdown)
- [Block Diagram](#block-diagram)

---

## 🔍 Overview

This project implements a simple but fully functional ALU on an FPGA (Intel DE10-Lite or compatible board). The ALU reads operands from a small register file (R0, R1, R2), performs one of four operations selected via slide switches, and displays the result live on the hex displays. A debounced key press writes the result back into a chosen register.

---

## ✨ Features

- ✅ **4 ALU operations**: Addition, Subtraction, Multiplication, Move
- ✅ **8-bit operands**, 9-bit result (handles carry/overflow)
- ✅ **3 general-purpose registers**: R0, R1, R2
- ✅ **Immediate value input** via switches
- ✅ **Status flags**: Carry, Zero, Sign — shown on LEDs
- ✅ **7-segment hex display** for result and active operation
- ✅ **Hardware debouncing** for the write key (10ms @ 50 MHz)
- ✅ **Fully synthesizable** pure Verilog (no IP cores)

---

## 📁 Project Structure

```
├── calcv2.v        # Top-level module — ALU controller & register file
├── adder.v         # 8-bit ripple-carry adder (built from 1-bit full adders)
├── subtractor.v    # Subtractor using 2's complement adder
├── multiply.v      # Shift-and-add multiplier (partial products)
└── hex_decoder.v   # 4-bit to 7-segment decoder
```

---

## 🔧 Hardware Setup

| Board | Intel DE10-Lite (or equivalent) |
|---|---|
| Clock | `CLOCK_50` — 50 MHz onboard oscillator |
| Inputs | `SW[9:0]` — Slide switches |
| Button | `KEY` — Write result to register |
| Outputs | `LEDR[9:0]` — Status LEDs |
| Displays | `HEX0` – `HEX5` — 7-segment displays |

> **To run:** Compile in Intel Quartus Prime → assign pins → program the `.sof` file onto the board.

---

## 🕹️ How to Use

1. **Select the operation** using `SW[9:8]`
2. **Select operand A source** using `SW[7:6]`
3. **Select operand B source / destination register** using `SW[5:4]`
4. *(Optional)* If operand A is set to immediate mode (`SW[7:6] = 11`), set the value on `SW[3:0]`
5. **Watch the result live** on `HEX0`–`HEX1` and the flags on `LEDR`
6. **Press `KEY`** to latch the result into the destination register

---

## 🎛️ Switch Mapping

### `SW[9:8]` — Operation Select

| SW[9:8] | Operation | Display |
|---------|-----------|---------|
| `00` | ADD | `A` |
| `01` | SUB | `S` |
| `10` | MUL | `N` |
| `11` | MOV | `E` |

### `SW[7:6]` — Operand A Source

| SW[7:6] | Source |
|---------|--------|
| `00` | Register R0 |
| `01` | Register R1 |
| `10` | Register R2 |
| `11` | Immediate value from `SW[3:0]` |

### `SW[5:4]` — Operand B Source & Write Destination

| SW[5:4] | Operand B | Write Destination (on KEY press) |
|---------|-----------|----------------------------------|
| `00` | Register R0 | → R0 |
| `01` | Register R1 | → R1 |
| `10` | Register R2 | → R2 |
| `11` | `0x00` | *(no write)* |

---

## 💡 Output Indicators

### 7-Segment Displays

| Display | Shows |
|---------|-------|
| `HEX0` | Lower nibble of result |
| `HEX1` | Upper nibble of result |
| `HEX2` | Active operation letter (`A` / `S` / `N` / `E`) |
| `HEX3`–`HEX5` | Off |

### LEDs

| LED | Flag | Meaning |
|-----|------|---------|
| `LEDR[0]` | **Carry** | ADD overflow or SUB borrow |
| `LEDR[1]` | **Sign** | Result bit 7 is set (negative in signed) |
| `LEDR[2]` | **Zero** | Result is `0x00` |

---

## 🧩 Module Breakdown

### `calcv2` — Top Level
The main controller. Instantiates all sub-modules, manages the register file (R0/R1/R2), routes operands, computes flags, and drives the displays. Includes a 10 ms hardware debouncer for the KEY input to generate a clean write pulse.

### `adder` — 8-bit Ripple Carry Adder
A generate-loop of 8 single-bit `adding` full adders chained together. Takes an 8-bit `a`, `b`, and a carry-in, and produces a 9-bit result (the 9th bit is the carry-out).

### `subtractor` — 2's Complement Subtractor
Reuses the `adder` module. Computes `A - B` by inverting `B` and feeding a carry-in of `1` — the standard 2's complement subtraction trick.

### `multiply` — Shift-and-Add Multiplier
Implements binary multiplication using partial products. Each bit of operand B shifts operand A left by the corresponding power of 2 (via the `multipling` helper module), then four partial products are summed using three `adder` instances. Operates on the lower 4 bits of each operand.

### `hex_decoder` — 7-Segment Decoder
A combinational lookup table that converts a 4-bit nibble (`0x0`–`0xF`) into the correct active-low 7-segment pattern for the DE10-Lite displays.

---

## 📐 Block Diagram

```
SW[9:8] ──► Operation Select ─────────────────────────┐
                                                       │
SW[7:6] ──► Operand A MUX ──► operand_A ──┐           ▼
                 │                         ├──► [ ALU ] ──► alu_output [8:0]
SW[5:4] ──► Operand B MUX ──► operand_B ──┘       │             │
                 │                                  │        ┌───┴────┐
                 │                                  │        │ Flags  │
SW[3:0] ──► Immediate ──────────────────────────────│        └───┬────┘
                                                    │            │
KEY ──► Debouncer ──► write_pulse ──────────────────│       LEDR[2:0]
                                                    │
                                               Register File
                                              ┌─────────────┐
                                              │  R0  R1  R2 │
                                              └─────────────┘
                                                    │
                                               HEX0 HEX1 HEX2
```

---

## 👨‍💻 Authors
Yehia Mahmoud 
Hashim elhelo
Mostafa Hany 
Yassen 
Made with ❤️ as a Logic Design course project.

> Feel free to fork, star ⭐, and build on top of it!
