`timescale 1ns / 1ps

module alu #(parameter  WIDTH = 32)
  (input alu_control_t aluControl,
  input logic [WIDTH-1:0] src1, src2,
  input logic [4:0] shamt,
  output logic [WIDTH-1:0] result,
  output logic zero);

  assign zero = (result == 0) ? 1 : 0;

  always_comb begin
    case (aluControl)
      ALU_AND: result = src1 & src2;
      ALU_OR: result = src1 | src2;
      ALU_XOR: result = src1 ^ src2;
      ALU_ADD: result = src1 + src2;
      ALU_SUB: result = src1 - src2;
      ALU_SLL: result = src1 << shamt;
      ALU_SRL: result = src1 >> shamt;
      ALU_SLA: result = $signed(src1) <<< shamt;
      ALU_SRA: result = $signed(src1) >>> shamt;
      default: result = 'x;
    endcase
  end

endmodule
