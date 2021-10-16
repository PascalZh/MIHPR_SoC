`include "stddef.v"
`include "bus.v"

module bus_slave_mux (
    input s0_cs_,
    input [`WordDataBus] s0_rd_data,
    input s0_rdy_,

    input s1_cs_,
    input [`WordDataBus] s1_rd_data,
    input s1_rdy_,

    input s2_cs_,
    input [`WordDataBus] s2_rd_data,
    input s2_rdy_,

    input s3_cs_,
    input [`WordDataBus] s3_rd_data,
    input s3_rdy_,

    input s4_cs_,
    input [`WordDataBus] s4_rd_data,
    input s4_rdy_,

    input s5_cs_,
    input [`WordDataBus] s5_rd_data,
    input s5_rdy_,

    input s6_cs_,
    input [`WordDataBus] s6_rd_data,
    input s6_rdy_,

    input s7_cs_,
    input [`WordDataBus] s7_rd_data,
    input s7_rdy_,

    output reg [`WordDataBus] m_rd_data,
    output reg m_rdy_
);

always @(*) begin
    if (s0_cs_ == `ENABLE_) begin
        m_rd_data = s0_rd_data;
        m_rdy_ = s0_rdy_;
    end else if (s1_cs_ == `ENABLE_) begin
        m_rd_data = s1_rd_data;
        m_rdy_ = s1_rdy_;
    end else if (s2_cs_ == `ENABLE_) begin
        m_rd_data = s2_rd_data;
        m_rdy_ = s2_rdy_;
    end else if (s3_cs_ == `ENABLE_) begin
        m_rd_data = s3_rd_data;
        m_rdy_ = s3_rdy_;
    end else if (s4_cs_ == `ENABLE_) begin
        m_rd_data = s4_rd_data;
        m_rdy_ = s4_rdy_;
    end else if (s5_cs_ == `ENABLE_) begin
        m_rd_data = s5_rd_data;
        m_rdy_ = s5_rdy_;
    end else if (s6_cs_ == `ENABLE_) begin
        m_rd_data = s6_rd_data;
        m_rdy_ = s6_rdy_;
    end else if (s7_cs_ == `ENABLE_) begin
        m_rd_data = s7_rd_data;
        m_rdy_ = s7_rdy_;
    end else begin
        m_rd_data = `WORD_DATA_W'h0;
        m_rdy_ = `DISABLE_;
    end
end

endmodule