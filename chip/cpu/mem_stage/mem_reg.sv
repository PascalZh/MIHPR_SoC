`include "cpu.vh"
`include "isa.vh"

module mem_reg (
    input clk, input rst,

    input [`WordData] in,
    input miss_align,

    pipeline_io.slave pl,

    input [`WordAddr] ex_pc,
    input ex_en,
    mem_reg_io.in ex_in,

    output [`WordAddr] mem_pc,
    output mem_en,
    mem_reg_io.out mem_out,

    output [`WordData] mem_data_out
  );

  task reset();
    begin
      mem_pc <= #1 '0;
      mem_en <= #1 `DISABLE;
      mem_out.br_flag <= #1 `DISABLE;
      mem_out.ctrl_op <= #1 `CTRL_OP_NOP;
      mem_out.dst_addr <= #1 '0;
      mem_out.gpr_we_ <= #1 `DISABLE_;
      mem_out.exp_code <= #1 `ISA_EXP_NO_EXP;
      mem_data_out <= #1 '0;
    end
  endtask

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      reset();
    end
    else begin
      if (pl.stall == `DISABLE) begin
        if (pl.flush == `ENABLE) begin
          reset();
        end
        else if (miss_align == `ENABLE) begin
          mem_pc <= #1 ex_pc;
          mem_en <= #1 ex_en;
          mem_out.br_flag <= #1 ex_in.br_flag;
          mem_out.ctrl_op <= #1 `CTRL_OP_NOP;
          mem_out.dst_addr <= #1 '0;
          mem_out.gpr_we_ <= #1 `DISABLE_;
          mem_out.exp_code <= #1 `ISA_EXP_MISS_ALIGN;
          mem_data_out <= #1 '0;
        end
        else begin
          mem_pc <= #1 ex_pc;
          mem_en <= #1 ex_en;
          mem_out.br_flag <= #1 ex_in.br_flag;
          mem_out.ctrl_op <= #1 ex_in.ctrl_op;
          mem_out.dst_addr <= #1 ex_in.dst_addr;
          mem_out.gpr_we_ <= #1 ex_in.gpr_we_;
          mem_out.exp_code <= #1 ex_in.exp_code;
          mem_data_out <= #1 in;
        end
      end
    end
  end

endmodule
