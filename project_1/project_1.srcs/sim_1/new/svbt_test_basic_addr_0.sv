`include "svbt_base_unit.sv"
`include "svbt_packet.sv"
`include "svbt_reset_bfm.sv"
`include "svbt_data_in_generator.sv"
`include "svbt_data_in_bfm.sv"
`include "svbt_environment.sv"

constraint svbt_packet::keep_address_fixed {address == 0;}
constraint svbt_packet::keep_length_small {length < 10;}

program test;
    svbt_environment env;
    
    initial begin
       env = new(15, "Environment", 25);
       env.run();
       
       end
endprogram