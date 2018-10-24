import Common::*;
import Control::*;

module unicycle(
                input logic clk,
                input logic rst,
                //Memory Interface
                output logic [3:0]  instType_o,
                output uint32       writeData_o,
                output uint32       dataAddress_o,
                input  uint32       readData_i,
                input  uint32       memException_i,
                output uint32       pc_o,
                input  raw_instr_t  instruction_i
                );

    /////////////////////
    // Internal signals
    ////////////////////

   uint32 alu_data1, alu_data2;                   // ALU Operands
   uint32 alu_result;                             // ALU output
   logic doBranch;                                //Result Branch

   // Register file in/out data
   uint32 reg_file_write_data;
   uint32 reg_file_read_data1;
   uint32 reg_file_read_data2;

   uint32 data_mem_out;

   uint32 csrReadData;
   uint32 mtvec;
   uint32 mepc;

   /////////////
   // PC
   /////////////

   uint32 PC_reg;
   uint32 PC_next;
   uint32 PC_plus_4;

   assign PC_plus_4 = PC_reg + 4;
   assign doBranch = control_out.is_branch & alu_result[0];


   // This is old
   // always_comb begin//Con JUMP y Branch
   //   if (control_out.is_branch & alu_result[0])
   //      PC_next = PC_reg + immediate_val;
   //   else
   //     case(control_out.is_jump)
   //       1'b0:  PC_next = PC_plus_4;
   //       1'b1:  PC_next = {alu_result[31:1],0};
   //     endcase
   // end

   // This params are temporal
   // localparam  PC_PLUS_4 = 0;
   // localparam  PC_BRANCH = 1;
   // localparam  PC_JUMP = 2;
   // localparam  PC_MTVEC = 3;
   // localparam  PC_MEPC = 4;

//select PC_next
   always_comb begin
     case (control_out.pc_next)
       Common::PC_PLUS_4: PC_next = PC_plus_4;
       Common::PC_BRANCH: PC_next = PC_reg + immediate_val;
       Common::PC_JUMP: PC_next = memToReg;
       Common::PC_MTVEC: PC_next = mtvec;
       Common::PC_MEPC: PC_next = mepc;
       default: PC_next = PC_plus_4;
     endcase
   end

   //This is old
   // always_comb
   //  begin
   //    if(control_out.is_branch)
   //      PC_next = PC_reg + immediate_val;
   //    else if(control_out.is_jump)
   //      PC_next = memToReg;
   //    else if(control_out.excRequest)
   //      PC_next = mtvec;
   //    else if(control_out.excRet)
   //      PC_next = mepc;
   //    else
   //      PC_next = PC_plus_4;
   // end

   always_ff @(posedge clk) begin
     if (rst) PC_reg <= 0;
     else begin
       PC_reg <= PC_next;
     end
   end

   ////////////////////////////////////////////
   // Instruction decoding and immediate gen
   ////////////////////////////////////////////

   Common::decoded_instr_t decoded_instr;
   int32_t  immediate_val;

   assign decoded_instr = Common::decode_instruction(instruction_i);
   assign immediate_val = Common::sign_extend_imm(decoded_instr);

   // Control
   Common::control_out_t control_out;
   assign control_out = Control::control_from_instruction(decoded_instr,doBranch);

   //////////////////
   // Register File
   //////////////////

   uint32 memToReg;
   uint32 writeBack;
   uint32 mtimeData;

   // Data from memory or alu_result
   assign memToReg = control_out.mem_to_reg ? data_mem_out : alu_result;

   RegFile reg_file(.clk(clk),
                    .rst(clk),
                    .read_reg1    (decoded_instr.rs1),
                    .read_reg2    (decoded_instr.rs2),
                    .write_reg    (decoded_instr.rd),
                    .write_data   (reg_file_write_data),
                    .write_enable (control_out.reg_write),
                    .read_data1   (reg_file_read_data1),
                    .read_data2   (reg_file_read_data2));

    always_comb begin
      unique case (control_out.regData)
        2'b00: reg_file_write_data = memToReg;
        2'b01: reg_file_write_data = PC_plus_4;
        2'b10: reg_file_write_data = csrReadData;
        2'b11: reg_file_write_data = immediate_val;
      endcase
    end

   /////////////
   // ALU
   /////////////

   ALU alu(.control   (control_out.alu_op),
           .data1     (alu_data1),
           .data2     (alu_data2),
           .result    (alu_result));

   assign alu_data1 = control_out.alu_from_pc ? PC_reg : reg_file_read_data1;
   assign alu_data2 = control_out.alu_from_imm ? immediate_val : reg_file_read_data2;

   ////////////////////
   // To/From Memory
   ////////////////////

   assign pc_o = PC_reg;

   assign dataAddress_o = alu_result;
   assign writeData_o = reg_file_read_data2;

   assign data_mem_out = (control_out.mem_from_mtime) ?  mtimeData : readData_i;

   ////////////////////
   // CSRs
   ////////////////////
   uint32 dataToCsr;
   assign dataToCsr = (control_out.csr_source) ? reg_file_read_data1 : immediate_val;


   csrUnit csrs(
      .clk(clk),
      .rst(rst),
     .op_i          (control_out.csr_op),
     .address_i     (decoded_instr.imm[11:0]), // TODO: Check this
     .data_i        (dataToCsr),
     .data_o        (csrReadData),
     .pc_i          (PC_reg),
     .excRequest_i  (control_out.excRequest),
     .excCause_i    (control_out.excCause),
     .trapInfo_i    (control_out.trapInfo),      // TODO: Check this
     .exc_o         (exc_to_controler),          // TODO: Check this
     .mtvec_o       (mtvec),
     .mepc_o        (mepc),
     .mtimeData_i   (reg_file_read_data2),
     .mtimeWe_i     (control_out.mtimeWe),      //TODO: Check this
     .mtimeAddress_i(control_out.mtimeAddress), //TOdO: Check this
     .mtimeData_o   (mtimeData)
     );

endmodule
