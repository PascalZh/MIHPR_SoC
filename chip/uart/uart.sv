`include "stddef.vh"
`include "uart.vh"

module uart (
    input clk, rst,
    input cs_,
    output rdy_,
    simple_bus_io.slave bus,

    output irq_tx,
    output irq_rx,

    output tx,
    input rx
  );

  reg [7:0] tx_data;
  reg [7:0] rx_data;
  reg tx_start, tx_busy, tx_end;
  reg rx_busy, rx_end;

  uart_ctrl uart_ctrl(.*);

  uart_tx uart_tx(.*);
  uart_rx uart_rx(.*);
endmodule
