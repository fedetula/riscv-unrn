`timescale 1ns / 1ps

import Common::*;

module top_uart(input logic btn,
                input logic rst,
                input logic clk,
                input logic [3:0] sw,
                output logic enviado,
                output logic ocupado,
                output logic je);
    
logic e_baud,clk_baud,e_write,e_read,busy_tx,e_busTX,TX,RX,n_paso;
    uint8 tx_data;
    uint32 w_data,r_data;
    
logic libre,DB_out;

//typedef enum {esperar,mandar} state_t;
    
uartController inst1 (clk,rst,e_write,e_read,busy_tx,w_data,e_busTX,tx_data,r_data);
baudGen inst2 (clk,rst,e_baud,clk_baud);
uartTX inst3 (clk,rst,e_busTX,clk_baud,tx_data,busy_tx,e_baud,TX);
DeBounce paraEnviar(clk,rst,btn,DB_out);

//assign DB_out = btn; 

always_ff @(posedge clk)
    if(rst) begin
      enviado <= 0;
      //e_read <= 1;
      e_write <= 0;
      ocupado <= 0;
    end else if(~libre) begin
        ocupado <= 0;
        if(DB_out) begin
            enviado <= 1;
            e_write <= 1;
        end else begin
            enviado <= 0;
        end   
    end else begin
       enviado <= 0;
       e_write <= 0;
       ocupado <= 1;
    end 
 
 assign e_read = 1;           
 assign je = TX;     
 assign libre = r_data[31];
 assign w_data = {27'b0,sw};  
    
endmodule
