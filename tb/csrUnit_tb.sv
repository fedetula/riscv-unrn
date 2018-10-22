`timescale 1ns / 1ps

import riscV_unrn_pkg::*;




module csrUnit_tb();
  // Clock and Reset
   logic clk, rst;
  // From CSR Instructions
   csr_op_t op_i;
   csr_num_t address_i;
   logic [4:0] rd_i;
  // From datapath
   logic [XLEN-1:0] data_i;
   logic [XLEN-1:0] data_o;
  // Exceptions
   logic [31:0] pc_i;       // Actual PC causing the exception
   logic excRequest_i;       // EXception request from controller
   logic [31:0] excCause_i;  // Exception Cause Code
   logic exc_o;              // We have an exception if enabled
   logic [31:0] trapInfo_i;

   task write_set_clear();
     // Test CSRRNOP
     op_i = CSRRNOP;
     data_i = 32'hFFFF_FFFF;
     #10;
     // Test read/write
     op_i = CSRRW;
     #10;
     // Test read/clear
     op_i = CSRRC;
     #10;
     // Test read/set
     op_i = CSRRS;
     #10;
   endtask : write_set_clear

  //DUT
  csrUnit csrs(.*);

  // Generate clock
  always begin
    clk = 1; #5; clk = 0; #5;
  end

  // Generate reset
  initial begin
    rst = 1; #50; rst = 0;
  end

  initial begin
    // Signals intitialization
    op_i = CSRRW;
    address_i = CSR_MSTATUS;
    rd_i = 1;
    data_i = 1;
    pc_i = 32'hAAAA_AAAA;
    excRequest_i = 0;
    excCause_i = M_EXT_INT;
    #100;

    // Testing read_write_set_clear operations

    // // mstatus
    // write_set_clear();
    // // mtvec
    // address_i = CSR_MTVEC;
    // write_set_clear();
    // // mip
    // address_i = CSR_MIP;
    // write_set_clear();
    // // mie
    // address_i = CSR_MIE;
    // write_set_clear();
    // // mie
    // address_i = CSR_MSCRATCH;
    // write_set_clear();
    // // mepc
    // address_i = CSR_MEPC;
    // write_set_clear();

    // Testing Exceptions

    //Enable Interrupts
    data_i = 32'hFFFF_FFFF;
    op_i = CSRRS;
    address_i = CSR_MIE;      //Machine External
    #10;
    address_i = CSR_MSTATUS;  //Global
    #10;
    // Raise exception excRequest
    excRequest_i = 1;
    excCause_i = M_EXT_INT;
    trapInfo_i = 32'h5555_5555;


  end


endmodule
