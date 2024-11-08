Got it, here's the README file for the main RISCV32I repository:

# RISC-V 32I Processor Design

This repository contains two implementations of a RISC-V 32I processor design:

1. **Single Cycle Design**
2. **Multi Cycle Design**

## Project Structure

```
RISCV32I/
├── Multi_Cycle
│   ├── control_unit.sv
│   ├── data_memory.sv
│   ├── forwarding_unit.sv
│   ├── hazard_detection_unit.sv
│   ├── instr_memory.sv
│   ├── mem_access_control.sv
│   ├── reg_file.sv
│   ├── riscv_core.sv
│   ├── riscv_pkg.sv
│   ├── riscv_top.sv
│   └── riscv_top_tb.sv
└── Single_Cycle
    ├── arch.png
    ├── control_unit.sv
    ├── data_memory.sv
    ├── instr_memory.sv
    ├── mem_access_control.sv
    ├── README.md
    ├── reg_file.sv
    ├── riscv_core.sv
    ├── riscv_pkg.sv
    ├── riscv_top.sv
    └── riscv_top_tb.sv
```

## Single Cycle Design

The Single Cycle Design folder contains the implementation of a RISC-V 32I processor that can execute instructions in a single clock cycle. The key components of this design are:

- `control_unit.sv`: Implements the control unit for the processor.
- `data_memory.sv`: Implements the data memory module.
- `instr_memory.sv`: Implements the instruction memory module.
- `mem_access_control.sv`: Implements the memory access control logic.
- `reg_file.sv`: Implements the register file.
- `riscv_core.sv`: Contains the top-level implementation of the RISC-V 32I processor core.
- `riscv_top.sv`: Implements the top-level module for the RISC-V 32I processor design.
- `riscv_top_tb.sv`: Contains the testbench for the RISC-V 32I processor design.

For more details, please refer to the [Single Cycle Design README](Single_Cycle/README.md).

## Multi Cycle Design

The Multi Cycle Design folder contains the implementation of a RISC-V 32I processor that executes instructions over multiple clock cycles. The key components of this design are:

- `control_unit.sv`: Implements the control unit for the processor.
- `data_memory.sv`: Implements the data memory module.
- `forwarding_unit.sv`: Implements the forwarding unit for the processor.
- `hazard_detection_unit.sv`: Implements the hazard detection unit for the processor.
- `instr_memory.sv`: Implements the instruction memory module.
- `mem_access_control.sv`: Implements the memory access control logic.
- `reg_file.sv`: Implements the register file.
- `riscv_core.sv`: Contains the top-level implementation of the RISC-V 32I processor core.
- `riscv_top.sv`: Implements the top-level module for the RISC-V 32I processor design.
- `riscv_top_tb.sv`: Contains the testbench for the RISC-V 32I processor design.

For more details, please refer to the [Multi Cycle Design README](Multi_Cycle/README.md).

## Getting Started

To get started with either the Single Cycle or Multi Cycle design, please follow the instructions in the respective README files.

## Contributors

This project was developed by:
- [TheRA1A](https://github.com/TheRA1A)
- [Kassa Keerthi](https://github.com/kassakeerthi)

