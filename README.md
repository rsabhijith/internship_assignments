# VLSI IC Design - Internship Assignments

A comprehensive repository documenting hands-on experience with industry-standard EDA tools for end-to-end IC design and VLSI workflow. This repository contains mini-projects, assignments, and design implementations across the complete VLSI design flow.

## 📋 Table of Contents

- [Overview](#overview)
- [Training Focus Areas](#training-focus-areas)
- [Repository Structure](#repository-structure)
- [Projects & Assignments](#projects--assignments)
- [Design Flow](#design-flow)
- [Tools & Technologies](#tools--technologies)
- [Getting Started](#getting-started)
- [Project Details](#project-details)
- [Learning Outcomes](#learning-outcomes)

## Overview

This internship at **TKMCE** provides intensive hands-on training in VLSI design methodologies, covering the complete chip design lifecycle:

- **RTL Design** → Simulation → Synthesis → Physical Design → Verification
- Real-time chip design projects and guided mini-tapeout style workflows
- Mentorship from industry experts and faculty advisors
- Certification-based performance evaluation

## 🎯 Training Focus Areas

### Core Competencies
- ✓ ASIC and System-on-Chip (SoC) Development
- ✓ Design for Testability (DFT)
- ✓ Physical Design & Layout
- ✓ Low-power and High-performance IC Design
- ✓ Design Verification & Validation

### Learning Outcomes
- Strong fundamentals in hardware design and verification
- Proficiency with industry-standard EDA tools
- Hands-on prototyping and tapeout experience
- Portfolio-ready projects for academic and professional advancement

## 📁 Repository Structure

```
internship_assignments/
├── README.md
├── day1/
│   ├── BCD_Adder/
│   │   ├── design/
│   │   │   ├── rca.v              # Ripple Carry Adder (4-bit)
│   │   │   ├── fulladd.v          # Full Adder cell
│   │   │   └── [other modules]
│   │   ├── testbench/
│   │   │   └── tb_bcd.v           # Test benches
│   │   ├── simulation/
│   │   │   └── [waveforms & logs]
│   │   ├── synthesis/
│   │   ├── physical_design/
│   │   └── bcd.md                 # Project documentation
│   └── [other day1 projects]
├── day2/
│   └── [Projects and assignments]
├── docs/
│   ├── VLSI_Flow_Guide.md
│   ├── Tool_Setup.md
│   └── Best_Practices.md
└── resources/
    ├── datasheets/
    └── references/
```

## 🔧 Projects & Assignments

### Day 1: Introduction to RTL & Basic Arithmetic

#### **BCD Adder (Binary Coded Decimal Adder)**
- **Objective**: Design and verify a BCD adder using basic combinational logic
- **Components**:
  - `rca.v` - 4-bit Ripple Carry Adder (RCA)
  - `fulladd.v` - Full Adder module
  - Testbench and simulation scripts
- **Design Hierarchy**: Full Adder → RCA → BCD Adder Logic
- **Verification**: Functional simulation, test coverage analysis

**Files**:
- Design: `day1/BCD_Adder/design/`
- Testbench: `day1/BCD_Adder/testbench/`
- Documentation: `day1/BCD_Adder/bcd.md`

**Status**: 🔄 Completed

---

## 🔄 Design Flow

### Complete VLSI Design Cycle

```
┌─────────────┐
│ Specification│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  RTL Design │ ◄── Verilog/SystemVerilog
└──────┬��─────┘
       │
       ▼
┌─────────────┐
│ Simulation  │ ◄── ModelSim/VCS
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Synthesis   │ ◄── Design Compiler/Vivado
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│ Physical Design  │ ◄── Place & Route
└──────┬───────────┘
       │
       ▼
┌─────────────┐
│Verification │ ◄── STA, LVS, DRC
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Tapeout    │
└─────────────┘
```

## 🛠️ Tools & Technologies

### EDA Tools
- **Simulation**: ModelSim, VCS
- **Synthesis**: Xilinx Vivado, Design Compiler
- **Physical Design**: Cadence Innovus, Synopsys ICC
- **Verification**: LVS (Layout vs Schematic), DRC (Design Rule Check), STA (Static Timing Analysis)

### Languages & Formats
- **HDL**: Verilog, SystemVerilog
- **Scripting**: Tcl, Python
- **Documentation**: Markdown, PDF

## 🚀 Getting Started

### Prerequisites
1. EDA tools installed (Vivado)
2. Verilog/SystemVerilog knowledge
3. Basic digital logic understanding

### Running Simulations

#### For Day 1 - BCD Adder
```bash
cd day1/BCD_Adder/

# Run simulation in ModelSim
vsim -do simulate.do

# Or compile and simulate manually
vlog design/*.v testbench/*.v
vsim work.tb_bcd
run -all
```

### File Naming Conventions
- **Design modules**: `*.v` (lowercase, descriptive names)
- **Testbenches**: `tb_*.v` (prefix with `tb_`)
- **Documentation**: `*.md` (markdown format)

## 📝 Project Details

### BCD Adder - Detailed Breakdown

**Module: rca.v** (Ripple Carry Adder)
```verilog
module rca(
    input A0, A1, A2, A3,           // Input operand A (4-bit)
    input B0, B1, B2, B3,           // Input operand B (4-bit)
    input Cin,                       // Carry in
    output S0, S1, S2, S3,          // Sum outputs (4-bit)
    output Cout                      // Carry out
);
```

**Architecture**: Cascaded Full Adders for bit-wise addition with carry propagation

**Key Features**:
- ✓ 4-bit addition capability
- ✓ Carry ripple through stages
- ✓ Modular design (reusable FA blocks)

---

## 📈 Learning Outcomes

By completing this internship, you will:

1. **Master the VLSI Design Flow**: RTL design through physical implementation
2. **Hardware Verification Skills**: Writing effective testbenches and coverage analysis
3. **Tool Proficiency**: Industry-standard EDA tools and automation
4. **Design Optimization**: Power, performance, and area (PPA) trade-offs
5. **Documentation & Communication**: Technical writing and design documentation

## 📚 Additional Resources

### Documentation
- EDA Tool User Guides (Vivado)
- IEEE Verilog Standards (IEEE 1364-2005)
- VLSI Design Textbooks

### Useful Links
- [Vivado Documentation](https://www.xilinx.com/support/documentation-navigation.html)


## 📧 Support & Mentorship

- **Faculty Mentors**: TKMCE Department of ECE
- **Industry Mentors**: Experienced semiconductor design professionals


## 📜 Certificate & Recommendation

Upon successful completion of the internship:
- Certificate of Completion from TKMCE
- Performance-based Letter of Recommendation
- Opportunity for research publications and design contest participation

---

## 📝 Assignment Tracking

| Day | Project | Status | Deadline | Remarks |
|-----|---------|--------|----------|---------|
| 1   | BCD Adder | 🔄 In Progress | - | RTL Design Phase |
| -   | - | - | - | More projects TBA |

---

## 🔗 Links & References

- **Institution**: TKMCE (Karicode,Kollam)
- **Internship Duration**: [from 8th june]
- **Updated**: 2026

---

**Maintained by**: rsabhijith  
**Last Updated**: June 2026

---

### Notes for Contributors
- Follow the directory structure strictly
- Document all projects with clear README files
- Include simulation results and waveforms
- Maintain clean, commented code
- Update the main README as new projects are added
