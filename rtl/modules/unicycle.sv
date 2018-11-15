import Common::*;
//import Control::*;

module unicycle(
                input logic  clk,
                input logic  rst,
                //Memory Interface
                output       mem_inst_type_t instType_o,
                output       uint32 writeData_o,
                output       uint32 dataAddress_o,
                input        uint32 readData_i,
                output       uint32 pc_o,
                input        raw_instr_t instruction_i,
                output logic exception_o,
                output uint32 mtime_debug_o
                );

    /////////////////////
    // Internal signals
    ////////////////////

    uint32 alu_data1, alu_data2;                   // ALU Operands
    uint32 alu_result;                             // ALU output
    logic exceptionPresent;
    logic mtime_exc;
    logic isJump;

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
    uint32 PC_JumpDst;

    assign PC_plus_4 = PC_reg + 4;

   logic  jumpToMtvec;
   assign jumpToMtvec = control_out.excRequest || exceptionPresent;

    //select PC_next
    always_comb begin
        //Logica para PC_next
        pc_next_t pcSource;
        isJump = 0;

        if(control_out.is_branch & alu_result[0]) begin
            isJump = 1;
            PC_JumpDst = PC_reg + immediate_val;
        end if(control_out.is_jal) begin
            isJump = 1;
            PC_JumpDst = memToReg;
        end else if(control_out.is_jalr) begin
            isJump = 1;
            PC_JumpDst = {memToReg[31:1], 1'b0};
        end

        if (jumpToMtvec) begin
            pcSource = Common::PC_MTVEC;
        end else if(control_out.is_jal) begin
            pcSource = Common::PC_JUMP;
        end else if(control_out.is_jalr) begin
            pcSource = Common::PC_JUMP_R;
        end else if(control_out.is_branch & alu_result[0])
        pcSource = Common::PC_BRANCH;
        else if(control_out.excRet)
        pcSource = Common::PC_MEPC;
        else
        pcSource = Common::PC_PLUS_4;

        case (pcSource)
            Common::PC_PLUS_4: PC_next = PC_plus_4;
            Common::PC_BRANCH: PC_next = PC_reg + immediate_val;
            Common::PC_JUMP: PC_next = memToReg;
            Common::PC_JUMP_R: PC_next = {memToReg[31:1], 1'b0};
            Common::PC_MTVEC: PC_next = mtvec;
            Common::PC_MEPC: PC_next = mepc;
            default: PC_next = PC_plus_4;
        endcase
    end


    always_ff @(posedge clk) begin
        if (rst) PC_reg <= 32'h8000_0004;
        else begin
            PC_reg <= PC_next;
        end
    end

    ////////////////////////////////////////////
    // Instruction decoding and immediate gen
    ////////////////////////////////////////////

    Common::decoded_instr_t decoded_instr;
    logic [31:0]  immediate_val;

    // assign decoded_instr = Common::decode_instruction(instruction_i);
    // assign immediate_val = Common::sign_extend_imm(decoded_instr);

    instr_decoder deco(.raw_instr_i (instruction_i),
                       .instr_o     (decoded_instr),
                       .imm_o       (immediate_val));

    // Control
    Common::control_out_t control_out;

    control_unit control(.instr_i    (decoded_instr),
                         .imm_i      (immediate_val),
                         .control_o  (control_out));

    //assign control_out = Control::control_from_instruction(decoded_instr);

    //////////////////
    // Register File
    //////////////////

    uint32 memToReg;
    uint32 mtimeData;

    // Data from memory or alu_result
    assign memToReg = control_out.mem_to_reg ? data_mem_out : alu_result;

    RegFile reg_file(.clk(clk),
    //.rst(rst),
    .read_reg1    (decoded_instr.rs1),
    .read_reg2    (decoded_instr.rs2),
    .write_reg   (decoded_instr.rd),
    .write_data   (reg_file_write_data),
    .write_enable (control_out.reg_write & ~exceptionPresent),
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

    logic mtimeWe;
    logic mem_from_mtime;

    assign pc_o = PC_reg;

    assign dataAddress_o = alu_result;
    assign writeData_o = reg_file_read_data2;

    // Check if we are accessing mtime or mtimemcmp registers
    always_comb begin
        instType_o = control_out.instType;
        case (dataAddress_o)
            riscV_unrn_pkg::MTIME_MEM_ADDRESS_LOW,
            riscV_unrn_pkg::MTIME_MEM_ADDRESS_HIGH,
            riscV_unrn_pkg::MTIMECMP_MEM_ADDRESS_LOW,
            riscV_unrn_pkg::MTIMECMP_MEM_ADDRESS_HIGH:
            begin         // If we actually are:
                // Write to registers if on store
                mtimeWe = control_out.instType[2] && (control_out.instType[1:0] != 2'b11);
                instType_o = Common::MEM_NOP;        // Invalidate access to memory
                mem_from_mtime = 1;   // Data comes from registes if on load
            end
            default: begin
                mtimeWe = 0;
                mem_from_mtime = 0;
            end
        endcase
    end

    assign data_mem_out = (mem_from_mtime) ?  mtimeData : readData_i;

    ////////////////////
    // CSRs
    ////////////////////
    uint32 dataToCsr;
    assign dataToCsr = (control_out.csr_source) ? reg_file_read_data1 : 32'(decoded_instr.rs1);

    logic [31:0] trapInfo;
    logic [31:0] excCause;

    csrUnit csrs(
                .clk           (clk),
                .rst           (rst),
                .op_i          (control_out.csr_op),
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
                .mtimeData_o   (mtimeData),
                 .mtime_debug_o
    );

    ////////////////////
    // excDetect
    ////////////////////

    assign exception_o = exceptionPresent;
    //Todavia no terminado revisar luego de finalizado las conexiones
    excDetect excDetect(
                        .shouldJump_i(isJump),
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


endmodule
