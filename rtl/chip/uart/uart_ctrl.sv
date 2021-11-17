`include "stddef.vh"
`include "uart.vh"

module uart_ctrl (
    input clk, rst,
    input cs_,
    output reg rdy_,
    simple_bus_io.slave bus,
    output irq_rx, irq_tx,
    input rx_busy, rx_end,
    input [7:0] rx_data,
    input tx_busy, tx_end,
    output reg tx_start,
    output reg [7:0] tx_data
  );

  reg [7:0] rx_buf;
  wire rw_en = cs_ == `ENABLE_ && bus.as_ == `ENABLE_;

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      bus.rd_data = '0;
      rdy_ = `DISABLE_;
      irq_rx = `DISABLE;
      irq_tx = `DISABLE;
      rx_buf = '0;
      tx_start = `DISABLE;
      tx_data = '0;
    end
    else begin
      if (rw_en) begin
        rdy_ = `ENABLE_;
      end
      else begin
        rdy_ = `DISABLE_;
      end

      if (bus.rw == `READ && rw_en) begin
        case (bus.addr)
          `UART_ADDR_STATUS: begin
            bus.rd_data = {{`WORD_DATA_W-4{1'b0}}, tx_busy, rx_busy, irq_tx, irq_rx};
          end
          `UART_ADDR_DATA: begin
            bus.rd_data = {{`BYTE_DATA_W*3{1'b0}}, rx_buf};
          end
        endcase
      end

      if (tx_end == `ENABLE) begin
        irq_tx = `ENABLE;
      end
      else if (bus.rw == `WRITE && rw_en && bus.addr == `UART_ADDR_STATUS) begin
        irq_tx = bus.wr_data[`UartCtrlIrqTx];
      end

      if (rx_end == `ENABLE) begin
        irq_rx = `ENABLE;
      end
      else if (bus.rw == `WRITE && rw_en && bus.addr == `UART_ADDR_STATUS) begin
        irq_rx = bus.wr_data[`UartCtrlIrqRx];
      end

      if (bus.rw == `WRITE && rw_en && bus.addr == `UART_ADDR_DATA) begin
        tx_start = `ENABLE;
        tx_data = bus.wr_data[`BYTE_MSB:`LSB];
      end
      else begin
        tx_start = `DISABLE;
        tx_data = `BYTE_DATA_W'h0;
      end

      if (rx_end == `ENABLE) begin
        rx_buf = rx_data;
      end
    end
  end

endmodule
