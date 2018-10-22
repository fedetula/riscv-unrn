import Common::*;

package Control;
   function Common::control_out_t control_from_instruction(Common::decoded_instr_t instr); // "instr" tiene que pasar como parametro. Antes debe ejecutar la funcion decode_instruction
      automatic Common::control_out_t result = 0;
	  automatic Common::opcode_t opcode = Common::get_opcode(instr);
	  automatic Common::instr_e instr_name = Common::get_instruction_name(instr); 

	// is_branch
    result.is_branch = instr_name == (Common::instr_beq || Common::instr_bne || Common::instr_blt || Common::instr_bge || Common::instr_bltu || Common::instr_bgeu);
	
	//is_jump (la linea 13 la deje comentada como opcion 2. Capaz reduce recursos)
	//result.is_jump = instr_name == (Common::instr_jal || Common::instr_jalr); 
	
	//mem_read ; mem_write ; mem_to_reg ; alu_from_imm ; alu_op ; reg_write ; unsign
	case (opcode)
		7'b0000011: begin//LOAD'S
		////result.mem_read = 1;
		result.is_jump = 0;
		//result.mem_write = 0;
		result.mem_to_reg = 1;
		result.alu_from_imm = 1;
		result.alu_op = Common::ALU_add;
		result.regData = 2'00;
		result.reg_write = 1;
		result.alu_from_pc = 0;
		//result.pcSource = 2'b00;
		case (instr.funct3)
			3'b000: begin
			result.instType = 4'b1000;
			end
			3'b001: begin
			result.instType = 4'b1001;
			end
			3'b010: begin
			result.instType = 4'b1010;
			end
			3'b100: begin
			result.instType = 4'b1011;
			end
			3'b101: begin
			result.instType = 4'b1111;
			end
			default begin
			result.instType = 4'b0000;
			end
		endcase
		end
		7'b0001111: begin //NO TENEMOS DEFINIDO EN EL EXCEL LOS VALORES PARA ESTE OPCODE, ES UN FENCE/FENCEI
		//result.mem_read = 0;
		result.regData = 2'00;
		result.alu_from_pc = 0;
		//result.mem_write = 0;
		result.is_jump = 0;
		result.mem_to_reg = 0;
		result.alu_from_imm = 0;
		result.alu_op = Common::ALU_add;
		//result.pcSource = 2'b00;
		result.reg_write = 0;	
		result.instType = 4'b0000;
		end
		7'b0010011: begin//ARITHMETIC INM
		//result.mem_read = 0;
		//result.mem_write = 0;
		//result.pcSource = 2'b00;
		result.is_jump = 0;
		result.regData = 2'00;
		result.alu_from_pc = 0;
		result.mem_to_reg = 0;
		result.alu_from_imm = 1;
		result.reg_write = 1;
		result.instType = 4'b0000;
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
			result.alu_op = Common::ALU_slt;
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
		endcase		  
		end
		7'b0010111: begin//AUIPC
		//result.mem_read = 0;
		result.alu_from_pc = 1;
		//result.mem_write = 0;
		result.regData = 2'00;
		//result.pcSource = 2'b00;
		result.is_jump = 0;
		result.mem_to_reg = 0;
		result.alu_from_imm = 1;
		result.alu_op = Common::ALU_add;
		result.reg_write = 1;	
		result.instType = 4'b0000;
		end
		7'b0100011: begin//STORE'S
		//result.mem_read = 0;
		//result.mem_write = 1;
		result.regData = 2'00;
		result.alu_from_pc = 0;
		result.is_jump = 0;
		//result.pcSource = 2'b00;
		result.mem_to_reg = 0;
		result.alu_from_imm = 1;
		result.alu_op = Common::ALU_add;
		result.reg_write = 0;	
		case (instr.funct3)
			3'b000: begin
			result.instType = 4'b1100;
			end
			3'b001: begin
			result.instType = 4'b1101;
			end
			3'b010: begin
			result.instType = 4'b1110;
			end
			default begin
			result.instType = 4'b0000;
			end
		endcase
		end
		7'b0110011: begin//ARITHMETIC
		//result.mem_read = 0;
		//result.mem_write = 0;
		result.alu_from_pc = 0;
		result.regData = 2'00;
		//result.pcSource = 2'b00;
		result.is_jump = 0;
		result.mem_to_reg = 0;
		result.alu_from_imm = 0;
		result.reg_write = 1;
		result.instType = 4'b0000;
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
			result.alu_op = Common::ALU_slt;
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
		endcase		
		end
		7'b0110111: begin//LOAD INM
		result.instType = 4'b0000;
		//result.mem_read = 0;
		//result.mem_write = 0;
		result.mem_to_reg = 0;
		result.regData = 2'11;
		result.is_jump = 0;
		//result.pcSource = 2'b00;
		result.alu_from_pc = 0;
		result.alu_from_imm = 1;
		result.alu_op = Common::ALU_add;
		result.reg_write = 1;	
		result.unsign=0;
		end
		7'b1100011: begin//BRANCH'S
		//result.mem_read = 0;
		//result.mem_write = 0;
		result.alu_from_pc = 0;
		result.regData = 2'00;
		result.is_jump = 0;
		result.mem_to_reg = 0;
		//result.pcSource = 2'b00;
		result.alu_from_imm = 0;
		result.reg_write = 0;
		result.instType = 4'b0000;
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
			result.alu_op = Common::ALU_stlu;
			end
			3'b111: begin
			result.alu_op = Common::ALU_cgeu;
			end
		endcase
		end
		7'b1100111: begin//JALR
		//result.mem_read = 0;
		//result.mem_write = 0;
		result.alu_from_pc = 0;
		result.regData = 2'01;
		result.is_jump = 1;
		//result.pcSource = 2'b10;
		result.mem_to_reg = 0;
		result.alu_from_imm = 1;
		result.alu_op = Common::ALU_add;
		result.reg_write = 1;		  
		result.instType = 4'b0000;
		end
		7'b1101111: begin//JAL
		//result.mem_read = 0;
		//result.mem_write = 0;
		//result.pcSource = 2'b10;
		result.alu_from_pc = 1;
		result.mem_to_reg = 0;
		result.is_jump = 1;
		result.regData = 2'01;
		result.alu_from_imm = 1;
		result.alu_op = Common::ALU_add;
		result.reg_write = 0;		  
		result.instType = 4'b0000;
		end
		7'b1110011: begin // NO TENEMOS DEFINIDO EN EL EXCEL LOS VALORES PARA ESTE OPCODE, SON LAS PRIVILEGIADAS
		//result.mem_read = 0;
		//result.mem_write = 0;
		result.mem_to_reg = 0;
		result.alu_from_pc = 0;
		result.is_jump = 0;
		//result.pcSource = 2'b00;
		result.regData = 2'10;
		result.alu_from_imm = 0;
		result.alu_op = Common::ALU_add;
		result.reg_write = 0;	
		result.instType = 4'b0000;
		end
		default begin
           assert(0) else $error("could not classify opcode %b into instr type",
                                 opcode); 
		end
	endcase

    return result;
   endfunction
endpackage