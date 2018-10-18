`timescale 1ns / 1ps

import common::*;

module control #(parameter  WIDTH = 64)
  (input opcode_t opcode,
  input logic [2:0] funct7,
  input logic [2:0] funct3,
  input logic zero,
  output control_out_t controlOut);

  //Internal signals definitions
  // logic [1:0] aluOp;
  // logic branch;
  // logic [7:0] controlSignals;
  //
  // assign {aluSrc,memToReg,regWrite,memRead,memWrite,branch,aluOp} = controlSignals;
  // assign pcSrc = branch & zero;
  //
  // //Alu Operation Decoder instance
  // aluDecoder aluDec(aluOp,funct7,funct3,aluControl);
  //
  // //Main controller logic
  // always_comb begin
  //   unique case (opcode)
  //     OPCODE_OP: controlSignals = 8'b00100010; //R-format instruction
  //     OPCODE_LOAD: controlSignals = 8'b11110000; //ld
  //     OPCODE_STORE: controlSignals = 8'b1x001000; //sd
  //     OPCODE_BRANCH: controlSignals = 8'b0x000101; //beq
  //     default: controlSignals = 8'b0x100010; //Illegal opcode REVISAR!!!
  //   endcase
  // end



endmodule
