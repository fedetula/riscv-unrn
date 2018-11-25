import Common::*;
import riscV_unrn_pkg::*;

module multicycle(
                input logic  clk,
                input logic  rst,
                //Memory Interface
                output       mem_inst_type_t instType_o,
                output       uint32 writeData_o,
                output       uint32 dataAddress_o,
                input        uint32 readData_i,
                output       uint32 pc_o,
                output logic exception_o
                );
   /////////////////////
  // Internal signals
   ////////////////////

   ALU_control_t alu_control;

   uint32 alu_data1, alu_data2;                   // ALU Operands
   uint32 alu_result;                             // ALU output
   logic                     alu_start;
   logic                     alu_will_be_done;
   logic                     exceptionPresent;
   logic                     excDetect_shouldJump;
   logic                     mtime_exc;
   logic                     control_decode;
   logic                     instr_decode;
   decoded_instr_t dec_instr;
   uint32 immediate_val;



   // Register file in/out data
   logic reg_file_we;
   uint32 reg_file_write_data;
   uint32 reg_file_read_data1;
   uint32 reg_file_read_data2;

   uint32 data_mem_out;

   uint32 csrReadData;
   csr_op_t csr_op;
   uint32 mtvec;
   uint32 mepc;

   uint32 PC_reg;
   uint32 PC_next;
   uint32 PC_JumpDst;
   logic                     jumpToMtvec;

   uint32 memToReg;
   uint32 mtimeData;

   stage_t stage_reg;
   stage_t stage_next;

   logic                     mtimeWe;
   logic                     mem_from_mtime;
   uint32 dataToCsr;

   logic [31:0]              trapInfo;
   logic [31:0]              excCause;

   control_out_t control_out;

   assign exception_o = exceptionPresent;
   assign pc_o = PC_reg;

   always_ff @(posedge clk) begin
      if (rst) PC_reg <= 32'h8000_0000;
      else if (stage_next == PC_FETCH) begin
         PC_reg <= PC_next;
      end
   end

   instr_decoder deco(.clk,
                      .raw_instr_i (readData_i),
                      .store_imm(instr_decode),
                      .instr_o     (dec_instr),
                      .imm_o       (immediate_val)
                      );

   // Control

   control_unit control(.clk,
                        .instr_i    (dec_instr),
                        .imm_i      (deco.imm_next),
                        .decode     (control_decode),
                        .control_o  (control_out));

   RegFile reg_file(.clk(clk),
                    //.rst(rst),
                    .read_reg1    (control_out.rs1),
                    .read_reg2    (control_out.rs2),
                    .write_reg    (control_out.rd),
                    .write_data   (reg_file_write_data),
                    .write_enable (reg_file_we),
                    .read_data1   (reg_file_read_data1),
                    .read_data2   (reg_file_read_data2));


   /////////////
     // ALU
   /////////////

   ALU alu(.clk,
           .start(alu_start),
           .operation   (alu_control),
           .dataA     (alu_data1),
           .dataB     (alu_data2),
           .will_be_done(alu_will_be_done),
           .result    (alu_result));

   csrUnit csrs(
                .clk           (clk),
                .rst           (rst),
                .op_i          (csr_op),
                .address_i     (riscV_unrn_pkg::csr_num_t'(immediate_val[11:0])),
                .data_i        (dataToCsr),
                .data_o        (csrReadData),
                .pc_i          (PC_reg),
                .jumpingToMtvec_i(jumpToMtvec),
                .excCause_i    (excCause),
                .trapInfo_i    (trapInfo),
                .mtime_exc_o   (mtime_exc),
                .mtvec_o       (mtvec),
                .mepc_o        (mepc),
                .mtimeData_i   (reg_file_read_data2),
                .mtimeWe_i     (mtimeWe),
                .mtimeAddress_i(alu_result),
                .mtimeData_o   (mtimeData)
                );

   excDetect excDetect(
                       .shouldJump_i(excDetect_shouldJump),
                       .pcJumpDst_i(PC_JumpDst),
                       .pc_i            (pc_o),
                       .dataAddress_i   (alu_result),
                       .memInstType_i   (control_out.instType),
                       .inst_invalid_i  (control_out.inst_invalid),
                       .priv_i          (control_out.inst_priv),
                       .privCause_i     (control_out.excCause),
                       .mtime_exc_i     (mtime_exc),
                       .excCause_o      (excCause),
                       .trapInfo_o      (trapInfo),
                       .excPresent_o    (exceptionPresent)
                       );

   logic shouldTakeJump_reg;
   logic shouldTakeJump_next;

   always_ff @(posedge clk) begin
      shouldTakeJump_reg <= shouldTakeJump_next;
      stage_reg <= rst ? PC_FETCH : stage_next;
   end

   always_comb begin
      // outputs
      instType_o = MEM_NOP;
      writeData_o = 0;
      dataAddress_o = 0;
      // internal signals
      shouldTakeJump_next = 0;
      alu_control = ALU_add;
      instr_decode =0;
      control_decode = 0;
      PC_JumpDst = 0;
      PC_next = 0;
      alu_data1 = 0;
      alu_data2 = 0;
      alu_start = 0;
      csr_op = CSRRNOP;
      dataToCsr = 0;
      data_mem_out = 0;
      jumpToMtvec = 0;
      mem_from_mtime = 0;
      mtimeWe = 0;
      reg_file_we = 0;
      reg_file_write_data = 0;
      PC_JumpDst = 0;
      excDetect_shouldJump = 0;

      unique case (stage_reg)
        PC_FETCH: begin
           dataAddress_o = PC_reg;
           instType_o = MEM_LW;
           stage_next = INST_DEC;
        end
        INST_DEC: begin
           dataAddress_o = PC_reg;
           instType_o = MEM_LW;
           instr_decode = 1;
           control_decode = 1;
           stage_next = READ_REGS;
        end
        READ_REGS: begin
           stage_next = control_out.excRequest ? CALC_NEXT_PC : ALU;
        end
        ALU: begin
           alu_control = control_out.alu_op;
           alu_data1 = control_out.alu_from_pc ? PC_reg : reg_file_read_data1;
           alu_data2 = control_out.alu_from_imm ? immediate_val : reg_file_read_data2;
           alu_start = 1;
           stage_next = WAIT_ALU;
        end
        WAIT_ALU: begin
           alu_control = control_out.alu_op;
           stage_next = alu_will_be_done ? MEM_OP : WAIT_ALU;
        end
        MEM_OP: begin
           dataAddress_o = alu_result;
           writeData_o = reg_file_read_data2;
           // Check if we are accessing mtime or mtimemcmp registers
           instType_o = control_out.instType;
           case (dataAddress_o)
             riscV_unrn_pkg::MTIME_MEM_ADDRESS_LOW,
             riscV_unrn_pkg::MTIME_MEM_ADDRESS_HIGH,
             riscV_unrn_pkg::MTIMECMP_MEM_ADDRESS_LOW,
             riscV_unrn_pkg::MTIMECMP_MEM_ADDRESS_HIGH:
                  begin         // If we actually are:
                     // Write to registers if on store
                     mtimeWe = ~control_out.instType[3] && |control_out.instType;
                     instType_o = MEM_NOP;        // Invalidate access to memory
                  end
           endcase
           if (exceptionPresent) begin
              jumpToMtvec = 1;
              PC_next = mtvec;
              stage_next = PC_FETCH;
              instType_o = MEM_NOP;
           end else begin
              stage_next = control_out.reg_write ? WRITEBACK : CALC_NEXT_PC;
           end
        end
        WRITEBACK: begin
           unique case (alu_result)
             riscV_unrn_pkg::MTIME_MEM_ADDRESS_LOW,
                    riscV_unrn_pkg::MTIME_MEM_ADDRESS_HIGH,
                    riscV_unrn_pkg::MTIMECMP_MEM_ADDRESS_LOW,
                    riscV_unrn_pkg::MTIMECMP_MEM_ADDRESS_HIGH:
                      begin
                         mem_from_mtime = 1;
                      end
             default: begin
                mem_from_mtime = 0;
             end
           endcase

           dataAddress_o = alu_result;
           instType_o = control_out.instType;
           csr_op = control_out.csr_op;
           reg_file_we = control_out.reg_write & ~exceptionPresent;
           data_mem_out = (mem_from_mtime) ?  mtimeData : readData_i;
           memToReg = control_out.mem_to_reg ? data_mem_out : alu_result;
           dataToCsr = (control_out.csr_source) ? reg_file_read_data1 : 32'(control_out.rs1);

           unique case (control_out.regData)
             2'b00: reg_file_write_data = memToReg;
             2'b01: reg_file_write_data = PC_reg + 4;
             2'b10: reg_file_write_data = csrReadData;
             2'b11: reg_file_write_data = immediate_val;
           endcase
           stage_next = CALC_NEXT_PC;
        end
        CALC_NEXT_PC: begin
           alu_control = ALU_add;

           if (control_out.excRequest) begin
              jumpToMtvec = 1;
              PC_next = mtvec;
              stage_next = PC_FETCH;
           end else  begin
              if(control_out.is_jal) begin
                 shouldTakeJump_next = 1;
                 PC_JumpDst = alu_result;
              end else if(control_out.is_jalr) begin
                 shouldTakeJump_next = 1;
                 PC_JumpDst = {alu_result[31:1], 1'b0};
              end else if(control_out.is_branch & alu_result[0]) begin
                 shouldTakeJump_next = 1;
                 alu_data1 = PC_reg;
                 alu_data2 = immediate_val;
                 alu_start = 1;
              end else if(control_out.excRet) begin
                 PC_next = mepc;
              end else begin
                 alu_data1 = PC_reg;
                 alu_data2 = 4;
                 alu_start = 1;
              end

              if (alu_start) begin
                 stage_next = WAIT_ALU_PC;
              end else if (~shouldTakeJump_next) begin
                 stage_next = PC_FETCH;
              end else begin
                 excDetect_shouldJump = 1;
                 stage_next = PC_FETCH;
                 if (exceptionPresent) begin
                    jumpToMtvec = 1;
                    PC_next = mtvec;
                    stage_next = PC_FETCH;
                 end else  begin
                    PC_next = PC_JumpDst;
                    stage_next = PC_FETCH;
                 end
              end
           end
        end
        WAIT_ALU_PC: begin
           alu_control = ALU_add;
           shouldTakeJump_next = shouldTakeJump_reg;
           stage_next = alu_will_be_done ? STORE_ALU_PC : WAIT_ALU_PC;
        end
        STORE_ALU_PC: begin
           PC_next = alu_result;
           if (shouldTakeJump_reg) begin
              excDetect_shouldJump = 1;
              PC_JumpDst = alu_result;
              if (exceptionPresent) begin
                 jumpToMtvec = 1;
                 PC_next = mtvec;
              end
           end
           stage_next = PC_FETCH;
        end
      endcase
   end

endmodule
