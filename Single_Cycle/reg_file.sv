// Register File Module
module reg_file (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] rs1_addr,
    input  logic [ 4:0] rs2_addr,
    input  logic [ 4:0] rd_addr,
    input  logic [31:0] rd_data,
    input  logic        rd_we,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

  logic [31:0] registers[32];

  // Read
  assign rs1_data = (rs1_addr == 0) ? 32'b0 : registers[rs1_addr];
  assign rs2_data = (rs2_addr == 0) ? 32'b0 : registers[rs2_addr];

  // Write
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < 32; i++) begin
        registers[i] <= 32'b0;
      end
    end else if (rd_we && rd_addr != 0) begin
      registers[rd_addr] <= rd_data;
    end
  end
endmodule

