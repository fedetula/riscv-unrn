import riscV_unrn_pkg::*;
import Common::*;
import MemoryBus::*;

module DataMem_lattice #(parameter WIDTH=10)
   (
    input logic  clk,rst,
    logic [13:0] bus_address,
    logic        write_enable,
    input        MemoryBus::Cmd membuscmd,
    output       MemoryBus::Result membusres
    );

//memoria de lattice address de 14 bits
mem_lattice data(clk,membuscmd.maskByte,write_enable,membuscmd.writeValue,bus_address,membusres);


endmodule