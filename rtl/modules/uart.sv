import MemoryBus::*;

module uart#(parameter  BAUDRATE = 9600, parameter F_CLK = 576000)(
    input sys_clk_i,   // System clock, 50 MHz
    input sys_rst_i,    // System reset
   // Outputs
   // output uart_busy,   // High means UART is transmitting
   output MemoryBus::Result uart_data_o,
   output reg uart_tx_o,     // UART transmit wire
   // Inputs
   input uart_wr_i,   // Raise to transmit byte
   input logic [7:0] uart_dat_i  // 8-bit data
);

  reg [3:0] bitcount;
  reg [8:0] shifter;
  //reg uart_tx;

  logic uart_busy;
  wire sending;

  assign uart_busy = |bitcount[3:1];
  assign sending = |bitcount;

  assign uart_data_o = {31'b0,uart_busy};
  // sys_clk_i is F_CLK.  We want a BAUDRATE clock

  // reg [16:0] d;
  // wire [16:0] dInc;
  // wire [16:0] dNxt;
  //
  // assign dInc = d[16] ? (BAUDRATE) : (BAUDRATE - F_CLK);
  // assign dNxt = d + dInc;
  //
  // always_ff @(posedge sys_clk_i) begin
  //     if (sys_rst_i) begin
  //         d <= 0;
  //     end else begin
  //         d <= dNxt;
  //     end
  // end

  // wire ser_clk;
  // assign ser_clk = ~d[16]; // this is the uart clock

  logic [4:0] d;
  logic ser_clk = d[4];

  always_ff @(posedge sys_clk_i) begin
      if (sys_rst_i || ser_clk) begin
          d <= 1;
      end else begin
          d <= d << 1;
      end
  end


  always_ff @(posedge sys_clk_i)
  begin
    if (sys_rst_i) begin
      uart_tx_o <= 1;
      bitcount <= 0;
      shifter <= 0;
    end else begin
      // just got a new byte
      if (uart_wr_i & ~uart_busy) begin
        shifter <= { uart_dat_i[7:0], 1'h0 };
        bitcount <= (1 + 8 + 2);
      end

      if (sending & ser_clk) begin
        { shifter, uart_tx_o } <= { 1'h1, shifter };
        bitcount <= bitcount - 1;
      end
    end
  end

endmodule
