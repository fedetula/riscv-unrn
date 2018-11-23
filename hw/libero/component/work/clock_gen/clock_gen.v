//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Fri Nov 23 13:03:34 2018
// Version: v11.9 SP1 11.9.1.0
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// clock_gen
module clock_gen(
    // Outputs
    GL0,
    RCOSC_25_50MHZ_O2F
);

//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output GL0;
output RCOSC_25_50MHZ_O2F;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   GL0_net_0;
wire   OSC_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC;
wire   RCOSC_25_50MHZ_O2F_net_0;
wire   RCOSC_25_50MHZ_O2F_net_1;
wire   GL0_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire   GND_net;
wire   [7:2]PADDR_const_net_0;
wire   [7:0]PWDATA_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net            = 1'b0;
assign PADDR_const_net_0  = 6'h00;
assign PWDATA_const_net_0 = 8'h00;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign RCOSC_25_50MHZ_O2F_net_1 = RCOSC_25_50MHZ_O2F_net_0;
assign RCOSC_25_50MHZ_O2F       = RCOSC_25_50MHZ_O2F_net_1;
assign GL0_net_1                = GL0_net_0;
assign GL0                      = GL0_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------clock_gen_FCCC_0_FCCC   -   Actel:SgCore:FCCC:2.0.201
clock_gen_FCCC_0_FCCC FCCC_0(
        // Inputs
        .RCOSC_25_50MHZ ( OSC_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC ),
        // Outputs
        .GL0            ( GL0_net_0 ),
        .LOCK           (  ) 
        );

//--------clock_gen_OSC_0_OSC   -   Actel:SgCore:OSC:2.0.101
clock_gen_OSC_0_OSC OSC_0(
        // Inputs
        .XTL                ( GND_net ), // tied to 1'b0 from definition
        // Outputs
        .RCOSC_25_50MHZ_CCC ( OSC_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC ),
        .RCOSC_25_50MHZ_O2F ( RCOSC_25_50MHZ_O2F_net_0 ),
        .RCOSC_1MHZ_CCC     (  ),
        .RCOSC_1MHZ_O2F     (  ),
        .XTLOSC_CCC         (  ),
        .XTLOSC_O2F         (  ) 
        );


endmodule
