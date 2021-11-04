`include "isa.vh"
`include "cpu.vh"
`include "spm.vh"
`include "rom.vh"

module ctrl (
    input clk, rst,
    input [`GprAddr] creg_rd_addr,
    output [`WordData] creg_rd_data,
    output exe_mode,

    input [`Irq] irq,
    output int_detect,

    input [`WordAddr] id_pc,

    input [`WordAddr] mem_pc,
    input mem_en,
    input mem_br_flag,
    input [`CtrlOp] mem_ctrl_op,
    input [`GprAddr] mem_dst_addr,
    input [`IsaExp] mem_exp_code,
    input [`WordData] mem_data_in,

    input if_busy,
    input ld_hazard,
    input mem_busy,

    output if_stall, id_stall, ex_stall, mem_stall,
    output if_flush, id_flush, ex_flush, mem_flush,
    output [`WordAddr] new_pc
  );
  reg int_en, pre_exe_mode, pre_int_en;
  // save pc to epc when entering exception programs
  reg [`WordAddr] epc;
  reg [`WordAddr] exp_vector;
  reg [`IsaExp] exp_code;
  // mask for interrupt
  reg [`Irq] mask;
  reg dly_flag;
  reg [`WordAddr] pre_pc;
  reg br_flag;

  wire stall = if_busy | mem_busy;
  assign if_stall = stall | ld_hazard;
  // id_stall, ex_stall and mem_stall will delay the corresponding reg one clock
  assign id_stall = stall;
  assign ex_stall = stall;
  assign mem_stall = stall;

  reg flush;
  assign if_flush = flush;
  assign id_flush = flush | ld_hazard;
  assign ex_flush = flush;
  assign mem_flush = flush;

  always @(*) begin
    new_pc = '0;
    flush = `DISABLE;
    if (mem_en == `ENABLE) begin
      if (mem_exp_code != `ISA_EXP_NO_EXP) begin
        new_pc = exp_vector;
        flush = `ENABLE;
      end
      else if (mem_ctrl_op == `CTRL_OP_EXRT) begin
        new_pc = epc;
        flush = `ENABLE;
      end
      else if (mem_ctrl_op == `CTRL_OP_WRCR) begin
        // mem_pc corresponds to pc of current MEM stage + 1
        new_pc = mem_pc;
        flush = `ENABLE;
      end
    end
  end

  // interrupt
  always @(*) begin
    if (int_en == `ENABLE && (|((~mask) & irq) == `ENABLE)) begin
      int_detect = `ENABLE;
    end
    else begin
      int_detect = `DISABLE;
    end
  end

  // creg (control register) read
  always @(*) begin
    case (creg_rd_addr)
      `CREG_ADDR_STATUS: begin
        creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, int_en, exe_mode};
      end
      `CREG_ADDR_PRE_STATUS: begin
        creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, pre_int_en, pre_exe_mode};
      end
      `CREG_ADDR_PC: begin
        creg_rd_data = {id_pc, {`BYTE_OFFSET_W'b0}};
      end
      `CREG_ADDR_EPC: begin
        creg_rd_data = {epc, {`BYTE_OFFSET_W'b0}};
      end
      `CREG_ADDR_EXP_VECTOR: begin
        creg_rd_data = {exp_vector, {`BYTE_OFFSET_W'b0}};
      end
      `CREG_ADDR_CAUSE: begin
        creg_rd_data = {{`WORD_DATA_W-1-`ISA_EXP_W{1'b0}}, dly_flag, exp_code};
      end
      `CREG_ADDR_INT_MASK: begin
        creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_W{1'b0}}, mask};
      end
      `CREG_ADDR_IRQ: begin
        creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_W{1'b0}}, irq};
      end
      `CREG_ADDR_ROM_SIZE: begin
        creg_rd_data = $unsigned(`ROM_SIZE);
      end
      `CREG_ADDR_SPM_SIZE: begin
        creg_rd_data = $unsigned(`SPM_SIZE);
      end
      `CREG_ADDR_CPU_INFO: begin
        creg_rd_data = {`RELEASE_YEAR, `RELEASE_MONTH, `RELEASE_VERSION, `RELEASE_REVISION};
      end
      default: begin
        creg_rd_data = '0;
      end
    endcase
  end

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      exe_mode <= #1 `CPU_KERNEL_MODE;
      int_en <= #1 `DISABLE;
      pre_exe_mode <= #1 `CPU_KERNEL_MODE;
      pre_int_en <= #1 `DISABLE;
      exp_code <= #1 `ISA_EXP_NO_EXP;
      mask <= #1 {`CPU_IRQ_W{`ENABLE}};
      dly_flag <= #1 `DISABLE;
      epc <= #1 '0;
      exp_vector <= #1 '0;
      pre_pc <= #1 '0;
      br_flag <= #1 `DISABLE;
    end
    else begin
      if (mem_en == `ENABLE && stall === `DISABLE) begin
        pre_pc <= #1 mem_pc;
        br_flag <= #1 mem_br_flag;
        if (mem_exp_code != `ISA_EXP_NO_EXP) begin
          // @1 see @2
          pre_exe_mode <= #1 exe_mode;
          pre_int_en <= #1 int_en;

          exe_mode <= #1 `CPU_KERNEL_MODE;
          int_en <= #1 `DISABLE;
          exp_code <= #1 mem_exp_code;
          dly_flag <= #1 br_flag;
          epc <= #1 pre_pc;
        end
        else if (mem_ctrl_op == `CTRL_OP_EXRT) begin
          // @2
          exe_mode <= #1 pre_exe_mode;
          int_en <= #1 pre_int_en;
        end
        else if (mem_ctrl_op == `CTRL_OP_WRCR) begin
          case (mem_dst_addr)
            `CREG_ADDR_STATUS: begin
              exe_mode <= #1 mem_data_in[`CregExeModeLoc];
              int_en <= #1 mem_data_in[`CregIntEnableLoc];
            end
            `CREG_ADDR_PRE_STATUS: begin
              pre_exe_mode <= #1 mem_data_in[`CregExeModeLoc];
              pre_int_en <= #1 mem_data_in[`CregIntEnableLoc];
            end
            `CREG_ADDR_EPC: begin
              epc <= #1 mem_data_in[`WordAddrLoc];
            end
            `CREG_ADDR_EXP_VECTOR: begin
              exp_vector <= #1 mem_data_in[`WordAddrLoc];
            end
            `CREG_ADDR_CAUSE: begin
              dly_flag <= #1 mem_data_in[`CregDlyFlagLoc];
              exp_code <= #1 mem_data_in[`CregExpCodeLoc];
            end
            `CREG_ADDR_INT_MASK: begin
              mask <= #1 mem_data_in[`IrqMaskLoc];
            end
          endcase
        end
      end
    end
  end

endmodule
