module top(
    input logic clk,
    input logic rst,
    input logic sw
//    output logic[3:0] led
    );

    clk_wiz_0 clk_wiz(.clk_out1(clk_lento), .clk_in1(clk));

    Uniciclo uniciclo(.clk(clk_lento), .rst(sw));

    unicycle  softCore(.*,
                    //Memory Interface
                    instType_o,
                    writeData_o,
                    dataAddress_o,
                    readData_i,
                    memException_i,
                    pc_o,
                    instruction_i
                    );


    // //A modificar
    //   DataMem data_mem(.*,
    //                  .mem_read    (control_mem_out.mem_read),
    //                  .mem_write   (control_mem_out.mem_write),
    //                  .address     (alu_result[31:2]),
    //                  .write_data  (reg_file_read_data2),
    //                  .read_data(data_mem_out)
    //                  .pc          (PC_reg),
    //                  .instruction (instruction_i)
    //                  );


endmodule
