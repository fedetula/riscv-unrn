import Common ::*;

module uartTX
  (input logic clk,rst,
   input logic e_bus,
   input logic baud_rate,
   input uint8 data,
   output logic busy,e_baudrate,
   output logic TX_transmit
  );

uint8 data_aux;
logic [9:0] shift_register;
logic [3:0] counter;
logic load;
typedef enum {idle,start,send} state_t;
state_t reg_state, next_state;


always_ff @(posedge clk) begin
     if (rst) begin
		reg_state<= idle;
    end
    else begin
		reg_state <= next_state;
	end
end

//logica de transicion
always_comb begin
  next_state = reg_state; 
  load = 0;
  e_baudrate = 0;
  case (reg_state)
    idle: begin
        busy = 0;
		if (e_bus) begin
			next_state = start;
			busy = 1;
		end
	end
    start: begin
      load = 1;
      busy = 1;
      next_state = send;
    end
    send: begin
      e_baudrate = 1;
      busy = 1;
      if (counter == 10)
        next_state = idle;
    end
    default: begin
      busy = 1;
	end
  endcase
end

assign data_aux = (load) ? data : 0;

/*always_ff @(posedge clk) begin
	if(reg_state==idle) begin
		if(e_bus) begin
			data_aux<=data;
		end
		else begin
			data_aux<=0;
		end
	end
end*/

always_ff @(posedge clk) begin
	if(rst) begin
	    TX_transmit<=1;
		shift_register <= 10'b11_1111_1111;
		counter <= 0;
	end
	else if (load) begin
		shift_register <= {1'b1,data_aux,1'b0};
		counter <= 0;
	end
	else if (!load && baud_rate) begin
	    TX_transmit<=shift_register[0];
		shift_register <= {1'b1, shift_register[9:1]};
		counter <= counter + 1;
	end
end


endmodule