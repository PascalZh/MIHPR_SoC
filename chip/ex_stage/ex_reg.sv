`include "cpu.vh"
`include "isa.vh"

module ex_reg (
    input clk, rst,

    input alu_overflow,

    pipeline_io.slave pl,
    input int_detect,

    input [`WordAddr] id_pc,
    input id_en,
    ex_reg_io.in ex_in,
    input [`WordData] alu_in,

    output [`WordAddr] ex_pc,
    output ex_en,
    ex_reg_io.out ex_out,
    output [`WordData] ex_data_out
  );

  task reset_result();
    begin
      ex_out.mem_op <= #1 `MEM_OP_NOP;
      ex_out.mem_wr_data <= #1 '0;
      ex_out.ctrl_op <= #1 `CTRL_OP_NOP;
      ex_out.dst_addr <= #1 '0;
      ex_out.gpr_we_ <= #1 `DISABLE;
      ex_data_out <= #1 '0;
    end
  endtask

  task reset_all();
    begin
      ex_pc <= #1 '0;
      ex_en <= #1 `DISABLE;
      ex_out.br_flag <= #1 `DISABLE;
      ex_out.exp_code <= #1 `ISA_EXP_NO_EXP;
      reset_result();
    end
  endtask // reset

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      reset_all();
    end
    else begin
      if (pl.stall == `DISABLE) begin
        if (pl.flush == `ENABLE) begin
          reset_all();
        end
        else if (int_detect == `ENABLE) begin
          ex_pc <= #1 id_pc;
          ex_en <= #1 id_en;
          ex_out.br_flag <= #1 ex_in.br_flag;
          reset_result();
          ex_out.exp_code <= #1 `ISA_EXP_EXT_INT;
        end
        else if (alu_overflow == `ENABLE) begin
          ex_pc <= #1 id_pc;
          ex_en <= #1 id_en;
          ex_out.br_flag <= #1 ex_in.br_flag;
          reset_result();
          ex_out.exp_code <= #1 `ISA_EXP_OVERFLOW;
        end
        else begin
          ex_pc <= #1 id_pc;
          ex_en <= #1 id_en;
          ex_out.br_flag <= #1 ex_in.br_flag;
          ex_out.exp_code <= #1 ex_in.exp_code;
          ex_out.mem_op <= #1 ex_in.mem_op;
          ex_out.mem_wr_data <= #1 ex_in.mem_wr_data;
          ex_out.ctrl_op <= #1 ex_in.ctrl_op;
          ex_out.dst_addr <= #1 ex_in.dst_addr;
          ex_out.gpr_we_ <= #1 ex_in.gpr_we_;
          ex_data_out <= #1 alu_in;
        end
      end
    end
  end

endmodule
