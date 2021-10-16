module bus_tb;
reg clk, rst_n;
reg m0_req_, m1_req_;
wire m0_grnt_, m1_grnt_, m2_grnt_, m3_grnt_;

bus bus(
      .rst (rst_n),
      .clk (clk),
      .m0_req_ (m0_req_),
      .m1_req_ (m1_req_),

      .m0_grnt_ (m0_grnt_),
      .m1_grnt_ (m1_grnt_),
      .m2_grnt_ (m2_grnt_),
      .m3_grnt_ (m3_grnt_)
    );

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
  clk = 0; rst_n = 0;

  m0_req_ = 1;
  m1_req_ = 1;

  #(CLK_PERIOD) rst_n = 1;

  #(CLK_PERIOD) m1_req_ = 0;

  #(100 * CLK_PERIOD)

   $stop;
end

endmodule
