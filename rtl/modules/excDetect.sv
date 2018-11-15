import Common::*;
import riscV_unrn_pkg::*;


module excDetect(
                 input               shouldJump_i,
                 input logic [31:0]  pcJumpDst_i,
                 input logic [31:0]  pc_i,
                 input logic [31:0]  dataAddress_i,
                 input               mem_inst_type_t memInstType_i,
                //input opcode_t      opcode_i,
                 input logic         inst_invalid_i,
                 input logic         priv_i,
                 input logic [31:0]  privCause_i,
                 input logic         mtime_exc_i,
                 output logic [31:0] excCause_o,
                 output logic [31:0] trapInfo_o,
                 output logic        excPresent_o
                );

logic excPresent;
logic [31:0] excCause;
logic [31:0] trapInfo;

assign  excPresent_o = excPresent;
assign  excCause_o = excCause;
assign  trapInfo_o = trapInfo;

  always_comb begin
    excPresent = 0;
    excCause = 0;     //TODO: Verify this default values
    trapInfo = 0;     //TODO: Verify this default values

    // Misaligned PC
    if (shouldJump_i && pcJumpDst_i[1:0] != 2'b00) begin
        excPresent = 1;
        excCause = M_INSTR_MISALIGN;
        trapInfo = pcJumpDst_i;
    end
    // Invalid PC
    else if ((pc_i < PC_VALID_RANGE_BASE) || (pc_i > PC_VALID_RANGE_LIMIT) ) begin
        excPresent = 1;
        excCause = M_INSTR_AFAULT;
        trapInfo = pc_i;
    end
    // Invalid Instruction
    else if (inst_invalid_i) begin
      excPresent = 1;
      excCause = M_ILL_INSTR;
      trapInfo = pc_i;
    end
     // Privilieged instruction
    else if (priv_i) begin
       excPresent = 1;
       excCause  = privCause_i;
       trapInfo = pc_i;
    end
    // Invalid memory access
    else if (memInstType_i[3]) begin
           if (dataAddress_i != 'h100
               && ~((dataAddress_i < MEM_VALID_RANGE_BASE)
                 || (dataAddress_i > MEM_VALID_RANGE_LIMIT))
               &&  ~((dataAddress_i < MTIME_MEM_ADDRESS_LOW)
                     || (dataAddress_i > MTIMECMP_MEM_ADDRESS_HIGH))) begin
          excPresent = 1;
          case (memInstType_i)
            default: begin end
            MEM_LB, MEM_LH, MEM_LW, MEM_LBU, MEM_LHU: excCause = M_LOAD_AFAULT;
            MEM_SB, MEM_SH, MEM_SW:                 excCause = M_STORE_AFAULT;
          endcase
          trapInfo = dataAddress_i;
       end else  begin
          trapInfo = dataAddress_i;
           case (dataAddress_i[1:0])
             1: begin
                case (memInstType_i)
                  default: begin end
                  MEM_LH,MEM_LW,MEM_LHU: begin
                     excPresent = 1;
                     excCause = M_LOAD_MISALIGN;
                  end
                  MEM_SH, MEM_SW:        begin
                     excPresent = 1;
                     excCause = M_STORE_MISALIGN;
                  end
                endcase
             end
             2: begin
                case (memInstType_i)
                  default: begin end
                  MEM_LW: begin
                     excPresent = 1;
                     excCause = M_LOAD_MISALIGN;
                  end
                  MEM_SW:        begin
                     excPresent = 1;
                     excCause = M_STORE_MISALIGN;
                  end
                endcase
             end
             3: begin
                case (memInstType_i)
                  default: begin end
                  MEM_LH,MEM_LW,MEM_LHU: begin
                     excPresent = 1;
                     excCause = M_LOAD_MISALIGN;
                  end
                  MEM_SH, MEM_SW:        begin
                     excPresent = 1;
                     excCause = M_STORE_MISALIGN;
                  end
                endcase
             end
             default: begin
                excPresent = 0;
                trapInfo = 0;
             end
           endcase
        end
       if (excPresent) begin
          $display("============warning==========");
       end
    end
    else if (mtime_exc_i) begin
       excPresent = 1;
       excCause = M_TIMER_INT;
    end
  end
endmodule
