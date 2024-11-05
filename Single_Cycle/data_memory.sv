// Data Memory Module
module data_memory (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] addr,   // Address input
    input  logic [31:0] wdata,  // Write data
    input  logic        we,     // Write enable
    input  logic [ 3:0] be,     // Byte enable
    output logic [31:0] rdata   // Read data
);
  // Memory array: 1024 words (4KB)
  logic [7:0] mem[4096];  // Byte addressable memory

  // Read operation (combinational)
  always_comb begin
    rdata = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
  end

  // Write operation (sequential)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Initialize memory to 0 on reset
      for (int i = 0; i < 4096; i++) begin
        mem[i] <= 8'h00;
      end
    end else if (we) begin
      // Write enabled, check byte enables
      if (be[0]) mem[addr+0] <= wdata[7:0];
      if (be[1]) mem[addr+1] <= wdata[15:8];
      if (be[2]) mem[addr+2] <= wdata[23:16];
      if (be[3]) mem[addr+3] <= wdata[31:24];
    end
  end
endmodule
