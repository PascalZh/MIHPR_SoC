`include "cpu.vh"

interface id_reg_io;
  logic [`AluOp] alu_op;
  logic [`WordData] alu_in_0, alu_in_1;
  logic br_flag;
  logic [`MemOp] mem_op;
  logic [`WordData] mem_wr_data;
  logic [`CtrlOp] ctrl_op;
  logic [`GprAddr] dst_addr;
  logic gpr_we_;
  logic [`IsaExp] exp_code;
  modport in(
            input alu_op, alu_in_0, alu_in_1, br_flag, mem_op, mem_wr_data, ctrl_op, dst_addr, gpr_we_, exp_code
          );
  modport out(
            output alu_op, alu_in_0, alu_in_1, br_flag, mem_op, mem_wr_data, ctrl_op, dst_addr, gpr_we_, exp_code
          );
endinterface //id_reg_io

module id_stage (
    input clk, rst,

    input if_en,
    input [`WordAddr] if_pc,
    input [`WordData] if_insn,

    gpr_rd_bus_io.master gpr,

    // control reg
    input exe_mode,
    input [`WordData] creg_rd_data,
    output [`GprAddr] creg_rd_addr,

    // forwarding
    input ex_en,
    input [`WordData] ex_fwd_data,
    input [`GprAddr] ex_dst_addr,
    input ex_gpr_we_,
    input [`WordData] mem_fwd_data,

    // pipeline control
    output reg [`WordAddr] br_addr,
    output reg br_taken,
    output reg ld_hazard,
    pipeline_io.slave pl,

    // id registers
    output [`WordAddr] id_pc,
    output id_en,
    id_reg_io.out id_out
  );

  id_reg_io id_dec_out();

  decoder decoder(
            .if_pc (if_pc),
            .if_insn (if_insn),
            .gpr (gpr),

            // id_reg reconnect to decoder
            .id_en (id_en),
            .id_dst_addr (id_out.dst_addr),
            .id_gpr_we_ (id_out.gpr_we_),
            .id_mem_op (id_out.mem_op),

            .exe_mode (exe_mode),
            .creg_rd_data (creg_rd_data),
            .creg_rd_addr (creg_rd_addr),

            .ex_en (ex_en),
            .ex_fwd_data (ex_fwd_data),
            .ex_dst_addr (ex_dst_addr),
            .ex_gpr_we_ (ex_gpr_we_),
            .mem_fwd_data (mem_fwd_data),

            .br_addr (br_addr),
            .br_taken (br_taken),
            .ld_hazard (ld_hazard),

            .id_dec_out (id_dec_out)
          );

  id_reg id_reg(
           .clk (clk), .rst (rst),
           .pl (pl),

           .if_pc (if_pc),
           .if_en (if_en),
           .id_in (id_dec_out),

           .id_pc (id_pc),
           .id_en (id_en),
           .id_out (id_out)
         );

endmodule
