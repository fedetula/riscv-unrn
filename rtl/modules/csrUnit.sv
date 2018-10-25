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
  output logic [31:0] mepc_o,
  // Timers
  input logic [31:0] mtimeData_i,
  input logic mtimeWe_i,
  input logic [31:0] mtimeAddress_i,
  output logic [31:0] mtimeData_o

  );

  //////////////////////////
  // Internal Signals
  //////////////////////////

  csr_raw_t csrWrite, csrRead;
  logic     we;   // Write enable to registers

  // Operation decode and write data setup
  always_comb begin
    csrWrite = data_i;
    we = 1;
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

  csr_raw64_t   mtime_reg, mtime_next;
  csr_raw64_t   mtimecmp_reg, mtimecmp_next;

  ////////////////////
  // Actual Registers
  ////////////////////

  ///////////////
  // Read Logic
  ///////////////

  // Common CSRs
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

  // Timer Registers
      case (mtimeAddress_i)
        MTIME_ADDRESS_LOW:      mtimeData_o = mtime_reg[31:0];
        MTIME_ADDRESS_HIGH:     mtimeData_o = mtime_reg[63:32];
        MTIMECMP_ADDRESS_LOW:   mtimeData_o = mtimecmp_reg[31:0];
        MTIMECMP_ADDRESS_HIGH:  mtimeData_o = mtimecmp_reg[63:32];
        default: ;
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
                        mstatus_next.spie = 1'b0;
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
                        //Use only one of this lines: Hardcoded value vs. write data from datapath
                        //mtvec_next = {csrWrite[31:2],2'b0}; // Two LSBs hardwired to zero
                        mtvec_next = HARDCODED_MTVEC; // Two LSBs hardwired to zero
                      end
        CSR_MIP:      begin
                        mip_next = csrWrite & 32'h080;    // TODO: Verify this mask! Only accesible bit is MTIP for clearing Timer interrupts
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

    ///////////////////////////
    //  Timer registers write
    ///////////////////////////

    // TODO: Timer exceptions/interrupts
    mtime_next = mtime_reg + 1;
    mtimecmp_next = mtimecmp_reg;
    if (mtimeWe_i) begin
      case (mtimeAddress_i)
        MTIME_LOW:      mtime_next = {mtime_reg[63:32],mtimeData_i};
        MTIME_HIGH:     mtime_next = {mtimeData_i,mtime_reg[31:0]};
        MTIMECMP_LOW:   begin
                          mtimecmp_next = {mtimecmp_reg[63:32],mtimeData_i};
                        mip_next.mtip = 0;      // Clear mtime pending interrupt bit when writing to mtimecmp register
                        end
        MTIMECMP_HIGH:  begin
                          mtimecmp_next = {mtimeData_i,mtimecmp_reg[31:0]};
                          mip_next.mtip = 0;    // Clear mtime pending interrupt bit when writing to mtimecmp register
                        end
        default: ;
      endcase
    end

    ////////////////////////////
    // Timer Exception detect
    ////////////////////////////
    // Raise mtime pending interrupt bit if interrupt enabled and timer overflowed
    if (mstatus_reg.mie && mie_reg.mtie) begin
      if (mtime_reg >= mtimecmp_reg) begin
        mip_next.mtip = 1;
      end
    end


    //////////////////////////////////////////////////////
    // Manage exceptions conditions to write to registers that need to be written
    /////////////////////////////////////////////////////

    if ((excRequest_i || mip_next.mtip) & mstatus_reg.mie) begin   //Exception request fromm controller or timer overflow
      //mip_next.meip = mie_next.meie;                             // Raise pending exception flag if enabled NOT IMPLEMENTED: WE ARE NOT USING EXTERNAL INTERRUPTS
      mepc_next = pc_i;                                            // Save actual pc
      mcause_next = mip_next.mtip ? M_TIMER_INT : excCause_i;      // Register exception cause.

      mtval_next = trapInfo_i;  // TODO: Verify if specific values should be written within this block
    end

  end : write_logic




  // Check if enabled and pending interrupt match
  assign exc_o = (mstatus_reg.mie) ? (mie_reg.meie && mip_reg.meip): 1'b0;


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
        mtime_reg     <= '0;
        mtimecmp_reg  <= '0;
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
        mtime_reg     <= mtime_next;
        mtimecmp_reg  <= mtimecmp_next;
      end
  end



endmodule
