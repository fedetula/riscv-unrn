
module ALU #(parameter N=32)
  (input logic clk,start,
   input logic [N-1:0] dataA, dataB,
   input logic [3:0] operation, 
   output logic will_be_done,
   output logic [N-1:0] result
   );
   
 /*
 0 AND-----OK
 1 OR-----OK
 2 ADD-----OK
 3 CNE-----OK
 4 SLL-----OK
 5 SUB-----OK
 6 SRL-----OK
 7 SRA-----OK
 8 SLT-----OK
 9 SLTU-----OK
 10 XOR-----OK
 11 CGE-----OK 
 12 CGEU-----OK
 13 CE----- OK
 */
 
 
 /*-------------------------
     SENALES INTERNAS
   -------------------------*/

logic new_value, old_value, aux_sub, aux_data2 , aux_start_bit , aux_register_2 , aux_stall , select_mux , old_reg_counter ,flag2;
logic carry_b, flag_aux, aux1_slt, aux2_slt, aux3_slt, aux4_slt, aux5_slt, aux6_slt , flag;
logic [1:0] aux_register;
logic [N-2:0] reg_Counter;
logic aux1, aux2, aux3, MSB1, MSB2, start_bit,data1 ,data2;
logic [N-1:0] aux_dataA, aux_dataB;
logic [N-1:0] data_decode;
logic [N-1:0] aux_data_shift ;
logic [4:0] decode;


/*-------------------------
    LOGICA COMBINACIONAL
  -------------------------*/

always_comb begin
    aux_register = 0;
	aux_register_2 = 0;
    flag_aux = 1;
    new_value = 0;
    aux1_slt = 0;
    aux2_slt = 0;
    aux3_slt = 0;
    aux4_slt = 0;
    aux5_slt = 0;
    aux6_slt = 0;
	select_mux = 0;
    aux_start_bit = start_bit;
    unique case(operation) 
        0: begin
            aux_register = data1 & data2;   
        end
        1: begin
            aux_register = data1 | data2;   
        end
		2: begin
            aux_register = data1 + data2 + carry_b;   
        end
        3: begin
            aux_register = start_bit;
			aux_register_2 = data1 ~^ data2;
            flag_aux = aux_register_2;   
			select_mux = 1;
        end
		4: begin
            aux_register = data1 & data2;
        end
		5: begin
            aux_register = data1 + aux_data2  + carry_b + aux_sub;   
        end
		6: begin
            aux_register = data1;
            aux_start_bit = data2;   
        end
		7: begin
            aux_register = data1;
            aux_start_bit = data2;   
        end
        8: begin
            aux1_slt = ~data1 & old_value;
            aux2_slt = ~data1 & data2 & ~old_value;
            aux3_slt =  data1 & data2 & old_value;
            new_value = aux1_slt | aux2_slt | aux3_slt;
            aux4_slt = new_value & ~MSB1 & ~MSB2;
            aux5_slt = new_value &  MSB1 &  MSB2;
            aux6_slt = MSB1 & ~MSB2; 
			aux_register = start_bit;
            aux_register_2 = aux4_slt | aux5_slt | aux6_slt;
            flag_aux = (~aux_register_2) ? 0 : flag_aux;  //No se cumple que D1>=D2
			select_mux = 1;
        end
        9: begin
            aux1_slt = ~data1 & old_value;
            aux2_slt = ~data1 & data2 & ~old_value;
            aux3_slt =  data1 & data2 & old_value;
			aux_register = start_bit;
            aux_register_2 = aux1_slt | aux2_slt | aux3_slt;
            flag_aux = (~aux_register_2 ) ? 0 : flag_aux;  //No se cumple que D1<D2    
			select_mux = 1;
        end
		10: begin
            aux_register = data1 ^ data2;   
        end
        11: begin
            aux1_slt = ~data1 & old_value;
            aux2_slt = ~data1 & data2 & ~old_value;
            aux3_slt =  data1 & data2 & old_value;
            new_value = aux1_slt | aux2_slt | aux3_slt;
            aux4_slt = new_value & ~MSB1 & ~MSB2;
            aux5_slt = new_value &  MSB1 &  MSB2;
            aux6_slt = MSB1 & ~MSB2; 
			aux_register = start_bit;
            aux_register_2 = aux4_slt | aux5_slt | aux6_slt;
            flag_aux = (aux_register_2) ? 0 : flag_aux;  //No se cumple que D1>=D2 
			select_mux = 1;
        end
        12: begin
            aux1_slt = ~data1 & old_value;
            aux2_slt = ~data1 & data2 & ~old_value;
            aux3_slt =  data1 & data2 & old_value;
			aux_register = start_bit;
            aux_register_2 = aux1_slt | aux2_slt | aux3_slt;
            flag_aux = (aux_register_2) ? 0 : flag_aux;  //No se cumple que D1<D2   
			select_mux = 1;			
        end
		13: begin
            aux_register = start_bit;
			aux_register_2 = data1 ~^ data2;
            flag_aux = aux_register_2;  
			select_mux = 1;
        end
    endcase
end
	

/*-------------------------
    LOGICA SECUENCIAL
  -------------------------*/

always_ff @(posedge clk) begin
    start_bit <= 0; 
    if(start) begin
	    carry_b <= 0;
		reg_Counter <= 0;
		old_value <= 0;
        aux_dataA<=dataA[N-1:0];
        aux_dataB<=dataB[N-1:0];
        MSB1<=dataA[N-1];
        MSB2<=dataB[N-1];
        start_bit <= 1;
		aux_data_shift <= data_decode;
    end
    else begin
		reg_Counter <= {aux_start_bit,reg_Counter[N-2:1]};
		carry_b <= aux_register[1];
		old_value <= aux_register_2; // Es para SLT y SLTU
		old_reg_counter <= reg_Counter[0];
		aux_dataB<={aux_register[0],aux_dataB[N-1:1]};
        case(operation)
            4: begin //SLL
                if(aux3) begin 
                    aux_dataA<={1'b0,aux_dataA[N-1:1]};
                end
                else begin
                    aux_data_shift<={1'b0,aux_data_shift[N-1:1]};
                end
            end
            7: begin//SRA
                aux_dataA<={MSB1,aux_dataA[N-1:1]};
                aux_data_shift<={1'b0,aux_data_shift[N-1:1]};
            end
            default: begin //Otras operaciones
                aux_dataA<={1'b0,aux_dataA[N-1:1]};
                aux_data_shift<={1'b0,aux_data_shift[N-1:1]};
            end
        endcase
    end
end


/*-------------------------
    VARIABLES INTERNAS
  -------------------------*/

assign flag2 = (operation == 3) ? flag : ~flag;
assign aux_data2 = ~data2;
assign aux_sub = start_bit;
assign aux_stall = ((~reg_Counter[0] & flag2 & old_reg_counter) | (reg_Counter[0] & ~flag2 & ~old_reg_counter));
assign flag = (start) ? 1 : (~reg_Counter[0] & old_reg_counter) ? flag : (operation == 8 | operation == 9 | operation == 11 | operation == 12 ) ? flag_aux :(flag & flag_aux);

assign decode = dataB[4:0];
assign aux1 = aux_dataA[0];
assign aux2 = aux_dataB[0]; 
assign aux3 = aux_data_shift[0]; 
  
always_comb begin
        unique case(decode)
            0:data_decode = 32'h0000_0001;
            1:data_decode = 32'h0000_0002;
            2:data_decode = 32'h0000_0004;
            3:data_decode = 32'h0000_0008;
            4:data_decode = 32'h0000_0010;
            5:data_decode = 32'h0000_0020;
            6:data_decode = 32'h0000_0040;
            7:data_decode = 32'h0000_0080;
            8:data_decode = 32'h0000_0100;
            9:data_decode = 32'h0000_0200;
           10:data_decode = 32'h0000_0400;
           11:data_decode = 32'h0000_0800;
           12:data_decode = 32'h0000_1000;
           13:data_decode = 32'h0000_2000;
           14:data_decode = 32'h0000_4000;
           15:data_decode = 32'h0000_8000;
           16:data_decode = 32'h0001_0000;
           17:data_decode = 32'h0002_0000;
           18:data_decode = 32'h0004_0000;
           19:data_decode = 32'h0008_0000;
           20:data_decode = 32'h0010_0000;
           21:data_decode = 32'h0020_0000;
           22:data_decode = 32'h0040_0000;
           23:data_decode = 32'h0080_0000;
           24:data_decode = 32'h0100_0000;
           25:data_decode = 32'h0200_0000;
           26:data_decode = 32'h0400_0000;
           27:data_decode = 32'h0800_0000;
           28:data_decode = 32'h1000_0000;
           29:data_decode = 32'h2000_0000;
           30:data_decode = 32'h4000_0000;
           31:data_decode = 32'h8000_0000; 
        endcase
end  
    

/*-------------------------
    VARIABLES DE SALIDA
  -------------------------*/
  
assign data1 = aux1;
assign data2 = (operation==4 | operation==6 | operation==7) ? aux3 : aux2; 
assign result = aux_dataB;
assign will_be_done = (select_mux) ? aux_stall : reg_Counter[0];

endmodule

