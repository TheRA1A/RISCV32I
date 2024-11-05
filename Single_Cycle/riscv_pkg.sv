package riscv_pkg;

  // Instruction Type Formats
  typedef enum logic [6:0] {
    R_TYPE = 7'b0110011,
    I_TYPE = 7'b0010011,
    LOAD   = 7'b0000011,
    STORE  = 7'b0100011,
    BRANCH = 7'b1100011,
    JAL    = 7'b1101111,
    JALR   = 7'b1100111,
    LUI    = 7'b0110111,
    AUIPC  = 7'b0010111
  } opcode_t;

  typedef enum logic [3:0] {
    ALU_ADD,   // Addition
    ALU_SUB,   // Subtraction
    ALU_SLL,   // Shift Left Logical
    ALU_SLT,   // Set Less Than
    ALU_SLTU,  // Set Less Than Unsigned
    ALU_XOR,   // Exclusive OR
    ALU_SRL,   // Shift Right Logical
    ALU_SRA,   // Shift Right Arithmetic
    ALU_OR,    // OR
    ALU_AND    // AND
  } alu_op_t;

  typedef struct packed {
    logic       reg_write;    // Enable register write
    logic       mem_write;    // Enable memory write
    logic       mem_read;     // Enable memory read
    logic [1:0] next_pc_sel;  // PC selection control
    logic [1:0] op_a_sel;     // ALU operand A selection
    logic [1:0] op_b_sel;     // ALU operand B selection
    logic [3:0] alu_op;       // ALU operation
    logic [2:0] mem_size;     // Memory access size
  } ctrl_signals_t;

endpackage : riscv_pkg
