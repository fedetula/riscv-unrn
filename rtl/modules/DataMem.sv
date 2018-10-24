import Common::*;

module DataMem(
               input logic clk,
               input logic rst,
               input       MemoryBusCmd membuscmd,
               output      MemoryBusResult membusres,
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

   localparam N = 10;
   logic [3:0] [7:0] mem [2**N-1];
   logic [31:0]      address_aux;


//Variables
uint32 writeValue;
uint32 pc_aux;

assign writeValue = membuscmd.write_data;
assign pc_aux = {pc[31:2],2'b00};
assign address_aux = {membuscmd.address,2'b00};

//Instruction
assign instruction = mem[pc_aux]; //4 byte copy

//Read Data
   always_comb begin
      if (membuscmd.mem_read) begin
         membusres.read_data = mem[address_aux]; //4 byte copy
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
  			1:   mem[address_aux][0] <= writeValue[7:0];//1 byte copy
  			2:   mem[address_aux][1] <= writeValue[7:0];//1 byte copy
  			3:   mem[address_aux][1:0] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			4:   mem[address_aux][2] <= writeValue[7:0];//1 byte copy
  			6:   mem[address_aux][2:1] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			8:   mem[address_aux][3] <= writeValue[7:0];//1 byte copy
  			12:  mem[address_aux][3:2] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			15: mem[address_aux] <= writeValue[31:0]; //4 byte copy / debe ser little-endian
			endcase
		end
end

endmodule
