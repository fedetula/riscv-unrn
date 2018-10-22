module TOP(
    input logic clk,
    input logic sw,
//    output logic[3:0] led
    );
    
    clk_wiz_0 clk_wiz(.clk_out1(clk_lento), .clk_in1(clk));
    
    Uniciclo uniciclo(.clk(clk_lento), .rst(sw));
    
endmodule
