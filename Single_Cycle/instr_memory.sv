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
    mem[0]  = 32'h00000013;  // nop                     // No operation after reset
    mem[1]  = 32'h00500093;  // addi x1, x0, 5         // x1 = 5
    mem[2]  = 32'h00A00113;  // addi x2, x0, 10        // x2 = 10
    mem[3]  = 32'h00300193;  // addi x3, x0, 3         // x3 = 3
    mem[4]  = 32'h00800213;  // addi x4, x0, 8         // x4 = 8

    // Basic Arithmetic Operations (R-type instructions)
    mem[5]  = 32'h002080B3;  // add  x1, x1, x2        // x1 = x1 + x2  (5 + 10 = 15)
    mem[6]  = 32'h40318133;  // sub  x2, x3, x3        // x2 = x3 - x3  (3 - 3 = 0)
    mem[7]  = 32'h004181B3;  // add  x3, x3, x4        // x3 = x3 + x4  (3 + 8 = 11)
    //
    // // Complex ALU Operations
    // mem[8] = 32'h12345437;  // lui   x8, 0x12345      // x8 = 0x12345000
    // mem[9] = 32'h00001497;  // auipc x9, 1            // x9 = PC + 0x1000
    //
    // Memory Store Operations (S-type)
    mem[8]  = 32'h00112223;  // sw    x1, 4(x2)        // Store x1 to mem[x2 + 4]
    mem[9]  = 32'h00311423;  // sh    x3, 8(x2)        // Store lower 16-bits of x3 to mem[x2 + 8]
    mem[10] = 32'h00410523;  // sb    x4, 10(x2)       // Store lower 8-bits of x4 to mem[x2 + 10]

    // Memory Load Operations (I-type)
    mem[11] = 32'h00412503;  // lw    x10, 4(x2)       // Load word from mem[x2 + 4] to x10
    mem[12] = 32'h00811583;  // lh    x11, 8(x2)       // Load halfword from mem[x2 + 8] to x11
    mem[13] = 32'h00A10603;  // lb    x12, 10(x2)      // Load byte from mem[x2 + 10] to x12

    // // Jump Instructions (J-type)
    // mem[16] = 32'h0100006F;  // jal   x0, 16           // Jump to PC + 16 (absolute jump)
    // mem[17] = 32'h018006EF;    // jal   x13, 24          // Jump to PC + 24 and save return address in x13
    // mem[18] = 32'h000680E7;    // jalr  x1, x13, 0       // Jump to address in x13 and save return address in x1
    //
    // // Branch Instructions (B-type)
    // mem[19] = 32'h00208463;  // beq   x1, x2, 8        // Branch if x1 equals x2
    // mem[20] = 32'h00314663;  // blt   x2, x3, 12       // Branch if x2 less than x3
    // mem[21] = 32'h00415863;  // bge   x2, x4, 16       // Branch if x2 greater than or equal to x4
    //
    // // Complex Jump Sequence
    // mem[22] = 32'h02000537;  // lui   x10, 0x2000      // Load upper immediate
    // mem[23] = 32'h00150067;  // jalr  x0, x10, 1       // Jump to address in x10 + 1
    //
    // // Memory Operations with Base+Offset
    // mem[24] = 32'h04000693;  // addi  x13, x0, 64      // x13 = 64 (base address)
    // mem[25] = 32'h00D62023;  // sw    x13, 0(x12)      // Store x13 to address in x12
    // mem[26] = 32'h00062703;  // lw    x14, 0(x12)      // Load from address in x12 to x14

  end
endmodule
