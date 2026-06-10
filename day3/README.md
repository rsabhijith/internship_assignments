# Day 3: Sequence Detector System with FIFO

## Overview
This project implements a complete digital system consisting of three main components:
1. **FSM (Finite State Machine)** - Sequence Detector
2. **FIFO (First-In-First-Out Buffer)** - 8x8 memory
3. **Output Module** - Data output controller

## Project Structure
```
day3/
├── use_case/
│   ├── design/
│   │   ├── top.v                      # Top-level module instantiating all components
│   │   ├── use_case.v                 # Main sequence detector FSM
│   │   └── output_module/
│   │       ├── output_module.v        # Output controller module
│   │       ├── output_module_tb.v     # Testbench for output module
│   │       └── output_module.md       # Output module documentation
│   └── test/
│       ├── top_tb.v                   # Testbench for complete system
│       └── use_case_tb.v              # Testbench for sequence detector
├── use_case.md                        # System behavior documentation
└── README.md                          # This file
```

## Component Details

### 1. Sequence Detector (FSM)
**File:** `design/use_case.v`

The sequence detector implements a finite state machine that identifies specific data patterns in the input stream.

**Features:**
- Detects predefined sequences in 8-bit input data
- State-based pattern recognition
- Synchronous operation with clock and reset signals

**I/O Signals:**
- `clk` - Clock input
- `rst` - Reset signal
- `s_in[7:0]` - 8-bit sequence input
- `s_out[7:0]` - 8-bit output (detected sequence)

### 2. FIFO Buffer (8x8)
**File:** `design/fifo.v` (external module instantiated)

Asynchronous FIFO buffer with 8 locations and 8-bit data width.

**Features:**
- Stores intermediate data between FSM and output module
- Full and empty flags for flow control
- Read and write enable control signals

**I/O Signals:**
- `clk` - Clock input
- `rst` - Reset signal
- `wr_enb` - Write enable
- `rd_enb` - Read enable
- `din[7:0]` - Data input
- `full` - Full flag
- `empty` - Empty flag
- `dout[7:0]` - Data output

### 3. Output Module
**File:** `design/output_module/output_module.v`

State machine that controls the timing of data output from the FIFO.

**Features:**
- 3-state FSM for sequenced data output
- Generates read enable signal for FIFO
- Latches data to output on demand

**States:**
- **S0:** Idle state, no read operation
- **S1:** Wait state, prepare for read
- **S2:** Read and latch data to output

**I/O Signals:**
- `clk` - Clock input
- `rst` - Reset signal
- `din[7:0]` - Data from FIFO
- `rd_enb` - Read enable to FIFO
- `dout[7:0]` - Final output data

## System Architecture

```
Input Stream → Sequence Detector (FSM) → FIFO Buffer → Output Module → Output Stream
                    (use_case.v)         (fifo.v)    (output_module.v)
```

The top-level module instantiates all three components and manages their interconnection:
- Sequence detector processes incoming data
- Valid sequences are stored in FIFO
- Output module controls FIFO reads and presents data sequentially

## Simulation

### Output Module Testbench
**File:** `design/output_module/output_module_tb.v`

Tests the output module's ability to:
- Reset to initial state
- Sequence data output with 3-cycle delay pattern
- Handle continuous input stream

**Run with:**
```bash
iverilog -o output_module_tb.vvp output_module.v output_module_tb.v
vvp output_module_tb.vvp
```

### Complete System Testbench
**File:** `test/top_tb.v`

Tests the complete system with:
- Reset sequence
- 8 different input patterns
- Verifies data flow through all components

**Run with:**
```bash
iverilog -o top_tb.vvp top.v use_case.v fifo.v output_module.v top_tb.v
vvp top_tb.vvp
```

## Key Timing
- **Input:** Every 10ns new input data is applied
- **Output Module Cycle:** 3 clock cycles per output (30ns @ 10ns clock period)
- **Simulation Duration:** 250ns minimum for complete observation

## Signals and Behavior

| Signal | Direction | Width | Purpose |
|--------|-----------|-------|---------|
| clk | Input | 1 | System clock (10ns period in testbench) |
| rst | Input | 1 | Synchronous reset |
| s_in | Input | 8 | Sequence input data |
| s_out | Internal | 8 | FSM output to FIFO |
| rd_enb | Internal | 1 | FIFO read control |
| d_out | Output | 8 | Final system output |

## Testing Recommendations
1. Verify FSM correctly detects sequences
2. Confirm FIFO doesn't overflow with valid patterns
3. Validate output module timing and data latching
4. Check reset functionality across all modules
5. Monitor empty/full flags during operation

---
**Author:** RSabhijith  
**Date:** 2026-06-10
