# Memory Block Generator

## Overview
A synchronous 256x8 RAM (Random Access Memory) module implemented in Verilog that demonstrates dual-port read/write operations with asynchronous reset functionality.

## Key Features
- **Memory Size:** 256 locations (8-bit addressable)
- **Data Width:** 8-bit per location
- **Operations:** Synchronous read and write on clock edges
- **Reset:** Active-low asynchronous reset
- **Mode Control:** Single `wrenb` signal controls read/write mode

## Design Implementation
The module includes:
- Synchronous write operations at positive clock edges
- Registered read output for stable data transfer
- Asynchronous reset clearing all memory

## Simulation Output
<img width="1232" height="558" alt="Memory Block Generator Simulation" src="https://github.com/user-attachments/assets/b16e5aba-b62b-4b83-91e7-fd3d8b9e9d13" />

**Test Results:** Successfully demonstrates writing 8 data values (0x10 through 0x80) to memory addresses 0x00-0x07, followed by reading all values back with correct data integrity verified.
