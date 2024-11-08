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
  logic [31:0] reg_addr;

  logic reg_write;

  // ALU Signals
  logic [31:0] alu_operand_a;
  logic [31:0] alu_operand_b;
  logic [31:0] alu_result;

  // Control Signals
  ctrl_signals_t ctrl;

  // Pipeline Registers
  if_id_reg_t if_id_reg, if_id_next;
  id_ex_reg_t id_ex_reg, id_ex_next;
  ex_mem_reg_t ex_mem_reg, ex_mem_next;
  mem_wb_reg_t mem_wb_reg, mem_wb_next;

  // Hazard Detection Unit signals
  logic stall_if, stall_id;
  logic flush_if, flush_id, flush_ex;

  // Forwarding Unit signals
  logic [1:0] forward_a, forward_b;


  //================================================
  // Instruction Fetch Stage
  //================================================

  // Program Counter
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_current <= 32'h0;
    end else if (stall_if) begin
      pc_current <= pc_current;
    end else begin
      pc_current <= pc_next;
    end
  end

  // Branch condition evaluation
  logic branch_taken;
  always_comb begin
    branch_taken = 1'b0;  // Default: don't take branch
    if ((opcode_t'(id_ex_reg.instruction[6:0]) == BRANCH) && (id_ex_reg.ctrl.next_pc_sel != 2'b00)) begin
      case (id_ex_reg.instruction[14:12])  // Using instruction from pipeline register
        3'b000: branch_taken = (alu_result == 0);  // BEQ: rs1 == rs2
        3'b001: branch_taken = (alu_result != 0);  // BNE: rs1 != rs2
        3'b100: branch_taken = (alu_result[0] == 1);  // BLT: rs1 < rs2
        3'b101: branch_taken = (alu_result[0] == 0);  // BGE: rs1 >= rs2
        3'b110: branch_taken = (alu_result[0] == 1);  // BLTU: rs1 < rs2
        3'b111: branch_taken = (alu_result[0] == 0);  // BGEU: rs1 >= rs2
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

  // IF/ID Pipeline Register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      if_id_reg <= '0;
    end else if (!stall_id) begin
      if (flush_if) begin
        if_id_reg <= '0;
      end else begin
        if_id_reg <= if_id_next;
      end
    end else begin
      if_id_reg <= if_id_reg;
    end
  end

  always_comb begin
    if_id_next.pc = pc_current;
    if_id_next.instruction = instruction;
  end

  //================================================
  // Instruction Decode Stage
  //================================================

  // Instruction Decode
  always_comb begin
    opcode = if_id_reg.instruction[6:0];
    rd     = if_id_reg.instruction[11:7];
    funct3 = if_id_reg.instruction[14:12];
    rs1    = if_id_reg.instruction[19:15];
    rs2    = if_id_reg.instruction[24:20];
    funct7 = if_id_reg.instruction[31:25];

    // Immediate Generation
    case (opcode_t'(opcode))
      I_TYPE, LOAD, JALR:  // I-type
      imm = {{20{if_id_reg.instruction[31]}}, if_id_reg.instruction[31:20]};

      STORE:  // S-type
      imm = {
        {20{if_id_reg.instruction[31]}}, if_id_reg.instruction[31:25], if_id_reg.instruction[11:7]
      };

      BRANCH:  // B-type
      imm = {
        {20{if_id_reg.instruction[31]}},
        if_id_reg.instruction[7],
        if_id_reg.instruction[30:25],
        if_id_reg.instruction[11:8],
        1'b0
      };

      JAL:  // J-type
      imm = {
        {12{if_id_reg.instruction[31]}},
        if_id_reg.instruction[19:12],
        if_id_reg.instruction[20],
        if_id_reg.instruction[30:21],
        1'b0
      };

      LUI, AUIPC:  // U-type
      imm = {if_id_reg.instruction[31:12], 12'b0};

      default: imm = 32'h0;
    endcase
  end

  // Control Unit
  control_unit ctrl_unit (
      .opcode  (opcode),
      .funct3  (funct3),
      .funct7  (funct7),
      .ctrl_out(ctrl)
  );

  // Register File
  reg_file reg_file_inst (
      .clk     (clk),
      .rst_n   (rst_n),
      .rs1_addr(rs1),
      .rs2_addr(rs2),
      .rd_addr (reg_addr),
      .rd_data (reg_wdata),
      .rd_we   (reg_write),
      .rs1_data(reg_rdata1),
      .rs2_data(reg_rdata2)
  );

  // ID/EX Pipeline Register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      id_ex_reg <= '0;
    end else if (flush_id) begin
      id_ex_reg <= '0;
    end else begin
      id_ex_reg <= id_ex_next;
    end
  end

  always_comb begin
    id_ex_next.pc = if_id_reg.pc;
    id_ex_next.instruction = if_id_reg.instruction;
    id_ex_next.rs1_data = reg_rdata1;
    id_ex_next.rs2_data = reg_rdata2;
    id_ex_next.imm = imm;
    id_ex_next.rd_addr = rd;
    id_ex_next.rs1_addr = rs1;
    id_ex_next.rs2_addr = rs2;
    id_ex_next.ctrl = ctrl;
  end

  //================================================
  // Execute Stage
  //================================================

  logic [31:0] forwarded_rs1;
  logic [31:0] forwarded_rs2;

  // Forwarding MUX for rs1
  always_comb begin
    case (forward_a)
      2'b00:   forwarded_rs1 = id_ex_reg.rs1_data;
      2'b01:   forwarded_rs1 = reg_wdata;
      2'b10:   forwarded_rs1 = ex_mem_reg.alu_result;
      default: forwarded_rs1 = id_ex_reg.rs1_data;
    endcase
  end

  // Forwarding MUX for rs2
  always_comb begin
    case (forward_b)
      2'b00:   forwarded_rs2 = id_ex_reg.rs2_data;
      2'b01:   forwarded_rs2 = reg_wdata;
      2'b10:   forwarded_rs2 = ex_mem_reg.alu_result;
      default: forwarded_rs2 = id_ex_reg.rs2_data;
    endcase
  end

  // ALU input MUX
  always_comb begin
    case (id_ex_reg.ctrl.op_a_sel)
      2'b00:   alu_operand_a = forwarded_rs1;
      2'b01:   alu_operand_a = id_ex_reg.pc;
      2'b10:   alu_operand_a = 32'h0;
      default: alu_operand_a = forwarded_rs1;
    endcase

    case (id_ex_reg.ctrl.op_b_sel)
      2'b00:   alu_operand_b = forwarded_rs2;
      2'b01:   alu_operand_b = id_ex_reg.imm;
      default: alu_operand_b = forwarded_rs2;
    endcase
  end

  // ALU Operation
  always_comb begin
    unique case (alu_op_t'(id_ex_reg.ctrl.alu_op))
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


  // EX/MEM Pipeline Register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ex_mem_reg <= '0;
    end else if (flush_ex) begin
      ex_mem_reg <= '0;
    end else begin
      ex_mem_reg <= ex_mem_next;
    end
  end

  always_comb begin
    ex_mem_next.pc = id_ex_reg.pc;
    ex_mem_next.alu_result = alu_result;
    ex_mem_next.rs2_data = forwarded_rs2;
    ex_mem_next.rd_addr = id_ex_reg.rd_addr;
    ex_mem_next.ctrl = id_ex_reg.ctrl;
  end

  //================================================
  // Memory Stage
  //================================================

  // Memory Interface
  assign data_addr = ex_mem_reg.alu_result;
  assign data_wdata = ex_mem_reg.rs2_data;
  assign data_we = ex_mem_reg.ctrl.mem_write;
  assign mem_size = ex_mem_reg.ctrl.mem_size;


  // MEM/WB Pipeline Register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem_wb_reg <= '0;
    end else begin
      mem_wb_reg <= mem_wb_next;
    end
  end

  always_comb begin
    mem_wb_next.pc = ex_mem_reg.pc;
    mem_wb_next.mem_data = data_rdata;
    mem_wb_next.alu_result = ex_mem_reg.alu_result;
    mem_wb_next.rd_addr = ex_mem_reg.rd_addr;
    mem_wb_next.ctrl = ex_mem_reg.ctrl;
  end

  //================================================
  // Writeback Stage
  //================================================

  // Writeback MUX
  always_comb begin
    if (mem_wb_reg.ctrl.mem_read) reg_wdata = mem_wb_reg.mem_data;
    else if (mem_wb_reg.ctrl.next_pc_sel != 2'b00) reg_wdata = mem_wb_reg.pc + 4;
    else reg_wdata = mem_wb_reg.alu_result;

    reg_addr  = mem_wb_reg.rd_addr;
    reg_write = mem_wb_reg.ctrl.reg_write;
  end

  //================================================
  // Hazard Detection Unit
  //================================================

  hazard_detection_unit hazard_unit (
      .id_ex_mem_read(id_ex_reg.ctrl.mem_read),
      .id_ex_rd_addr(id_ex_reg.rd_addr),
      .if_id_rs1_addr(rs1),
      .if_id_rs2_addr(rs2),
      .branch_taken(branch_taken),
      .stall_if(stall_if),
      .stall_id(stall_id),
      .flush_if(flush_if),
      .flush_id(flush_id),
      .flush_ex(flush_ex)
  );

  //================================================
  // Forwarding Unit
  //================================================

  forwarding_unit forward_unit (
      .ex_mem_reg_write(ex_mem_reg.ctrl.reg_write),
      .ex_mem_rd_addr(ex_mem_reg.rd_addr),
      .mem_wb_reg_write(mem_wb_reg.ctrl.reg_write),
      .mem_wb_rd_addr(mem_wb_reg.rd_addr),
      .id_ex_rs1_addr(id_ex_reg.rs1_addr),
      .id_ex_rs2_addr(id_ex_reg.rs2_addr),
      .forward_a(forward_a),
      .forward_b(forward_b)
  );

endmodule


