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

module ex_stage (
    input clk, rst,
    input int_detect,
    pipeline_io.slave pl,

    input [`WordAddr] id_pc,
    input id_en,
    output [`WordAddr] ex_pc,
    output ex_en,

    input [`AluOp] id_alu_op,
    input [`WordData] id_alu_in_0,
    input [`WordData] id_alu_in_1,
    output [`WordData] ex_fwd_data,
    output [`WordData] ex_data_out,

    ex_reg_io.in id_in,

    ex_reg_io.out ex_out
  );

  reg [`WordData] alu_out;
  reg alu_overflow;
  assign ex_fwd_data = alu_out;

  alu alu(
        .in_0 (id_alu_in_0),
        .in_1 (id_alu_in_1),
        .op (id_alu_op),
        .out (alu_out),
        .overflow (alu_overflow)
      );

  ex_reg ex_reg(
           .clk (clk), .rst (rst),
           .pl (pl),
           .int_detect (int_detect),

           .id_pc (id_pc),
           .id_en (id_en),
           .id_in (id_in),

           .ex_pc (ex_pc),
           .ex_en (ex_en),
           .ex_out (ex_out),

           .alu_overflow (alu_overflow),
           .alu_in (alu_out),
           .ex_data_out (ex_data_out)
         );

endmodule
