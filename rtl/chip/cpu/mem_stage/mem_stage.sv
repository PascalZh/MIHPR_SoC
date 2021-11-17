`include "cpu.vh"
`include "isa.vh"

interface mem_reg_io;
  logic br_flag;
  logic [`CtrlOp] ctrl_op;
  logic [`GprAddr] dst_addr;
  logic gpr_we_;
  logic [`IsaExp] exp_code;
  modport in(
            input br_flag, ctrl_op, dst_addr, gpr_we_, exp_code
          );
  modport out(
            output br_flag, ctrl_op, dst_addr, gpr_we_, exp_code
          );
endinterface //mem_reg_io

module mem_stage (
    input clk, rst,

    pipeline_io.slave pl,
    output busy,

    simple_bus_io.master spm,

    bus_io.master bus,

    input [`MemOp] ex_mem_op,
    input [`WordData] ex_mem_wr_data,
    input [`WordData] ex_data_in,

    input [`WordAddr] ex_pc,
    input ex_en,
    mem_reg_io.in ex_in,

    output [`WordAddr] mem_pc,
    output mem_en,
    mem_reg_io.out mem_out,
    output [`WordData] mem_data_out,
    output [`WordData] mem_fwd_data
  );

  simple_bus_io mem_ctrl_bus();
  reg [`WordData] ctrl_out;
  assign mem_fwd_data = ctrl_out;
  reg miss_align;

  bus_if bus_if(
           .clk (clk),
           .rst (rst),
           .pl (pl),
           .busy (busy),

           .spm (spm),
           .bus (bus),
           .cpu (mem_ctrl_bus)
         );

  mem_ctrl mem_ctrl(
             .ex_en (ex_en),
             .ex_mem_op (ex_mem_op),
             .ex_mem_wr_data (ex_mem_wr_data),
             .ex_data_in (ex_data_in),
             .mem (mem_ctrl_bus),
             .out (ctrl_out),
             .miss_align (miss_align)
           );

  mem_reg mem_reg(
            .clk (clk),
            .rst (rst),
            .pl (pl),
            .in (ctrl_out),
            .miss_align (miss_align),
            .ex_pc (ex_pc),
            .ex_en (ex_en),
            .ex_in (ex_in),

            .mem_pc (mem_pc),
            .mem_en (mem_en),
            .mem_out (mem_out),
            .mem_data_out (mem_data_out)
          );

endmodule
