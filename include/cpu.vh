`ifndef __CPU_VH__
`define __CPU_VH__

`include "stddef.vh"

`define GPR_NUM 32
`define GPR_ADDR_W 5
`define GprAddr 4:0

`define ALU_OP_W 4
`define AluOp 3:0
`define ALU_OP_NOP 4'h0
`define ALU_OP_AND 4'h1
`define ALU_OP_OR 4'h2
`define ALU_OP_XOR 4'h3
`define ALU_OP_ADDS 4'h4
`define ALU_OP_ADDU 4'h5
`define ALU_OP_SUBS 4'h6
`define ALU_OP_SUBU 4'h7
`define ALU_OP_SHRL 4'h8
`define ALU_OP_SHLL 4'h9

`define MEM_OP_W 2
`define MemOp 1:0
`define MEM_OP_NOP 2'h0
`define MEM_OP_LDW 2'h1
`define MEM_OP_STW 2'h2

`define CTRL_OP_W 2
`define CtrlOp 1:0
`define CTRL_OP_NOP 2'h0
`define CTRL_OP_WRCR 2'h1
`define CTRL_OP_EXRT 2'h2

`define CPU_EXE_MODE_W 1
`define CpuExeMode 0:0
`define CPU_KERNEL_MODE 1'b0
`define CPU_USER_MODE 1'b1

`define CREG_ADDR_STATUS 5'h0
`define CREG_ADDR_PRE_STATUS 5'h1
`define CREG_ADDR_PC 5'h2
`define CREG_ADDR_EPC 5'h3
`define CREG_ADDR_EXP_VECTOR 5'h4
`define CREG_ADDR_CAUSE 5'h5
`define CREG_ADDR_INT_MASK 5'h6
`define CREG_ADDR_IRQ 5'h7
`define CREG_ADDR_ROM_SIZE 5'h1d
`define CREG_ADDR_SPM_SIZE 5'h1e
`define CREG_ADDR_CPU_INFO 5'h1f
`define CregExeModeLoc 0
`define CregIntEnableLoc 1
`define CregExpCodeLoc 2:0
`define CregDlyFlagLoc 3

`define RST_VECTOR 30'h0

`define BusIfStateIndex 1:0
`define BUS_IF_STATE_IDLE 2'h0
`define BUS_IF_STATE_REQ 2'h1
`define BUS_IF_STATE_ACCESS 2'h2
`define BUS_IF_STATE_STALL 2'h3

`endif