//Falta agregar instrucciones fence y priviliged a la funcion getName, y ver donde mas agregar cosas
import riscV_unrn_pkg::*;

package Common;

/*----------VARIABLES----------*/

   typedef logic[4:0] regId_t;
   typedef logic [31:0] uint32;
   typedef logic [7:0] uint8;
   typedef logic signed [31:0] int32_t;
   typedef logic [4:0]  opcode_t;
   typedef logic [31:0] raw_instr_t;

/*-----------TYPEDEF ENUM----------*/

   typedef enum logic [5:0] {
                             instr_type_R = 'b1,
                             instr_type_I = 'b10,
                             instr_type_S =  'b100,
                             instr_type_SB ='b1000,
                             instr_type_U =  'b10000,
                             instr_type_UJ = 'b100000
                       } instr_type_t;

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

    typedef enum	logic [2:0] {
                      PC_PLUS_4 = 'b000,
                      PC_BRANCH = 'b001,
                      PC_JUMP = 'b010,
                      PC_JUMP_R = 'b011,
                      PC_MTVEC = 'b100,
                      PC_MEPC = 'b101
    } pc_next_t;


    typedef enum logic [3:0]{
       MEM_LB =  4'b1110,
       MEM_LH =  4'b1010,
       MEM_LW =  4'b1100,
       MEM_LBU = 4'b1111,
       MEM_LHU = 4'b1011,
       MEM_SB =  4'b0110,
       MEM_SH =  4'b0010,
       MEM_SW =  4'b0100,
       MEM_NOP = 4'b0000
    }mem_inst_type_t;

   /*----------ESTRUCTURAS-----------*/
   typedef struct packed {
						  opcode_t opcode;
						  // logic [31:0]      imm;
						  logic [2:0]       funct3;
						  logic [6:0]       funct7;
						  regId_t rs1;
						  regId_t rs2;
						  regId_t rd;
						} decoded_instr_t;

   typedef struct packed{
      logic             is_branch;
      logic             mem_to_reg;
      logic             alu_from_imm;
      logic 			      alu_from_pc;
      logic 			      is_jal;
      logic 			      is_jalr;
      logic [1:0]       regData;
      logic 			      csr_source;
      ALU_control_t     alu_op;
      mem_inst_type_t    instType;
      logic             reg_write;
      logic             inst_invalid;
      logic             inst_priv;
      riscV_unrn_pkg::csr_op_t  csr_op;
      logic             excRequest;
      logic             excRet;
      uint32            excCause;
	  } control_out_t;


endpackage
