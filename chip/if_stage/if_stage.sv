`include "stddef.vh"
module if_stage (
  input clk,
  input rst,
  output busy,

  simple_bus_io.slave spm,

  bus_io.slave bus,

  pipeline_io.master pl,

  // control the branch
  input [`WordAddrBus] new_pc,
  input br_taken,
  input br_addr,
  // if_instruction is one cycle behind if_pc
  output reg [`WordAddrBus] if_pc,
  output reg [`WordDataBus] if_instruction,
  output reg if_en
);

simple_bus_io always_read();
assign always_read.as_ = `ENABLE_;
assign always_read.rw = `READ;
assign always_read.wr_data = '0;
assign always_read.addr = if_pc;

bus_if bus_if(
  .clk (clk),
  .rst (rst),
  .busy (busy),

  .spm (spm),
  .bus (bus),
  .cpu (always_read),
  .pl (pl)
);

if_reg if_reg(
  .clk (clk),
  .rst (rst),
  .pl (pl),
  .instruction (always_read.rd_data),

  .new_pc (new_pc),
  .br_taken (br_taken),
  .br_addr (br_addr),
  .if_pc (if_pc),
  .if_instruction (if_instruction),
  .if_en (if_en)
);
  
endmodule