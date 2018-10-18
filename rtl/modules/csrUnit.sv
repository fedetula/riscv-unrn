`timescale 1ns / 1ps

import riscV_unrn_pkg::*;

module csrUnit
  (
  //Clock and Reset
  input logic clk, rst,

  input csr_op_t op_i,
  input csr_num_t address_i,
  input logic [4:0] rd,
  input logic [31:0] pc,
  input logic [XLEN-1:0] data_i,
  output logic [XLEN-1:0] data_o);

  //////////////////////////
  // Internal Signals
  //////////////////////////

  csr_raw_t csrWrite, csrRead;
  logic     we;


  // Operation decode and write data setup
  always_comb begin
    //csrWData = data_i;
    we = (rd == 0) ? 0 : 1;  //Do not write to CSRs if destination register is x0
    unique case (op_i)
      CSRRW: csrWrite = data_i;
      CSRRS: csrWrite = data_i | csrRead;
      CSRRC: csrWrite = (~data_i) & csrRead;
      default: ;
    endcase
  end


  //////////////////////////
  // Implemented Registers
  //////////////////////////

  //TODO: Verify stripping unused bits, actually all registers are 32 bits
  mstatus_csr_t mstatus_reg, mstatus_next;
  csr_raw_t     mtvec_reg, mtvec_next;
  mip_csr_t     mip_reg, mip_next;
  mie_csr_t     mie_reg, mie_next;
  csr_raw_t     mscratch_reg, mscratch_next;
  csr_raw_t     mepc_reg, mepc_next;
  csr_raw_t     mcause_reg, mcause_next;
  csr_raw_t     mtval_reg, mtval_next;


  ////////////////////
  // Actual Registers
  ////////////////////

  ///////////////
  // Read Logic
  ///////////////
  always_comb begin

    unique case (address_i)
      CSR_MSTATUS:  csrRead = mstatus_reg;
      CSR_MTVEC:    csrRead = mtvec_reg;
      CSR_MIP:      csrRead = mip_reg;
      CSR_MIE:      csrRead = mie_reg;
      CSR_MSCRATCH: csrRead = mscratch_reg;
      default: ;
    endcase

  end
  ///////////////
  // Write Logic
  //////////////
  always_comb begin

    mstatus_next   = mstatus_reg;
    mtvec_next     = mtvec_reg;
    mip_next       = mip_reg;
    mie_next       = mie_reg;
    mscratch_next  = mscratch_reg;
    mepc_next      = mepc_reg;
    mcause_next    = mcause_reg;
    mtval_next     = mtval_reg;

    if (we) begin
      unique case (address_i)
        CSR_MSTATUS: begin
                        mstatus_next = csrWrite;
                        //Hardwired fields
                        mstatus_next.uie = 1'b0;
                        mstatus_next.fs = 2'b0;
                        mstatus_next.xs = 2'b0;
                        mstatus_next.mprv = 1'b0;
                        mstatus_next.sum = 1'b0;
                        mstatus_next.mxr = 1'b0;
                        mstatus_next.tvm = 1'b0;
                        mstatus_next.tw = 1'b0;
                        mstatus_next.tsr = 1'b0;
                        mstatus_next.sd = 1'b0;
                     end

        CSR_MTVEC:    begin
                        //TODO: Define if writeable
                        mtvec_next = {csrWrite[31:2],2'b0} //Two LSBs hardwired to zero
                        //Or not
                        //mtvec_next = MTEVC_BASE_ADDRESS
                      end

        CSR_MIP:      begin
                      //TODO: Define which bits are writeable through CSR instructions, apparently none for this implementation
                      end
        CSR_MIE:      begin:
                        mie_next = csrWrite & SUPPORTED_INTERRUPTS_MASK;
                      end
        CSR_MSCRATCH: begin:
                        mscratch_next = csrWrite;
                      end
        default: ;
      endcase
    end


  end


  always_ff @ (posedge clk) begin
      if(rst) begin
        //TODO: Review reset conditions for registers
        mstatus_reg = '0;
      end
      else  begin
        mstatus_reg   <= mstatus_next;
        mtvec_reg     <= mtvec_next;
        mip_reg       <= mip_next;
        mie_reg       <= mie_next;
        mscratch_reg  <= mscratch_next;
        mepc_reg      <= mepc_next;
        mcause_reg    <= mcause_next;
        mtval_reg     <= mtval_next;
      end
  end


endmodule
