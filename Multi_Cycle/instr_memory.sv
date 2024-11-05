// Instruction Memory Module
module instr_memory (
    input  logic [31:0] addr,  // Address input
    output logic [31:0] data   // Instruction output
);
  // Memory array: 1024 words (4KB)
  logic [31:0] mem[1024];

  // Read operation (combinational)
  always_comb begin
    // Convert byte address to word address by dropping 2 LSBs
    data = mem[addr[11:2]];
  end

  // Initialize memory with test program
  initial begin

    // Initial setup - Register Initialization (I-type instructions)
    mem[0] = 32'h00500093;  // addi x1, x0, 5         // x1 = 5
    mem[1] = 32'h00A00113;  // addi x2, x0, 10        // x2 = 10
    mem[2] = 32'h00300193;  // addi x3, x0, 3         // x3 = 3
    mem[3] = 32'h00800213;  // addi x4, x0, 8         // x4 = 8
    mem[4] = 32'h00900293;  // addi x5, x0, 9         // x5 = 9

    // Basic Arithmetic Operations (R-type instructions)
    mem[5] = 32'h002080B3;  // add  x1, x1, x2        // x1 = x1 + x2  (5 + 10 = 15)
    mem[6] = 32'h40318133;  // sub  x2, x3, x3        // x2 = x3 - x3  (3 - 3 = 0)
    mem[7] = 32'h004181B3;  // add  x3, x3, x4        // x3 = x3 + x4  (3 + 8 = 11)

    // Basic Arithmetic Operations (R-type instructions)
    mem[8] = 32'h002080B3;  // add x1, x2, x3        // x1 = x2 + x3 (0 + 11 = 11)
                            // Data hazard: The value of x1 used in this instruction is the old
                            // value (15) from the previous add instruction (mem[5]),
                            // not the updated value (11) from the sub instruction (mem[6])

    mem[9] = 32'h00410133;  // add x2, x1, x4        // x2 = x1 + x4 (11 + 8 = 19)
                            // Data hazard: The value of x1 used in this instruction is the old
                            // value (15) from the add instruction (mem[5]),
                            // not the updated value (11) from the previous add instruction (mem[8])

  end
endmodule
