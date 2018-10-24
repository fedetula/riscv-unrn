import Common::*;


module MasterBusMux
  (input logic useA,
   input  MemoryBusCmd busACmd,
   output MemoryBusResult busAResult,
   input  MemoryBusCmd busBCmd,
   output MemoryBusResult busBResult,
   output MemoryBusCmd busCommonCmd,
   input  MemoryBusResult busCommonResult
   );

   always_comb begin
      busAResult = '{default:0};
      busBResult = '{default:0};
      if (useA) begin
         busCommonCmd = busACmd;
         busAResult = busCommonResult;
      end else begin
         busCommonCmd = busBCmd;
         busBResult = busCommonResult;
      end
   end

endmodule; // BusMasterMux
