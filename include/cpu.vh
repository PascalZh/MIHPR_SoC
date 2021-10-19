`define GPR_NUM 32
`define GPR_ADDR_W 5
`define GprAddrBus 4:0

`define RST_VECTOR 30'h0

`define BusIfStateIndex 1:0
`define BUS_IF_STATE_IDLE 2'h0
`define BUS_IF_STATE_REQ 2'h1
`define BUS_IF_STATE_ACCESS 2'h2
`define BUS_IF_STATE_STALL 2'h3