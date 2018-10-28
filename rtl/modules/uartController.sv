import Common ::*;

module uartController
  (input logic clk,rst,
   input logic e_write,e_read,busy_tx,
   input uint32 w_data,
   output logic e_busTX,
   output uint8 tx_data,
   output uint32 r_data
  );

// status_fifo_tx == 0 -> fifo no esta completa
// status_fifo_tx == 1 -> fifo esta completa

logic [2:0] cant_tx;
logic [1:0] indice1_tx,indice2_tx;
logic status_fifo_tx;
uint8 fifo_tx [4];
uint32 registerTX;

typedef enum {idle,transmit} state_t;
state_t reg_state,next_state;


//-----Machine state-----

always_ff @(posedge clk) begin
  if(rst) begin
    reg_state<=idle;
  end
  else begin
    reg_state<=next_state;
  end
end

always_comb begin
  case(reg_state)
    idle: begin
      if(cant_tx>0) begin
        next_state=transmit;
      end
    end
    transmit:begin
      if(!busy_tx) begin
        next_state = idle;
      end
    end
    default: begin
        next_state = idle;
    end
  endcase
end

always_comb begin
  e_busTX = 0;
  tx_data = 0;
  case(reg_state)
    idle:begin
    if(cant_tx>0) begin
      e_busTX = 1;
    end
    end
    transmit: begin
//      e_busTX = 1;
      tx_data = fifo_tx[indice2_tx];
      if(busy_tx==0) begin
        cant_tx = cant_tx-1;
        case(indice2_tx)
          0:begin
            indice2_tx = 1;
          end
          1:begin
            indice2_tx = 2;
          end
          2:begin
            indice2_tx = 3;
          end
          3:begin
            indice2_tx = 0;
          end
         endcase
      end
    end
  endcase
end

//-----STATUS FIFO-----

assign status_fifo_tx = (cant_tx == 4) ? 1 : 0;

//-----FIFO TX-----

always_ff @(posedge clk) begin
  if(rst) begin
    indice1_tx <= 0;
    indice2_tx<=0;
    fifo_tx <= '{default:0};
    cant_tx <=0;
  end
  else if(!status_fifo_tx && registerTX[31]) begin
    case(indice1_tx)
      0:begin
            fifo_tx[0] <= registerTX;
            indice1_tx <= 1;
            cant_tx <= cant_tx + 1;
            registerTX<=registerTX & 32'h7fffffff;
      end
      1:begin
          fifo_tx[1] <= registerTX;
          indice1_tx <= 2;
          cant_tx <= cant_tx + 1;
          registerTX<=registerTX & 32'h7fffffff;
      end
      2:begin
          fifo_tx[2] <= registerTX;
          indice1_tx <= 3;
          cant_tx <= cant_tx + 1;
          registerTX<=registerTX & 32'h7fffffff;
      end
      3:begin
          fifo_tx[3] <= registerTX;
          indice1_tx <= 0;
          cant_tx <= cant_tx + 1;
          registerTX<=registerTX & 32'h7fffffff;
      end
    endcase
  end
end


//-----REGISTER TX-----
always_ff @(posedge clk) begin
    if(rst)begin
        registerTX <= 0;
    end
    else if(e_write && !registerTX[31]) begin
//        if(status_fifo_tx) begin
          registerTX<= {1'b1,w_data[30:0]};
//        end
//        else begin
//          registerTX <= {1'b1,w_data[30:0]};
//        end
    end
end

assign r_data = (e_read) ? registerTX : {1'b1,31'b0};

endmodule
