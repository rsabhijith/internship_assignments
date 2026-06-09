# Day 2: Sequential Logic & Control Circuits

## Overview
Day 2 focuses on sequential logic elements and control circuits. Building upon combinational logic from Day 1, this day introduces flip-flops, latches, and shift registers. Additionally, we explore conditional statements, blocking/non-blocking assignments, and combinational circuits like encoders and decoders.

---

## 📚 Learning Objectives

- ✅ Conditional statements (if-else, case) in Verilog
- ✅ Blocking and non-blocking assignments
- ✅ SR Latch and SR Flip-Flop implementation
- ✅ D Flip-Flop (edge-triggered behavior)
- ✅ Shift registers: SISO, SIPO, PISO, PIPO
- ✅ 4:2 Encoder design
- ✅ Universal Shift Register (USR)
- ✅ Sequential circuit timing and behavior

---

## 📝 Key Verilog Concepts - Day 2

### 1. **Conditional Statements**

#### **if-else Statement**
Used for sequential selection of code blocks. Useful in both combinational and sequential logic.

```verilog
// Example 1: Simple if-else
if (enable == 1'b1) begin
    output = input_data;
end else begin
    output = default_value;
end

// Example 2: if-else if-else
if (sel == 2'b00)
    result = value0;
else if (sel == 2'b01)
    result = value1;
else if (sel == 2'b10)
    result = value2;
else
    result = value3;
```

#### **case Statement**
Cleaner alternative to multiple if-else statements. Used for multi-way branching.

```verilog
// Example: 4:1 Multiplexer using case
case (select)
    2'b00: output = input0;
    2'b01: output = input1;
    2'b10: output = input2;
    2'b11: output = input3;
    default: output = 1'bx;
endcase
```
###  **while Loop**
Used for repetitive operations, though less common in hardware design.

```verilog
// Example: Find MSB position
integer i = 0;
while (i < 8 && data[i] == 1'b0) begin
    i = i + 1;
end
```


### 2. **Blocking vs Non-Blocking Assignments**

#### **Blocking Assignment (=)**
- Executes immediately in procedural order
- RHS is evaluated and assigned before next statement
- Used in **combinational logic**
- Creates sequential behavior within always block

```verilog
// Example: Combinational logic using blocking
always @(*) begin
    a = b & c;      // Execute first, a gets result
    d = a | e;      // d uses the NEW value of a
end
```

**Best Practice:** Use for combinational logic (always @(*))

#### **Non-Blocking Assignment (<=)**
- Evaluates all RHS expressions before updating LHS
- All assignments in the always block happen simultaneously
- Used in **sequential logic** (flip-flops, registers)
- Prevents race conditions and simulator artifacts

```verilog
// Example: Sequential logic using non-blocking
always @(posedge clk) begin
    Q <= D;         // All assignments happen at clock edge
    Qbar <= ~Q;     // Qbar uses OLD value of Q
end

// Without non-blocking (WRONG):
always @(posedge clk) begin
    Q = D;          // Q changes immediately
    Qbar = ~Q;      // Qbar gets inverted NEW Q (wrong!)
end
```

**Key Rule:** 
- **Blocking (=)** → Combinational logic
- **Non-blocking (<=)** → Sequential logic / flip-flops

### 3. **while Loop**
Used for repetitive operations, though less common in hardware design.

```verilog
// Example: Find MSB position
integer i = 0;
while (i < 8 && data[i] == 1'b0) begin
    i = i + 1;
end
```

---

## 🔧 Circuits Implemented

### 1. **SR Latch (Set-Reset Latch)**
**Purpose:** Basic sequential element using cross-coupled NOR gates; state dependent on inputs

**Truth Table:**
| S | R | Q(t+1) | State |
|---|---|--------|-------|
| 0 | 0 | Q(t)   | Hold  |
| 0 | 1 |   0    | Reset |
| 1 | 0 |   1    | Set   |
| 1 | 1 |   ?    | Invalid |

**Characteristics:**
- Uses NOR gates (asynchronous)
- No clock required
- Unstable in S=R=1 state
- Stores one bit of information

**Verilog Implementation:**
```verilog
module sr_latch(input S, R, output reg Q);
    always @(S or R) begin
        if (S == 1'b1 && R == 1'b0)
            Q = 1'b1;
        else if (S == 1'b0 && R == 1'b1)
            Q = 1'b0;
        else if (S == 1'b0 && R == 1'b0)
            Q = Q;  // Hold state
    end
endmodule
```

**Location:**
- Schematic & Output: `day2/sr_flipflop/sr_flipflop.md`

---

### 2. **SR Flip-Flop (Clocked SR Flip-Flop)**
**Purpose:** Synchronous version of SR latch; state changes synchronized to clock edges

**Key Differences from Latch:**
- Clock input added for synchronization
- Changes occur at clock edges
- Multiple flip-flops can work in synchronization
- Better suited for sequential systems

**Truth Table (on rising clock edge):**
| Clk | S | R | Q(t+1) | Behavior |
|-----|---|---|--------|----------|
| ↑   | 0 | 0 | Q(t)   | Hold     |
| ↑   | 0 | 1 |   0    | Reset    |
| ↑   | 1 | 0 |   1    | Set      |
| ↑   | 1 | 1 |   ?    | Invalid  |
| 0   | X | X | Q(t)   | No Change|

**Verilog Implementation:**
```verilog
module sr_flipflop(input clk, S, R, output reg Q);
    always @(posedge clk) begin
        if (S == 1'b1 && R == 1'b0)
            Q <= 1'b1;
        else if (S == 1'b0 && R == 1'b1)
            Q <= 1'b0;
        else if (S == 1'b0 && R == 1'b0)
            Q <= Q;  // Hold
    end
endmodule
```

**Location:**
- Schematic & Output: `day2/sr_flipflop/sr_flipflop.md`

---

### 3. **D Flip-Flop (Data Flip-Flop)**
**Purpose:** Captures and holds input data on clock edge; no invalid state

**Key Advantages:**
- No invalid state (single data input)
- Eliminates metastability issues
- Most commonly used flip-flop in industry
- Can be built from SR flip-flop with logic

**Truth Table:**
| Clock | D | Q(t+1) | Behavior |
|-------|---|--------|----------|
| ↑     | 0 |   0    | Reset    |
| ↑     | 1 |   1    | Set      |
| 0     | X | Q(t)   | Hold     |

**Verilog Implementation:**
```verilog
module d_flipflop(input clk, D, output reg Q);
    always @(posedge clk) begin
        Q <= D;  // Non-blocking assignment - CRITICAL
    end
endmodule
```

**With Asynchronous Reset:**
```verilog
module d_flipflop_async_reset(input clk, D, reset, output reg Q);
    always @(posedge clk or negedge reset) begin
        if (~reset)
            Q <= 1'b0;  // Active low reset
        else
            Q <= D;
    end
endmodule
```

**Location:**
- Schematic & Output: `day2/d_flipflop/d_ff.md`

---

### 4. **Shift Registers**
**Purpose:** Store and shift data bits; serial-to-parallel or parallel-to-serial conversion

#### **4.1 SISO (Serial In, Serial Out)**
- Data enters and exits serially
- Used for bit-by-bit transmission
- 4-bit SISO operation: `Q(t+1) = [D_in, Q(t)[3:1]]`

```verilog
module siso_4bit(input clk, reset, D_in, output Q_out);
    reg [3:0] shift_reg;
    
    always @(posedge clk or negedge reset) begin
        if (~reset)
            shift_reg <= 4'b0000;
        else
            shift_reg <= {D_in, shift_reg[3:1]};
    end
    
    assign Q_out = shift_reg[0];
endmodule
```

**Operation Example:**
```
Initial: shift_reg = 1010, D_in = 1
After 1 clk: shift_reg = 1101
After 2 clk: shift_reg = 1110
After 3 clk: shift_reg = 1111
After 4 clk: shift_reg = 1111  (now all 1's)
```

#### **4.2 SIPO (Serial In, Parallel Out)**
- Data enters serially, all bits available in parallel
- Used for serial-to-parallel conversion
- Example: Receiving serial data, then outputting 4 bits in parallel

```verilog
module sipo_4bit(input clk, reset, D_in, output [3:0] Q);
    reg [3:0] shift_reg;
    
    always @(posedge clk or negedge reset) begin
        if (~reset)
            shift_reg <= 4'b0000;
        else
            shift_reg <= {D_in, shift_reg[3:1]};
    end
    
    assign Q = shift_reg;
endmodule
```

#### **4.3 PISO (Parallel In, Serial Out)**
- Data loaded in parallel, output serially one bit at a time
- Used for parallel-to-serial conversion
- Requires load/shift control signal

```verilog
module piso_4bit(input clk, reset, load, [3:0] P_in, output D_out);
    reg [3:0] shift_reg;
    
    always @(posedge clk or negedge reset) begin
        if (~reset)
            shift_reg <= 4'b0000;
        else if (load)
            shift_reg <= P_in;      // Load parallel data
        else
            shift_reg <= {1'b0, shift_reg[3:1]};  // Shift right
    end
    
    assign D_out = shift_reg[0];
endmodule
```

#### **4.4 PIPO (Parallel In, Parallel Out)**
- Loads parallel data and outputs it
- Acts like a register latch
- Simplest configuration

```verilog
module pipo_4bit(input clk, reset, load, [3:0] P_in, output [3:0] Q);
    reg [3:0] shift_reg;
    
    always @(posedge clk or negedge reset) begin
        if (~reset)
            shift_reg <= 4'b0000;
        else if (load)
            shift_reg <= P_in;
    end
    
    assign Q = shift_reg;
endmodule
```

---

### 5. **4:2 Encoder**
**Purpose:** Convert 4 input lines to 2-bit binary output (inverse of decoder)

**Truth Table (Priority Encoder):**
| I3 | I2 | I1 | I0 | Y1 | Y0 | Valid |
|----|----|----|----|----|----|----|
| 0  | 0  | 0  | 1  | 0  | 0  | 1 |
| 0  | 0  | 1  | X  | 0  | 1  | 1 |
| 0  | 1  | X  | X  | 1  | 0  | 1 |
| 1  | X  | X  | X  | 1  | 1  | 1 |
| 0  | 0  | 0  | 0  | X  | X  | 0 |

**Priority:** I3 > I2 > I1 > I0 (highest priority first)

**Verilog Implementation (Priority Encoder):**
```verilog
module encoder_4to2(input [3:0] I, output reg [1:0] Y, output valid);
    always @(*) begin
        if (I[3])
            Y = 2'b11;
        else if (I[2])
            Y = 2'b10;
        else if (I[1])
            Y = 2'b01;
        else if (I[0])
            Y = 2'b00;
        else
            Y = 2'bxx;
    end
    
    assign valid = |I;  // Valid = 1 if any input is high
endmodule
```

---

### 6. **2:4 Decoder**
**Purpose:** Convert 2-bit binary input to 4 distinct output lines; one line active at a time

**Truth Table:**
| A | B | Y0 | Y1 | Y2 | Y3 |
|---|---|----|----|----|-----|
| 0 | 0 |  1 |  0 |  0 |  0 |
| 0 | 1 |  0 |  1 |  0 |  0 |
| 1 | 0 |  0 |  0 |  1 |  0 |
| 1 | 1 |  0 |  0 |  0 |  1 |

**Logic Equations:**
- Y0 = A'B'
- Y1 = A'B
- Y2 = AB'
- Y3 = AB

**Verilog Implementation:**
```verilog
module decoder_2to4(input A, B, output [3:0] Y);
    assign Y[0] = (~A) & (~B);
    assign Y[1] = (~A) & B;
    assign Y[2] = A & (~B);
    assign Y[3] = A & B;
endmodule
```

**Location:**
- Schematic & Output: `day2/decoder2_4/decoder.md`

---

### 7. **Universal Shift Register (USR)**
**Purpose:** Multi-function shift register supporting all shift modes (left, right, load, hold)

**Control Signals (2-bit mode selector):**
| S1 | S0 | Operation |
|----|----|----|
|  0 |  0 | Hold (No shift) |
|  0 |  1 | Shift Right |
|  1 |  0 | Shift Left |
|  1 |  1 | Parallel Load |

**Features:**
- Supports all 4 shift register operations
- Parallel input for rapid loading
- Left and right shift capability
- Left serial input (LSI) for left shifts
- Right serial input (RSI) for right shifts

**Verilog Implementation:**
```verilog
module universal_shift_register(
    input clk, reset,
    input [1:0] mode,           // 00: Hold, 01: Right, 10: Left, 11: Load
    input [3:0] parallel_in,    // For parallel load
    input LSI, RSI,             // Left/Right Serial Inputs
    output reg [3:0] Q          // 4-bit output
);
    
    always @(posedge clk or negedge reset) begin
        if (~reset)
            Q <= 4'b0000;
        else begin
            case(mode)
                2'b00: Q <= Q;                      // Hold
                2'b01: Q <= {RSI, Q[3:1]};         // Shift Right
                2'b10: Q <= {Q[2:0], LSI};         // Shift Left
                2'b11: Q <= parallel_in;           // Parallel Load
                default: Q <= Q;
            endcase
        end
    end
endmodule
```

**Operation Example (4-bit, Initial Q = 1010):**

```
Mode 00 (Hold):
  After clk: Q = 1010 (no change)

Mode 01 (Shift Right, RSI = 1):
  After clk: Q = 1101 (1 enters from left/MSB)

Mode 10 (Shift Left, LSI = 0):
  After clk: Q = 0100 (0 enters from right/LSB)

Mode 11 (Load, parallel_in = 1111):
  After clk: Q = 1111 (loaded in parallel)
```

**Location:**
- Schematic & Output: `day2/universal_shift_register/usr.md`

---

## 📁 Directory Structure

```
day2/
├── sr_flipflop/
│   └── sr_flipflop.md          # SR Latch & Flip-Flop documentation
│
├── d_flipflop/
│   └── d_ff.md                 # D Flip-Flop documentation
│
├── decoder2_4/
│   └── decoder.md              # 2:4 Decoder documentation
│
├── universal_shift_register/
│   └── usr.md                  # Universal Shift Register documentation
│
└── readme.md                   # This file
```

---

## 📊 Comparison Table - Shift Registers

| Register | Input Type | Output Type | Control Signals | Use Case |
|----------|-----------|-----------|-----------------|----------|
| SISO | Serial | Serial | Shift clock | Bit-by-bit data transmission |
| SIPO | Serial | Parallel | Shift clock | Serial-to-parallel conversion |
| PISO | Parallel | Serial | Load/Shift | Parallel-to-serial conversion |
| PIPO | Parallel | Parallel | Load clock | Register/storage element |

---

## 🎯 Learning Outcomes

By completing Day 2, you should understand:

1. ✅ How to use conditional statements (if-else, case) in Verilog
2. ✅ When to use blocking vs non-blocking assignments
3. ✅ SR latch operation and invalid state problem
4. ✅ Synchronous SR flip-flop design
5. ✅ D flip-flop as universal memory element
6. ✅ All four types of shift registers and their applications
7. ✅ 4:2 Priority encoder design
8. ✅ 2:4 Decoder operation
9. ✅ Multi-function universal shift register design
10. ✅ How to use sensitivity lists and control logic

---


---

**Created:** 9th June 2026  
**Internship:** VLSI IC Design at TKMCE  
**Status:** ✅ Completed  day2

---

*For detailed schematics and simulation results, refer to individual project documentation files.*
