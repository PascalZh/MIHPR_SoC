`include "stddef.vh"
`include "global_config.vh"
`include "cpu.vh"
`include "isa.vh"

module if_reg (
  input clk,
  input rst,

  input instruction,  // 读取的指令
  pipeline_io.master pl,

  // control the branch
  input [`WordAddrBus] new_pc,
  input br_taken,
  input br_addr,
  // if_instruction is one cycle behind if_pc
  output reg [`WordAddrBus] if_pc,
  output reg [`WordDataBus] if_instruction,
  output reg if_en
);

always @(posedge clk, `RST_EDGE rst) begin
  if (rst == `RST_ENABLE) begin
    if_pc <= #1 `RST_VECTOR;
    if_en <= #1 `DISABLE;
    if_instruction <= #1 `ISA_NOP;
  end else begin
		if (pl.stall == `DISABLE) begin
      if (pl.flush == `ENABLE) begin
        if_pc <= #1 new_pc;
        if_instruction <= #1 `ISA_NOP;
        if_en <= #1 `DISABLE;
      end else if (br_taken == `ENABLE) begin
        if_pc <= #1 br_addr;
        if_instruction <= #1 instruction;
        if_en <= #1 `ENABLE;
      end else begin
        if_pc <= #1 if_pc + 1'd1;
        if_instruction <= #1 instruction;
        if_en <= #1 `ENABLE;
      end
    end
  end
end
  
endmodule