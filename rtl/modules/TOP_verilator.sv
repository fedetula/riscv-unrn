import Common::*;
import MemoryBus::*;

module TOP_verilator(
                     input logic        clk,
                     input logic        rst_cpu,
                     input logic        rst_platform,
                     input logic        probe_mem,

                     input logic [29:0] probe_address,
                     input logic        probe_mem_read, probe_mem_write,
                     input logic [3:0]  probe_mask_byte,
                     input              uint32 probe_write_data,
                     output             uint32 probe_read_data
                     );

   logic                                invalid_bus_address;

   MemoryBus::Cmd cpu_bus_cmd;
   MemoryBus::Result cpu_bus_result;
   MemoryBus::Cmd probe_bus_cmd;
   MemoryBus::Result probe_bus_result;
   MemoryBus::Cmd memory_bus_cmd;
   MemoryBus::Result memory_bus_result;

   MemoryBus::Cmd data_bus_cmd;
   MemoryBus::Result data_bus_result;

   MemoryBus::Cmd uart_bus_cmd;
   MemoryBus::Result uart_bus_result;

   Common::uint32 dataRead_mem;

   assign probe_bus_cmd.address = probe_address;
   assign probe_bus_cmd.mem_read = probe_mem_read;
   assign probe_bus_cmd.mem_write = probe_mem_write;
   assign probe_bus_cmd.mask_byte = probe_mask_byte;
   assign probe_bus_cmd.write_data = probe_write_data;
   assign probe_read_data = probe_bus_result.read_data;

//Bus
   MasterBusMux #(.TCmd(MemoryBus::Cmd),
                  .TResult(MemoryBus::Result))
   master_bus(.useA(probe_mem),
              .busACmd(probe_bus_cmd),
              .busAResult(probe_bus_result),
              .busBCmd(cpu_bus_cmd),
              .busBResult(cpu_bus_result),
              .busCommonCmd(memory_bus_cmd),
              .busCommonResult(memory_bus_result)
              );

   SlaveBusMux #(.TCmd(MemoryBus::Cmd),
                 .TResult(MemoryBus::Result),
                 .Base1(PC_VALID_RANGE_BASE),
                 .Size1(2**10),
                 .Base2('h800),
                 .Size2(1))
   slave_bus(.cmd_in(memory_bus_cmd),
             .result_out(memory_bus_result),
             .invalid_address(invalid_bus_address),
             .cmd_1(data_bus_cmd),
             .result_1(data_bus_result),
             .cmd_2(uart_bus_cmd),
             .result_2(uart_bus_result));

//Memory Interface
ControllerMem controllerMem(.address(cpu_bus_cmd.address[1:0]),
                            .dataMemOut(memory_bus_result.read_data),
                            .instType(instType_cpu),
                            .dataRead(cpu_bus_result.read_data),
                            .maskByte(cpu_bus_cmd.mask_byte),
                            .read(cpu_bus_cmd.mem_read),
                            .write(cpu_bus_cmd.mem_write)
                            );


//Memory

   uint32 pc = 0;
   uint32 instruction;

   DataMem data_mem(.clk,
                    .rst(rst_platform),
                    .membuscmd(data_bus_cmd),
                    .membusres(data_bus_result),
                    .pc(pc),
                    .instruction(instruction)
                    );
//Core

assign cpu_bus_cmd.address = addressCpu_o[31:2];

   Common::mem_inst_type_t instType_cpu;
   Common::uint32 addressCpu_o;

   unicycle unicycle(
                    //INPUTS
                    .clk,
                    .rst(rst_cpu),
                    .readData_i(cpu_bus_result),
                    .instruction_i(instruction),
                    //OUTPUS
                    .instType_o(instType_cpu),
                    .writeData_o(cpu_bus_cmd.write_data),
                    .dataAddress_o(addressCpu_o),
                    .pc_o(pc)
   );










endmodule; // TOP_verilator
