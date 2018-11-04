import Common::*;

module ControllerMem(
                     input [1:0]        address,
                     input              uint32 dataMemOut,
                     input              mem_inst_type_t instType,
                     input              exception,
                     output             uint32 dataRead,
                     output logic [3:0] maskByte,
                     output logic       read,write
                     );

   /*	Validez| Tipo de Instruccion | tipo de dato
		1      |		0			           |	00			    Load Byte
		1      |		0                |	01			    Load Half
		1      |		0                |	10			    Load Word
		1      |		0			           |	11			    Load Unsigned Byte
		1      |		1                |	00			    Store Byte
		1      |		1                |	01			    Store Half
		1      |		1                |	10			    Store Word
		1      |		1			           |	11			    Load Unsigned Half
    */

   /*-----Dudas-----
 	  1)Si se quiere un LB y no esta en el primer byte el dato esta estructura no funcionaria

    */
   always_comb begin
      dataRead = 0;
      maskByte = 0;
      read = 0;
      write = 0;

      if (~exception) begin
		     case(instType)
  		     MEM_LB: begin   //Load Byte
        		  read = 1;
        		  unique case(address[1:0])
                0:  dataRead = 32'($signed(dataMemOut[7:0]));
                1:  dataRead = 32'($signed(dataMemOut[15:8]));
                2:  dataRead = 32'($signed(dataMemOut[23:16]));
                3:  dataRead = 32'($signed(dataMemOut[31:24]));
                //default: dataRead='x;
        		  endcase
           end
  		     MEM_LH: begin   //Load Half
        		  read = 1;
        		  case(address[1:0])
            	  0: begin
            		   dataRead = 32'($signed(dataMemOut[15:0]));
            	  end
            	  1: begin
      					   dataRead = 32'($signed(dataMemOut[23:8]));
            	  end
            	  2: begin
            		   dataRead = 32'($signed(dataMemOut[31:16]));
            	  end
            	  3: begin
            		   dataRead = 'x;
            	  end
        		  endcase
           end
  		     MEM_LW: begin   //Load Word
        		  read = 1;
            	dataRead = dataMemOut;
           end
  		     MEM_LBU: begin //Load Unsigned Byte
        		  read = 1;
        		  unique case(address[1:0])
            	  0: dataRead = 32'($unsigned(dataMemOut[7:0]));
            	  1: dataRead = 32'($unsigned(dataMemOut[15:8]));
            	  2: dataRead = 32'($unsigned(dataMemOut[23:16]));
            	  3: dataRead = 32'($unsigned(dataMemOut[31:24]));
            	  //default: dataRead='x
        		  endcase
  			   end
  		     MEM_SB: begin   //Store Byte
        		  write = 1;
						  // dataMemIn = dataMem;
        		  case(address[1:0])
            	  0: begin
            		   maskByte = 4'b0001;
            	  end
            	  1: begin
            		   maskByte = 4'b0010;
            	  end
            	  2: begin
            		   maskByte = 4'b0100;
            	  end
            	  3: begin
            		   maskByte = 4'b1000;
            	  end
        		  endcase
           end
  		     MEM_SH: begin   //Store Half
        		  write = 1;
        		  case(address[1:0])
            	  0: begin
            		   maskByte = 4'b0011;
            	  end
            	  1: begin
            		   maskByte = 4'b0110;
            	  end
            	  2: begin
            		   maskByte = 4'b1100;
            	  end
            	  default: begin
            		   maskByte=4'b0000;
            	  end
        		  endcase
        		  // dataMemIn = write_data;
           end
  		     MEM_SW: begin   //Store Word
        		  write = 1;
              // dataMemIn = write_data;
        		  case(address[1:0])
            	  0: begin
            		   maskByte = 4'b1111;
            	  end
            	  default: begin
            		   maskByte=4'b0000;
            	  end
              endcase
           end
  		     MEM_LHU: begin   //Load Unsigned Half
        		  read = 1;
        		  case(address[1:0])
            	  0: begin
            		   dataRead = 32'($unsigned(dataMemOut[15:0]));
            	  end
            	  1: begin
            		   dataRead = 32'($unsigned(dataMemOut[23:8]));
            	  end
            	  2: begin
            		   dataRead = 32'($unsigned(dataMemOut[31:16]));
            	  end
            	  default: begin
            		   dataRead='x;
            	  end
              endcase
           end
  		     default: begin
        		  read = 0;
        		  write = 0;
        		  dataRead = 0;
        		  // dataMemIn = 0;
  			   end
		     endcase
      end
	 end
endmodule
