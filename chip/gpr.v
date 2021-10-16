`include "stddef.v"
`include "global_config.v"
`include "cpu.v"

module gpr (
         input clk,
         input rst,
         input [`GprAddrBus] rd_addr_0,
         output [`WordDataBus] rd_data_0,
         input [`GprAddrBus] rd_addr_1,
         output [`WordDataBus] rd_data_1,

         input we_,
         input [`GprAddrBus] wr_addr,
         input [`WordDataBus] wr_data
       );

reg [`WordDataBus] gpr[`GPR_NUM];

// Read logic

// Return wr_data directly when read and write at the same time, otherwise gpr[rd_addr_0]
assign rd_data_0 = ((we_ == `ENABLE_) && (rd_addr_0 == wr_addr)) ? wr_data : gpr[rd_addr_0];
assign rd_data_1 = ((we_ == `ENABLE_) && (rd_addr_1 == wr_addr)) ? wr_data : gpr[rd_addr_1];

// Write logic

integer i;

always @(posedge clk, `RST_EDGE rst) begin
  if (rst == `RST_ENABLE) begin
    for (i = 0; i < `GPR_NUM; i = i + 1) begin
      gpr[i] <= #1 `WORD_DATA_W'h0;
    end
  end else begin
    if (we_ == `ENABLE_) begin
      gpr[wr_addr] <= #1 wr_data;
    end
  end
end

endmodule
