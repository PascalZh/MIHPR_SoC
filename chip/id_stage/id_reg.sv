`include "isa.vh"
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

module id_reg (
    input clk, rst,
    pipeline_io.slave pl,

    input [`WordAddr] if_pc,
    input if_en,
    id_reg_io.in id_in,

    output [`WordAddr] id_pc,
    output id_en,
    id_reg_io.out id_out
  );

  task automatic reset();
    begin
      id_pc <= #1 '0;
      id_en <= #1 `DISABLE;

      id_out.alu_op <= #1 `ALU_OP_NOP;
      id_out.alu_in_0 <= #1 '0;
      id_out.alu_in_1 <= #1 '0;
      id_out.br_flag <= #1 `DISABLE;
      id_out.mem_op <= #1 `MEM_OP_NOP;
      id_out.mem_wr_data <= #1 '0;
      id_out.ctrl_op <= #1 `CTRL_OP_NOP;
      id_out.dst_addr <= #1 '0;
      id_out.gpr_we_ <= #1 `DISABLE_;
      id_out.exp_code <= #1 `ISA_EXP_NO_EXP;
    end
  endtask //automatic

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      reset();
    end
    else begin
      if (pl.stall == `DISABLE) begin
        if (pl.flush == `ENABLE) begin
          reset();
        end
        else begin
          id_pc <= #1 if_pc;
          id_en <= #1 if_en;

          id_out.alu_op <= id_in.alu_op;
          id_out.alu_in_0 <= id_in.alu_in_0;
          id_out.alu_in_1 <= id_in.alu_in_1;
          id_out.br_flag <= id_in.br_flag;
          id_out.mem_op <= id_in.mem_op;
          id_out.mem_wr_data <= id_in.mem_wr_data;
          id_out.ctrl_op <= id_in.ctrl_op;
          id_out.dst_addr <= id_in.dst_addr;
          id_out.gpr_we_ <= id_in.gpr_we_;
          id_out.exp_code <= id_in.exp_code;
        end
      end
    end
  end

endmodule
