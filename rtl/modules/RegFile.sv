import Common::*;

module RegFile(
               input logic clk,
               //input logic rst,
               input       regId_t read_reg1, read_reg2, write_reg,
               input       uint32 write_data,
               input logic write_enable,
               output      uint32 read_data1, read_data2
			   );

  uint32 registers[32];
  regId_t addr1_reg;
  regId_t addr2_reg;

always_comb begin
   read_data1 = registers[addr1_reg];
   read_data2 = registers[addr2_reg];
end

always_ff @(posedge clk) begin
   addr1_reg <= read_reg1;
   addr2_reg <= read_reg2;
   if(write_enable & write_reg != 0) begin
          registers[write_reg] <= write_data;
   end
end

endmodule // RegFile
