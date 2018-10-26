module SlaveBusMux #(type TCmd = logic,
                     type TResult = logic,
                     parameter Base1 = 0,
                     parameter Size1 = 0,
                     parameter Base2 = 0,
                     parameter Size2 = 0
                     )
   (
    input              TCmd cmd_in,
    output             TResult result_out,
    output logic       invalid_address,
    // == hw 1 ==
    output             TCmd cmd_1,
    input              TResult result_1,
    // == hw 2 ==
    output             TCmd cmd_2,
    input              TResult result_2
    );

   localparam LogSize1 = $clog2(Size1);
   localparam LogSize2 = $clog2(Size2);

   always_comb begin
      invalid_address = 0;
      cmd_1 = '{default: 0};
      cmd_2 = '{default: 0};
      result_out = 'x;

      if (cmd_in.address[29:LogSize1] == Base1[29:LogSize1]) begin
         result_out = result_1;
         cmd_1 = cmd_in;
      end if (cmd_in.address[29:LogSize2] == Base2[29:LogSize2]) begin
         result_out = result_2;
         cmd_2 = cmd_in;
      end else begin
        invalid_address = 1;
      end
   end
endmodule
