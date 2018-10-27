import Common::*;
import MemoryBus::*;

module DataMem
  #(parameter WIDTH=10)
   (
    input logic clk,
    input logic rst,
    input       MemoryBus::Cmd membuscmd,
    output      MemoryBus::Result membusres,
    input       uint32 pc,
    output      uint32 instruction
    );

/*-----Dudas-----

	1)Si se pide la direccion cero que deberia devolver??
	2)Si hay un reset no puedo poner toda la memoria en cero porque tengo las intruciones, solo deberia borrar
	  la seccion de datos, queda para despues ver eso.
	3)Los SB, el dato que ingresa a la memoria trae el byte a escribir en el menos significativo??
	  Que sucede con los SH, tambien vienen en los bytes menos significativos???
*/
   logic [3:0] [7:0] mem [2**WIDTH];

   logic [WIDTH-1:0] short_address;
   assign short_address = membuscmd.address[WIDTH-1:0];

//Variables
uint32 writeValue;
logic [29:0] pc_aux;

assign writeValue = membuscmd.write_data;

//Instruction
assign instruction = mem[pc[WIDTH+1:2]]; //4 byte copy

//Read Data
   always_comb begin
      if (membuscmd.mem_read) begin
         membusres.read_data = mem[short_address]; //4 byte copy
      end else begin
         membusres.read_data =  32'bx ; //4 byte copy
      end
   end

//Write Data
always_ff @(posedge clk, posedge rst) begin
    if (rst) mem <= '{default:0};
    else
    if (membuscmd.mem_write) begin
			case(membuscmd.mask_byte)
  			1:   mem[short_address][0] <= writeValue[7:0];//1 byte copy
  			2:   mem[short_address][1] <= writeValue[7:0];//1 byte copy
  			3:   mem[short_address][1:0] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			4:   mem[short_address][2] <= writeValue[7:0];//1 byte copy
  			6:   mem[short_address][2:1] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			8:   mem[short_address][3] <= writeValue[7:0];//1 byte copy
  			12:  mem[short_address][3:2] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			15:  mem[short_address] <= writeValue[31:0]; //4 byte copy / debe ser little-endian
			endcase
		end
end

endmodule
