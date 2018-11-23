import Common::*;

module control_unit (input logic clk,
                     input              decoded_instr_t instr_i,
                     input logic [31:0] imm_i,
                     input logic        decode,
                     output             control_out_t control_o);

   control_out_t control_next;

   always_ff @(posedge clk) begin
      if (decode) begin
         control_o <= control_next;
      end
   end

   always_comb begin
      control_next = 0;
      control_next.instType = MEM_NOP;
      control_next.reg_write = 0;
      control_next.rd = instr_i.rd;
      control_next.rs1 = instr_i.rs1;
      control_next.rs2 = instr_i.rs2;

      unique case (instr_i.opcode)
        5'b00000: begin //LOAD'S
           control_next.mem_to_reg = 1;
           control_next.alu_from_imm = 1;
           control_next.alu_op = ALU_add;
           control_next.reg_write = 1;
           case (instr_i.funct3)
             3'b000: begin
                control_next.instType = MEM_LB;
             end
             3'b001: begin
                control_next.instType = MEM_LH;
             end
             3'b010: begin
                control_next.instType = MEM_LW;
             end
             3'b100: begin
                control_next.instType = MEM_LBU;
             end
             3'b101: begin
                control_next.instType = MEM_LHU;
             end
             default: begin
                control_next.inst_invalid = 1;
                control_next.instType = MEM_NOP;
                control_next.excCause = 32'h2;
             end
           endcase
        end
        5'b00011: begin //FENCE/FENCEI implemened like a NOP
           control_next.alu_op = ALU_add;
           control_next.instType = MEM_NOP;
        end
        5'b00100: begin//ARITHMETIC INM
           control_next.alu_from_imm = 1;
           control_next.reg_write = 1;
           control_next.instType = MEM_NOP;
           case(instr_i.funct3)
             3'b000: begin
                control_next.alu_op = ALU_add;
             end
             3'b001: begin
                control_next.alu_op = ALU_sll;
             end
             3'b010: begin
                control_next.alu_op = ALU_slt;
             end
             3'b011: begin
                control_next.alu_op = ALU_sltu;
             end
             3'b100: begin
                control_next.alu_op = ALU_xor;
             end
             3'b101: begin
                //case(instr_i.imm[10])
                case(imm_i[10])
                  1'b0: begin
                     control_next.alu_op = ALU_srl;
                  end
                  1'b1: begin
                     control_next.alu_op = ALU_sra;
                  end
                endcase
             end
             3'b110: begin
                control_next.alu_op = ALU_or;
             end
             3'b111: begin
                control_next.alu_op = ALU_and;
             end
             default:
               begin
                  control_next.inst_invalid = 1;
                  control_next.excCause = 32'h2;
               end
           endcase
        end
        5'b00101: begin//AUIPC
           control_next.alu_from_pc = 1;
           control_next.alu_from_imm = 1;
           control_next.alu_op = ALU_add;
           control_next.reg_write = 1;
           control_next.instType = MEM_NOP;
        end
        5'b01000: begin//STORE'S
           control_next.alu_from_imm = 1;
           control_next.alu_op = ALU_add;
           case (instr_i.funct3)
             3'b000: begin
                control_next.instType = MEM_SB;
             end
             3'b001: begin
                control_next.instType = MEM_SH;
             end
             3'b010: begin
                control_next.instType = MEM_SW;
             end
             default: begin
                control_next.inst_invalid = 1;
                control_next.instType = MEM_NOP;
                control_next.excCause[30:0] = 31'h2;
             end
           endcase
        end
        5'b01100: begin//ARITHMETIC
           control_next.reg_write = 1;
           control_next.instType = MEM_NOP;
           case (instr_i.funct3)
             3'b000: begin
                case(instr_i.funct7[5])
                  1'b0: begin
                     control_next.alu_op = ALU_add;
                  end
                  1'b1: begin
                     control_next.alu_op = ALU_sub;
                  end
                endcase
             end
             3'b001: begin
                control_next.alu_op = ALU_sll;
             end
             3'b010: begin
                control_next.alu_op = ALU_slt;
             end
             3'b011: begin
                control_next.alu_op = ALU_sltu;
             end
             3'b100: begin
                control_next.alu_op = ALU_xor;
             end
             3'b101: begin
                case(instr_i.funct7[5])
                  1'b0: begin
                     control_next.alu_op = ALU_srl;
                  end
                  1'b1: begin
                     control_next.alu_op = ALU_sra;
                  end
                endcase
             end
             3'b110: begin
                control_next.alu_op = ALU_or;
             end
             3'b111: begin
                control_next.alu_op = ALU_and;
             end
             default:
               begin
                  control_next.inst_invalid = 1;
                  control_next.excCause = 32'h2;
               end
           endcase
        end
        5'b01101: begin//LOAD INM
           control_next.instType = MEM_NOP;
           control_next.regData = 2'b11;
           control_next.alu_from_imm = 1;
           control_next.alu_op = ALU_add;
           control_next.reg_write = 1;
        end
        5'b11000: begin//BRANCH'S
           control_next.instType = MEM_NOP;
           control_next.is_branch = 1'b1;
           case (instr_i.funct3)
             3'b000: begin
                control_next.alu_op = ALU_ce;
             end
             3'b001: begin
                control_next.alu_op = ALU_cne;
             end
             3'b100: begin
                control_next.alu_op = ALU_slt;
             end
             3'b101: begin
                control_next.alu_op = ALU_cge;
             end
             3'b110: begin
                control_next.alu_op = ALU_sltu;
             end
             3'b111: begin
                control_next.alu_op = ALU_cgeu;
             end
             default:
               begin
                  control_next.inst_invalid = 1;
                  control_next.excCause = 32'h2;
               end
           endcase
        end
        5'b11001: begin//JALR
           control_next.regData = 2'b01;
           control_next.alu_from_imm = 1;
           control_next.alu_op = ALU_add;
           control_next.reg_write = 1;
           control_next.instType = MEM_NOP;
           control_next.is_jalr = 1'b1;
        end
        5'b11011: begin//JAL
           control_next.alu_from_pc = 1;
           control_next.regData = 2'b01;
           control_next.alu_from_imm = 1;
           control_next.alu_op = ALU_add;
           control_next.reg_write = 1;
           control_next.instType = MEM_NOP;
           control_next.is_jal = 1'b1;
        end
        5'b11100: begin // SYSTEM Estan completadas un poco, falta ver que pasa si rs1=0x00 o rd=0x00
           control_next.instType = MEM_NOP;
           control_next.alu_op = ALU_add;
           case (instr_i.funct3)
             3'b000: begin
                //case(instr_i.imm[2:0])
                case(imm_i[2:0])
                  3'b000://ECALL
                    begin
                       control_next.inst_priv = 1;
                       control_next.excRet = 1'b0;
                       control_next.excRequest = 1;
                       control_next.csr_source = 0;
                       control_next.regData = 2'b10;
                       control_next.reg_write = 0;
                       control_next.excCause = 32'd11;
                    end
                  3'b001://EBREAK
                    begin
                       control_next.inst_priv = 1;
                       control_next.excRet = 1'b0;
                       control_next.excRequest = 1;
                       control_next.csr_source=0;
                       control_next.regData = 2'b10;
                       control_next.reg_write = 0;
                       control_next.excCause = 32'h3;
                       control_next.excRet = 1'b0;
                    end
                  3'b010://MRET
                    begin
                       control_next.csr_source=0;
                       control_next.regData = 2'b10;
                       control_next.reg_write = 0;
                       control_next.csr_op = riscV_unrn_pkg::CSRRNOP;
                       control_next.excRet = 1'b1;
                    end
                  3'b101://WFI
                    begin
                       control_next.csr_source=0;
                       control_next.regData = 2'b10;
                       control_next.reg_write = 0;
                       control_next.csr_op = riscV_unrn_pkg::CSRRNOP;
                       control_next.excRet = 1'b0;
                    end
                  default:
                    begin
                       control_next.inst_invalid = 1;
                       control_next.excRet = 1'b0;
                       control_next.excCause = 32'h2;
                    end
                endcase
             end
             3'b001: begin
                //riscV_unrn_pkg::CSRRW
                control_next.excRet = 1'b0;
                control_next.csr_source= 1;
                control_next.regData = 2'b10;
                control_next.reg_write = 1;
                control_next.csr_op = riscV_unrn_pkg::CSRRW;
                control_next.excRet = 1'b0;
             end
             3'b010: begin
                //riscV_unrn_pkg::CSRRS
                control_next.excRet = 1'b0;
                control_next.csr_source = 1;
                control_next.regData = 2'b10;
                control_next.reg_write = 1;
                control_next.csr_op = riscV_unrn_pkg::CSRRS;
                control_next.excRet = 1'b0;
             end
             3'b011: begin
                //riscV_unrn_pkg::CSRRC
                control_next.excRet = 1'b0;
                control_next.csr_source = 1;
                control_next.regData = 2'b10;
                control_next.reg_write = 1;
                control_next.csr_op = riscV_unrn_pkg::CSRRC;
                control_next.excRet = 1'b0;
             end
             3'b101: begin
                //riscV_unrn_pkg::CSRRWI
                control_next.excRet = 1'b0;
                control_next.csr_source = 0;
                control_next.regData = 2'b10;
                control_next.reg_write = 1;
                control_next.csr_op = riscV_unrn_pkg::CSRRW;
                control_next.excRet = 1'b0;
             end
             3'b110: begin
                //riscV_unrn_pkg::CSRRSI
                control_next.excRet = 1'b0;
                control_next.csr_source = 0;
                control_next.regData = 2'b10;
                control_next.reg_write = 1;
                control_next.csr_op = riscV_unrn_pkg::CSRRS;
                control_next.excRet = 1'b0;
             end
             3'b111: begin
                //riscV_unrn_pkg::CSRRCI
                control_next.excRet = 1'b0;
                control_next.csr_source = 0;
                control_next.regData = 2'b10;
                control_next.reg_write = 1;
                control_next.csr_op = riscV_unrn_pkg::CSRRC;
                control_next.excRet = 1'b0;
             end
             default:
               begin
                  control_next.inst_invalid = 1;
                  control_next.excCause = 32'h2;
                  control_next.excRet = 1'b0;
               end
           endcase
        end
        default begin
           control_next.inst_invalid = 1;
           control_next.excCause = 32'h2;
           control_next.excRet = 1'b0;
        end
      endcase
   end

endmodule // control_unit
