`include "cpu.vh"
`include "bus.vh"

module bus_if (
    input clk, rst,

    pipeline_io.slave pl,
    output reg busy,

    simple_bus_io.slave cpu,

    simple_bus_io.master spm,

    bus_io.master bus
  );

  reg [`WordData] rd_buf;
  reg [`BusIfStateIndex] state;
  wire [`BusSlaveIndex] s_index;

  assign s_index = cpu.addr[`BusSlaveIndexLoc];

  assign spm.addr = cpu.addr;
  assign spm.rw = cpu.rw;
  assign spm.wr_data = cpu.wr_data;

  // read to rd_data: read spm/read bus; interacting with pl
  always @(*) begin
    cpu.rd_data = `WORD_DATA_W'h0;
    spm.as_ = `DISABLE_;
    busy = `DISABLE;

    case (state)
      `BUS_IF_STATE_IDLE: begin
        if ((pl.flush == `DISABLE) && (cpu.as_ == `ENABLE_)) begin
          if (s_index == `BUS_SLAVE_1) begin
            if (pl.stall == `DISABLE) begin
              spm.as_ = `ENABLE_;
              if (cpu.rw == `READ) begin
                cpu.rd_data = spm.rd_data;
              end
            end
          end
          else begin  // accessing bus
            busy = `ENABLE;
          end
        end
      end

      `BUS_IF_STATE_REQ: begin
        busy = `ENABLE;
      end

      // accessing the bus
      `BUS_IF_STATE_ACCESS: begin
        if (bus.rdy_ == `ENABLE_) begin
          if (cpu.rw == `READ) begin
            cpu.rd_data = bus.rd_data;
          end
        end
        else begin
          busy = `ENABLE;
        end
      end

      `BUS_IF_STATE_STALL: begin
        if (cpu.rw == `READ) begin
          cpu.rd_data = rd_buf;
        end
      end
    endcase
  end

  // state machine; interacting with bus: write to bus.wr_data/read to rd_buf
  always @(posedge clk or `RST_EDGE rst) begin
    if (rst == `RST_ENABLE) begin
      state <= #1 `BUS_IF_STATE_IDLE;
      bus.req_  <= #1 `DISABLE_;
      bus.addr <= #1 '0;
      bus.as_ <= #1 `DISABLE_;
      bus.rw <= #1 `READ;
      bus.wr_data <= #1 '0;

      rd_buf <= #1 '0;
    end
    else begin
      case (state)
        // if cpu.as_ is enabled, and accessing the bus, send req_ to bus
        `BUS_IF_STATE_IDLE: begin
          if ((pl.flush == `DISABLE) && (cpu.as_ == `ENABLE_)) begin
            // accessing the bus
            if (s_index != `BUS_SLAVE_1) begin
              state <= #1 `BUS_IF_STATE_REQ;
              bus.req_ <= #1 `ENABLE_;
              bus.addr <= #1 cpu.addr;
              bus.rw <= #1 cpu.rw;
              bus.wr_data <= #1 cpu.wr_data;
            end
          end
        end

        // wait grnt_ to be returned, send as_ to bus
        `BUS_IF_STATE_REQ: begin
          if (bus.grnt_ == `ENABLE_) begin
            state <= #1 `BUS_IF_STATE_ACCESS;
            bus.as_ <= #1 `ENABLE_;
          end
        end

        // wait bus to be ready, then read to rd_buf; check if stall is enabled
        `BUS_IF_STATE_ACCESS: begin
          bus.as_ <= #1 `DISABLE_;
          if (bus.rdy_ == `ENABLE_) begin
            bus.req_ <= #1 `DISABLE_;
            bus.addr <= #1 '0;
            bus.rw <= #1 `READ;
            bus.wr_data <= #1 '0;
            if (bus.rw == `READ) begin
              rd_buf <= #1 bus.rd_data;
            end
            if (pl.stall == `ENABLE) begin
              state <= #1 `BUS_IF_STATE_STALL;
            end
            else begin
              state <= #1 `BUS_IF_STATE_IDLE;
            end
          end
        end

        // Support stall function, allow bus to store to rd_buf, then wait
        // the pl to cancel the stall, since at that time the bus accessing is
        // finished, we need to read the rd_buf
        `BUS_IF_STATE_STALL: begin
          if (pl.stall == `DISABLE) begin
            state <= #1 `BUS_IF_STATE_IDLE;
          end
        end
      endcase
    end
  end

endmodule
