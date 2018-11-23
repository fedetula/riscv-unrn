import Common::*;
import MemoryBus::*;

module DataMem
  #(parameter WIDTH=15)
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
/*
   initial $readmemh("/home/nicolas/Code/unrn-riscv/unrn-riscv-softcpu/hw/program0.mem", mem0);
   initial $readmemh("/home/nicolas/Code/unrn-riscv/unrn-riscv-softcpu/hw/program1.mem", mem1);
   initial $readmemh("/home/nicolas/Code/unrn-riscv/unrn-riscv-softcpu/hw/program2.mem", mem2);
   initial $readmemh("/home/nicolas/Code/unrn-riscv/unrn-riscv-softcpu/hw/program3.mem", mem3);
*/
   //Write Data
   always_ff @(posedge clk) begin
			   if (write_enable && membuscmd.mask_byte[0])begin
            mem0[bus_address] <= writeValue[7:0];
			   end else begin
            membusres[7:0] <= mem0[bus_address];
         end
         if (write_enable && membuscmd.mask_byte[1])begin
            mem1[bus_address] <= writeValue[15:8];
         end else begin
            membusres[15:8] <= mem1[bus_address];
         end
         if (write_enable && membuscmd.mask_byte[2])begin
            mem2[bus_address] <= writeValue[23:16];
         end else begin
            membusres[23:16] <= mem2[bus_address];
         end
         if (write_enable && membuscmd.mask_byte[3])begin
            mem3[bus_address] <= writeValue[31:24];
         end else begin
            membusres[31:24] <= mem3[bus_address];
         end
   end

endmodule
