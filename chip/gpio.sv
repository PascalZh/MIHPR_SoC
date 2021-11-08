`include "stddef.vh"
`include "gpio.vh"

module gpio (
    input clk, rst,
    input cs_,
    simple_bus_io.slave bus,
    output reg rdy_,

    input [`GPIO_IN_W-1:0] gpio_in,
    output reg [`GPIO_OUT_W-1:0] gpio_out,
    inout [`GPIO_IO_W-1:0] gpio_io
  );

`ifdef GPIO_IO_W
  wire [`GPIO_IO_W-1:0] io_in;
  reg [`GPIO_IO_W-1:0] io_out;
  reg [`GPIO_IO_W-1:0] io_dir;

  assign io_in = gpio_io;

  generate
    genvar i;
    for (i = 0; i < `GPIO_IO_W; i = i + 1) begin: IO_DIR
      assign gpio_io[i] = io_dir[i] == `GPIO_DIR_IN ? 1'bz : io_out[i];
    end
  endgenerate
`endif

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      bus.rd_data <= #1 '0;
      rdy_ <= #1 `DISABLE;
`ifdef GPIO_OUT_W
      gpio_out <= #1 {`GPIO_OUT_W{`LOW}};
`endif
`ifdef GPIO_IO_W
      io_out <= #1 {`GPIO_IO_W{`LOW}};
      io_dir <= #1 {`GPIO_IO_W{`GPIO_DIR_IN}};
`endif
    end else begin
      if (cs_ == `ENABLE_ && bus.as_ == `ENABLE_) begin
        rdy_ <= #1 `ENABLE_;
      end else begin
        rdy_ <= #1 `DISABLE_;
      end

      if (cs_ == `ENABLE_ && bus.as_ == `ENABLE_ && bus.rw == `READ) begin
        case (bus.addr)
`ifdef GPIO_IN_W
          `GPIO_ADDR_IN_DATA: begin
            bus.rd_data <= #1 {{`WORD_DATA_W-`GPIO_IN_W{1'b0}}, gpio_in};
          end
`endif
`ifdef GPIO_OUT_W
          `GPIO_ADDR_OUT_DATA: begin
            bus.rd_data <= #1 {{`WORD_DATA_W-`GPIO_OUT_W{1'b0}}, gpio_out};
          end
`endif
`ifdef GPIO_IO_W
          `GPIO_ADDR_IO_DATA: begin
            bus.rd_data <= #1 {{`WORD_DATA_W-`GPIO_IO_W{1'b0}}, io_in};
          end
          `GPIO_ADDR_IO_DIR: begin
            bus.rd_data <= #1 {{`WORD_DATA_W-`GPIO_IO_W{1'b0}}, io_dir};
          end
`endif
        endcase
      end else begin
        bus.rd_data <= #1 '0;
      end
      if (cs_ == `ENABLE_ && bus.as_ == `ENABLE_ && bus.rw == `WRITE) begin
        case (bus.addr)
`ifdef GPIO_OUT_W
          `GPIO_ADDR_OUT_DATA: begin
            gpio_out <= #1 bus.wr_data[`GPIO_OUT_W-1:0];
          end
`endif
`ifdef GPIO_IO_W
          `GPIO_ADDR_IO_DATA: begin
            io_out <= #1 bus.wr_data[`GPIO_IO_W-1:0];
          end
          `GPIO_ADDR_IO_DIR: begin
            io_dir <= #1 bus.wr_data[`GPIO_IO_W-1:0];
          end
`endif
        endcase
      end
    end
  end

endmodule
