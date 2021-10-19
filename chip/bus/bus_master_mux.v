`include "stddef.vh"
`include "bus.vh"

module bus_master_mux (
    input [`WordAddrBus] m0_addr,
    input m0_as_,
    input m0_rw,
    input [`WordDataBus] m0_wr_data,
    input m0_grnt_,

    input [`WordAddrBus] m1_addr,
    input m1_as_,
    input m1_rw,
    input [`WordDataBus] m1_wr_data,
    input m1_grnt_,

    input [`WordAddrBus] m2_addr,
    input m2_as_,
    input m2_rw,
    input [`WordDataBus] m2_wr_data,
    input m2_grnt_,

    input [`WordAddrBus] m3_addr,
    input m3_as_,
    input m3_rw,
    input [`WordDataBus] m3_wr_data,
    input m3_grnt_,

    output reg [`WordAddrBus] s_addr,
    output reg s_as_,
    output reg s_rw,
    output reg [`WordDataBus] s_wr_data
);

always @(*) begin
    if (m0_grnt_ == `ENABLE_) begin
        s_addr = m0_addr;
        s_as_ = m0_as_;
        s_rw = m0_rw;
        s_wr_data = m0_wr_data;
    end else if (m1_grnt_ == `ENABLE_) begin
        s_addr = m1_addr;
        s_as_ = m1_as_;
        s_rw = m1_rw;
        s_wr_data = m1_wr_data;
    end else if (m2_grnt_ == `ENABLE_) begin
        s_addr = m2_addr;
        s_as_ = m2_as_;
        s_rw = m2_rw;
        s_wr_data = m2_wr_data;
    end else if (m3_grnt_ == `ENABLE_) begin
        s_addr = m3_addr;
        s_as_ = m3_as_;
        s_rw = m3_rw;
        s_wr_data = m3_wr_data;
    end else begin
        s_addr = `WORD_ADDR_W'h0;
        s_as_ = `DISABLE_;
        s_rw = `READ;
        s_wr_data = `WORD_DATA_W'h0;
    end
end
    
endmodule