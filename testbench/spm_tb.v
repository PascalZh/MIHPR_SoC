`timescale 1ns/1ns
`include "stddef.vh"
`include "global_config.vh"
`include "spm.vh"

module spm_tb;
reg clk, rst_n;

integer i;
reg [`SpmAddrBus] addr;
reg as_;
reg rw;
reg [`WordData] wr_data;
wire [`WordData] rd_data;

spm spm(
      .clk (clk),
      .if_spm_addr (addr),
      .if_spm_as_ (as_),
      .if_spm_rw (rw),
      .if_spm_wr_data (wr_data),
      .if_spm_rd_data (rd_data)
    );


`define CLK_PERIOD 10
always #(`CLK_PERIOD/2) clk=~clk;

initial begin
  clk = 1;
  wr_data = 0;
  addr = 0;

  as_ = `DISABLE_;
  #(`CLK_PERIOD*20);
  for (i=0;i<=15;i=i+1) begin
    as_ = `ENABLE_;
    rw = `WRITE;
    wr_data = 255 - i;
    addr = i;
    #`CLK_PERIOD;
  end

  as_ = `DISABLE_;
  #(`CLK_PERIOD*20);
  for (i=0;i<=15;i=i+1) begin
    as_ = `ENABLE_;
    rw = `READ;
    addr = i;
    #`CLK_PERIOD;
  end
  #(`CLK_PERIOD*20);
  $stop;
end

endmodule
