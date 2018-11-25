import Common::*;
import MemoryBus::*;

module TOP_verilator(input logic         clk,
                     input logic         rst_cpu,
                     input logic         probe_mem,

                     input logic [29:0]  probe_address,
                     input logic         probe_mem_read, probe_mem_write,
                     input logic [3:0]   probe_mask_byte,
                     input               uint32 probe_write_data,
                     output              uint32 probe_read_data,
                     output logic [7:0]  uart_data,
                     output logic        uart_write,
                     output logic        test_done
                     );

   logic [29:0]                          cpu_bus_address;
   logic                                 cpu_mem_write;
   logic                                 data_bus_write_enable;

   MemoryBus::Cmd cpu_bus_cmd;
   MemoryBus::Result cpu_bus_result;
   MemoryBus::Cmd probe_bus_cmd;
   MemoryBus::Result probe_bus_result;
   logic [29:0]                          memory_bus_address;
   MemoryBus::Cmd memory_bus_cmd;
   MemoryBus::Result memory_bus_result;

   logic [29:0]                          data_bus_address;
   MemoryBus::Cmd data_bus_cmd;
   MemoryBus::Result data_bus_result;

   logic [29:0]                          uart_bus_address;
   MemoryBus::Cmd uart_bus_cmd;
   MemoryBus::Result uart_bus_result;

   assign uart_data = uart_bus_cmd.write_data[7:0];
   assign uart_bus_result = '{default: 0};

   uint32 cpu_data_result;

   assign probe_bus_cmd.mem_read = probe_mem_read;
   assign probe_bus_cmd.mask_byte = probe_mask_byte;
   assign probe_bus_cmd.write_data = probe_write_data;
   assign probe_read_data = probe_bus_result;

   logic                                 memory_write_enable;

   //Bus
   MasterBusMux #(.TCmd(MemoryBus::Cmd),
                  .TResult(MemoryBus::Result))
   master_bus(.useA(probe_mem),
              .addressA(probe_address),
              .writeEnableA(probe_mem_write),
              .busACmd(probe_bus_cmd),
              .busAResult(probe_bus_result),
              .addressB(cpu_bus_address),
              .writeEnableB(cpu_mem_write),
              .busBCmd(cpu_bus_cmd),
              .busBResult(cpu_bus_result),
              .addressCommon(memory_bus_address),
              .writeEnableCommon(memory_write_enable),
              .busCommonCmd(memory_bus_cmd),
              .busCommonResult(memory_bus_result)
              );

   SlaveBusMux #(.TCmd(MemoryBus::Cmd),
                 .TResult(MemoryBus::Result),
                 .Base1(riscV_unrn_pkg::PC_VALID_RANGE_BASE),
                 .Size1(2**riscV_unrn_pkg::RAM_WIDTH),
                 .Base2('h100),
                 .Size2(2**2))
   slave_bus(
             .address_in(memory_bus_address),
             .we_in(memory_write_enable),
             .cmd_in(memory_bus_cmd),
             .result_out(memory_bus_result),
             .address_1(data_bus_address),
             .we_1(data_bus_write_enable),
             .cmd_1(data_bus_cmd),
             .result_1(data_bus_result),
             .address_2(uart_bus_address),
             .we_2(uart_write),
             .cmd_2(uart_bus_cmd),
             .result_2(uart_bus_result));

   //Memory Interface
   logic                                 exception;

   ControllerMem controllerMem(.address(addressCpu_o[1:0]),
                               .dataMemOut(cpu_bus_result),
                               .instType(instType_cpu),
                               .exception(exception),
                               .dataRead(cpu_data_result),
                               .maskByte(cpu_bus_cmd.mask_byte),
                               .read(cpu_bus_cmd.mem_read),
                               .write(cpu_mem_write)
                               );


   //Memory

   uint32 pc;

   DataMem #(.WIDTH(riscV_unrn_pkg::RAM_WIDTH))
   data_mem(.clk,
            .write_enable(data_bus_write_enable),
            .bus_address(data_bus_address[riscV_unrn_pkg::RAM_WIDTH-2-1:0]),
            .membuscmd(data_bus_cmd),
            .membusres(data_bus_result)
            );
   //Core

   assign cpu_bus_address = addressCpu_o[31:2];

   mem_inst_type_t instType_cpu;
   uint32 addressCpu_o;

   multicycle multicycle(
                     //INPUTS
                     .clk,
                     .rst(rst_cpu),
                     .readData_i(cpu_data_result),
                     //OUTPUS
                     .instType_o(instType_cpu),
                     .writeData_o(cpu_bus_cmd.write_data),
                     .dataAddress_o(addressCpu_o),
                     .exception_o(exception),
                     .pc_o(pc)
                     );

   always_ff @(posedge clk) begin
      if (rst_cpu) begin
         test_done <= 0;
      end else if (pc == 'h80007FF0) begin
         test_done <= 1;
      end
   end


endmodule; // TOP_verilator
