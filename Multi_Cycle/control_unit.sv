module control_unit
  import riscv_pkg::*;
(
    input  logic          [6:0] opcode,
    input  logic          [2:0] funct3,
    input  logic          [6:0] funct7,
    output ctrl_signals_t       ctrl_out
);
  // Previous cases remain the same...
  // Continuing from JAL case:
  always_comb begin
    // Default values
    ctrl_out = '{
        reg_write: 1'b0,
        mem_write: 1'b0,
        mem_read: 1'b0,
        next_pc_sel: 2'b00,
        op_a_sel: 2'b00,
        op_b_sel: 2'b00,
        alu_op: ALU_ADD,
        mem_size: 3'b010
    };

    case (opcode_t'(opcode))
      R_TYPE: begin
        ctrl_out.reg_write = 1'b1;
        ctrl_out.op_a_sel  = 2'b00;
        ctrl_out.op_b_sel  = 2'b00;
        case (funct3)
          3'b000: ctrl_out.alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD;
          3'b001: ctrl_out.alu_op = ALU_SLL;
          3'b010: ctrl_out.alu_op = ALU_SLT;
          3'b011: ctrl_out.alu_op = ALU_SLTU;
          3'b100: ctrl_out.alu_op = ALU_XOR;
          3'b101: ctrl_out.alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
          3'b110: ctrl_out.alu_op = ALU_OR;
          3'b111: ctrl_out.alu_op = ALU_AND;
        endcase
      end

      I_TYPE: begin
        ctrl_out.reg_write = 1'b1;
        ctrl_out.op_a_sel  = 2'b00;
        ctrl_out.op_b_sel  = 2'b01;
        case (funct3)
          3'b000: ctrl_out.alu_op = ALU_ADD;
          3'b010: ctrl_out.alu_op = ALU_SLT;
          3'b011: ctrl_out.alu_op = ALU_SLTU;
          3'b100: ctrl_out.alu_op = ALU_XOR;
          3'b110: ctrl_out.alu_op = ALU_OR;
          3'b111: ctrl_out.alu_op = ALU_AND;
          3'b001: ctrl_out.alu_op = ALU_SLL;
          3'b101: ctrl_out.alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
        endcase
      end

      LOAD: begin
        ctrl_out.reg_write = 1'b1;
        ctrl_out.mem_read  = 1'b1;
        ctrl_out.op_a_sel  = 2'b00;
        ctrl_out.op_b_sel  = 2'b01;
        ctrl_out.mem_size  = funct3;
      end

      STORE: begin
        ctrl_out.mem_write = 1'b1;
        ctrl_out.op_a_sel  = 2'b00;
        ctrl_out.op_b_sel  = 2'b01;
        ctrl_out.mem_size  = funct3;
      end

      BRANCH: begin
        ctrl_out.next_pc_sel = 2'b01;
        ctrl_out.op_a_sel    = 2'b00;
        ctrl_out.op_b_sel    = 2'b00;

        case (funct3)
          3'b000: ctrl_out.alu_op = ALU_SUB;  // BEQ If result is 0, then rs1 == rs2
          3'b001: ctrl_out.alu_op = ALU_SUB;  // BNE If result is NOT 0, then rs1 != rs2
          3'b100: ctrl_out.alu_op = ALU_SLT;  // BLT If result is 1, then rs1 < rs2
          3'b101: ctrl_out.alu_op = ALU_SLT;  // BGE If result is 0, then rs1 >= rs2
          3'b110: ctrl_out.alu_op = ALU_SLTU;  // BLTU If result is 1, then rs1 < rs2 (unsigned)
          3'b111: ctrl_out.alu_op = ALU_SLTU;  // BGEU If result is 0, then rs1 >= rs2 (unsigned)
        endcase
      end

      JAL: begin
        ctrl_out.reg_write   = 1'b1;
        ctrl_out.next_pc_sel = 2'b10;
        ctrl_out.op_a_sel    = 2'b01;
        ctrl_out.op_b_sel    = 2'b01;
        ctrl_out.alu_op      = ALU_ADD;
      end

      JALR: begin
        ctrl_out.reg_write   = 1'b1;
        ctrl_out.next_pc_sel = 2'b11;
        ctrl_out.op_a_sel    = 2'b00;
        ctrl_out.op_b_sel    = 2'b01;
        ctrl_out.alu_op      = ALU_ADD;
      end

      LUI: begin
        ctrl_out.reg_write = 1'b1;
        ctrl_out.op_a_sel  = 2'b10;  // Select 0
        ctrl_out.op_b_sel  = 2'b01;  // Select immediate
        ctrl_out.alu_op    = ALU_ADD;
      end

      AUIPC: begin
        ctrl_out.reg_write = 1'b1;
        ctrl_out.op_a_sel  = 2'b01;  // Select PC
        ctrl_out.op_b_sel  = 2'b01;  // Select immediate
        ctrl_out.alu_op    = ALU_ADD;
      end

      default: begin
        ctrl_out = '{
            reg_write: 1'b0,
            mem_write: 1'b0,
            mem_read: 1'b0,
            next_pc_sel: 2'b00,
            op_a_sel: 2'b00,
            op_b_sel: 2'b00,
            alu_op: ALU_ADD,
            mem_size: 3'b010
        };
      end
    endcase
  end
endmodule
