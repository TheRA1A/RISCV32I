module register_file_tb ();

  logic clk, reset, we;
  logic [4:0] a1, a2, wa;
  logic [31:0] wd;
  logic [31:0] rd1, rd2;

  // register_file dut (
  //     .clk(clk),
  //     .reset(reset),
  //     .we(we),
  //     .a1(a1),
  //     .a2(a2),
  //     .wa(wa),
  //     .wd(wd),
  //     .rd1(rd1),
  //     .rd2(rd2)
  // );

  register_file dut (.*);

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    @(negedge clk);
    reset = 1'b0;
    @(negedge clk);
    reset = 1'b1;

    we = 1'b1;
    @(negedge clk);

    wa = 5'b00101;
    wd = 32'h000005;

    @(negedge clk);
    wa = 5'b00111;
    wd = 32'h000007;

    @(negedge clk);
    a1 = 5'b00101;
    a2 = 5'b00111;

    #50;
    $finish;

  end

endmodule
