module riscv_top_tb ();

  logic clk;
  logic rst_n;

  riscv_top dut (
      .clk  (clk),
      .rst_n(rst_n)
  );

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    #15;
    rst_n = 1'b1;

    #500;
    $finish;
  end

endmodule

