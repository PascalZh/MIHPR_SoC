`include "../../include/stddef.h"
`include "../../include/bus.h"
module bus_arbiter (
    input rst,
    input clk,
    input m0_req_,
    input m1_req_,
    input m2_req_,
    input m3_req_,
    output reg m0_grnt_,
    output reg m1_grnt_,
    output reg m2_grnt_,
    output reg m3_grnt_
);

reg [`BusOwnerBus] owner;

// owner --> grnt_
always @(*) begin
    m0_grnt_ = `DISABLE_;
    m1_grnt_ = `DISABLE_;
    m2_grnt_ = `DISABLE_;
    m3_grnt_ = `DISABLE_;

    case (owner)
        `BUS_MASTER_0: m0_grnt_ = `ENABLE_;
        `BUS_MASTER_1: m1_grnt_ = `ENABLE_;
        `BUS_MASTER_2: m2_grnt_ = `ENABLE_;
        `BUS_MASTER_3: m3_grnt_ = `ENABLE_;
    endcase
end

// arbit the owner
always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
        owner <= #1 0;
    end else begin
        case (owner)
            `BUS_MASTER_0: begin
                if (m0_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_0;
                end else if (m1_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_1;
                end else if (m2_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_2;
                end else if (m3_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_3;
                end
            end
            `BUS_MASTER_1: begin
                if (m1_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_1;
                end else if (m2_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_2;
                end else if (m3_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_3;
                end else if (m0_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_0;
                end
            end
            `BUS_MASTER_2: begin
                if (m2_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_2;
                end else if (m3_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_3;
                end else if (m0_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_0;
                end else if (m1_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_1;
                end
            end
            `BUS_MASTER_3: begin
                if (m3_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_3;
                end else if (m0_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_0;
                end else if (m1_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_1;
                end else if (m2_req_ == `ENABLE_) begin
                    owner <= #1 `BUS_MASTER_2;
                end
            end
        endcase
    end
end

endmodule