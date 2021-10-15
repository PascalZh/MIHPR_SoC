`include "stddef.h"
`include "global_config.h"
`include "spm.h"
module spm (
         input clk,
         input [`SpmAddrBus] if_spm_addr,
         input if_spm_as_,
         input if_spm_rw,
         input [`WordDataBus] if_spm_wr_data,
         input [`WordDataBus] if_spm_rd_data,

         input [`SpmAddrBus] mem_spm_addr,
         input mem_spm_as_,
         input mem_spm_rw,
         input [`WordDataBus] mem_spm_wr_data,
         input [`WordDataBus] mem_spm_rd_data
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
        .clock_a(clk),
        .address_a (if_spm_addr),
        .data_a (if_spm_wr_data),
        .wren_a (we_a),
        .q_a (if_spm_rd_data),

        .clock_b(clk),
        .address_b (mem_spm_addr),
        .data_b (mem_spm_wr_data),
        .wren_b (we_b),
        .q_b (mem_spm_rd_data)
      );

endmodule
