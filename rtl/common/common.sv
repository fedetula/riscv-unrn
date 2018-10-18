package Common;

  parameter XLEN = 32;


   typedef logic[4:0] regId_t;
   typedef logic [63:0] uint64_t;
   typedef logic signed [63:0] int64_t;
   typedef logic [6:0]  opcode_t;

   typedef enum         {
                         instr_type_R,
                         instr_type_I,
                         instr_type_S,
                         instr_type_SB,
                         instr_type_U,
                         instr_type_UJ
                         } instr_type_t;

   typedef enum         {
                         instr_ld,
                         instr_sd,
                         instr_add,
                         instr_sub,
                         instr_and,
                         instr_or,
                         instr_beq
                         } instr_e;

   typedef logic [31:0] raw_instr_t;

   typedef struct packed {
      opcode_t opcode;
      logic [31:0]      imm;
      logic [2:0]       funct3;
      logic [6:0]       funct7;
      regId_t rs1;
      regId_t rs2;
      regId_t rd;
   } decoded_instr_t;

   typedef enum         logic [3:0]
                        {
                         ALU_AND = 'b0000,
                         ALU_OR  = 'b0001,
                         ALU_ADD = 'b0010,
                         ALU_SUB = 'b0110,
                         ALU_SLL,
                         ALU_SRL,
                         ALU_SLA,
                         ALU_SRA
                         } alu_control_t;

   typedef struct packed      {
      logic             is_branch;
      logic             mem_read;
      logic             mem_write;
      logic             mem_to_reg;
      logic             alu_from_imm;
      alu_control_t     alu_op;
      logic             reg_write;
   } control_out_t;

   function opcode_t get_opcode(raw_instr_t instr);
      return instr[6:0];
   endfunction

   function instr_type_t get_instr_type(opcode_t opcode);
      casez (opcode)
        7'b0000011: return instr_type_I;
        7'b0001111: return instr_type_I;
        7'b0010011: return instr_type_I;
        7'b0010111: return instr_type_U;
        7'b0011011: return instr_type_I;
        7'b0100011: return instr_type_S;
        7'b0110011: return instr_type_R;
        7'b0110111: return instr_type_U;
        7'b0111011: return instr_type_R;
        7'b1100011: return instr_type_SB;
        7'b1000111: return instr_type_I;
        7'b1101111: return instr_type_UJ;
        7'b1110011: return instr_type_I;
        default: begin
           assert(0) else $error("could not classify opcode %b into instr type",
                                 opcode);
        end
      endcase
   endfunction

   function instr_e get_instruction_name(decoded_instr_t instr);
      automatic opcode_t opcode = instr.opcode;
      automatic instr_type_t instr_type = get_instr_type(opcode);
      unique case (instr_type)
        instr_type_I, instr_type_S, instr_type_SB: begin
           unique case ({opcode, instr.funct3})
             'b0000011_011: return instr_ld;
             'b0100011_011: return instr_sd;
             'b1100011_000: return instr_beq;
           endcase
        end
        instr_type_U, instr_type_UJ: begin
        end
        instr_type_R: begin
           $display("%b", {opcode, instr.funct3, instr.funct7});
           unique case ({opcode, instr.funct3, instr.funct7})
             'b0110011_000_0000000: return instr_add;
             'b0110011_000_0100000: return instr_sub;
             'b0110011_110_0000000: return instr_or;
             'b0110011_111_0000000: return instr_and;
           endcase
        end
        endcase
        assert(0) else $error("instruction not implemented");
   endfunction

   function int64_t sign_extend_imm(decoded_instr_t instr);
      automatic opcode_t opcode = instr.opcode;
      automatic instr_type_t instr_type = get_instr_type(opcode);
      automatic int64_t result = 'x;
      unique case (instr_type)
        instr_type_I:  result =  64'(signed'(instr.imm[11:0]));
        instr_type_S:  result =  64'(signed'(instr.imm[11:0]));
        instr_type_SB: result =  64'(signed'(instr.imm[12:0]));
        instr_type_U:  result =  64'(signed'(instr.imm[31:0]));
        instr_type_UJ: result =  64'(signed'(instr.imm[20:0]));
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
           result.imm[11:0] = instr[31:21];
           result.rs1 = instr[19:15];
           result.funct3 = instr[14:12];
           result.rd = instr[11:7];
        end
        instr_type_U: begin
           result.imm = instr[31:12];
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
