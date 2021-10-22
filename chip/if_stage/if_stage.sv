`include "stddef.vh"
module if_stage (
    input clk,
    input rst,
    output busy,

    simple_bus_io.master spm,

    bus_io.master bus,

    pipeline_io.slave pl,

    // control the branch
    input [`WordAddr] new_pc,
    input br_taken,
    input br_addr,
    // if_insn is one cycle behind if_pc
    output reg [`WordAddr] if_pc,
    output reg [`WordData] if_insn,
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
           .insn (always_read.rd_data),

           .new_pc (new_pc),
           .br_taken (br_taken),
           .br_addr (br_addr),
           .if_pc (if_pc),
           .if_insn (if_insn),
           .if_en (if_en)
         );

endmodule
