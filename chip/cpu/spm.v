`include "stddef.vh"
`include "global_config.vh"
`include "spm.vh"

module spm (
    input clk,

    input [`SpmAddrBus] if_spm_addr,
    input if_spm_as_,
    input if_spm_rw,
    input [`WordData] if_spm_wr_data,
    output [`WordData] if_spm_rd_data,

    input [`SpmAddrBus] mem_spm_addr,
    input mem_spm_as_,
    input mem_spm_rw,
    input [`WordData] mem_spm_wr_data,
    output [`WordData] mem_spm_rd_data
  );

  // port A for IF, port B for MEM
  reg we_a, we_b;

  // Write enable
  always @(*) begin
    if ((if_spm_as_ == `ENABLE_) && (if_spm_rw == `WRITE)) begin
      we_a = `MEM_ENABLE;
    end
    else begin
      we_a = `MEM_DISABLE;
    end

    if ((mem_spm_as_ == `ENABLE_) && (mem_spm_rw == `WRITE)) begin
      we_b = `MEM_ENABLE;
    end
    else begin
      we_b = `MEM_DISABLE;
    end
  end

  dpram dpram(
          .clock (clk),

          .address_a (if_spm_addr),
          .data_a (if_spm_wr_data),
          .wren_a (we_a),
          .q_a (if_spm_rd_data),

          .address_b (mem_spm_addr),
          .data_b (mem_spm_wr_data),
          .wren_b (we_b),
          .q_b (mem_spm_rd_data)
        );

endmodule
