# RV32I RISC-V Processor in Verilog

This is a RISC-V processor in Verilog. It runs a small set of RISC-V instructions, the same kind of instructions a real computer chip understands.

I am building this in 2 steps: 
1. A **single-cycle** version, where each instruction finishes in one clock cycle.
2. A **5-stage pipelined** version, where five instructions are worked on at once, like an assembly line. It's faster, but it needs extra logic for instructions that depend on each other.

I'm building this to learn how a processor works, from the basics ie logic gates.

**Status: in progress**

## What's done so far

| File | What it does | Status |
|---|---|---|
| `rtl/alu.v` | Does the math (add, subtract), logic (AND, OR, XOR), and shifts | Done, compiles |
| `rtl/register_file.v` | Holds the 32 registers the processor uses for its values | Done, compiles |
| `rtl/immediate_gen.v` | Pulls small constant numbers out of an instruction | Done, compiles |
| `rtl/control_unit.v` | Reads an instruction and decides what every other part should do | Done, compiles |

"Compiles" means the Verilog is written correctly enough for the simulator to read it. It doesn't mean it's been tested yet.

## What's next

- Instruction and data memory
- The single-cycle processor, built from all the parts
- A testbench, a test program that runs the processor and checks the answer
- The pipelined version and its hazard logic

## Instructions supported

ADD, SUB, AND, OR, XOR, ADDI, LW, SW, BEQ, BNE, JAL

These are enough to run loops and read and write arrays. The full RISC-V instruction set is much bigger, and I'm not building all of it.

## How to check the files compile

Run these from the project folder. If a command prints nothing, the file compiled.
