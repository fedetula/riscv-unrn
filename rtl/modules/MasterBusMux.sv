import Common::*;


module MasterBusMux
#(type TCmd = logic,
  type TResult = logic)
  (input logic useA,
   input  TCmd busACmd,
   output TResult busAResult,
   input  TCmd busBCmd,
   output TResult busBResult,
   output TCmd busCommonCmd,
   input  TResult busCommonResult
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
