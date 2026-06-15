# FIFO Interface

## Overview
A **FIFO (First-In-First-Out)** is a memory storage structure where the first data written is the first data to be read out. It operates on a queue principle and is commonly used in digital design for data buffering between different clock domains or modules operating at different speeds.

## FIFO Design Specifications

### Module: fifo
- **Depth**: 8 locations
- **Width**: 8 bits per location
- **Total Memory**: 64 bits (8 × 8)

### I/O Signals

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `clk` | Input | 1 | Clock signal for synchronous operation |
| `rst` | Input | 1 | Reset signal (active high) |
| `wrenb` | Input | 1 | Write enable signal |
| `rdenb` | Input | 1 | Read enable signal |
| `data_in` | Input | 8 | Data input bus |
| `data_out` | Output | 8 | Data output bus |
| `full` | Output | 1 | Full flag (1 when FIFO is full) |
| `empty` | Output | 1 | Empty flag (1 when FIFO is empty) |

### Key Components

- **Memory Array**: `mem[7:0]` - 8 locations, each 8 bits wide
- **Write Pointer**: `wr_ptr` - 3-bit pointer tracking write location
- **Read Pointer**: `rd_ptr` - 3-bit pointer tracking read location

### Operation

1. **Write Operation**: When `wrenb=1` and `full=0`, data is written to `mem[wr_ptr]` and write pointer increments
2. **Read Operation**: When `rdenb=1` and `empty=0`, data is read from `mem[rd_ptr]` and read pointer increments
3. **Status Flags**:
   - **Full**: Asserted when `(wr_ptr + 1) == rd_ptr` (next write would overwrite unread data)
   - **Empty**: Asserted when `wr_ptr == rd_ptr` (no unread data in FIFO)

## Output of FIFO
<img width="722" height="520" alt="image" src="https://github.com/user-attachments/assets/f08b7d11-4345-4faa-84cb-6c5f80b06dc8" />

## Application
FIFOs are essential for:
- Data buffering between asynchronous clock domains
- Decoupling producer and consumer modules
- Handling bandwidth mismatches between interfacing components
- Data synchronization in complex digital systems
