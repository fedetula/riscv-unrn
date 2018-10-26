import Common::*;

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

   MemoryBusCmd cpu_bus_cmd = '{default:0};
   MemoryBusResult cpu_bus_result;
   MemoryBusCmd probe_bus_cmd;
   MemoryBusResult probe_bus_result;
   MemoryBusCmd memory_bus_cmd;
   MemoryBusResult memory_bus_result;

   MemoryBusCmd data_bus_cmd;
   MemoryBusResult data_bus_result;

   MemoryBusCmd uart_bus_cmd;
   MemoryBusResult uart_bus_result = '{default:0};

   assign probe_bus_cmd.address = probe_address;
   assign probe_bus_cmd.mem_read = probe_mem_read;
   assign probe_bus_cmd.mem_write = probe_mem_write;
   assign probe_bus_cmd.mask_byte = probe_mask_byte;
   assign probe_bus_cmd.write_data = probe_write_data;
   assign probe_read_data = probe_bus_result.read_data;


   MasterBusMux #(.TCmd(MemoryBusCmd), .TResult(MemoryBusResult))
   master_bus(.useA(probe_mem),
              .busACmd(probe_bus_cmd),
              .busAResult(probe_bus_result),
              .busBCmd(cpu_bus_cmd),
              .busBResult(cpu_bus_result),
              .busCommonCmd(memory_bus_cmd),
              .busCommonResult(memory_bus_result)
              );

   SlaveBusMux #(.TCmd(MemoryBusCmd),
                 .TResult(MemoryBusResult),
                 .Base1(0),
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

   uint32 pc = 0;
   uint32 instruction;

   DataMem data_mem(.clk,
                    .rst(rst_platform),
                    .membuscmd(data_bus_cmd),
                    .membusres(data_bus_result),
                    .pc, .instruction);

endmodule; // TOP_verilator
