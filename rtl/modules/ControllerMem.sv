import Common::*;

module ControllerMem(
                     input [1:0]        address,
                     input              MemoryBus::Result dataMemOut,
                     input              mem_inst_type_t instType,
                     input              exception,
                     output             MemoryBus::Result dataRead,
                     output logic [3:0] maskByte,
                     output logic       read,write
                     );

   /*-----Dudas-----
 	  1)Si se quiere un LB y no esta en el primer byte el dato esta estructura no funcionaria

    */
   always_comb begin
      dataRead.data = 0;
      dataRead.done = dataMemOut.done;
      maskByte = 0;
      read = 0;
      write = 0;

		  case(instType)
  		  MEM_LB: begin   //Load Byte
        	 read = 1;
        	 unique case(address[1:0])
             0:  dataRead.data = 32'($signed(dataMemOut.data[7:0]));
             1:  dataRead.data = 32'($signed(dataMemOut.data[15:8]));
             2:  dataRead.data = 32'($signed(dataMemOut.data[23:16]));
             3:  dataRead.data = 32'($signed(dataMemOut.data[31:24]));
             //default: dataRead.data='x;
        	 endcase
        end
  		  MEM_LH: begin   //Load Half
        	 read = 1;
        	 case(address[1:0])
             0: begin
            		dataRead.data = 32'($signed(dataMemOut.data[15:0]));
             end
             1: begin
      					dataRead.data = 32'($signed(dataMemOut.data[23:8]));
             end
             2: begin
            		dataRead.data = 32'($signed(dataMemOut.data[31:16]));
             end
             3: begin
            		dataRead.data = 'x;
             end
        	 endcase
        end
  		  MEM_LW: begin   //Load Word
        	 read = 1;
           dataRead.data = dataMemOut.data;
        end
  		  MEM_LBU: begin //Load Unsigned Byte
        	 read = 1;
        	 unique case(address[1:0])
             0: dataRead.data = 32'($unsigned(dataMemOut.data[7:0]));
             1: dataRead.data = 32'($unsigned(dataMemOut.data[15:8]));
             2: dataRead.data = 32'($unsigned(dataMemOut.data[23:16]));
             3: dataRead.data = 32'($unsigned(dataMemOut.data[31:24]));
             //default: dataRead.data='x
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
            		dataRead.data = 32'($unsigned(dataMemOut.data[15:0]));
             end
             1: begin
            		dataRead.data = 32'($unsigned(dataMemOut.data[23:8]));
             end
             2: begin
            		dataRead.data = 32'($unsigned(dataMemOut.data[31:16]));
             end
             default: begin
            		dataRead.data='x;
             end
           endcase
        end
  		  default: begin
        	 read = 0;
        	 write = 0;
        	 dataRead.data = 0;
        	 // dataMemIn = 0;
  			end
		  endcase
      if (exception) begin
         write = 0;
      end
	 end
endmodule
