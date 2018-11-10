import Common::*;


module MasterBusMux
#(type TCmd = logic,
  type TResult = logic)
  (input logic useA,
   input logic [29:0]  addressA,
   input               TCmd busACmd,
   input logic         writeEnableA,
   output              TResult busAResult,
   input logic [29:0]  addressB,
   input               TCmd busBCmd,
   input logic         writeEnableB,
   output              TResult busBResult,
   output logic [29:0] addressCommon,
   output logic         writeEnableCommon,
   output              TCmd busCommonCmd,
   input               TResult busCommonResult
   );

   always_comb begin
      busAResult = '{default:0};
      busBResult = '{default:0};
      addressCommon = 0;
      if (useA) begin
         busAResult = busCommonResult;
      end else begin
         busBResult = busCommonResult;
      end
   end

   always_comb begin
      if (useA) begin
         addressCommon = addressA;
         busCommonCmd = busACmd;
         writeEnableCommon = writeEnableA;
      end else begin
         addressCommon = addressB;
         busCommonCmd = busBCmd;
         writeEnableCommon = writeEnableB;
      end
   end

endmodule; // BusMasterMux
