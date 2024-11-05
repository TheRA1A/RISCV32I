// Forwarding Unit
module forwarding_unit (
    input  logic       ex_mem_reg_write,
    input  logic [4:0] ex_mem_rd_addr,
    input  logic       mem_wb_reg_write,
    input  logic [4:0] mem_wb_rd_addr,
    input  logic [4:0] id_ex_rs1_addr,
    input  logic [4:0] id_ex_rs2_addr,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

  always_comb begin
    // Forward A logic
    if (ex_mem_reg_write && (ex_mem_rd_addr != 0) && (ex_mem_rd_addr == id_ex_rs1_addr)) begin
      forward_a = 2'b10;  // Forward from EX/MEM
    end else if (mem_wb_reg_write && (mem_wb_rd_addr != 0) && (mem_wb_rd_addr == id_ex_rs1_addr))
    begin
      forward_a = 2'b01;  // Forward from MEM/WB
    end else begin
      forward_a = 2'b00;  // No forwarding
    end

    // Forward B logic
    if (ex_mem_reg_write && (ex_mem_rd_addr != 0) && (ex_mem_rd_addr == id_ex_rs2_addr)) begin
      forward_b = 2'b10;  // Forward from EX/MEM
    end else if (mem_wb_reg_write && (mem_wb_rd_addr != 0) && (mem_wb_rd_addr == id_ex_rs2_addr))
    begin
      forward_b = 2'b01;  // Forward from MEM/WB
    end else begin
      forward_b = 2'b00;  // No forwarding
    end
  end

endmodule
