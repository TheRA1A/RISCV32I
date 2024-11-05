// Hazard Detection Unit
module hazard_detection_unit (
    input  logic       id_ex_mem_read,
    input  logic [4:0] id_ex_rd_addr,
    input  logic [4:0] if_id_rs1_addr,
    input  logic [4:0] if_id_rs2_addr,
    input  logic       branch_taken,
    output logic       stall_if,
    output logic       stall_id,
    output logic       flush_if,
    output logic       flush_id,
    output logic       flush_ex
);

  // Load-use hazard detection
  always_comb begin
    if (id_ex_mem_read &&
        ((id_ex_rd_addr == if_id_rs1_addr) || (id_ex_rd_addr == if_id_rs2_addr))) begin
      stall_if = 1'b1;
      stall_id = 1'b1;
      flush_ex = 1'b1;
    end else begin
      stall_if = 1'b0;
      stall_id = 1'b0;
      flush_ex = 1'b0;
    end

    // Control hazard handling
    if (branch_taken) begin
      flush_if = 1'b1;
      flush_id = 1'b1;
      flush_ex = 1'b1;
    end else begin
      flush_if = 1'b0;
      flush_id = 1'b0;
    end
  end

endmodule
