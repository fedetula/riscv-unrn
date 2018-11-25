import Common::*;
import MemoryBus::*;

module DataMem
  #(parameter WIDTH=15)
   (
    input logic         clk,
    input logic         rst,
    logic [WIDTH-2-1:0] bus_address,
    logic               write_enable,
    input               MemoryBus::Cmd membuscmd,
    output              MemoryBus::Result membusres
    );

   logic [7:0]          mem0 [2**(WIDTH-2)]  /* synthesis syn_ramstyle="rw_check" */;
   logic [7:0]          mem1 [2**(WIDTH-2)]  /* synthesis syn_ramstyle="rw_check" */;
   logic [7:0]          mem2 [2**(WIDTH-2)]  /* synthesis syn_ramstyle="rw_check" */;
   logic [7:0]          mem3 [2**(WIDTH-2)]  /* synthesis syn_ramstyle="rw_check" */;

   // initial $readmemh("/home/unrn/unrn-riscv/unrn-riscv-softcpu/hw/program0.mem", mem0);
   // initial $readmemh("/home/unrn/unrn-riscv/unrn-riscv-softcpu/hw/program1.mem", mem1);
   // initial $readmemh("/home/unrn/unrn-riscv/unrn-riscv-softcpu/hw/program2.mem", mem2);
   // initial $readmemh("/home/unrn/unrn-riscv/unrn-riscv-softcpu/hw/program3.mem", mem3);

   //Variables
   uint32 writeValue;

   assign writeValue = membuscmd.write_data;

   logic [7:0]          writeValMem0;
   logic [7:0]          writeValMem1;
   logic [7:0]          writeValMem2;
   logic [7:0]          writeValMem3;

   always_comb begin
      writeValMem0 = writeValue[7:0];
      writeValMem1 = writeValue[15:8];
      writeValMem2 = writeValue[23:16];
      writeValMem3 = writeValue[31:24];
      unique case (membuscmd.mask_byte)
         4'b0001: begin
            writeValMem0 = writeValue[7:0];
         end
        4'b0010: begin
           writeValMem1 = writeValue[7:0];
        end
        4'b0100: begin
           writeValMem2 = writeValue[7:0];
        end
        4'b1000: begin
           writeValMem3 = writeValue[7:0];
        end
        4'b0011: begin
           writeValMem0 = writeValue[7:0];
           writeValMem1 = writeValue[15:8];
        end
        4'b0110: begin
           writeValMem1 = writeValue[7:0];
           writeValMem2 = writeValue[15:8];
        end
        4'b1100: begin
           writeValMem2 = writeValue[7:0];
           writeValMem3 = writeValue[15:8];
        end
        4'b1111: begin
           writeValMem0 = writeValue[7:0];
           writeValMem1 = writeValue[15:8];
           writeValMem2 = writeValue[23:16];
           writeValMem3 = writeValue[31:24];
        end
        default: begin
        end
      endcase
   end

   typedef enum {
                 ready,
                 waiting
                 } state_t;

   logic [3:0]  wait_count;
   state_t state;


   always_ff @(posedge clk) begin
      if (rst) begin
         membusres.data <= 0;
         membusres.done <= 0;
      end else begin
         if (state == ready) begin
            if (membuscmd.start) begin
               state <= waiting;
               membusres <= 0;
               wait_count <= 4;
			         if (write_enable && membuscmd.mask_byte[0])begin
                  mem0[bus_address] <= writeValMem0;
               end
               if (write_enable && membuscmd.mask_byte[1])begin
                  mem1[bus_address] <= writeValMem1;
               end
               if (write_enable && membuscmd.mask_byte[2])begin
                  mem2[bus_address] <= writeValMem2;
               end
               if (write_enable && membuscmd.mask_byte[3])begin
                  mem3[bus_address] <= writeValMem3;
               end
            end
         end else begin
            if (wait_count == 0) begin
               membusres.data[7:0] <= mem0[bus_address];
               membusres.data[15:8] <= mem1[bus_address];
               membusres.data[23:16] <= mem2[bus_address];
               membusres.data[31:24] <= mem3[bus_address];
               state <= ready;
               membusres.done <= 0;
            end else begin
               wait_count <= wait_count - 1;
               state <= waiting;
               membusres.done <= (wait_count == 1);
            end
         end
      end
   end

endmodule
