`include "isa.vh"
`include "cpu.vh"

module decoder (
  input [`WordAddr] if_pc,
  input [`WordData] if_insn,

  // GPR interface
  gpr_rd_bus_io.master gpr,

  // EX data forwarding
  // id_dst_addr is used by current EX stage,
  // thus refers to 1 instructions before now
  input id_en,
  input [`GprAddr] id_dst_addr,
  input id_gpr_we_,
  input [`MemOp] id_mem_op,
  input [`WordData] ex_fwd_data,

  // MEM data forwarding
  // ex_dst_addr is used by current MEM stage,
  // thus refers to 2 instructions before now
  input ex_en,
  input [`GprAddr] ex_dst_addr,
  input ex_gpr_we_,
  input [`WordData] mem_fwd_data,

  // control reg (creg)
  input exe_mode,
  input [`WordData] creg_rd_data,
  output [`GprAddr] creg_rd_addr,

  output reg [`WordAddr] br_addr,
  output reg br_taken,
  output reg ld_hazard,

  id_reg_io.out id_dec_out
);

wire [`IsaOp] op = if_insn[`IsaOpLoc];
wire [`GprAddr] ra_addr = if_insn[`IsaRaAddrLoc];
wire [`GprAddr] rb_addr = if_insn[`IsaRbAddrLoc];
wire [`GprAddr] rc_addr = if_insn[`IsaRcAddrLoc];

wire [`IsaImm] imm = if_insn[`IsaImmLoc];
wire [`WordData] imm_s = {{`ISA_EXT_W{imm[`ISA_IMM_MSB]}}, imm};
wire [`WordData] imm_u = {{`ISA_EXT_W{1'b0}}, imm};

assign gpr.rd_addr_0 = ra_addr;
assign gpr.rd_addr_1 = rb_addr;
assign creg_rd_addr = ra_addr;

reg [`WordData] ra_data, rb_data;
wire signed [`WordData] s_ra_data = $signed(ra_data);
wire signed [`WordData] s_rb_data = $signed(rb_data);
assign id_dec_out.mem_wr_data = rb_data;

// CALL instruction: if_pc is already +1 in ID stage,
// and there must be a delayed gap after CALL, so the return address
// must +1 one more time, will be store at gpr31
wire [`WordAddr] ret_addr = if_pc + 1'b1;
wire [`WordAddr] br_target = if_pc + imm_s[`WORD_ADDR_MSB:0];
wire [`WordAddr] jr_target = ra_data[`WordAddrLoc];

// Data forwarding
always @(*) begin
  // Ra
  if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && (id_dst_addr == ra_addr)) begin
    // data forwarding from EX
    ra_data = ex_fwd_data;
  end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && (ex_dst_addr == ra_addr)) begin
    // data forwarding from MEM
    ra_data = mem_fwd_data;
  end else begin
    ra_data = gpr.rd_data_0;
  end
  //Rb
  if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && (id_dst_addr == rb_addr)) begin
    rb_data = ex_fwd_data;
  end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && (ex_dst_addr == rb_addr)) begin
    rb_data = mem_fwd_data;
  end else begin
    rb_data = gpr.rd_data_1;
  end
end

always @(*) begin
  if (id_en == `ENABLE && id_mem_op == `MEM_OP_LDW &&
     (id_dst_addr == ra_addr || id_dst_addr == rb_addr)) begin
    ld_hazard = `ENABLE;
  end else begin
    ld_hazard = `DISABLE;
  end
end

always @(*) begin
  br_taken = `DISABLE;
  br_addr = '0;

  id_dec_out.alu_op = `ALU_OP_NOP;
  id_dec_out.alu_in_0 = ra_data;
  id_dec_out.alu_in_1 = rb_data;
  id_dec_out.br_flag = `DISABLE;
  id_dec_out.mem_op = `MEM_OP_NOP;
  id_dec_out.ctrl_op = `CTRL_OP_NOP;
  id_dec_out.dst_addr = rb_addr;
  id_dec_out.gpr_we_ = `DISABLE_;
  id_dec_out.exp_code = `ISA_EXP_NO_EXP;
  case (if_insn)
    `ISA_OP_ANDR: begin
      id_dec_out.alu_op = `ALU_OP_AND;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_ANDI: begin
      id_dec_out.alu_op = `ALU_OP_AND;
      id_dec_out.alu_in_1 = imm_u;
      id_dec_out.gpr_we_ = `ENABLE_;
    end

    `ISA_OP_ORR: begin
      id_dec_out.alu_op = `ALU_OP_OR;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_ORI: begin
      id_dec_out.alu_op = `ALU_OP_OR;
      id_dec_out.alu_in_1 = imm_u;
      id_dec_out.gpr_we_ = `ENABLE_;
    end

    `ISA_OP_XORR: begin
      id_dec_out.alu_op = `ALU_OP_XOR;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_XORI: begin
      id_dec_out.alu_op = `ALU_OP_XOR;
      id_dec_out.alu_in_1 = imm_u;
      id_dec_out.gpr_we_ = `ENABLE_;
    end

    `ISA_OP_ADDSR: begin
      id_dec_out.alu_op = `ALU_OP_ADDS;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_ADDSI: begin
      id_dec_out.alu_op = `ALU_OP_ADDS;
      id_dec_out.alu_in_1 = imm_s;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_ADDUR: begin
      id_dec_out.alu_op = `ALU_OP_ADDU;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_ADDUI: begin
      id_dec_out.alu_op = `ALU_OP_ADDU;
      id_dec_out.alu_in_1 = imm_u;
      id_dec_out.gpr_we_ = `ENABLE_;
    end

    `ISA_OP_SUBSR: begin
      id_dec_out.alu_op = `ALU_OP_SUBS;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_SUBUR: begin
      id_dec_out.alu_op = `ALU_OP_SUBU;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end

    `ISA_OP_SHRLR: begin
      id_dec_out.alu_op = `ALU_OP_SHRL;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_SHRLI: begin
      id_dec_out.alu_op = `ALU_OP_SHRL;
      id_dec_out.alu_in_1 = imm_u;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_SHLLR: begin
      id_dec_out.alu_op = `ALU_OP_SHLL;
      id_dec_out.dst_addr = rc_addr;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_SHLLI: begin
      id_dec_out.alu_op = `ALU_OP_SHLL;
      id_dec_out.alu_in_1 = imm_u;
      id_dec_out.gpr_we_ = `ENABLE_;
    end

    `ISA_OP_BE: begin
      br_taken = (ra_data == rb_data) ? `ENABLE : `DISABLE;
      id_dec_out.br_flag = `ENABLE;
      br_addr = br_target;
    end
    `ISA_OP_BNE: begin
      br_taken = (ra_data != rb_data) ? `ENABLE : `DISABLE;
      id_dec_out.br_flag = `ENABLE;
      br_addr = br_target;
    end
    `ISA_OP_BSGT: begin
      br_taken = (s_ra_data < s_rb_data) ? `ENABLE : `DISABLE;
      id_dec_out.br_flag = `ENABLE;
      br_addr = br_target;
    end
    `ISA_OP_BUGT: begin
      br_taken = (ra_data < rb_data) ? `ENABLE : `DISABLE;
      id_dec_out.br_flag = `ENABLE;
      br_addr = br_target;
    end
    `ISA_OP_JMP: begin
      br_taken = `ENABLE;
      id_dec_out.br_flag = `ENABLE;
      br_addr = jr_target;
    end
    `ISA_OP_CALL: begin
      id_dec_out.alu_in_0 = {ret_addr, {`BYTE_OFFSET_W{1'b0}}};
      id_dec_out.dst_addr = `GPR_ADDR_W'd31;
      br_taken = `ENABLE;
      id_dec_out.br_flag = `ENABLE;
      br_addr = jr_target;
      id_dec_out.gpr_we_ = `ENABLE_;
    end

    `ISA_OP_LDW: begin
      id_dec_out.alu_op = `ALU_OP_ADDU;
      id_dec_out.alu_in_1 = imm_s;
      id_dec_out.mem_op = `MEM_OP_LDW;
      id_dec_out.gpr_we_ = `ENABLE_;
    end
    `ISA_OP_STW: begin
      id_dec_out.alu_op = `ALU_OP_ADDU;
      id_dec_out.alu_in_1 = imm_s;
      id_dec_out.mem_op = `MEM_OP_STW;
    end

    `ISA_OP_TRAP: begin
      id_dec_out.exp_code = `ISA_EXP_TRAP;
    end
    `ISA_OP_RDCR: begin
      if (exe_mode == `CPU_KERNEL_MODE) begin
        id_dec_out.alu_in_0 = creg_rd_data;
        id_dec_out.gpr_we_ = `ENABLE_;
      end else begin
        id_dec_out.exp_code = `ISA_EXP_PRV_VIO;
      end
    end
    `ISA_OP_WRCR: begin
      if (exe_mode == `CPU_KERNEL_MODE) begin
        id_dec_out.ctrl_op = `CTRL_OP_WRCR;
      end else begin
        id_dec_out.exp_code = `ISA_EXP_PRV_VIO;
      end
    end
    `ISA_OP_EXRT: begin
      if (exe_mode == `CPU_KERNEL_MODE) begin
        id_dec_out.ctrl_op = `CTRL_OP_EXRT;
      end else begin
        id_dec_out.exp_code = `ISA_EXP_PRV_VIO;
      end
    end
    default: begin
      id_dec_out.exp_code = `ISA_EXP_UNDEF_INSN;
    end
  endcase
end

endmodule
