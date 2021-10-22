`ifndef __STDDEF_VH__
`define __STDDEF_VH__
`include "global_config.vh"

`define HIGH 1'b1
`define LOW 1'b0
`define DISABLE 1'b0
`define ENABLE 1'b1
`define DISABLE_ 1'b1
`define ENABLE_ 1'b0
`define READ 1'b1
`define WRITE 1'b0
`define LSB 0

`define WORD_DATA_W 32
`define WORD_MSB 31
`define WordData 31:0

`define WORD_ADDR_W 30
`define WORD_ADDR_MSB 29
`define WordAddr 29:0

`define BYTE_OFFSET_W 2
`define ByteOffsetBus 1:0

`define WordAddrLoc 31:2
`define ByteOffsetLoc 1:0

`define BYTE_OFFSET_WORD 2'b00

`endif