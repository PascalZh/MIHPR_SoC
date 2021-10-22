`ifndef __ISA_VH__
`define __ISA_VH__

`include "stddef.vh"

`define ISA_NOP 32'h0
`define ISA_OP_W 6
`define IsaOp 5:0
`define IsaOpLoc 31:26

`define ISA_OP_ANDI 6'H01
`define ISA_OP_ORR 6'H02
`define ISA_OP_ORI 6'H03
`define ISA_OP_XORR 6'H04
`define ISA_OP_XORI 6'H05
`define ISA_OP_ADDSR 6'H06
`define ISA_OP_ADDSI 6'H07
`define ISA_OP_ADDUR 6'H08
`define ISA_OP_ADDUI 6'H09
`define ISA_OP_SUBSR 6'H0a
`define ISA_OP_SUBUR 6'H0b
`define ISA_OP_SHRLR 6'H0c
`define ISA_OP_SHRLI 6'H0d
`define ISA_OP_SHLLR 6'H0e
`define ISA_OP_SHLLI 6'H0f
`define ISA_OP_BE 6'H10
`define ISA_OP_BNE 6'H11
`define ISA_OP_BSGT 6'H12
`define ISA_OP_BUGT 6'H13
`define ISA_OP_ANDR 6'h00
`define ISA_OP_JMP 6'H14
`define ISA_OP_CALL 6'H15
`define ISA_OP_LDW 6'H16
`define ISA_OP_STW 6'H17
`define ISA_OP_TRAP 6'H18
`define ISA_OP_RDCR 6'H19
`define ISA_OP_WRCR 6'H1a
`define ISA_OP_EXRT 6'H1b

`define ISA_REG_ADDR_W 5
// the same as GprAddr
`define IsaRegAddr 4:0
`define IsaRaAddrLoc 25:21
`define IsaRbAddrLoc 20:16
`define IsaRcAddrLoc 15:11

`define ISA_IMM_W 16
// the width that needs to be extended for immediate numbers
`define ISA_EXT_W 16
`define ISA_IMM_MSB 15
`define IsaImm 15:0
`define IsaImmLoc 15:0

`define ISA_EXP_W 3
`define IsaExp 2:0
`define ISA_EXP_NO_EXP 3'h0
`define ISA_EXP_EXT_INT 3'h1
`define ISA_EXP_UNDEF_INSN 3'h2
`define ISA_EXP_OVERFLOW 3'h3
`define ISA_EXP_MISS_ALIGN 3'h4
`define ISA_EXP_TRAP 3'h5
`define ISA_EXP_PRV_VIO 3'h6

`endif