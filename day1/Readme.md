# Day 1: Verilog Basics & Arithmetic Circuits

## Overview
Day 1 focuses on learning Verilog fundamentals and implementing basic combinational arithmetic circuits. This foundational knowledge is essential for VLSI design.

---

## 📚 Learning Objectives

- ✅ Verilog module syntax and port declarations
- ✅ Gate-level primitives (AND, OR, XOR, NOT)
- ✅ Combinational logic design
- ✅ Hierarchical design and component reuse
- ✅ Testbench creation and simulation
- ✅ Digital arithmetic circuit implementation

---

## 🔧 Circuits Implemented

### 1. **Half Adder**
**Purpose:** 1-bit addition without carry input

**Truth Table:**
| A | B | Sum | Carry |
|---|---|-----|-------|
| 0 | 0 |  0  |   0   |
| 0 | 1 |  1  |   0   |
| 1 | 0 |  1  |   0   |
| 1 | 1 |  0  |   1   |

**Logic Equations:**
- Sum = A XOR B
- Carry = A AND B

**Verilog Implementation Pattern:**
```verilog
module half_adder(input A, B, output sum, carry);
    xor(sum, A, B);
    and(carry, A, B);
endmodule
```

---

### 2. **Half Subtractor**
**Purpose:** 1-bit subtraction without borrow input

**Truth Table:**
| A | B | Diff | Borrow |
|---|---|------|--------|
| 0 | 0 |  0   |   0    |
| 0 | 1 |  1   |   1    |
| 1 | 0 |  1   |   0    |
| 1 | 1 |  0   |   0    |

**Logic Equations:**
- Difference = A XOR B
- Borrow = (NOT A) AND B

**Verilog Implementation Pattern:**
```verilog
module half_subtractor(input A, B, output diff, borrow);
    xor(diff, A, B);
    and(borrow, ~A, B);
endmodule
```

---

### 3. **Full Adder**
**Purpose:** 1-bit addition with carry input/output (building block for multi-bit adders)

**Truth Table:**
| A | B | Cin | Sum | Cout |
|---|---|-----|-----|------|
| 0 | 0 |  0  |  0  |  0   |
| 0 | 0 |  1  |  1  |  0   |
| 0 | 1 |  0  |  1  |  0   |
| 0 | 1 |  1  |  0  |  1   |
| 1 | 0 |  0  |  1  |  0   |
| 1 | 0 |  1  |  0  |  1   |
| 1 | 1 |  0  |  0  |  1   |
| 1 | 1 |  1  |  1  |  1   |

**Logic Equations:**
- Sum = A XOR B XOR Cin
- Cout = (A AND B) OR (B AND Cin) OR (A AND Cin)

**Verilog Implementation:**
```verilog
module fulladd(input A, B, Cin, output sum, carry);
    wire w1, w2, w3;
    xor(sum, A, B, Cin);
    and(w1, A, B);
    and(w2, B, Cin);
    and(w3, A, Cin);
    or(carry, w1, w2, w3);
endmodule
```

**Location:** 
- BCD Adder: `day1/BCD_Adder/design/fulladd.v`
- RCA: `day1/Ripple_Carry_Adder/design/fulladd.v`

---

### 4. **Ripple Carry Adder (RCA)**
**Purpose:** 4-bit addition using cascaded Full Adders

**Architecture:**
```
A[3:0] + B[3:0] + Cin -----> Full Adder chain -----> S[3:0] + Cout
```

**Design Hierarchy:**
```
RCA (4-bit)
├── FA1 (Bit 0)
├── FA2 (Bit 1)
├── FA3 (Bit 2)
└── FA4 (Bit 3)
```

**Key Features:**
- ✓ 4-bit parallel addition
- ✓ Carry ripple through stages
- ✓ Modular and reusable design
- ✓ Latency increases with bit width

**Verilog Implementation:**
```verilog
module rca(input A0,A1,A2,A3,B0,B1,B2,B3,Cin,
           output S0,S1,S2,S3,Cout);
    wire w1, w2, w3;
    fulladd FA1(A0,B0,Cin,S0,w1);
    fulladd FA2(A1,B1,w1,S1,w2);
    fulladd FA3(A2,B2,w2,S2,w3);
    fulladd FA4(A3,B3,w3,S3,Cout);
endmodule
```

**Test Cases:**
| A | B | Cin | S  | Cout |
|---|---|----|----|----|
| 0 | 0 | 0  | 0  | 0  |
| 4 | 4 | 0  | 8  | 0  |
| 6 | 3 | 0  | 9  | 0  |
| 7 | 5 | 0  | 12 | 0  |
| 9 | 8 | 0  | 17 | 1  |

**Location:** 
- `day1/Ripple_Carry_Adder/design/rca.v`
- `day1/Ripple_Carry_Adder/test/rca_tb.v`

---

### 5. **BCD Adder**
**Purpose:** Binary Coded Decimal addition with automatic result correction

**Concept:**
BCD (Binary Coded Decimal) encodes decimal digits (0-9) using 4 bits each. When adding two BCD numbers, if the result exceeds 9 (binary 1001), we need to add 6 (binary 0110) to correct it.

**Algorithm:**
1. Add A and B using RCA
2. Check if result > 9 (C4 = 1 OR (C3 AND C2))
3. If true, add 6 to the result
4. Output the corrected BCD result

**Design Hierarchy:**
```
BCD Adder
├── RCA1 (First 4-bit addition)
├── Correction Logic (Check if > 9)
└── RCA2 (Add 6 if needed)
```

**Verilog Implementation:**
```verilog
module bcd(input A0,A1,A2,A3,B0,B1,B2,B3,Cin,
           output S0,S1,S2,S3,Cout);
    wire w1,w2,w3,w4,w5,w6,w7,w8;
    
    // First RCA: Add A and B
    rca r1(A0,A1,A2,A3,B0,B1,B2,B3,Cin,w8,w7,w6,w5,w4);
    
    // Correction logic: Check if result > 9
    and(w1, w5, w6);      // C3 AND C2
    and(w2, w5, w7);      // C3 AND C1
    or(w3, w4, w1, w2);   // C4 OR (C3 AND C2) OR (C3 AND C1)
    
    // Second RCA: Add 6 if correction needed
    rca r2(w8,w7,w6,w5,1'b0,w3,w3,1'b0,1'b0,S0,S1,S2,S3);
    
    assign Cout = w3;
endmodule
```

**Test Cases (BCD):**
| A (Dec) | B (Dec) | Sum (Dec) | Output (BCD) |
|---------|---------|-----------|--------------|
| 0       | 0       | 0         | 0000         |
| 4       | 4       | 8         | 1000         |
| 6       | 3       | 9         | 1001         |
| 7       | 5       | 12        | 0001 0010    |
| 9       | 8       | 17        | 0001 0111    |
| 9       | 9       | 18        | 0001 1000    |

**Location:**
- Design: `day1/BCD_Adder/design/bcd.v`
- Testbench: `day1/BCD_Adder/test/bcd_tb.v`
- Documentation: `day1/BCD_Adder/bcd.md`

---

## 📁 Directory Structure

```
day1/
├── BCD_Adder/
│   ├── design/
│   │   ├── bcd.v              # BCD Adder module
│   │   ├── fulladd.v          # Full Adder (reused)
│   │   └── rca.v              # RCA used in BCD (reused)
│   ├── test/
│   │   └── bcd_tb.v           # BCD Adder testbench
│   └── bcd.md                 # BCD documentation with schematics
│
├── Ripple_Carry_Adder/
│   ├── design/
│   │   ├── fulladd.v          # Full Adder cell
│   │   └── rca.v              # 4-bit RCA module
│   ├── test/
│   │   └── rca_tb.v           # RCA testbench
│   └── rca.md                 # RCA documentation with schematics
│
└── Readme.md                  # This file



```

## 📝 Key Verilog Concepts Learned

```

### Module Declaration
```verilog
module module_name(port_list);
    // Implementation
endmodule
```

### Port Types
- `input` - Input ports
- `output` - Output ports
- `inout` - Bidirectional ports (not used in Day 1)

### Gate-Level Primitives
```verilog
and(output, input1, input2, ...);
or(output, input1, input2, ...);
xor(output, input1, input2, ...);
not(output, input);
```



## 🎯 Learning Outcomes

By completing Day 1, you should understand:

1. ✅ How to write Verilog modules for combinational circuits
2. ✅ Difference between Half Adder and Full Adder
3. ✅ How carry ripples through multi-bit adders
4. ✅ Why BCD addition requires correction logic
5. ✅ How to create hierarchical designs using module instantiation
6. ✅ How to write and run testbenches in ModelSim/Vivado
7. ✅ Basic simulation waveform analysis

---

## 📊 Complexity Analysis

| Circuit | Inputs | Outputs | Logic Gates | Depth |
|---------|--------|---------|-------------|-------|
| Half Adder | 2 | 2 | 2 | 1 |
| Half Subtractor | 2 | 2 | 3 | 2 |
| Full Adder | 3 | 2 | 5 | 2 |
| 4-bit RCA | 9 | 5 | 20 | 8 |
| BCD Adder | 9 | 5 | 30+ | 10+ |


---


---

**Created:** 8th June 2026  
**Internship:** VLSI IC Design at TKMCE  
**Status:** ✅ Completed  day1

---

*For detailed schematics and simulation results, refer to individual project documentation files.*
