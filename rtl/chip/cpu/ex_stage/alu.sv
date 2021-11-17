`include "cpu.vh"
`include "isa.vh"
module alu (
    input [`WordData] in_0,
    input [`WordData] in_1,
    input [`AluOp] op,
    output [`WordData] out,
    output overflow
  );

  wire signed [`WordData] s_in_0 = $signed(in_0);
  wire signed [`WordData] s_in_1 = $signed(in_1);
  wire signed [`WordData] s_out = $signed(out);

  always @(*) begin
    case (op)
      `ALU_OP_AND: begin
        out = in_0 & in_1;
      end
      `ALU_OP_OR: begin
        out = in_0 | in_1;
      end
      `ALU_OP_XOR: begin
        out = in_0 ^ in_1;
      end
      `ALU_OP_ADDS: begin
        out = in_0 + in_1;
      end
      `ALU_OP_ADDU: begin
        out = in_0 + in_1;
      end
      `ALU_OP_SUBS: begin
        out = in_0 - in_1;
      end
      `ALU_OP_SUBU: begin
        out = in_0 - in_1;
      end
      `ALU_OP_SHRL: begin
        out = in_0 >> in_1[`ShAmountLoc];
      end
      `ALU_OP_SHLL: begin
        out = in_0 << in_1[`ShAmountLoc];
      end
      default: begin
        out = in_0;
      end
    endcase
  end

  always @(*) begin
    case (op)
      `ALU_OP_ADDS: begin
        if (s_in_0 > 0 && s_in_1 > 0 && s_out < 0 ||
            s_in_0 < 0 && s_in_1 < 0 && s_out > 0) begin

          overflow = `ENABLE;
        end
        else
          overflow = `DISABLE;
      end
      `ALU_OP_SUBS: begin
        if (s_in_0 < 0 && s_in_1 > 0 && s_out > 0 ||
            s_in_0 > 0 && s_in_1 < 0 && s_out < 0) begin

          overflow = `ENABLE;
        end
        else
          overflow = `DISABLE;
      end
      default: begin
        overflow = `DISABLE;
      end
    endcase
  end

endmodule
