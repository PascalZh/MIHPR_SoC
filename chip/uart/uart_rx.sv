`include "stddef.vh"
`include "uart.vh"

module uart_rx (
    input clk, rst,
    output rx_busy,
    output reg rx_end,
    output reg [7:0] rx_data,

    input rx
  );

  reg state;
  reg [`UartDivCnt] div_cnt;
  reg [`UartBitCnt] bit_cnt;

  assign rx_busy = state != `UART_STATE_IDLE ? `ENABLE : `DISABLE;

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      rx_end <= #1 `DISABLE;
      rx_data <= #1 '0;
      state <= #1 `UART_STATE_IDLE;
      div_cnt <= #1 `UART_DIV_RATE / 2;
      bit_cnt <= #1 '0;
    end
    else begin
      case (state)
        `UART_STATE_IDLE: begin
          if (rx == `UART_START_BIT) begin
            state <= #1 `UART_STATE_RX;
          end
          rx_end <= #1 `DISABLE;
        end
        `UART_STATE_RX: begin
          if (div_cnt == '0) begin
            case (bit_cnt)
              `UART_BIT_CNT_STOP: begin
                state <= #1 `UART_STATE_IDLE;
                bit_cnt <= #1 `UART_BIT_CNT_START;
                div_cnt <= #1 `UART_DIV_RATE / 2;
                if (rx == `UART_STOP_BIT) begin
                  rx_end <= #1 `ENABLE;
                end
              end
              default: begin
                rx_data <= #1 {rx, rx_data[`BYTE_MSB:`LSB+1]};
                bit_cnt <= #1 bit_cnt + 1'b1;
                div_cnt <= #1 `UART_DIV_RATE;
              end
            endcase
          end
          else begin
            div_cnt <= #1 div_cnt - 1'b1;
          end
        end
      endcase
    end
  end

endmodule
