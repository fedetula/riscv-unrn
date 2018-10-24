module codePcNext
  ( input logic branch,jump,excep,retExc,
    output logic [2:0] pc_next);

always_comb
      begin
        if(branch)
          pc_next =2'b001;
        else if(jump)
          pc_next =2'b010;
        else if(excep)
          pc_next =2'b011;
        else if(reyExc)
          pc_next =2'b100;
        else
          pc_next =2'b000;
      end
