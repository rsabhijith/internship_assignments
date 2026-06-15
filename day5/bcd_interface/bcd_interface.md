# BCD Interface

## Overview
A BCD (Binary Coded Decimal) Interface module that implements the conversion and interfacing logic for BCD adder operations. This design translates binary inputs into BCD format, performs arithmetic operations, and converts the results back to binary representation. The interface acts as a bridge between standard binary systems and BCD-based computation units.

## Key Features

- **Binary to BCD Conversion**: Converts standard 4-bit binary inputs into valid BCD representation (0-9)
- **BCD Arithmetic Support**: Enables addition of two BCD numbers with carry propagation
- **BCD to Binary Conversion**: Translates BCD results back to binary format for system integration
- **Carry Handling**: Manages carry signals between BCD digit additions


## Operations

1. **Input Processing**: Binary values are validated and converted to BCD format
2. **Arithmetic Execution**: BCD addition is performed with proper carry management
3. **Result Generation**: Output is available in both BCD and binary formats
4. **Format Verification**: Output signals indicate data validity and overflow conditions

## Output
<img width="976" height="156" alt="image" src="https://github.com/user-attachments/assets/8ca0754e-5df7-4320-94c1-f48beb42a680" />


## Applications

- Digital display controllers requiring BCD format
- Legacy system integration with BCD-based arithmetic
- Multi-digit decimal number processing
- Calculator and measurement systems
