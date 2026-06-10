# Day 3: Sequence Detector System with FIFO

## Overview
This project implements a complete digital system consisting of three main components:
1. **FSM (Finite State Machine)** - Sequence Detector
2. **FIFO (First-In-First-Out Buffer)** - 8x8 memory



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




---
  
**Date:** 2026-06-10
