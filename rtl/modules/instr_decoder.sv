import Common::*;

module instr_decoder (input Common::raw_instr_t raw_instr_i,
                      output Common::decoded_instr_t instr_o,
                      output logic [31:0] imm_o);

    instr_type_t instr_type;
    logic [4:0] opcode;
    assign opcode = raw_instr_i[6:2];

    always_comb begin
        instr_type = instr_type_R;
        case (opcode)
          5'b00000: instr_type = instr_type_I;//RiscV32I
          5'b00011: instr_type = instr_type_I;//RiscV32I
          5'b00100: instr_type = instr_type_I;//RiscV32I
          5'b00101: instr_type = instr_type_U;//RiscV32I
          5'b01000: instr_type = instr_type_S;//RiscV32I
          5'b01100: instr_type = instr_type_R;//RiscV32I-RiscV32M    ----------------------------------------------------?????
          5'b01101: instr_type = instr_type_U;//RiscV32I
          5'b11000: instr_type = instr_type_SB;//RiscV32I
          5'b10001: instr_type = instr_type_I;//RiscV32D	---------------------------------------------------------------?????
          5'b11011: instr_type = instr_type_UJ;//RiscV32I
  		  5'b11001: instr_type = instr_type_I;//RiscV32I
          5'b11100: instr_type = instr_type_I;//RiscV32I_privileged
          default: begin
          end
        endcase
    end

    always_comb begin
        instr_o = 0;
        instr_o.opcode = opcode;
        imm_o = 0;
        case (instr_type)
            instr_type_I: begin
                imm_o = 32'(signed'(raw_instr_i[31:20]));
                instr_o.rs1 = raw_instr_i[19:15];
                instr_o.funct3 = raw_instr_i[14:12];
                instr_o.rd = raw_instr_i[11:7];
            end
            instr_type_U: begin
                imm_o[31:12] = raw_instr_i[31:12];
                instr_o.rd = raw_instr_i[11:7];
            end
            instr_type_R: begin
                instr_o.funct7 = raw_instr_i[31:25];
                instr_o.rs2 = raw_instr_i[24:20];
                instr_o.rs1 = raw_instr_i[19:15];
                instr_o.funct3 = raw_instr_i[14:12];
                instr_o.rd = raw_instr_i[11:7];
            end
            instr_type_S: begin
                // imm_o[11:5] = raw_instr_i[31:25];
                // imm_o[4:0] = raw_instr_i[11:7];
                imm_o = 32'(signed'({raw_instr_i[31:25],raw_instr_i[11:7]}));
                instr_o.rs2 = raw_instr_i[24:20];
                instr_o.rs1 = raw_instr_i[19:15];
                instr_o.funct3 = raw_instr_i[14:12];
            end
            instr_type_SB: begin
                imm_o[12]= raw_instr_i[31];
                imm_o[10:5] = raw_instr_i[30:25];
                imm_o[4:1] = raw_instr_i[11:8];
                imm_o[11]= raw_instr_i[7];
                imm_o[0] = 0;
                imm_o = 32'(signed'(imm_o[12:0]));
                instr_o.rs2 = raw_instr_i[24:20];
                instr_o.rs1 = raw_instr_i[19:15];
                instr_o.funct3 = raw_instr_i[14:12];
            end
            instr_type_UJ: begin
                imm_o[20]= raw_instr_i[31];
                imm_o[10:1] = raw_instr_i[30:21];
                imm_o[11]= raw_instr_i[20];
                imm_o[19:12] = raw_instr_i[19:12];
                imm_o[0] = 0;
                imm_o = 32'(signed'(imm_o[20:0]));
                instr_o.rd = raw_instr_i[11:7];
            end
            default: begin

            end
        endcase
    end
endmodule // instr_decoder
