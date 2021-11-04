`include "cpu.vh"
`include "isa.vh"
`include "spm.vh"

module cpu (
    input rst,
    input clk, reverse_clk,

    input [`Irq] irq,
    bus_io.master if_bus,
    bus_io.master mem_bus
  );

  simple_bus_io if_spm();
  simple_bus_io mem_spm();

  spm spm(
        .clk (reverse_clk),
        .if_spm_addr (if_spm.addr[`SpmAddrLoc]),
        .if_spm_as_ (if_spm.as_),
        .if_spm_rw (if_spm.rw),
        .if_spm_wr_data (if_spm.wr_data),
        .if_spm_rd_data (if_spm.rd_data),

        .mem_spm_addr (mem_spm.addr[`SpmAddrLoc]),
        .mem_spm_as_ (mem_spm.as_),
        .mem_spm_rw (mem_spm.rw),
        .mem_spm_wr_data (mem_spm.wr_data),
        .mem_spm_rd_data (mem_spm.rd_data)
      );

  pipeline_io if_pl();
  pipeline_io id_pl();
  pipeline_io ex_pl();
  pipeline_io mem_pl();

  wire if_busy, mem_busy;

  wire [`WordAddr] new_pc;
  // returned from ID stage
  wire br_taken;
  wire [`WordAddr] br_addr;
  wire ld_hazard;
  // if stage regs
  wire [`WordAddr] if_pc, id_pc, ex_pc, mem_pc;
  wire [`WordData] if_insn;
  wire if_en, id_en, ex_en, mem_en;

  gpr_rd_bus_io gpr_rd();
  gpr_wr_bus_io gpr_wr();

  wire exe_mode;
  wire [`WordData] creg_rd_data;
  wire [`GprAddr] creg_rd_addr;
  wire [`WordData] ex_fwd_data;
  wire [`WordData] ex_data_out;
  wire [`WordData] mem_fwd_data;
  ex_reg_io ex_out();

  id_reg_io id_out();

  ex_reg_io id_in();
  assign id_in.br_flag = id_out.br_flag;
  assign id_in.mem_op = id_out.mem_op;
  assign id_in.mem_wr_data = id_out.mem_wr_data;
  assign id_in.ctrl_op = id_out.ctrl_op;
  assign id_in.dst_addr = id_out.dst_addr;
  assign id_in.gpr_we_ = id_out.gpr_we_;
  assign id_in.exp_code = id_out.exp_code;
  wire int_detect;

  mem_reg_io ex_in();
  assign ex_in.br_flag = ex_out.br_flag;
  assign ex_in.ctrl_op = ex_out.ctrl_op;
  assign ex_in.dst_addr = ex_out.dst_addr;
  assign ex_in.gpr_we_ = ex_out.gpr_we_;
  assign ex_in.exp_code = ex_out.exp_code;

  mem_reg_io mem_out();
  wire [`WordData] mem_data_out;
  assign gpr_wr.we_ = mem_out.gpr_we_;
  assign gpr_wr.addr = mem_out.dst_addr;
  assign gpr_wr.data = mem_data_out;

  gpr gpr(.rst, .clk, .rd (gpr_rd), .wr (gpr_wr));

  if_stage if_stage(
             .rst, .clk,
             .bus (if_bus),
             .spm (if_spm),

             .busy (if_busy),
             .pl (if_pl),
             .new_pc,

             // from ID stage
             .br_taken, .br_addr,

             // IF regs
             .if_pc, .if_insn, .if_en
           );

  id_stage id_stage(
             .rst, .clk,
             // to IF stage
             .br_taken, .br_addr,

             .if_pc, .if_insn, .if_en,

             .gpr_rd,

             .exe_mode,
             .creg_rd_data,
             .creg_rd_addr,

             // forwarding from EX and MEM stage
             .ex_en,
             .ex_fwd_data,
             .ex_dst_addr (ex_out.dst_addr),
             .ex_gpr_we_ (ex_out.gpr_we_),
             .mem_fwd_data,

             .pl(id_pl),
             .ld_hazard,

             // output regs
             .id_pc,
             .id_en,
             .id_out
           );

  ex_stage ex_stage (
             .clk, .rst,
             .int_detect,
             .pl (ex_pl),

             .id_pc,
             .id_en,
             .ex_pc,
             .ex_en,

             .id_alu_op (id_out.alu_op),
             .id_alu_in_0 (id_out.alu_in_0),
             .id_alu_in_1 (id_out.alu_in_1),
             .ex_fwd_data,
             .ex_data_out,

             .id_in,
             .ex_out
           );

  mem_stage mem_stage (
              .clk, .rst,
              .pl (mem_pl),
              .busy (mem_busy),

              .spm (mem_spm),
              .bus (mem_bus),

              .ex_mem_op (ex_out.mem_op),
              .ex_mem_wr_data (ex_out.mem_wr_data),
              .ex_data_in (ex_data_out),

              .ex_pc,
              .ex_en,
              .ex_in,

              .mem_pc,
              .mem_en,
              .mem_out,
              .mem_data_out,
              .mem_fwd_data
            );

  ctrl ctrl (
    .clk, .rst,
    .exe_mode, .creg_rd_addr, .creg_rd_data,
    .irq,
    .int_detect,
    .id_pc,

    .mem_pc,
    .mem_en,
    .mem_br_flag (mem_out.br_flag),
    .mem_ctrl_op (mem_out.ctrl_op),
    .mem_dst_addr (mem_out.dst_addr),
    .mem_exp_code (mem_out.exp_code),
    .mem_data_in (mem_data_out),

    .if_busy,
    .ld_hazard,
    .mem_busy,

    .if_stall (if_pl.stall), .id_stall (id_pl.stall), .ex_stall (ex_pl.stall), .mem_stall (mem_pl.stall),
    .if_flush (if_pl.flush), .id_flush (id_pl.flush), .ex_flush (ex_pl.flush), .mem_flush (mem_pl.flush),
    .new_pc
  );

endmodule
