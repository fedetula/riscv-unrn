import Common::*;
import Control::*;

module Uniciclo(
                input logic clk,
                input logic rst,
                );

   // Components & connection signals.
   Common::raw_instr_t instruction_reg;
   Common::decoded_instr_t decoded_instr;
   int32_t  immediate_val;

   Common::control_out_t control_out;
   uint32 alu_data1, alu_data2;
   uint32 alu_result;
   logic alu_is_zero,alu_is_less,alu_is_great;

   uint32 reg_file_write_data;
   uint32 reg_file_read_data1;
   uint32 reg_file_read_data2;


   ALU alu(.control   (control_out.alu_op),
           .data1     (alu_data1),
           .data2     (alu_data2),
           .result    (alu_result),
           .is_zero   (alu_is_zero)
		       .is_less   (alu_is_less)
		       .is_great  (alu_is_great));

   uint32 data_mem_out;

//A modificar
/*DataMem data_mem(.clk,
                    .rst,
                    .mem_read(control_out.mem_read),
                    .mem_write(control_out.mem_write),
                    .address(alu_result),
                    .write_data(reg_file_read_data2),
                    .read_data(data_mem_out)
                    );
 */

    /////////////
    // PC
    /////////////
   uint32 PC_reg;
   uint32 PC_next;
   uint32 PC_plus_4;

   assign PC_plus_4 = PC_reg + 4;

   always_ff @(posedge clk) begin
      if (rst)
        PC_reg <= 0;
      else begin
        PC_reg <= PC_next;
//        $stop;
      end
   end

   always_comb begin//Con JUMP y Branch
      if (control_out.is_branch & alu_result[0])
		      PC_next = PC_reg + immediate_val;
      else
        case(control_out.is_jump)
		        1'b0:
			         PC_next = PC_plus_4;
		        1'b1:
			         PC_next = {alu_result[31:1],0};
		    endcase
   end

   //Common::raw_instr_t instr_memory[256] = '{default:0}; //A modificar
   //assign instruction_reg = instr_memory[PC_reg>>2]; //A modificar

   initial $readmemh("/home/nicolas/Code/ACA/Uniciclo/Uniciclo.srcs/sources_1/new/program.hex", instr_memory); //A modificar

   // Instruction decoding
   assign decoded_instr = Common::decode_instruction(instruction_reg);
   assign immediate_val = Common::sign_extend_imm(decoded_instr);

   // Control
   assign control_out = Control::control_from_instruction(decoded_instr);

   //////////////////
   // Register File
   //////////////////

   uint32 memToReg;
   uint32 writeBack;
   uint32 mtimeData;

   RegFile reg_file(.clk,
                    .rst,
                    .read_reg1    (decoded_instr.rs1),
                    .read_reg2    (decoded_instr.rs2),
                    .write_reg    (decoded_instr.rd),
                    .write_data   (reg_file_write_data),
                    .write_enable (control_out.reg_write),
                    .read_data1   (reg_file_read_data1),
                    .read_data2   (reg_file_read_data2),
                    );

    always_comb begin
      unique case (control_out.regData)
        2'b00: memToReg;
        2'b01: PC_plus_4;
        2'b10: csrRead;
        2'b11: immediate_val;
      endcase
    end

    // Data from memory or alu_result
    assign memToReg = control_out.mem_to_reg ? data_mem_out : alu_result;
    // TODO: Define this control signal
    assign writeBack = ( ) ?  memToReg : mtimeData;

    // Reemplacé esta sección por el always_comb
    // assign reg_file_write_data = (control_out.regData == 2'b00) ? memToReg     :
		// 					                  (control_out.regData == 2'b01) ? (PC_reg + 4) :
		// 						                (control_out.regData == 2'b10) ? CSR          :
		// 						                (control_out.regData == 2'b11) ? immediate_val;



   // ALU
   assign alu_data1 = control_out.alu_from_pc ? PC_reg : reg_file_read_data1;
   assign alu_data2 = control_out.alu_from_imm ? immediate_val : reg_file_read_data2;



endmodule
