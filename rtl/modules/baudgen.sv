//Baud Generator

module uart_tx #(PARAMETER baudRate=9600)
  (input logic clk,rst,
  input logic e_baudrate,
  output logic clk_baud
  );

localparam N = $clog2(baudRate);

logic [N-1:0] cnt;

always_ff @(posedge clk) begin
  if(rst) begin
    cnt<=0;
  end
  else if (e_baudrate)begin
    cnt <= (cnt == baudRate - 1) ? 0 : cnt + 1;
  end
  else begin
    cnt <= 0;
  end
end

assign clk_baud=(cnt==0) ? e_baudrate : 0;
