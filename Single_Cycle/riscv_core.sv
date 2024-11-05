// Main RISC-V Core
module riscv_core
  import riscv_pkg::*;
(
    input logic clk,
    input logic rst_n,

    // Instruction Memory Interface
    output logic [31:0] instr_addr,
    input  logic [31:0] instruction,

    // Data Memory Interface
    output logic [31:0] data_addr,
    output logic [31:0] data_wdata,
    input  logic [31:0] data_rdata,
    output logic        data_we,
    output logic [ 2:0] mem_size
    // output logic [ 3:0] data_be
);

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

  // Internal Signals
  logic [31:0] pc_current;
  logic [31:0] pc_next;

  // Instruction Fields
  logic [ 6:0] opcode;
  logic [4:0] rd, rs1, rs2;
  logic [ 2:0] funct3;
  logic [ 6:0] funct7;
  logic [31:0] imm;

  // Register File Signals
  logic [31:0] reg_rdata1, reg_rdata2;
  logic [31:0] reg_wdata;

  // ALU Signals
  logic [31:0] alu_operand_a;
  logic [31:0] alu_operand_b;
  logic [31:0] alu_result;

  // Control Signals
  ctrl_signals_t ctrl;

  // Program Counter
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_current <= 32'h0;
    end else begin
      pc_current <= pc_next;
    end
  end

  // Branch condition evaluation
  logic branch_taken;
  always_comb begin
    branch_taken = 1'b0;  // Default: don't take branch
    if (opcode_t'(opcode) == BRANCH) begin
      case (funct3)
        3'b000: branch_taken = (alu_result == 0);  // BEQ: rs1 == rs2 (if SUB result is 0)
        3'b001: branch_taken = (alu_result != 0);  // BNE: rs1 != rs2 (if SUB result is not 0)
        3'b100: branch_taken = (alu_result[0] == 1);  // BLT: rs1 < rs2 (SLT result is 1)
        3'b101: branch_taken = (alu_result[0] == 0);  // BGE: rs1 >= rs2 (SLT result is 0)
        3'b110: branch_taken = (alu_result[0] == 1);  // BLTU: rs1 < rs2 (SLTU result is 1)
        3'b111: branch_taken = (alu_result[0] == 0);  // BGEU: rs1 >= rs2 (SLTU result is 0)
      endcase
    end
  end

  // Next PC selection using branch_taken
  always_comb begin
    unique case (ctrl.next_pc_sel)
      2'b00:   pc_next = pc_current + 4;  // Normal
      2'b01:   pc_next = branch_taken ? pc_current + imm : pc_current + 4;  // BRANCH
      2'b10:   pc_next = pc_current + imm;  // JAL
      2'b11:   pc_next = (reg_rdata1 + imm) & ~32'h1;  // JALR  pc_next = {{reg_rdata1 + imm}
      default: pc_next = pc_current + 4;
    endcase
  end


  // Instruction Fetch
  assign instr_addr = pc_current;

  // Instruction Decode
  always_comb begin
    opcode = instruction[6:0];
    rd     = instruction[11:7];
    funct3 = instruction[14:12];
    rs1    = instruction[19:15];
    rs2    = instruction[24:20];
    funct7 = instruction[31:25];

    // Immediate Generation
    case (opcode_t'(opcode))
      I_TYPE, LOAD, JALR:  // I-type
      imm = {{20{instruction[31]}}, instruction[31:20]};

      STORE:  // S-type
      imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

      BRANCH:  // B-type
      imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

      JAL:  // J-type
      imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

      LUI, AUIPC:  // U-type
      imm = {instruction[31:12], 12'b0};

      default: imm = 32'h0;
    endcase
  end

  // Register File
  reg_file reg_file_inst (
      .clk     (clk),
      .rst_n   (rst_n),
      .rs1_addr(rs1),
      .rs2_addr(rs2),
      .rd_addr (rd),
      .rd_data (reg_wdata),
      .rd_we   (ctrl.reg_write),
      .rs1_data(reg_rdata1),
      .rs2_data(reg_rdata2)
  );

  // ALU
  always_comb begin
    // ALU Operand A Selection
    unique case (ctrl.op_a_sel)
      2'b00:   alu_operand_a = reg_rdata1;
      2'b01:   alu_operand_a = pc_current;
      2'b10:   alu_operand_a = 32'h0;
      default: alu_operand_a = reg_rdata1;
    endcase

    // ALU Operand B Selection
    unique case (ctrl.op_b_sel)
      2'b00:   alu_operand_b = reg_rdata2;
      2'b01:   alu_operand_b = imm;
      default: alu_operand_b = reg_rdata2;
    endcase
  end

  // ALU Operation
  always_comb begin
    unique case (alu_op_t'(ctrl.alu_op))
      ALU_ADD:  alu_result = alu_operand_a + alu_operand_b;
      ALU_SUB:  alu_result = alu_operand_a - alu_operand_b;
      ALU_SLL:  alu_result = alu_operand_a << alu_operand_b[4:0];
      ALU_SLT:  alu_result = {31'b0, $signed(alu_operand_a) < $signed(alu_operand_b)};
      ALU_SLTU: alu_result = {31'b0, alu_operand_a < alu_operand_b};
      ALU_XOR:  alu_result = alu_operand_a ^ alu_operand_b;
      ALU_SRL:  alu_result = alu_operand_a >> alu_operand_b[4:0];
      ALU_SRA:  alu_result = $signed(alu_operand_a) >>> alu_operand_b[4:0];
      ALU_OR:   alu_result = alu_operand_a | alu_operand_b;
      ALU_AND:  alu_result = alu_operand_a & alu_operand_b;
      default:  alu_result = alu_operand_a + alu_operand_b;
    endcase
  end

  // Control Unit
  control_unit ctrl_unit (
      .opcode  (opcode),
      .funct3  (funct3),
      .funct7  (funct7),
      .ctrl_out(ctrl)
  );


  // Memory Interface
  assign data_addr  = alu_result;
  assign data_wdata = reg_rdata2;
  assign data_we    = ctrl.mem_write;
  assign mem_size = ctrl.mem_size;

  // Write Back
  always_comb begin
    if (ctrl.mem_read) reg_wdata = data_rdata;
    else if (ctrl.next_pc_sel != 2'b00) reg_wdata = pc_current + 4;
    else reg_wdata = alu_result;
  end

endmodule
