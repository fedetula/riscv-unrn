`timescale 1ns / 1ps

import riscV_unrn_pkg::*;

module csrUnit
  (
  // Clock and Reset
  input logic clk, rst,
  // From CSR Instructions
  input csr_op_t op_i,
  input csr_num_t address_i,
  // From datapath
  input logic [XLEN-1:0] data_i,
  output logic [XLEN-1:0] data_o,
  // Exceptions
  input logic [31:0] pc_i,            // Actual PC causing the exception
  input logic excRequest_i,           // Exception request from controller
  input logic [31:0] excCause_i,      // Exception Cause Code
  input logic [31:0] trapInfo_i,      // Trap Informtation from Controller
  output logic exc_o,                 // We have an exception if enabled
  output logic [31:0] mtvec_o,        // Trap Vector output
  output logic [31:0] mepc_o
  );

  //////////////////////////
  // Internal Signals
  //////////////////////////

  csr_raw_t csrWrite, csrRead;
  logic     we;


  // Operation decode and write data setup
  always_comb begin
    csrWrite = data_i;
    unique case (op_i)
      CSRRNOP: we = 0;
      CSRRW: csrWrite = data_i;
      CSRRS: csrWrite = data_i | csrRead;
      CSRRC: csrWrite = (~data_i) & csrRead;
    endcase
  end

  ////////////////////////////////
  // Constant output assignments
  ////////////////////////////////
  assign data_o = csrRead;
  assign mtvec_o = mtvec_reg;
  assign mepc_o = mepc_reg;

  // TODO : Verify this section
  // Check if enabled and pending interrupt match
  assign exc_o = (mstatus_reg.mie) ? (mie_reg.meie && mip_reg.meip): 1'b0;

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
  always_comb begin : read_logic

    case (address_i)
      CSR_MSTATUS:  csrRead = mstatus_reg;
      CSR_MTVEC:    csrRead = mtvec_reg;
      CSR_MIP:      csrRead = mip_reg;
      CSR_MIE:      csrRead = mie_reg;
      CSR_MSCRATCH: csrRead = mscratch_reg;
      CSR_MEPC:     csrRead = mepc_reg;
      CSR_MCAUSE:   csrRead = mcause_reg;
      CSR_MTVAL:    csrRead = mtval_reg;
      default:      csrRead = 32'b0;
    endcase

  end : read_logic

  ///////////////
  // Write Logic
  //////////////
  always_comb begin : write_logic

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
                        mstatus_next.sie = 1'b0;
                        mstatus_next.wpri4 = 1'b0;
                        mstatus_next.upie = 1'b0;
                        mstatus_next.spie = 1'b0;rd
                        mstatus_next.wpri3 = 1'b0;
                        mstatus_next.spp = 1'b0;
                        mstatus_next.wpri2 = 1'b0;
                        mstatus_next.fs = 2'b0;
                        mstatus_next.xs = 2'b0;
                        mstatus_next.mprv = 1'b0;
                        mstatus_next.sum = 1'b0;
                        mstatus_next.mxr = 1'b0;
                        mstatus_next.tvm = 1'b0;
                        mstatus_next.tw = 1'b0;
                        mstatus_next.tsr = 1'b0;
                        mstatus_next.wpri1 = 8'b0;
                        mstatus_next.sd = 1'b0;
                     end

        CSR_MTVEC:    begin
                        mtvec_next = {csrWrite[31:2],2'b0}; //Two LSBs hardwired to zero
                      end
        CSR_MIP:      begin
                      // No U or S Modes, we do not write to mip register through csr instructions
                      end
        CSR_MIE:      begin
                        mie_next = csrWrite & SUPPORTED_INTERRUPTS_MASK;
                      end
        CSR_MSCRATCH: begin
                        mscratch_next = csrWrite;
                      end
        CSR_MEPC:     begin
                        mepc_next = {csrWrite[31:2],2'b0};
                      end
        CSR_MCAUSE:   begin
                        mcause_next = csrWrite; // TODO: Verify if we protect form writing illegal exception values
                      end
        CSR_MTVAL:    begin
                        mtval_next = csrWrite;
                      end
        //default: ;
      endcase

    end

    ////////////////////////////
    // Manage exception Inputs
    ////////////////////////////

    if (excRequest_i & mstatus_reg.mie) begin     //Exception request fromm controller
      mip_next.meip = mie_next.meie;            // Raise pending exception flag if enabled
      // mstatus??
      mepc_next = pc_i;         // Save actual pc
      mcause_next = excCause_i;  // Register exception cause

      mtval_next = trapInfo_i;  // TODO: Verify if specific values should be written within this block

    end

  end : write_logic



  always_ff @ (posedge clk) begin
      if(rst) begin
        mstatus_reg   <= '0;
        mtvec_reg     <= '0;
        mip_reg       <= '0;
        mie_reg       <= '0;
        mscratch_reg  <= '0;
        mepc_reg      <= '0;
        mcause_reg    <= '0;
        mtval_reg     <= '0;
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
