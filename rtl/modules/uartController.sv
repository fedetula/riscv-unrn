//Controller UART

typedef logic [31:0] uint32;
typedef logic [7:0] uint8;

module uartController
  (input logic clk,rst,
   input logic e_write,e_read,busy_tx,busy_rx,
   input logic instType,
   input uint8 rx_data,
   input uint32 w_data,
   output logic e_baudrate,e_busTX,e_busRX,
   output uint8 tx_data,
   output uint32 r_data
  );

// status_fifo_tx == 0 -> fifo no esta completa
// status_fifo_tx == 1 -> fifo esta completa
// status_fifo_rx == 0 -> fifo no esta vacia
// status_fifo_rx == 1 -> fifo esta vacia

// instType == 0 -> operacion de TX o RX
// instType == 1 -> view status_fifo

logic cant_tx,cant_rx;
logic indice1_tx,indice2_tx;
logic indice1_rx,indice2_rx;
logic status_fifo_rx,status_fifo_tx;
uint8 fifo_rx [4];
uint8 fifo_tx [4];

uint32 registerTX;
uint32 registerRX;

typedef enum {idle,start_tx,start_rx,transmit,recive} state_t;
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
  next_state = reg_state;
  case(reg_state)
    idle: begin
      if(e_read && !status_fifo_rx) begin
        next_state=start_rx;
      end
      else if(e_write && !status_fifo_tx) begin
        next_state=start_tx;
      end
    end
    start_rx: begin
      next_state=recive;
    end
    start_tx:begin
      next_state=transmit;
    end
    transmit:begin
      if(!busy_tx) begin
        next_state = idle;
      end
    end
    recive:begin

    end
    default:begin
      next_state<=idle;
    end
  endcase
end

always_comb begin
  e_baudrate = 0;
  e_busTX = 0;
  tx_data = 0;
  case(reg_state)
    idle:begin
    end
    start_tx: begin
      e_busTX = 1;
      e_baudrate = 1;
      tx_data = fifo_tx[indice2_tx];
    end
    transmit:begin
      e_baudrate = 1;
    end
  endcase
end

//-----STATUS FIFO-----

assign status_fifo_tx = (cant_tx == 4) ? 1 : 0;
assign status_fifo_rx = (cant_rx == 0) ? 1 : 0;

//-----FIFO TX-----

always_ff @(posedge clk) begin
  if(rst) begin
    cant_tx<=0;
    indice1_tx<=0;
    indice2_tx<=0;
  end
  else begin
    case(indice1_tx)
      0:begin
        if(e_write && !status_fifo_tx) begin
          fifo_tx[0] <= registerTX;
          registerTX <= 0;
          indice1_tx<=1;
          cant_tx <= cant_tx + 1;
        end
      end
      1:begin
        if(e_write && !status_fifo_tx) begin
          fifo_tx[1] <= registerTX;
          registerTX <= 0;
          indice1_tx<=2;
          cant_tx <= cant_tx + 1;
        end
      end
      2:begin
        if(e_write && !status_fifo_tx) begin
          fifo_tx[2] <= registerTX;
          registerTX <= 0;
          indice1_tx<=3;
          cant_tx <= cant_tx + 1;
        end
      end
      3:begin
        if(e_write && !status_fifo_tx) begin
          fifo_tx[3] <= registerTX;
          registerTX <= 0;
          indice1_tx<=0;
          cant_tx <= cant_tx + 1;
        end
      end
    endcase
  end
end

always_comb begin
   if(state_reg==transmit && !busy_tx) begin
    cant_tx = cant_tx - 1;
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
  end

end

//-----REGISTER TX-----

always_comb begin
  if(rst) begin
    registerTX=0;
  end
  else if(e_write) begin
    if(registerTX==0)begin
      registerTX = w_data & 32'h800000FF;
      r_data = registerTX; //storading ok
    end
    else begin
      r_data = 0; //storading fail- cpu wait
    end
  end
end


//-----FIFO RX-----
/*
always_comb begin
  if(rst) begin
    cant_tx<=0;
    cant_rx<=0;
    indice_rx<=0;
    indice_tx<=0;
  end
  else begin
    case(cant_rx)
      0:
        fifo_rx[0] = rx_data & 32'h800000FF;
      1:
        fifo_rx[1] = rx_data & 32'h800000FF;
      2:
        fifo_rx[2] = rx_data & 32'h800000FF;
      3:
        fifo_rx[3] = rx_data & 32'h800000FF;
    endcase
  end
end
*/


//-----REGISTER RX-----

always_comb begin

end
