import Common::*;


module ALU
  (input ALU_control_t control,
   input        uint32 data1,data2,
   output       uint32 result
   );

   always_comb begin//Alu solo op de and,or,xor,add,sub,sll,srl,sra los compare se pueden hacer mediante sub y con flag, ver que conviene
      case (control)
        ALU_and: begin
           result = data1 & data2;
        end
		ALU_ce: begin
           result = (data1 == data2) ? 32'b1 : 32'b0;
        end
		ALU_cne: begin
           result = (data1 != data2) ? 32'b1 : 32'b0;
        end
        ALU_or: begin
           result = data1 | data2;
        end
        ALU_add: begin
           result = data1 + data2;
        end
        ALU_sub: begin
           result = data1 - data2;
        end
		ALU_xor: begin
           result = data1 ^ data2;
        end
        ALU_sll: begin
           result = data1<<data2[4:0];
        end
		ALU_srl: begin
           result = data1>>data2[4:0];
        end
        ALU_sra: begin
           result = $signed(data1)>>>data2[4:0];
        end
		ALU_slt: begin
           result = ($signed(data1) < $signed(data2)) ? 32'b1 : 32'b0;
        end
		ALU_sltu: begin
           result = ($unsigned(data1) < $unsigned(data2)) ? 32'b1 : 32'b0;
        end
		ALU_cge: begin
		   result = ($signed(data1) >= $signed(data2)) ? 32'b1 : 32'b0;
		end
		ALU_cgeu: begin
		   result = ( $unsigned(data1) >= $unsigned(data2) ) ? 32'b1 : 32'b0;
		end
        default: begin
          result = 0; // avoid latch.
          assert(0) else $error("unknown ALU op");
        end
      endcase
   end

endmodule
