import Common::*;

module RegFile(
               input logic clk,
               input logic rst,
               input       regId_t read_reg1, read_reg2, write_reg,
               input       uint32_t write_data,
               input logic write_enable,
               output      uint32_t read_data1, read_data2
			   );
  
  uint32_t registers[31];

   
always_comb begin
    read_data1 = registers[read_reg1];
    read_data2 = registers[read_reg2];
end
   
always_ff @(posedge clk) begin
   if (rst) begin
      registers  <= '{default:0};
   end 
   else(write_enable & write_reg != 0) begin
          registers[write_reg] <= write_data;
   end
end

endmodule // RegFile
