import Common::*;

package Control;
   // "instr" tiene que pasar como parametro.
   // Antes debe ejecutar la funcion decode_instruction
   function Common::control_out_t
     control_from_instruction(Common::decoded_instr_t instr);

      automatic Common::control_out_t result = 0;
	    automatic Common::opcode_t opcode = instr.opcode;

	// is_branch
      result.is_branch = opcode == 7'b1100011;

	//is_jump
      casez(opcode)
        7'b110?111: begin
           result.is_jump = 1;
        end
        default: begin
          result.is_jump = 0;
        end
      endcase

	//mem_read ; mem_write ; mem_to_reg ; alu_from_imm ; alu_op ; reg_write
	case (opcode)
		7'b0000011: begin//LOAD'S
      		//result.is_branch=0;
      		//result.mem_write = 0;
      		//result.mem_read = 1;
      		//result.is_jump = 0;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source = 0;
      		result.mem_to_reg = 1;
      		result.alu_from_imm = 1;
      		result.alu_op = Common::ALU_add;
      		result.regData = 2'b00;
      		result.reg_write = 1;
      		result.alu_from_pc = 0;
      		case (instr.funct3)
      			3'b000: begin
      			result.instType = Common::MEM_LB;
      			end
      			3'b001: begin
      			result.instType = Common::MEM_LH;
      			end
      			3'b010: begin
      			result.instType = Common::MEM_LW;
      			end
      			3'b100: begin
      			result.instType = Common::MEM_LBU;
      			end
      			3'b101: begin
      			result.instType = Common::MEM_LHU;
      			end
      			default: begin
              result.inst_invalid = 1;
      			  result.instType = Common::MEM_NOP;
              result.excCause[31] = 0;
               // FIXME(nbertolo): esto está bien?
              result.excCause[30:0] = 31'h2;
      			end
      		endcase
		end
		7'b0001111: begin //FENCE/FENCEI implemened like a NOP
      		//result.is_branch=0;
      		//result.mem_read = 0;
      		//result.mem_write = 0;
      		//result.is_jump = 0;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source=0;
      		result.regData = 2'b00;
      		result.alu_from_pc = 0;
      		result.mem_to_reg = 0;
      		result.alu_from_imm = 0;
      		result.alu_op = Common::ALU_add;
      		result.reg_write = 0;
      		result.instType = Common::MEM_NOP;
      		end
	 7'b0010011: begin//ARITHMETIC INM
      		//result.mem_read = 0;
      		//result.mem_write = 0;
      		//result.is_branch=0;
      		//result.is_jump = 0;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source=0;
      		result.regData = 2'b00;
      		result.alu_from_pc = 0;
      		result.mem_to_reg = 0;
      		result.alu_from_imm = 1;
      		result.reg_write = 1;
      		result.instType = Common::MEM_NOP;
      		case(instr.funct3)
      			3'b000: begin
      			result.alu_op = Common::ALU_add;
      			end
      			3'b001: begin
      			result.alu_op = Common::ALU_sll;
      			end
      			3'b010: begin
      			result.alu_op = Common::ALU_slt;
      			end
      			3'b011: begin
      			result.alu_op = Common::ALU_sltu;
      			end
      			3'b100: begin
      			result.alu_op = Common::ALU_xor;
      			end
      			3'b101: begin
      			case(instr.imm[10])
      				1'b0: begin
      				result.alu_op = Common::ALU_srl;
      				end
      				1'b1: begin
      				result.alu_op = Common::ALU_sra;
      				end
      			endcase
      			end
      			3'b110: begin
      			result.alu_op = Common::ALU_or;
      			end
      			3'b111: begin
      			result.alu_op = Common::ALU_and;
      			end
      			default:
      			begin
              result.inst_invalid = 1;
              result.excCause[31] = 0;
              // FIXME(nbertolo): esto está bien?
              result.excCause[30:0] = 31'h2;
      			end
      		endcase
		end
		7'b0010111: begin//AUIPC
      		//result.mem_write = 0;
      		//result.is_branch=0;
      		//result.mem_read = 0;
      		//result.is_jump = 0;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source=0;
      		result.alu_from_pc = 1;
      		result.regData = 2'b00;
      		result.mem_to_reg = 0;
      		result.alu_from_imm = 1;
      		result.alu_op = Common::ALU_add;
      		result.reg_write = 1;
      		result.instType = Common::MEM_NOP;
		end
		7'b0100011: begin//STORE'S
        		//result.mem_read = 0;
        		//result.mem_write = 1;
        		//result.is_branch=0;
        		//result.is_jump = 0;
            result.inst_priv = 0;
            result.inst_invalid = 0;
            result.excRet = 1'b0;
            result.excRequest = 0;
            result.csr_op = 2'h0;
        		result.csr_source=0;
        		result.regData = 2'b00;
        		result.alu_from_pc = 0;
        		result.mem_to_reg = 0;
        		result.alu_from_imm = 1;
        		result.alu_op = Common::ALU_add;
        		result.reg_write = 0;

            case (instr.funct3)
              3'b000: begin
                result.instType = Common::MEM_SB;
              end
              3'b001: begin
                result.instType = Common::MEM_SH;
              end
              3'b010: begin
                result.instType = Common::MEM_SW;
              end
              default: begin
                result.inst_invalid = 1;
                result.instType = Common::MEM_NOP;
                // FIXME(nbertolo): esto está bien?
                result.excCause[30:0] = 31'h2;
              end
            endcase
          end
		7'b0110011: begin//ARITHMETIC
      		//result.mem_read = 0;
      		//result.mem_write = 0;
      		//result.is_branch=0;
      		//result.is_jump = 0;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source=0;
      		result.alu_from_pc = 0;
      		result.regData = 2'b00;
      		result.mem_to_reg = 0;
      		result.alu_from_imm = 0;
      		result.reg_write = 1;
      		result.instType = Common::MEM_NOP;
      		case (instr.funct3)
      			3'b000: begin
      			case(instr.funct7[5])
      				1'b0: begin
      				result.alu_op = Common::ALU_add;
      				end
      				1'b1: begin
      				result.alu_op = Common::ALU_sub;
      				end
      			endcase
      			end
      			3'b001: begin
      			result.alu_op = Common::ALU_sll;
      			end
      			3'b010: begin
      			result.alu_op = Common::ALU_slt;
      			end
      			3'b011: begin
      			result.alu_op = Common::ALU_sltu;
      			end
      			3'b100: begin
      			result.alu_op = Common::ALU_xor;
      			end
      			3'b101: begin
      			case(instr.funct7[5])
      				1'b0: begin
      				result.alu_op = Common::ALU_srl;
      				end
      				1'b1: begin
      				result.alu_op = Common::ALU_sra;
      				end
      			endcase
      			end
      			3'b110: begin
      			result.alu_op = Common::ALU_or;
      			end
      			3'b111: begin
      			result.alu_op = Common::ALU_and;
      			end
      			default:
      			begin
              result.inst_invalid = 1;
              result.excCause[31] = 0;
              // FIXME(nbertolo): esto está bien?
              result.excCause[30:0] = 31'h2;
      			end
      		endcase
		end
		7'b0110111: begin//LOAD INM
      		//result.mem_read = 0;
      		//result.mem_write = 0;
      		//result.is_branch=0;
      		//result.is_jump = 0;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source=0;
      		result.instType = Common::MEM_NOP;
      		result.mem_to_reg = 0;
      		result.regData = 2'b11;
      		result.alu_from_pc = 0;
      		result.alu_from_imm = 1;
      		result.alu_op = Common::ALU_add;
      		result.reg_write = 1;
      		end
  7'b1100011: begin//BRANCH'S
      		//result.mem_read = 0;
      		//result.mem_write = 0;
      		//result.is_branch=1;
      		//result.is_jump = 0;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source=0;
      		result.alu_from_pc = 0;
      		result.regData = 2'b00;
      		result.mem_to_reg = 0;
      		result.alu_from_imm = 0;
      		result.reg_write = 0;
      		result.instType = Common::MEM_NOP;
      		case (instr.funct3)
      			3'b000: begin
      			result.alu_op = Common::ALU_ce;
      			end
      			3'b001: begin
      			result.alu_op = Common::ALU_cne;
      			end
      			3'b100: begin
      			result.alu_op = Common::ALU_slt;
      			end
      			3'b101: begin
      			result.alu_op = Common::ALU_cge;
      			end
      			3'b110: begin
      			result.alu_op = Common::ALU_sltu;
      			end
      			3'b111: begin
      			result.alu_op = Common::ALU_cgeu;
      			end
      			default:
      			begin
              result.inst_invalid = 1;
              result.excCause[31] = 0;
              // FIXME(nbertolo): esto está bien?
              result.excCause[30:0] = 31'h2;
      			end
      		endcase
		end
		7'b1100111: begin//JALR
      		//result.mem_read = 0;
      		//result.mem_write = 0;
      		//result.is_branch=0;
      		//result.is_jump = 1;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source=0;
      		result.alu_from_pc = 0;
      		result.regData = 2'b01;
      		result.mem_to_reg = 0;
      		result.alu_from_imm = 1;
      		result.alu_op = Common::ALU_add;
      		result.reg_write = 1;
      		result.instType = Common::MEM_NOP;
      		end
		7'b1101111: begin//JAL
      		//result.mem_read = 0;
      		//result.mem_write = 0;
      		//result.is_branch=0;
      		//result.is_jump = 1;
          result.inst_priv = 0;
          result.inst_invalid = 0;
          result.excRet = 1'b0;
          result.excRequest = 0;
          result.csr_op = 2'h0;
      		result.csr_source=0;
      		result.alu_from_pc = 1;
      		result.mem_to_reg = 0;
      		result.regData = 2'b01;
      		result.alu_from_imm = 1;
      		result.alu_op = Common::ALU_add;
      		result.reg_write = 1;
      		result.instType = Common::MEM_NOP;
		      end
		7'b1110011: begin // Estan completadas un poco, falta ver que pasa si rs1=0x00 o rd=0x00
      		//result.mem_read = 0;
      		//result.mem_write = 0;
      		//result.is_branch=0;
      		//result.is_jump = 0;
          result.inst_priv = 0;
          result.inst_invalid = 0;
      		result.alu_from_pc = 0;
      		result.instType = Common::MEM_NOP;
      		result.alu_op = Common::ALU_add;
      		result.mem_to_reg = 0;
      		result.alu_from_imm = 0;
      		case (instr.funct3)
      			3'b000: begin
      				case(instr.imm[2:0])
      				3'b000://ECALL
      				begin
                result.inst_priv = 1;
                result.excRet = 1'b0;
                result.excRequest = 1;
      					result.csr_source=0;
      					result.regData = 2'b10;
      					result.reg_write = 0;
                result.excCause[31] = 0;
                result.excCause[30:0] = 31'd11;
      				end
      				3'b001://EBREAK
      				begin
                result.inst_priv = 1;
                result.excRet = 1'b0;
                result.excRequest = 1;
      					result.csr_source=0;
      					result.regData = 2'b10;
      					result.reg_write = 0;
                result.excCause[31] = 0;
                // FIXME(nbertolo): esto está bien?
                result.excCause[30:0] = 31'h2;
                result.excRet = 1'b0;
      				end
      				3'b010://MRET
      				begin
      					result.csr_source=0;
      					result.regData = 2'b10;
      					result.reg_write = 0;
                result.csr_op = 2'h0;
                result.excRet = 1'b1;
      				end
      				3'b101://WFI
      				begin
      					result.csr_source=0;
      					result.regData = 2'b10;
      					result.reg_write = 0;
                result.csr_op = 2'h0;
                result.excRet = 1'b0;
      				end
      				default:
      				begin
                result.inst_invalid = 1;
                result.excRet = 1'b0;
                result.excCause[31] = 0;
                // FIXME(nbertolo): esto está bien?
                result.excCause[30:0] = 31'h2;
      				end
      				endcase
      			end
      			3'b001: begin
      			//CSRRW
            result.excRet = 1'b0;
      				result.csr_source=0;
      				result.regData = 2'b10;
      				result.reg_write = 1;
              result.csr_op = 2'h1;
              result.excRet = 1'b0;
      			end
      			3'b010: begin
      			//CSRRS
              result.excRet = 1'b0;
      				result.csr_source=0;
      				result.regData = 2'b10;
      				result.reg_write = 1;
              result.csr_op = 2'h2;
              result.excRet = 1'b0;
      			end
      			3'b011: begin
      			//CSRRC
              result.excRet = 1'b0;
      				result.csr_source=0;
      				result.regData = 2'b10;
      				result.reg_write = 1;
              result.csr_op = 2'h3;
              result.excRet = 1'b0;
      			end
      			3'b101: begin
      			//CSRRWI
              result.excRet = 1'b0;
      				result.csr_source=1;
      				result.regData = 2'b10;
      				result.reg_write = 1;
              result.csr_op = 2'h1;
              result.excRet = 1'b0;
      			end
      			3'b110: begin
      			//CSRRSI
              result.excRet = 1'b0;
      				result.csr_source=1;
      				result.regData = 2'b10;
      				result.reg_write = 1;
              result.csr_op = 2'h2;
              result.excRet = 1'b0;
      			end
      			3'b111: begin
      			//CSRRCI
              result.excRet = 1'b0;
      				result.csr_source=1;
      				result.regData = 2'b10;
      				result.reg_write = 1;
              result.csr_op = 2'h3;
              result.excRet = 1'b0;
      			end
      			default:
      			begin
              result.inst_invalid = 1;
              result.excCause[31] = 0;
              // FIXME(nbertolo): esto está bien?
              result.excCause[30:0] = 31'h2;
              result.excRet = 1'b0;
      			end
      		endcase
      		end
		default begin
          result.inst_invalid = 1;
          result.excCause[31] = 0;
          // FIXME(nbertolo): esto está bien?
          result.excCause[30:0] = 31'h2;
          result.excRet = 1'b0;
                // $display("ERROR: could not classify opcode %b into instr type",
                //          opcode);
    		  end
	endcase

    return result;
   endfunction
endpackage
