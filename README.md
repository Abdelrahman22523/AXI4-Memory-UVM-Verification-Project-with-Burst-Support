# AXI4 Memory UVM Verification Project (with Burst Support)

## Overview
This project implements a **UVM testbench** for verifying an AXI4-compliant memory-mapped slave design.  
It covers:
- Basic **read and write transactions**
- **Burst transactions** (bonus feature)
- Error injection (invalid addresses, protocol violations)

The verification targets **100% functional and code coverage** and exercises **assertions** for protocol correctness.

## Features
- AXI4 Slave RTL (with and without burst support)
- UVM Environment:
  - Driver, Sequencer, Monitor
  - Scoreboard + Reference Model
  - Coverage collection
- Sequences:
  - `base_sequence` – normal reads/writes
  - `burst_sequence` – burst transfers
  - `error_sequence` – out-of-range access
- Functional + Code + Assertions coverage
- Factory overrides and passive agent practice

## Running the Simulation
Base tests:
```bash
vsim -do sim/run.do
