import Common::*;
import MemoryBus::*;

module TOP_microsemi(input logic         USER_BUTTON1,
                     output logic        FTDI_UART0_TXD
                     );
   logic clk;
   logic rst_cpu;
   assign rst_cpu = USER_BUTTON1;
module clock_generator(
    // Outputs
    .RCOSC_25_50MHZ_O2F(clk)
);

   logic uart_tx_o;

   logic [29:0]                          cpu_bus_address;
   logic                                 cpu_mem_write;
   logic                                 data_bus_write_enable;
   logic                                 memory_write_enable;
   logic                                 exception;
   uint32 pc;
   mem_inst_type_t instType_cpu;
   uint32 addressCpu_o;
   uint32 cpu_data_result;


   MemoryBus::Cmd cpu_bus_cmd;
   MemoryBus::Result cpu_bus_result;
   logic [29:0]                          memory_bus_address;
   MemoryBus::Cmd memory_bus_cmd;
   MemoryBus::Result memory_bus_result;

   logic [29:0]                          data_bus_address;
   MemoryBus::Cmd data_bus_cmd;
   MemoryBus::Result data_bus_result;

   logic [29:0]                          uart_bus_address;
   MemoryBus::Cmd uart_bus_cmd;
   MemoryBus::Result uart_bus_result;

   assign FTDI_UART0_TXD = uart_tx_o;

   assign memory_bus_address = cpu_bus_address;
   assign memory_write_enable = cpu_mem_write;
   assign memory_bus_cmd = cpu_bus_cmd;
   assign cpu_bus_result = memory_bus_result;
   assign pc_o = pc;

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

    //UART Instance
    uart #(.BAUDRATE(115200), .F_CLK(576000)) uart0(
        .sys_clk_i      (clk),
        .sys_rst_i      (rst_cpu),
        .uart_data_o    (uart_bus_result),
        .uart_tx_o      (uart_tx_o),
        .uart_wr_i      (uart_write),
        .uart_dat_i     (uart_bus_cmd.write_data[7:0])
        );

   //Memory Interface

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

   DataMem #(.WIDTH(riscV_unrn_pkg::RAM_WIDTH))
   data_mem(.clk,
            .write_enable(data_bus_write_enable),
            .bus_address(data_bus_address[1:0]),
            .membuscmd(data_bus_cmd),
            .membusres(data_bus_result)
            );

   //Core

   assign cpu_bus_address = addressCpu_o[31:2];

   unicycle unicycle(
                     //INPUTS
                     .clk,
                     .rst(rst_cpu),
                     .readData_i(cpu_data_result),
                     //OUTPUS
                     .instType_o(instType_cpu),
                     .writeData_o(cpu_bus_cmd.write_data),
                     .dataAddress_o(addressCpu_o),
                     .exception_o(exception),
                     .pc_o(pc),
                     .mtime_debug_o(mtime_o)
                     );

endmodule; // TOP_microsemi
