//Falta agregar instrucciones fence y priviliged a la funcion getName, y ver donde mas agregar cosas

package Common;

/*----------VARIABLES----------*/

   typedef logic[4:0] regId_t;
   typedef logic [31:0] uint32;
   typedef logic signed [31:0] int32_t;
   typedef logic [6:0]  opcode_t;
   typedef logic [31:0] raw_instr_t;

/*-----------TYPEDEF ENUM----------*/

   typedef enum         {
                         instr_type_R,
                         instr_type_I,
                         instr_type_S,
                         instr_type_SB,
                         instr_type_U,
                         instr_type_UJ
                         } instr_type_t;

   typedef enum         {
						//LOADS
                         instr_lb,
						 instr_lh,
						 instr_lw,
						 instr_lbu,
						 instr_lhu,
						 //STORES
                         instr_sb,
						 instr_sh,
						 instr_sw,
						 //SHIFTS
						 instr_sll,
						 instr_slli,
						 instr_srl,
						 instr_srli,
						 instr_sra,
						 instr_srai,
						 //ARITHMETIC
                         instr_add,
						 instr_addi,
						 instr_sub,
                         instr_lui,
						 instr_auipc,
						 //LOGIC
                         instr_xor,
						 instr_xori,
						 instr_or,
						 instr_ori,
						 instr_and,
						 instr_andi,
						 //COMPARE
						 instr_slt,
						 instr_slti,	
						 instr_sltu,
						 instr_sltiu,
						 //BRANCHES
                         instr_beq,
						 instr_bne,
						 instr_blt,
						 instr_bge,
						 instr_bltu,
						 instr_bgeu,
						 //JUMP & LINK
						 instr_jal,
						 instr_jalr,
						 //SYNCH
						 instr_fence,
						 instr_fence_i,
						 //SYSTEM
						 instr_scall,		//ESTA CREO QUE PUEDE ELIMINARSE
						 instr_sbreak,		//ESTA CREO QUE PUEDE ELIMINARSE
						 //COUNTERS
						 instr_rdcycle,
						 instr_rdcycleh,
						 instr_rdtime,
						 instr_rdtimeh,
						 instr_rdinstret,
						 instr_rdinstreth,
					//PRIVILEGED
						 //CSR ACCESS
						 instr_csrrw,
						 instr_csrrs,
						 instr_csrrc,
						 instr_csrrwi,
						 instr_csrrsi,
						 instr_csrrci,
						 //CHANGE LEVEL
						 instr_ecall,
						 instr_ebreak
                         } instr_e;
				
   typedef enum	logic [3:0] {
                         ALU_and = 'b0000,
                         ALU_or  = 'b0001,
                         ALU_add = 'b0010,
						 ALU_cne = 'b0011,
						 ALU_sll = 'b0100,
                         ALU_sub = 'b0110,
						 ALU_srl = 'b0111,
						 ALU_sra = 'b1000,
						 ALU_slt = 'b1001,
						 ALU_sltu = 'b1011,
						 ALU_xor = 'b1010,
						 ALU_cge = 'b1100,
						 ALU_cgeu = 'b1101,
						 ALU_ce = 'b1110
                         } ALU_control_t;


   /*----------ESTRUCTURAS-----------*/
   
   typedef struct packed {
						  opcode_t opcode;
						  logic [31:0]      imm;
						  logic [2:0]       funct3;
						  logic [6:0]       funct7;
						  regId_t rs1;
						  regId_t rs2;
						  regId_t rd;
						} decoded_instr_t;
						 
   typedef struct packed      {
						  logic             is_branch;
						  //logic             mem_read;
						  //logic             mem_write;
						  logic             mem_to_reg;
						  logic             alu_from_imm;
						  logic 			alu_from_pc;
						  logic 			is_jump;
						  logic [1:0]       regData;
						  logic [1:0]       pcSource;
						  logic 			csr_source;
						  ALU_control_t     alu_op;
						  logic [3:0]       instType;
						  logic             reg_write;
						  logic				unsign;
						} control_out_t;
						
   
   /*---------FUNCIONES----------*/
   
   function opcode_t get_opcode(raw_instr_t instr);
      return instr[6:0];
   endfunction

   function instr_type_t get_instr_type(opcode_t opcode);
      casez (opcode)
        7'b0000011: return instr_type_I;//RiscV32I
        7'b0001111: return instr_type_I;//RiscV32I
        7'b0010011: return instr_type_I;//RiscV32I
        7'b0010111: return instr_type_U;//RiscV32I
        7'b0100011: return instr_type_S;//RiscV32I
        7'b0110011: return instr_type_R;//RiscV32I-RiscV32M    ----------------------------------------------------?????
        7'b0110111: return instr_type_U;//RiscV32I
        7'b1100011: return instr_type_SB;//RiscV32I
        7'b1000111: return instr_type_I;//RiscV32D	---------------------------------------------------------------?????
        7'b1101111: return instr_type_UJ;//RiscV32I
		7'b1100111: return instr_type_I;//RiscV32I
        7'b1110011: return instr_type_I;//RiscV32I_privileged
        default: begin
           assert(0) else $error("could not classify opcode %b into instr type",
                                 opcode);
        end
      endcase
   endfunction

   function instr_e get_instruction_name(decoded_instr_t instr);
      automatic opcode_t opcode = instr.opcode; //OBTENGO EL OPCODE
      automatic instr_type_t instr_type = get_instr_type(opcode); //OBTENGO EL TIPO DE INSTRUCCION
      unique case (instr_type)
        instr_type_SB: begin
           unique case (instr.funct3)
			//SB (Branch's)
             'b000: return instr_beq;
			 'b001: return instr_bne;
			 'b100: return instr_blt;
			 'b101: return instr_bge;
			 'b110: return instr_bltu;
			 'b111: return instr_bgeu;
			 endcase
		end
		instr_type_S: begin
			unique case (instr.funct3)
			//S (Store's)
             'b000: return instr_sb;
			 'b001: return instr_sh;
			 'b010: return instr_sw;
           endcase
        end
		instr_type_I: begin
		    unique casez ({opcode, instr.funct3, instr.imm[11:5]})
			//I (Load's)
             'b0000011_000_???????: return instr_lb;
			 'b0000011_001_???????: return instr_lh;
			 'b0000011_010_???????: return instr_lw;
			 'b0000011_100_???????: return instr_lbu;
			 'b0000011_101_???????: return instr_lhu;
			//I (Arithmetic's)
			 'b0010011_000_???????: return instr_addi;
			 'b0010011_001_0000000: return instr_slli;
			 'b0010011_010_???????: return instr_slti;
			 'b0010011_011_???????: return instr_sltiu;
			 'b0010011_100_???????: return instr_xori;
			 'b0010011_101_0000000: return instr_srli;
			 'b0010011_101_0100000: return instr_srai;
			 'b0010011_110_???????: return instr_ori;
			 'b0010011_111_???????: return instr_andi;
           endcase
        end
        instr_type_U, instr_type_UJ: begin
			unique case (opcode)
			//SB (Branch's)
             'b0110111: return instr_lui;
			 'b0010111: return instr_auipc;
			 'b1101111: return instr_jal;
			 'b1100011: return instr_jalr;//Esta me queda la duda porque es J pero sus campos tiene mas info, parace mas un tipo I pero como solo obtiene el nombre
           endcase
        end
        instr_type_R: begin
           $display("%b", {opcode, instr.funct3, instr.funct7}); //No se que funcionalidad tiene (Consultar a nico)
           unique case ({opcode, instr.funct3, instr.funct7}) //Se deja  el opcode como entrada por si llegamos a usar instrucciones atomicas
             'b0110011_000_0000000: return instr_add;
             'b0110011_000_0100000: return instr_sub;
			 'b0110011_001_0000000: return instr_sll;
			 'b0110011_010_0000000: return instr_slt;
			 'b0110011_011_0000000: return instr_sltu;
			 'b0110011_100_0000000: return instr_xor;
			 'b0110011_101_0000000: return instr_srl;
			 'b0110011_101_0100000: return instr_sra;
             'b0110011_110_0000000: return instr_or;
             'b0110011_111_0000000: return instr_and;
           endcase
        end
        endcase
        assert(0) else $error("instruction not implemented");
   endfunction

   function int32_t sign_extend_imm(decoded_instr_t instr);
      automatic opcode_t opcode = instr.opcode;
      automatic instr_type_t instr_type = get_instr_type(opcode);
      automatic int32_t result = 'x;
      unique case (instr_type)
        instr_type_I:  result =  32'(signed'(instr.imm[11:0]));
        instr_type_S:  result =  32'(signed'(instr.imm[11:0]));
        instr_type_SB: result =  32'(signed'(instr.imm[12:0]));
        instr_type_U:  result =  32'(signed'(instr.imm[31:0]));
        instr_type_UJ: result =  32'(signed'(instr.imm[20:0]));
        instr_type_R:  assert(0) else $error("R-type instructions do not have imms");
      endcase
      return result;
   endfunction

   function decoded_instr_t decode_instruction(raw_instr_t instr);
      decoded_instr_t result;
      instr_type_t instr_type;
      
      result.opcode = get_opcode(instr);
      instr_type = get_instr_type(result.opcode);
      case (instr_type)
        default: begin
            result = 0;
        end
        instr_type_I: begin
           result.imm[10:0] = instr[31:21];
           result.rs1 = instr[19:15];
           result.funct3 = instr[14:12];
           result.rd = instr[11:7];
        end
        instr_type_U: begin
           result.imm[19:0] = instr[31:12];
           result.rd = instr[11:7];
        end
        instr_type_R: begin
           result.funct7 = instr[31:25];
           result.rs2 = instr[24:20];
           result.rs1 = instr[19:15];
           result.funct3 = instr[14:12];
           result.rd = instr[11:7];
        end
        instr_type_S: begin
           result.imm[11:5] = instr[31:25];
           result.rs2 = instr[24:20];
           result.rs1 = instr[19:15];
           result.funct3 = instr[14:12];
           result.imm[4:0] = instr[11:7];
        end
        instr_type_SB: begin
           result.imm[12]= instr[31];
           result.imm[10:5] = instr[30:25];
           result.rs2 = instr[24:20];
           result.rs1 = instr[19:15];
           result.funct3 = instr[14:12];
           result.imm[4:1] = instr[11:8];
           result.imm[11]= instr[7];
           result.imm[0] = 0;
        end
        instr_type_UJ: begin
           result.imm[20]= instr[31];
           result.imm[10:1] = instr[30:21];
           result.imm[11]= instr[20];
           result.imm[19:12] = instr[19:12];
           result.imm[0] = 0;
           result.rd = instr[11:7];
        end
      endcase
      return result;
   endfunction
   
   
endpackage
