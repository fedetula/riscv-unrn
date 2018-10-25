import Common::*;
import Control::*;

module excDetect(
                input logic [31:0]  pc_i,
                input logic [31:0]  dataAddress_i,
                input memInstType_t memInstType_i,
                input opcode_t      opcode_i,
                input logic         priv_i,
                input logic [31:0]  privCause_i,

                output logic [31:0] excCause_o,
                output logic [31:0] trapInfo_o,
                output logic        excPresent_o,
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
    if (pc_i[1:0] != 2'b00) begin
        excPresent = 1;
        excCause = M_INSTR_MISALIGN;
        trapInfo = pc_i;
    end
    // Invalid PC
    else if ((pc_i < PC_VALID_RANGE_BASE) || (pc_i > PC_VALID_RANGE_LIMIT) ) begin
        excPresent = 1;
        excCause = M_INSTR_AFAULT;
        trapInfo = pc_i;
    end
    // Invalid memory access
    else if (memInstType_i[3]) begin
        if ((dataAddress_i < MEM_VALID_RANGE_BASE) || (dataAddress_i > MEM_VALID_RANGE_LIMIT) ) begin
          excPresent = 1;
          case (memInstType)
            MEM_LB, MEM_LH,MEM_LW, MEM_LBU MEM_LHU: excCause_o = M_LOAD_AFAULT;
            MEM_SB, MEM_SH, MEM_SW:                 excCause_o = M_STORE_AFAULT;
          endcase
          trapInfo = dataAddress_i;
        end
    end
    // Privilieged instruction
    else if (priv_i) begin
      excPresent = 1;
      excCause  = privCause_i;
      trapInfo = pc_i;
    end
    // Misaligned memory access
    else  begin
      case (dataAddress_i[1:0])
        1: begin
              case (memInstType_i)
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
        default: excPresent = 0;
      endcase
    end
  end

endmodule
