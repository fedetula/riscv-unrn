import Common::*;

module ControlMem(
 input       uint32_t address, write_data,dataMemOut,
 input logic [3:0] instType,
 output      uint32_t dataMemIn,dataRead,
 output logic [29:0] adress_mem,
 output logic [3:0] maskByte,
 output logic read,write,exception
 );
 
/*	Validez| Tipo de Instruccion | tipo de dato
		1  |		0			 |	00			Load Byte
		1  |		0            |	01			Load Half
		1  |		0            |	10			Load Word
		1  |		0			 |	11			Load Unsigned Byte
		1  |		1            |	00			Store Byte
		1  |		1            |	01			Store Half
		1  |		1            |	10			Store Word
		1  |		1			 |	11			Load Unsigned Half
 */
 
 /*-----Dudas-----
 	1)Si se quiere un LB y no esta en el primer byte el dato esta estructura no funcionaria
 
 */
 always_comb
	begin
		case(instType)
		4'1000://Load Byte
			begin
				read = 1;
				exception=0;
				case(address[1:0])
				0: begin
					dataRead = 32'b($signed(dataMemOut[7:0]));
				end
				1: begin
					dataRead = 32'b($signed(dataMemOut[15:8])); //LEA:coregir sintaxis
				end
				2: begin
					dataRead = 32'b($signed(dataMemOut[23:16])); //LEA:coregir sintaxis
				end
				3: begin
					dataRead = 32'b($signed(dataMemOut[31:24])); //LEA:coregir sintaxis
				end
				default: begin
					dataRead='x
				end
				endcase
			end
		4'1001://Load Half
			begin
				read = 1;
				case(address[1:0])
				0: begin
					exception=1;
					dataRead = 'x;
				end
				1: begin
					exception=0;
					dataRead = 32'b($signed(dataMemOut[15:0]));
				end
				2: begin
					exception=0;
					dataRead = 32'b($signed(dataMemOut[23:8])); //LEA:coregir sintaxis
				end
				3: begin
					exception=0;
					dataRead = 32'b($signed(dataMemOut[31:16])); //LEA:coregir sintaxis
				end	
				default: begin
					exception='x;//LEA:Dejar en dont care o en cero?
					dataRead='x
				end				
				endcase
			end
		4'1010://Load Word
			begin
				read = 1;
				case(address[1:0])
				0: begin
					exception=1;
					dataRead = 'x;
				end
				1: begin
					exception=1;
					dataRead = 'x;
				end
				2: begin
					exception=1;
					dataRead = 'x;
				end
				3: begin
					exception=0;
					dataRead = dataMemOut;
				end			
				default: begin
					dataRead='x
				end				
				endcase
			end
		4'1011://Load Unsigned Byte
			begin
				read = 1;
				exception=0;
				case(address[1:0])
				0: begin
					dataRead = 32'b($unsigned(dataMemOut[7:0]));
				end
				1: begin
					dataRead = 32'b($unsigned(dataMemOut[15:8])); //coregir sintaxis
				end
				2: begin
					dataRead = 32'b($unsigned(dataMemOut[23:16])); //coregir sintaxis
				end
				3: begin
					dataRead = 32'b($unsigned(dataMemOut[31:24])); //coregir sintaxis
				end
				default: begin
					dataRead='x
				end
				endcase
			end
		4'1100://Store Byte
			begin
				write = 1;
				exception=0;
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
				default: begin
					exception='x; //LEA:Dejar en dont care o en cero?
					maskByte=4'bxxxx;
				end
				endcase
				dataMemIn = write_data;
			end
		4'1101://Store Half
			begin
				write = 1;
				case(address[1:0])
				0: begin
					//LEA:ver que hacer porque no se puede grabar en esa direccion
					exception=1;
					maskByte = 4'b0000;
				end
				1: begin
					exception=0;
					maskByte = 4'b0011;
				end
				2: begin
					exception=0;
					maskByte = 4'b0110;
				end
				3: begin
					exception=0;
					maskByte = 4'b1100;
				end
				default: begin
					exception='x;//LEA:Dejar en dont care o en cero?
					maskByte=4'bxxxx;
				end
				endcase
				dataMemIn = write_data;
			end
		4'1110://Store Word
			begin
				write = 1;
				case(address[1:0])
				0: begin
					//LEA:ver que hacer porque no se puede grabar en esa direccion
					exception=1;
					maskByte = 4'b0000;
				end
				1: begin
					//LEA:ver que hacer porque no se puede grabar en esa direccion
					exception=1;
					maskByte = 4'b0000;
				end
				2: begin
					//LEA:ver que hacer porque no se puede grabar en esa direccion
					exception=1;
					maskByte = 4'b0000;
				end
				3: begin
					exception=0;
					maskByte = 4'b1111;
				end
				default: begin
					exception='x;//LEA:Dejar en dont care o en cero?
					maskByte=4'bxxxx;
				end
				endcase
				dataMemIn = write_data;
			end
		4'1111://Load Unsigned Half
			begin
				read = 1;
				case(address[1:0])
				0: begin
					exception=1;
					dataRead = 'x;
				end
				1: begin
					exception=0;
					dataRead = 32'b($unsigned(dataMemOut[15:0]));
				end
				2: begin
					exception=0;
					dataRead = 32'b($unsigned(dataMemOut[23:8])); //LEA:coregir sintaxis
				end
				3: begin
					exception=0;
					dataRead = 32'b($unsigned(dataMemOut[31:16])); //LEA:coregir sintaxis
				end	
				default: begin
					exception='x;//LEA:Dejar en dont care o en cero?
					dataRead='x
				end				
				endcase
				//dataMemIn = write_data; LEA:esto estaba antes, yo lo borraria
			end
		default:
			begin
				exception=0;
				read = 0;
				write = 0;
				dataRead = 0;
				dataMemIn = 0;
			end
		endcase
	end