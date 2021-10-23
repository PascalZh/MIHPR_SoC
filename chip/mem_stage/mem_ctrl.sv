`include "cpu.vh"
`include "isa.vh"

module mem_ctrl (
    input ex_en,
    input [`MemOp] ex_mem_op,
    input [`WordData] ex_mem_wr_data,
    // the data is the address
    input [`WordData] ex_data_in,

    simple_bus_io.master mem,
    output [`WordData] out,
    output miss_align
  );

  assign mem.addr = ex_data_in[`WordAddrLoc];
  wire [`ByteOffset] offset = ex_data_in[`ByteOffsetLoc];
  assign mem.wr_data = ex_mem_wr_data;

  always @(*) begin
    miss_align = `DISABLE;
    out = '0;
    mem.as_ = `DISABLE_;
    mem.rw = `READ;
    if (ex_en == `ENABLE) begin
      case (ex_mem_op)
        `MEM_OP_LDW: begin
          if (offset == `BYTE_OFFSET_WORD) begin
            out = mem.rd_data;
            mem.as_ = `ENABLE_;
          end
          else begin
            miss_align = `ENABLE;
          end
        end
        `MEM_OP_STW: begin
          if (offset == `BYTE_OFFSET_WORD) begin
            mem.rw = `WRITE;
            mem.as_ = `ENABLE_;
          end
          else begin
            miss_align = `ENABLE;
          end
        end
        default: begin
          out = ex_data_in;
        end
      endcase
    end
  end

endmodule
