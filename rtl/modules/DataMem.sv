import Common::*;

module DataMem(
 input logic clk, rst, mem_read, mem_write,
 input logic [29:0] address,
 input logic [3:0] maskByte,
 input       uint32_t pc,write_data,
 output      uint32_t read_data,instruction,
 );
 
 
/*-----Dudas-----

	1)Si se pide la direccion cero que deberia devolver??
	2)Si hay un reset no puedo poner toda la memoria en cero porque tengo las intruciones, solo deberia borrar
	  la seccion de datos, queda para despues ver eso.
	3)Los SB, el dato que ingresa a la memoria trae el byte a escribir en el menos significativo?? 
	  Que sucede con los SH, tambien vienen en los bytes menos significativos???
*/

   localparam N = 10;
   logic [3:0] [7:0] mem [2**N-1];
   
//Variables
uint32_t writeValue;
uint32_t pc_aux;

assign writeValue = write_data; 
assign pc_aux = {pc[31:2],2'b00}; 
assign address_aux = {address,2'b00};

//Instruction
assign Instruction = mem[pc_aux]; //4 byte copy

//Read Data
assign read_data = mem_read? mem[address_aux] : 32'bx ; //4 byte copy

//Write Data   
always_ff @(posedge clk) begin
    //if (rst) mem <= '{default:0};
    //else 
    if (mem_write) begin
			case(maskByte)
			1://byte
			begin
				mem[address_aux][0] = writeValue[7:0];//1 byte copy
			end
			2://byte
			begin
				mem[address_aux][1] = writeValue[7:0];//1 byte copy
			end
			3://half
			begin
				mem[address_aux][1:0] = writeValue[15:0]; //2 byte copy / debe ser little-endian
			end
			4://byte
			begin
				mem[address_aux][2] = writeValue[7:0];//1 byte copy
			end
			6://half
			begin
				mem[address_aux][2:1] = writeValue[15:0]; //2 byte copy / debe ser little-endian
			end
			8://byte
			begin
				mem[address_aux][3] = writeValue[7:0];//1 byte copy
			end
			12://half
			begin
				mem[address_aux][3:2] = writeValue[15:0]; //2 byte copy / debe ser little-endian
			end
			15://Word
			begin
				mem[address_aux] = writeValue[31:0]; //4 byte copy / debe ser little-endian
/* 				mem[address-1] = writeValue[15:8];
				mem[address-2] = writeValue[23:16];//no recuerdo la organizacion de la memoria, se cambia - por + 
				mem[address-3] = writeValue[31:24]; */
			end
			endcase
		end
    end
end

endmodule
