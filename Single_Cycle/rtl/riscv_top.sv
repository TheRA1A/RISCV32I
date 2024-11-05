module riscv_top
  import riscv_pkg::*;
(
    input logic clk,
    input logic rst_n
);

  // Internal signals for instruction interface
  logic [31:0] instr_addr;
  logic [31:0] instruction;

  // Internal signals for data memory interface
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;
  logic [31:0] formatted_data_rdata;
  logic        data_we;
  logic [ 3:0] data_be;
  logic [ 2:0] mem_size;

  // Instantiate RISC-V Core
  riscv_core core (
      .clk  (clk),   // input
      .rst_n(rst_n), // input

      // Instruction Memory Interface
      .instr_addr (instr_addr),  // output
      .instruction(instruction), // input

      // Data Memory Interface
      .data_addr (data_addr), // output
      .data_wdata(data_wdata), // output
      .data_rdata(formatted_data_rdata), // input
      .data_we   (data_we), // output
      .mem_size (mem_size) // output
  );

  // Instantiate Instruction Memory
  instr_memory imem (
      .addr(instr_addr),  // input
      .data(instruction)  // output
  );

  // Instantiate Data Memory
  data_memory dmem (
      .clk  (clk), // input
      .rst_n(rst_n), // input
      .addr (data_addr), // input
      .wdata(data_wdata), // input
      .we   (data_we), // input
      .be   (data_be), // input
      .rdata(data_rdata) // output
  );

  // Instantiate Memory Access Control
  mem_access_control mem_ctrl (
      .mem_size           (mem_size),             // input
      .addr               (data_addr),            // input
      .byte_enable        (data_be),              // output
      .read_data          (data_rdata),           // input
      .formatted_read_data(formatted_data_rdata)  // output
  );

endmodule

