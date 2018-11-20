import Common::*;
import MemoryBus::*;

module mem_lattice(
                  input logic clk,
                  input logic [3:0] maskByte,
                  input logic /*read,*/write,
                  input uint32 dataWriteMem,
                  input logic [13:0] address,
                  output MemoryBus::Result dataReadMem//,
	      // output logic ok
  );

logic chipSelect_UP;
logic chipSelect_DOWN;
logic [3:0] maskwren_UP;
logic [3:0] maskwren_DOWN;
logic [15:0] dataOut_UP;
logic [15:0] dataOut_DOWN;


assign chipSelect_UP = (maskByte[3] || maskByte[2]) ? 1 : 0;
assign chipSelect_DOWN = (maskByte[1] || maskByte[0]) ? 1 : 0;
assign maskwren_UP [0] = maskByte[2];
assign maskwren_UP [1] = maskByte[2];
assign maskwren_UP [2] = maskByte[3];
assign maskwren_UP [3] = maskByte[3];
assign maskwren_DOWN [0] = maskByte[0];
assign maskwren_DOWN [1] = maskByte[0];
assign maskwren_DOWN [2] = maskByte[1];
assign maskwren_DOWN [3] = maskByte[1];
//assign ok = 1;
//assign dataWriteMem = 32'habcd0123;


//Lattice Radiant
SP256K ramfn_inst1(
.DI(dataWriteMem[31:16]),
.AD(address),
.MASKWE(maskwren_UP),
.WE(write),
.CS(chipSelect_UP),
.CK(clk),
.STDBY(0),
.SLEEP(0),
.PWROFF_N(0),
 .DO(dataOut_UP) );
 
  SP256K ramfn_inst2(
  .DI(dataWriteMem[15:0]),
  .AD(address),
  .MASKWE(maskwren_DOWN),
  .WE(write),
  .CS(chipSelect_DOWN),
  .CK(clk),
  .STDBY(0),
  .SLEEP(0),
  .PWROFF_N(0),
  .DO(dataOut_DOWN) );


//Lattice ICECUBE
/*SB_SPRAM256KA ramfn_inst1(
.DATAIN(dataWriteMem[31:16]),
.ADDRESS(address),
.MASKWREN(maskwren_UP),
.WREN(write),
.CHIPSELECT(chipSelect_UP),
.CLOCK(clk),
.STANDBY(0),
.SLEEP(0),
.POWEROFF(0),
 .DATAOUT(dataOut_UP) );

  SB_SPRAM256KA ramfn_inst2(
  .DATAIN(dataWriteMem[15:0]),
  .ADDRESS(address),
  .MASKWREN(maskwren_DOWN),
  .WREN(write),
  .CHIPSELECT(chipSelect_DOWN),
  .CLOCK(clk),
  .STANDBY(0),
  .SLEEP(0),
  .POWEROFF(0),
  .DATAOUT(dataOut_DOWN) );*/

  always_comb begin
    //if(read)
      case(maskByte)
      'b1111:  dataReadMem = {dataOut_UP,dataOut_DOWN};
      'b0001:  dataReadMem = {24'b0,dataOut_DOWN[7:0]};
      'b0010:  dataReadMem = {16'b0,dataOut_DOWN[15:7],7'b0};
      'b0100:  dataReadMem = {7'b0,dataOut_UP[7:0],16'b0};
      'b1000:  dataReadMem = {dataOut_UP[15:8],24'b0};
      'b0011:  dataReadMem = {16'b0,dataOut_DOWN};
      'b1100:  dataReadMem = {dataOut_UP,16'b0};
      default: dataReadMem = 32'b0;
      endcase
  end



endmodule
