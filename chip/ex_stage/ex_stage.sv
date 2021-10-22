`include "cpu.vh"
`include "isa.vh"

interface ex_reg_io;
  logic br_flag;
  logic [`MemOp] mem_op;
  logic [`WordData] mem_wr_data;
  logic [`CtrlOp] ctrl_op;
  logic [`GprAddr] dst_addr;
  logic gpr_we_;
  logic [`IsaExp] exp_code;
  modport in(
            input br_flag, mem_op, mem_wr_data, ctrl_op, dst_addr, gpr_we_, exp_code
          );
  modport out(
            output br_flag, mem_op, mem_wr_data, ctrl_op, dst_addr, gpr_we_, exp_code
          );
endinterface //ex_reg_io
