import riscV_unrn_pkg::*;
import Common::*;
import MemoryBus::*;

module DataMem #(parameter WIDTH=10)
   (
    input logic  clk,rst,
    logic [13:0] bus_address,
    logic        write_enable,
    input        MemoryBus::Cmd membuscmd,
    output       MemoryBus::Result membusres,
    input        logic[13:0] pc,
    output       uint32 instruction
    );

//Variables
uint32 writeValue,prev_inst;
uint32 readValue;
logic [13:0] addressMemory;
logic [3:0]  maskByte,aux2;
logic writeMem;
//logic address_ready;
//logic [3:0][7:0] mem [2**WIDTH];
logic [WIDTH-1:0] short_address,aux1;



//Asignacion Variables
assign writeValue = membuscmd.write_data;
assign membusres = readValue;
//assign readValue = mem [addressMemory];
assign short_address = addressMemory;

mem_lattice data(clk,maskByte,writeMem,writeValue,addressMemory,readValue);
//initial begin
	//$readmemh("memInst.mem", mem);
//end

always_comb
begin
	if(clk)	begin
		instruction = readValue;
		addressMemory = pc ;
		prev_inst = readValue;
		maskByte = 4'b1111 ;
		writeMem = 0 ;
	end else if(~clk) begin
		instruction = prev_inst;
		addressMemory = bus_address;
		maskByte = membuscmd.mask_byte;
		writeMem = write_enable;
	end
end



//always_ff @(posedge clk)
//begin		 
	//if (rst && clk) begin
		//addressMemory <= 0;
		//writeMem <= 0;
		//maskByte <= 0;
		//address_ready <= 0;
		//instruction <= mem[0];
		//prev_inst <= 0;
	//end else if(~clk) begin
		//addressMemory <= pc;
		//prev_inst <= instruction;
		//maskByte <= 4'b1111;
		//writeMem <= 0;
		//address_ready <= 1;
	/*end else begin
		doThings <= 0;
		restart <= 0;
		*/
		//maskByte <= membuscmd.mask_byte;
		//addressMemory <= bus_address;
		//address_ready <= 0;
		//instruction <= readValue;
		//writeMem <= write_enable;
	//end
//end



/*else if (~clk) begin
		prev_inst <= readValue;
	end else begin
		restart <= 0;
	end
	*/

	//end else if(~clk) begin
		//addressMemory <= pc;
		//prev_inst <= instruction;
		//maskByte <= 4'b1111;
		//writeMem <= 0;
		//address_ready <= 1;
	//end else begin
//		doThings <= 0;
//		restart <= 0;
		
		//maskByte <= membuscmd.mask_byte;
		//addressMemory <= bus_address;
		//address_ready <= 0;
		//instruction <= readValue;
		//writeMem <= write_enable;
//end


//always_ff @(negedge clk)
//begin
//	prev_inst <= instruction;	
//end






/*-----Dudas-----

	1)Si se pide la direccion cero que deberia devolver??
	2)Si hay un reset no puedo poner toda la memoria en cero porque tengo las intruciones, solo deberia borrar
	  la seccion de datos, queda para despues ver eso.
	3)Los SB, el dato que ingresa a la memoria trae el byte a escribir en el menos significativo??
	  Que sucede con los SH, tambien vienen en los bytes menos significativos???*/











//Instruction


//Read Data
   /*always_ff @(negedge clk) begin
      if (membuscmd.mem_read) begin
         membusres = mem[short_address]; //4 byte copy
      end else begin
         membusres =  32'bx ; //4 byte copy
      end
   end*/

//Write Data
//always_ff @(posedge clk /*, posedge rst*/) begin
     //if (rst) mem <= '{default:0};
     //else
    //if (write_enable) begin	
			//case(membuscmd.mask_byte)
  			//1:   mem[short_address][0] <= writeValue[7:0];//1 byte copy
  			//2:   mem[short_address][1] <= writeValue[7:0];//1 byte copy
  			//3:   mem[short_address][1:0] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			//4:   mem[short_address][2] <= writeValue[7:0];//1 byte copy
  			//6:   mem[short_address][2:1] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			//8:   mem[short_address][3] <= writeValue[7:0];//1 byte copy
  			//12:  mem[short_address][3:2] <= writeValue[15:0]; //2 byte copy / debe ser little-endian
  			//15:  mem[short_address] <= writeValue[31:0]; //4 byte copy / debe ser little-endian
			//endcase
		//end
//end


endmodule