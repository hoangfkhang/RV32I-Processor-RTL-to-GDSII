# 32-bit RISC-V Single-Cycle Processor

A 32-bit RISC-V Single-Cycle Processor designed in Verilog HDL and implemented through a complete ASIC RTL-to-GDSII flow.

## Project Overview

This project focuses on the design, verification, synthesis, and physical implementation of a 32-bit RISC-V processor.

The complete design flow includes:

```text
RTL Design
    ↓
Functional Simulation
    ↓
Logic Synthesis
    ↓
Floorplanning
    ↓
Power Planning
    ↓
Placement
    ↓
Clock Tree Synthesis
    ↓
Routing
    ↓
Post-Route Optimization
    ↓
Timing / DRC / Connectivity Verification
    ↓
GDSII
Processor Architecture

The processor consists of the following main blocks:

Program Counter (PC)
Instruction Memory
Register File
ALU
Control Unit
Immediate Generator
Data Memory
Branch / Jump Logic
Write-Back Logic
Architecture
             ┌──────────────┐
             │     PC       │
             └──────┬───────┘
                    ↓
          ┌──────────────────┐
          │ Instruction Mem. │
          └────────┬─────────┘
                   ↓
          ┌──────────────────┐
          │  Control Unit    │
          └────────┬─────────┘
                   │
        ┌──────────┴──────────┐
        ↓                     ↓
┌───────────────┐     ┌────────────────┐
│ Register File │     │ Immediate Gen. │
└───────┬───────┘     └───────┬────────┘
        │                      │
        └──────────┬───────────┘
                   ↓
             ┌──────────┐
             │   ALU    │
             └────┬─────┘
                  │
          ┌───────┴────────┐
          ↓                ↓
   ┌─────────────┐   ┌────────────┐
   │ Data Memory │   │ Write Back │
   └─────────────┘   └────────────┘
Instruction Set

The processor supports basic RV32I instructions, including:

Arithmetic operations
Logical operations
Immediate operations
Load / Store
Branch
Jump
RTL Verification

The RTL design was verified using a dedicated Verilog testbench.

Simulation tools:

Icarus Verilog
GTKWave

The simulation was used to verify:

Instruction execution
ALU operations
Register operations
Memory access
Branch and jump behavior
Processor control signals
Logic Synthesis

Logic synthesis was performed using Synopsys Design Compiler.

Main synthesis outputs:

Gate-level netlist
Timing report
Area report
Power report
SDC constraints
Physical Design

Physical implementation was performed using Cadence Encounter with a 45-nm GPDK045 technology.

Floorplanning

The floorplan defines:

Core area
Die area
Aspect ratio
Core utilization
Standard-cell rows
I/O locations
Power Planning

The power distribution network consists of:

VDD/VSS power rings
Horizontal power straps
Vertical power straps
Standard-cell power connections
Placement

Standard cells are placed inside the core region using timing- and congestion-aware placement.

Clock Tree Synthesis

CTS is performed to distribute the clock signal while controlling:

Clock skew
Clock latency
Transition
Fanout
Routing

Global and detailed routing are performed after CTS.

Post-route optimization is used to improve timing and resolve physical violations.

Physical Verification

The final layout is checked for:

DRC violations
Connectivity violations
Antenna violations
Setup timing
Hold timing
Routing congestion

Example verification commands:

verifyGeometry
verifyConnectivity -type all
verifyProcessAntenna
timeDesign -postRoute
Technology
Item	Technology
Process	45 nm
PDK	GPDK045
HDL	Verilog
Synthesis	Synopsys Design Compiler
Physical Design	Cadence Encounter
Simulation	Icarus Verilog
Waveform	GTKWave
Project Structure
RISC-V-Single-Cycle-RTL-to-GDSII/
│
├── RTL/
│   ├── top_module.v
│   ├── alu.v
│   ├── control_unit.v
│   ├── register_file.v
│   └── ...
│
├── Testbench/
│   └── tb_top_module.v
│
├── Synthesis/
│   ├── syn.tcl
│   ├── constraints.sdc
│   └── output/
│
├── Physical_Design/
│   ├── floorplan/
│   ├── power/
│   ├── placement/
│   ├── cts/
│   ├── routing/
│   └── reports/
│
├── GDS/
│   └── top_module.gds
│
├── images/
│   └── final_layout.png
│
└── README.md
Final Layout

References
Harris, S. L. & Harris, D. M., Digital Design and Computer Architecture: RISC-V Edition.
Govardhan, RISC-V Single Cycle Processor
https://github.com/govardhnn/RISC_V_Single_Cycle_Processor
Author

Lý Hoàng Khang

Electronics & Telecommunications Engineering

Ho Chi Minh City University of Technology and Education (HCMUTE)

This project was developed for educational purposes to study the complete ASIC RTL-to-GDSII design flow.
