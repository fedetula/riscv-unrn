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
logic [3:0]  maskByte;
logic writeMem;
//logic [3:0][7:0] mem [2**WIDTH];
//logic [WIDTH-1:0] short_address;



//Asignacion Variables
assign writeValue = membuscmd.write_data;
assign membusres = readValue;
assign short_address = addressMemory;

//memoria de lattice address de 14 bits
mem_lattice data(clk,maskByte,writeMem,writeValue,addressMemory,readValue);
//initial begin
	//$readmemh("memInst.mem", mem);
//end

always_comb
begin
	if(clk)	begin
		instruction = readValue;
		addressMemory = pc ;
		maskByte = 4'b1111 ;
		writeMem = 0 ;
	end else if(~clk) begin
		instruction = prev_inst;
		addressMemory = bus_address;
		maskByte = membuscmd.mask_byte;
		writeMem = write_enable;
	end
end


always_ff @(negedge clk) begin
    prev_inst <= readValue;
end


endmodule