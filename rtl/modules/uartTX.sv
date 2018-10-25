//uart TX

typedef logic [7:0] uint8;

module uartTX
  (input logic clk,rst,
   input logic e_bus,
   input logic baud_rate,
   input uint8 data,
   output logic busy,
   output logic TX_transmit,
  );


uint8 data_aux;
logic [9:0] shift_register;
logic [3:0] counter;
logig load;

always_ff @(posedge clk) begin
  if(rst) begin
    data_aux<=0;
    load<=0;
  end
  else if(e_bus) begin
    data_aux<=data;
    load<=1;
  end
end

always_ff @(posedge clk) begin
  if(rst) begin
    shift_register <= 10'b11_1111_1111;
    busy<=0;
    counter<=0;
  end
  else if(load) begin
    shift_register <= {data_aux,2'b10};
    counter
    load<=0;
  end
  else if(!e_bus && baud_rate) begin
    shift_register <= {1'b1,shift_register[9:1]};
    counter <= counter + 1;
    if(counter==10)begin
      busy<=0;
      counter<=0;
    end
    else begin
      busy<=1
    end
  end
end
