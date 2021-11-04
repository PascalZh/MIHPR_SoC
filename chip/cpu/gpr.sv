`include "cpu.vh"

interface gpr_rd_bus_io;
  logic [`GprAddr] addr_0, addr_1;
  logic [`WordData] data_0, data_1;
  modport master(
            input data_0, data_1,
            output addr_0, addr_1
          );
  modport slave(
            input addr_0, addr_1,
            output data_0, data_1
          );
endinterface // gpr_rd_bus_io

interface gpr_wr_bus_io;
  logic [`GprAddr] addr;
  logic [`WordData] data;
  logic we_;
  modport master(
            output addr,
            output data,
            output we_
          );
  modport slave(
            input data,
            input addr,
            input we_
          );
endinterface // gpr_wr_bus_io

module gpr (
    input clk,
    input rst,
    gpr_rd_bus_io.slave rd,
    gpr_wr_bus_io.slave wr
  );

  reg [`WordData] gpr[`GPR_NUM];

  // Read logic

  // Return wr_data directly when read and write at the same time, otherwise gpr[rd_addr_0]
  assign rd.data_0 = ((wr.we_ == `ENABLE_) && (rd.addr_0 == wr.addr)) ? wr.data : gpr[rd.addr_0];
  assign rd.data_1 = ((wr.we_ == `ENABLE_) && (rd.addr_1 == wr.addr)) ? wr.data : gpr[rd.addr_1];

  // Write logic

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      for (int i = 0; i < `GPR_NUM; i = i + 1) begin
        gpr[i] <= #1 `WORD_DATA_W'h0;
      end
    end
    else begin
      if (wr.we_ == `ENABLE_) begin
        gpr[wr.addr] <= #1 wr.data;
      end
    end
  end

endmodule
