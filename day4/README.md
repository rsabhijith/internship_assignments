# Day 4 - SoC Design and Vivado Implementation

## Today's Learning

### 1. SoC Fundamentals (ASIC, SoC, FPGA)
- **ASIC** (Application-Specific Integrated Circuit): Custom silicon designed for specific applications
- **SoC** (System-on-Chip): Complete system integrated on a single chip including processor, memory, and peripherals
- **FPGA** (Field-Programmable Gate Array): Reconfigurable hardware that can be programmed after manufacturing
- Explored the advantages of SoC architecture in embedded systems

### 2. SoC Architecture Components
Studied the architecture of SoC with the following key components:

#### Core Components:
- **Processor** - RISC-V based execution unit for computation and control
- **ROM** (Read-Only Memory) - Stores firmware, bootloader, and fixed program code
- **RAM** (Random Access Memory) - Runtime memory for data storage and program execution
- **DMA** (Direct Memory Access) - Enables peripherals to transfer data directly without processor intervention
- **GPIO** (General Purpose Input/Output) - Interface for connecting external devices and sensors
- **UART** (Universal Asynchronous Receiver-Transmitter) - Serial communication protocol for debug and external interfacing
- **Timer** - Provides timing, counting, and scheduling capabilities
- **Interrupt Controller** - Manages and prioritizes hardware and software interrupts

### 3. SoC Design in Vivado
Created a complete SoC design in Vivado using Block Diagram methodology:

#### Design Specifications:
- **Processor**: Vega-AT10591 RISC-V Processor
  - 32-bit RISC-V instruction set
  - Configurable performance and feature set
  
- **AXI Bus Architecture**:
  - AXI4 interconnect for high-performance communication
  - Master-Slave configuration for modular design

- **Integrated Peripherals**:
  - **ROM** - Instruction and data storage (Read-Only)
  - **RAM** - Main memory for runtime execution
  - **GPIO** - Digital I/O for external interfacing
  - **UART** - Serial communication interface

#### Design Hierarchy:
```
SoC
├── Vega-AT10591 RISC-V Processor (Master)
├── AXI Interconnect
└── AXI Slaves
    ├── ROM Controller
    ├── RAM Controller
    ├── GPIO Controller
    └── UART Controller
```

### 4. Memory Block Generator Implementation
Implemented a **synchronous 256x8 RAM** module as a core building block:

#### Features:
- **Memory Size:** 256 locations (8-bit addressable)
- **Data Width:** 8-bit per location
- **Operations:** Synchronous read and write on clock edges
- **Reset:** Active-low asynchronous reset
- **Control Signal:** `wrenb` for read/write mode selection

#### Design Details:
- Synchronous write operations at positive clock edges
- Registered read output for stable data transfer
- Asynchronous reset clearing all memory locations
- Successfully tested with write and read operations
- Demonstrated data integrity in simulation

## Key Design Principles Applied
1. **Hierarchical Design** - Modular architecture with clear interfaces
2. **Bus-Based Communication** - AXI protocol for inter-module communication
3. **Reusable Components** - Memory blocks, controllers as standard library elements
4. **Clock Synchronization** - Synchronized operations across multiple modules

## Project Structure
```
day4/
└── memory_block_generator/
    ├── design/          # RTL design files
    ├── test/            # Testbenches and simulation scripts
    └── mem_block.md     # Memory block documentation
```

## Hands-On Experience
- Building block diagrams in Vivado for SoC design
- Configuring AXI interconnects
- Instantiating RISC-V processor cores
- Mapping peripherals to address space
- Simulating memory block generator functionality

## Next Steps
- Implement address decoding and memory mapping
- Test complete SoC with all peripherals
- Develop bootloader for ROM
- Create driver software for GPIO and UART
- Integrate interrupt handling system

## Takeaways
- Understanding of complete SoC architecture from processor to peripherals
- Practical experience with Vivado block diagram design methodology
- Knowledge of AXI bus protocol for SoC communication
- Foundation for embedded system design on FPGA platforms
- Ready to move to software development and system integration
