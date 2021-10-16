`timescale 1ns/1ns
`include "stddef.v"
`include "global_config.v"
`include "spm.v"

module spm_tb;
reg clk, rst_n;

integer i;
reg [`SpmAddrBus] addr;
reg as_;
reg rw;
reg [`WordDataBus] wr_data;
wire [`WordDataBus] rd_data;

spm spm(
      .clk (clk),
      .if_spm_addr (addr),
      .if_spm_as_ (as_),
      .if_spm_rw (rw),
      .if_spm_wr_data (wr_data),
      .if_spm_rd_data (rd_data)
    );


localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
  clk = 0;
  wr_data = 0;
  addr = 0;

  as_ = `DISABLE_;
  #(CLK_PERIOD*20 +1 );
  for (i=0;i<=15;i=i+1) begin
    as_ = `ENABLE_;
    rw = `WRITE;
    wr_data = 255 - i;
    addr = i;
    #CLK_PERIOD;
  end

  as_ = `DISABLE_;
  #(CLK_PERIOD*20);
  for (i=0;i<=15;i=i+1) begin
    as_ = `ENABLE_;
    rw = `READ;
    addr = i;
    #CLK_PERIOD;
  end
  #(CLK_PERIOD*20);
  $stop;
end


endmodule
