import Common::*;
import MemoryBus::*;

module DataMem
  #(parameter WIDTH=10)
   (
    input logic         clk,
    logic [WIDTH-2-1:0] bus_address,
    logic               write_enable,
    input               MemoryBus::Cmd membuscmd,
    output              MemoryBus::Result membusres
    );

   logic [7:0]          mem0 [2**(WIDTH-2)];
   logic [7:0]          mem1 [2**(WIDTH-2)];
   logic [7:0]          mem2 [2**(WIDTH-2)];
   logic [7:0]          mem3 [2**(WIDTH-2)];

   //Variables
   uint32 writeValue;

   assign writeValue = membuscmd.write_data;

   logic [WIDTH-2-1:0]  bus_address_reg;

   assign membusres[7:0] = mem0[bus_address_reg]; //4 byte copy
   assign membusres[15:8] = mem1[bus_address_reg]; //4 byte copy
   assign membusres[23:16] = mem2[bus_address_reg]; //4 byte copy
   assign membusres[31:24] = mem3[bus_address_reg]; //4 byte copy

   //Write Data
   always_ff @(posedge clk) begin
      bus_address_reg <= bus_address;
      if (write_enable) begin
			   if (membuscmd.mask_byte[0])begin
            mem0[bus_address] <= writeValue[7:0];
			   end
         if (membuscmd.mask_byte[1])begin
            mem1[bus_address] <= writeValue[15:8];
         end
         if (membuscmd.mask_byte[2])begin
            mem2[bus_address] <= writeValue[23:16];
         end
         if (membuscmd.mask_byte[3])begin
            mem3[bus_address] <= writeValue[31:24];
         end
      end
   end

endmodule
