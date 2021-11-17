`include "stddef.vh"
`include "uart.vh"

module uart_tx (
    input clk, rst,
    input tx_start,
    input [7:0] tx_data,
    output tx_busy,
    output reg tx_end,

    output reg tx
  );

  reg state;
  // every time div_cnt is finished, bit_cnt is added by 1
  reg [`UartDivCnt] div_cnt;
  reg [`UartBitCnt] bit_cnt;
  reg [7:0] sh_reg;

  assign tx_busy = state == `UART_STATE_TX ? `ENABLE : `DISABLE;

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      state <= #1 `UART_STATE_IDLE;
      div_cnt <= #1 `UART_DIV_RATE;
      bit_cnt <= #1 `UART_BIT_CNT_START;
      sh_reg <= #1 '0;
      tx_end <= #1 `DISABLE;
      tx <= #1 `UART_STOP_BIT;
    end
    else begin
      case (state)
        `UART_STATE_IDLE: begin
          if (tx_start == `ENABLE) begin
            state <= #1 `UART_STATE_TX;
            sh_reg <= #1 tx_data;
            tx <= #1 `UART_START_BIT;
          end
          tx_end <= #1 `DISABLE;
        end
        `UART_STATE_TX: begin
          if (div_cnt == '0) begin
            div_cnt <= #1 `UART_DIV_RATE;
            case (bit_cnt)
              `UART_BIT_CNT_MSB: begin
                bit_cnt <= #1 `UART_BIT_CNT_STOP;
                tx <= #1 `UART_STOP_BIT;
              end
              `UART_BIT_CNT_STOP: begin
                state <= #1 `UART_STATE_IDLE;
                bit_cnt <= #1 `UART_BIT_CNT_START;
                tx_end <= #1 `ENABLE;
              end
              default: begin
                bit_cnt <= #1 bit_cnt + 1'b1;
                sh_reg <= #1 sh_reg >> 1'b1;
                tx <= #1 sh_reg[`LSB];
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
