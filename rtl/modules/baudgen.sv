import Common::*;

// baudrate 9600 -> 1041.5 counts

module baudGen #(parameter baudRate = 1085)
  (input logic clk,rst,
  input logic e_baudrate,
  output logic clk_baud
  );

//baudrates = [115200, 57600, 38400, 19200, 9600, 4800, 2400, 1200, 600, 300]

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

assign clk_baud = (cnt==0) ? e_baudrate:0;

endmodule
