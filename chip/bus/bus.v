`include "stddef.h"
`include "bus.h"

module bus(
    input clk,
    input rst,

    // master signals
    input m0_req_,
    input m1_req_,
    input m2_req_,
    input m3_req_,

    output m0_grnt_,
    output m1_grnt_,
    output m2_grnt_,
    output m3_grnt_,

    input [`WordAddrBus] m0_addr,
    input [`WordAddrBus] m1_addr,
    input [`WordAddrBus] m2_addr,
    input [`WordAddrBus] m3_addr,

    input m0_as_,
    input m1_as_,
    input m2_as_,
    input m3_as_,

    input m0_rw,
    input m1_rw,
    input m2_rw,
    input m3_rw,

    input [`WordDataBus] m0_wr_data,
    input [`WordDataBus] m1_wr_data,
    input [`WordDataBus] m2_wr_data,
    input [`WordDataBus] m3_wr_data,

    output [`WordDataBus] m_rd_data,
    output m_rdy_,

    // slave signals
    output [`WordAddrBus] s_addr,
    output s_as_,
    output s_rw,
    output [`WordDataBus] s_wr_data,

    output s0_cs_,
    output s1_cs_,
    output s2_cs_,
    output s3_cs_,
    output s4_cs_,
    output s5_cs_,
    output s6_cs_,
    output s7_cs_,

    input [`WordDataBus] s0_rd_data,
    input [`WordDataBus] s1_rd_data,
    input [`WordDataBus] s2_rd_data,
    input [`WordDataBus] s3_rd_data,
    input [`WordDataBus] s4_rd_data,
    input [`WordDataBus] s5_rd_data,
    input [`WordDataBus] s6_rd_data,
    input [`WordDataBus] s7_rd_data,

    input s0_rdy_,
    input s1_rdy_,
    input s2_rdy_,
    input s3_rdy_,
    input s4_rdy_,
    input s5_rdy_,
    input s6_rdy_,
    input s7_rdy_
    );

bus_arbiter bus_arbiter(
    .clk(clk),
    .rst(rst),
    .m0_req_(m0_req_),
    .m1_req_(m1_req_),
    .m2_req_(m2_req_),
    .m3_req_(m3_req_),
    .m0_grnt_(m0_grnt_),
    .m1_grnt_(m1_grnt_),
    .m2_grnt_(m2_grnt_),
    .m3_grnt_(m3_grnt_)
);

bus_master_mux bus_master_mux(
    .m0_grnt_(m0_grnt_),
    .m1_grnt_(m1_grnt_),
    .m2_grnt_(m2_grnt_),
    .m3_grnt_(m3_grnt_),

    .m0_addr(m0_addr),
    .m1_addr(m1_addr),
    .m2_addr(m2_addr),
    .m3_addr(m3_addr),

    .m0_as_(m0_as_),
    .m1_as_(m1_as_),
    .m2_as_(m2_as_),
    .m3_as_(m3_as_),

    .m0_rw(m0_rw),
    .m1_rw(m1_rw),
    .m2_rw(m2_rw),
    .m3_rw(m3_rw),

    .m0_wr_data(m0_wr_data),
    .m1_wr_data(m1_wr_data),
    .m2_wr_data(m2_wr_data),
    .m3_wr_data(m3_wr_data),

    .s_addr(s_addr),
    .s_as_(s_as_),
    .s_rw(s_rw),
    .s_wr_data(s_wr_data)
);

bus_addr_dec bus_addr_dec(
    .s_addr(s_addr),
    .s0_cs_(s0_cs_),
    .s1_cs_(s1_cs_),
    .s2_cs_(s2_cs_),
    .s3_cs_(s3_cs_),
    .s4_cs_(s4_cs_),
    .s5_cs_(s5_cs_),
    .s6_cs_(s6_cs_),
    .s7_cs_(s7_cs_)
);

bus_slave_mux bus_slave_mux(
    .s0_cs_(s0_cs_),
    .s1_cs_(s1_cs_),
    .s2_cs_(s2_cs_),
    .s3_cs_(s3_cs_),
    .s4_cs_(s4_cs_),
    .s5_cs_(s5_cs_),
    .s6_cs_(s6_cs_),
    .s7_cs_(s7_cs_),

    .m_rd_data(m_rd_data),
    .m_rdy_(m_rdy_),

    .s0_rd_data(s0_rd_data),
    .s1_rd_data(s1_rd_data),
    .s2_rd_data(s2_rd_data),
    .s3_rd_data(s3_rd_data),
    .s4_rd_data(s4_rd_data),
    .s5_rd_data(s5_rd_data),
    .s6_rd_data(s6_rd_data),
    .s7_rd_data(s7_rd_data),

    .s0_rdy_(s0_rdy_),
    .s1_rdy_(s1_rdy_),
    .s2_rdy_(s2_rdy_),
    .s3_rdy_(s3_rdy_),
    .s4_rdy_(s4_rdy_),
    .s5_rdy_(s5_rdy_),
    .s6_rdy_(s6_rdy_),
    .s7_rdy_(s7_rdy_)
);

endmodule