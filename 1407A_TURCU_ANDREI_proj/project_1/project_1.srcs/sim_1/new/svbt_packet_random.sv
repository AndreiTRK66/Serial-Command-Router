class svbt_packet_random extends svbt_packet;

constraint svbt_packet::keep_address_fixed { address inside {[0:3]}; } 
constraint svbt_packet::keep_cmd_fixed     { cmd inside {[0:3]}; }
constraint svbt_packet::keep_length_fixed  { length inside {[1:15]}; }
constraint svbt_packet::keep_delay         { delay inside {[0:20]}; }
constraint svbt_packet::keep_error_flags   { bad_parity == 0; mid_packet_drop == 0; } // Aici testam doar success rate

endclass: svbt_packet_random