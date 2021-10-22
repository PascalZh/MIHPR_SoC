`include "cpu.vh"
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
