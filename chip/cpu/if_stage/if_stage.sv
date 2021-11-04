`include "stddef.vh"
// used to communicate with spm
interface simple_bus_io;
  logic [`WordAddr] addr;
  logic as_;
  logic rw;
  logic [`WordData] wr_data;
  logic [`WordData] rd_data;

  modport slave (
            input addr, as_, rw, wr_data,
            output rd_data
          );
  modport master (
            input rd_data,
            output addr, as_, rw, wr_data
          );
endinterface  // simple_bus_io

interface bus_io;
  logic grnt_;
  logic req_;

  logic [`WordAddr] addr;
  logic as_;
  logic rw;
  logic [`WordData] wr_data;

  logic [`WordData] rd_data;
  logic rdy_;

  modport slave (
            input addr, as_, rw, wr_data,
            output rd_data,
            input req_,
            output grnt_, rdy_
          );
  modport master (
            input rd_data,
            output addr, as_, rw, wr_data,
            output req_,
            input grnt_, rdy_
          );
endinterface  // bus_io

interface pipeline_io;
  logic stall;
  logic flush;
  modport slave (
            input stall, flush
          );
  modport master (
            output stall, flush
          );
endinterface  // pipeline_io

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
    input [`WordAddr] br_addr,
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
