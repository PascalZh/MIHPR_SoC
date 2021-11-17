`include "stddef.vh"
`include "timer.vh"

module timer #(
    parameter WIDTH = 32
  ) (
    input clk, input rst,
    input cs_, as_, rw,
    input [1:0] addr,
    input [WIDTH-1:0]  wr_data,
    output [WIDTH-1:0] rd_data,
    output rdy_,
    output reg irq
  );
  // ctrl regs
  // set `start` to start counting
  reg mode, start;
  reg [WIDTH-1:0] max_value;
  reg [WIDTH-1:0] counter;

  wire max_flag = start == `ENABLE && counter == max_value ? `ENABLE : `DISABLE;
  wire write_enable = rw == `WRITE && cs_ == `ENABLE_ && as_ == `ENABLE_;

  always @(posedge clk, `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      rd_data <= #1 '0;
      rdy_ <= #1 `DISABLE_;
      irq <= #1 `DISABLE;
      mode <= #1 `TIMER_MODE_ONE_SHOT;
      start <= #1 `DISABLE;
      max_value <= #1 '0;
      counter <= #1 '0;
    end
    else begin
      if (cs_ == `ENABLE_ && as_ == `ENABLE) begin
        rdy_ <= #1 `ENABLE_;
      end
      else begin
        rdy_ <= #1 `DISABLE_;
      end

      if (rw == `READ && cs_ == `ENABLE_ && as_ == `ENABLE_) begin
        case (addr)
          `TIMER_ADDR_CTRL: begin
            rd_data <= #1 {{`TIMER_ADDR_W-2{1'b0}}, mode, start};
          end
          `TIMER_ADDR_INTR: begin
            rd_data <= #1 {{`TIMER_ADDR_W-1{1'b0}}, irq};
          end
          `TIMER_ADDR_MAX_VALUE: begin
            rd_data <= #1 max_value;
          end
          `TIMER_ADDR_COUNTER: begin
            rd_data <= #1 counter;
          end
        endcase
      end
      else begin
        rd_data <= #1 '0;
      end

      if (write_enable && addr == `TIMER_ADDR_CTRL) begin
        start <= #1 wr_data[`TimerStartLoc];
        mode <= #1 wr_data[`TimerModeLoc];
      end
      else if (max_flag && mode == `TIMER_MODE_ONE_SHOT) begin
        start <= #1 `DISABLE;
      end

      if (max_flag) begin
        irq <= #1 `ENABLE;
      end
      else if (write_enable && addr == `TIMER_ADDR_INTR) begin
        irq <= #1 wr_data[`TimerIrqLoc];
      end

      if (write_enable && addr == `TIMER_ADDR_MAX_VALUE) begin
        max_value <= #1 wr_data;
      end

      if (write_enable && addr == `TIMER_ADDR_COUNTER) begin
        counter <= #1 wr_data;
      end
      else if (max_flag) begin
        counter <= #1 '0;
      end
      else if (start) begin
        counter <= #1 counter + 1'd1;
      end
    end
  end

endmodule
