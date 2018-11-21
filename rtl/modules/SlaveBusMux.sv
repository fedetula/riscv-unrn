module SlaveBusMux #(type TCmd = logic,
                     type TResult = logic,
                     parameter Base1 = 0,
                     parameter Size1 = 0,
                     parameter Base2 = 0,
                     parameter Size2 = 0
                     )
   (
    input logic [29:0]  address_in,
    input logic         we_in,
    input               TCmd cmd_in,
    output              TResult result_out,
    // == hw 1 ==
    output logic [29:0] address_1,
    output logic         we_1,
    output              TCmd cmd_1,
    input               TResult result_1,
    // == hw 2 ==
    output logic [29:0] address_2,
    output logic         we_2,
    output              TCmd cmd_2,
    input               TResult result_2
    );

   localparam LogSize1 = $clog2(Size1);
   localparam LogSize2 = $clog2(Size2);

   always_comb begin
      cmd_1 = '{default: 0};
      cmd_2 = '{default: 0};
      we_1 = 0;
      we_2 = 0;
      address_1 = 0;
      address_2 = 0;
      result_out = 'x;

      if (address_in[29:LogSize1-2] == Base1[31:LogSize1]) begin
         result_out = result_1;
         cmd_1 = cmd_in;
         we_1 = we_in;
         address_1[LogSize1-1:0] = address_in[LogSize1-1:0];
      end if (address_in[29:LogSize2-2] == Base2[31:LogSize2]) begin
         result_out = result_2;
         cmd_2 = cmd_in;
         we_2 = we_in;
         address_2[LogSize2-1:0] = address_in[LogSize2-1:0];
      end else begin
      end
   end
endmodule
