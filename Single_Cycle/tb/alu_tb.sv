module alu_tb;

  logic [31:0] op_1_in, op_2_in;
  logic [ 3:0] opcode_in;
  logic [31:0] result_out;

  alu dut (.*);

  parameter bit [2:0] ADD = 3'b000;
  parameter bit [2:0] SLT = 3'b001;
  parameter bit [2:0] SLTU = 3'b010;
  parameter bit [2:0] AND = 3'b011;
  parameter bit [2:0] OR = 3'b100;
  parameter bit [2:0] XOR = 3'b101;
  parameter bit [2:0] SLL = 3'b110;
  parameter bit [2:0] SRL = 3'b111;

  task static initialize;
    op_1_in   = 32'b0;
    op_2_in   = 32'b0;
    opcode_in = 4'b0;
    #10;
  endtask

  task static stiumulus(input logic [31:0] op_1, input logic [31:0] op_2, input logic [2:0] opcode,
                        input logic ctrl);
    op_1_in = op_1;
    op_2_in = op_2;
    opcode_in[2:0] = opcode;
    opcode_in[3] = ctrl;
    #10;
  endtask

  initial begin
    $monitor("Inputs op_1_in = %d \t op_2_in = %d \t opcode_in = %d \n Output result_out = %d",
             op_1_in, op_2_in, opcode_in, result_out);
  end

  initial begin
    initialize;
    // stiumulus (op_1_in,op_2_in,opcode[2:0],opcode[3]);
    stiumulus(32'd20, 32'd40, ADD, 1'b0);
    stiumulus(32'd20, 32'd40, ADD, 1'b1);
    stiumulus(32'd60, 32'd50, SLT, 1'b0);
    stiumulus(32'd60, 32'd70, SLT, 1'b0);
    stiumulus(32'd60, 32'd1, SLL, 1'b0);
    #100 $finish;
  end

endmodule

