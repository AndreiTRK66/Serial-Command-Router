`include "svbt_base_unit.sv"
`include "svbt_packet.sv"
`include "svbt_reset_bfm.sv"
`include "svbt_data_in_generator.sv"
`include "svbt_data_in_bfm.sv"
`include "svbt_environment.sv"
`include "svbt_monitor_in.sv"
`include "svbt_monitor_out.sv"
`include "svbt_scoreboard.sv"

//constraint svbt_packet::keep_address_fixed {(cmd != 2'b11) ? address = 2'b11}
constraint svbt_packet::keep_length_small {length < 10;}

program test;
    svbt_environment env;
    
    initial begin
       env = new(15, "Environment", 25);
       env.run();
       
       end
endprogram