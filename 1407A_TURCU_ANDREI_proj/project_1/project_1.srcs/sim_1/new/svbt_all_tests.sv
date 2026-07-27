`include "svbt_base_unit.sv"
`include "svbt_packet.sv"
`include "svbt_data_in_generator.sv"
`include "svbt_data_in_bfm.sv"
`include "svbt_monitor_in.sv"
`include "svbt_monitor_out.sv"
`include "svbt_reset_bfm.sv"
`include "svbt_scoreboard.sv"
`include "svbt_environment.sv"

class svbt_packet_bad_parity extends svbt_packet;

constraint keep_address_fixed { address inside {2'b00, 2'b01}; }
constraint keep_cmd_fixed { cmd == 2'b00; }
constraint keep_length_fixed { length inside {[2:4]}; }
constraint keep_delay { delay inside {[15:20]}; }
constraint keep_error_flags { bad_parity == 1; mid_packet_drop == 0; } // fortam EROAREA

virtual function svbt_packet copy();
    svbt_packet_bad_parity h;
    h = new();
    this.copy_data(h);
    return h;
endfunction: copy

endclass: svbt_packet_bad_parity

class svbt_packet_basic extends svbt_packet;

constraint keep_address_fixed { address == 0; }       
constraint keep_cmd_fixed { cmd inside {0, 1, 2}; }      // Fara comenzi speciale (doar Write, Read, Inc)
constraint keep_length_fixed { length inside {[1:5]}; }    
constraint keep_delay { delay inside {[15:20]}; }   

virtual function svbt_packet copy();
    svbt_packet_basic h;
    h = new();
    this.copy_data(h);
    return h;
endfunction: copy

endclass: svbt_packet_basic

class svbt_packet_err_addr extends svbt_packet;

constraint keep_address_fixed { address == 2'b11; }                 // Adresa 3 (Securitate)
constraint keep_cmd_fixed { cmd inside {2'b00, 2'b01, 2'b10}; } // Comenzi NORMALE (Ilegal pe 3)
constraint keep_length_fixed  { length inside {[1:3]}; }
constraint keep_delay { delay inside {[15:20]}; }
constraint keep_error_flags { bad_parity == 0; mid_packet_drop == 0; }

virtual function svbt_packet copy();
    svbt_packet_err_addr h;
    h = new();
    this.copy_data(h);
    return h;
endfunction: copy

endclass: svbt_packet_err_addr

class svbt_packet_functional extends svbt_packet;
constraint keep_address_fixed { address inside {2'b00, 2'b01, 2'b10, 2'b11}; } // Toate adresele
constraint keep_cmd_fixed { cmd inside {2'b00, 2'b01, 2'b10, 2'b11}; }     // Toate comenzile
constraint keep_length_fixed { length inside {[1:5]}; }
constraint keep_delay { delay inside {[15:20]}; }
constraint keep_error_flags { bad_parity == 0; mid_packet_drop == 0; }  

virtual function svbt_packet copy();
    svbt_packet_functional h;
    h = new();
    this.copy_data(h);
    return h;
endfunction: copy     

endclass: svbt_packet_functional

class svbt_packet_mid_drop extends svbt_packet;
constraint keep_address_fixed { address == 2'b00; }
constraint keep_cmd_fixed { cmd == 2'b00; }
constraint keep_length_fixed { length == 6; } // Lungime mare ca sa putem abandona la jumatate
constraint keep_delay { delay inside {[15:20]}; }
constraint keep_error_flags { bad_parity == 0; mid_packet_drop == 1; } // fortam abandonul

virtual function svbt_packet copy();
    svbt_packet_mid_drop h;
    h = new();
    this.copy_data(h);
    return h;
endfunction: copy 

endclass: svbt_packet_mid_drop

class svbt_packet_random extends svbt_packet;

constraint keep_address_fixed { address inside {[0:3]}; } 
constraint keep_cmd_fixed { cmd inside {[0:3]}; }
constraint keep_length_fixed { length inside {[1:15]}; }
constraint keep_delay { delay inside {[0:20]}; }
constraint keep_error_flags { bad_parity == 0; mid_packet_drop == 0; } // Aici testam doar success rate

virtual function svbt_packet copy();
    svbt_packet_random h;
    h = new();
    this.copy_data(h);
    return h;
endfunction: copy 

endclass: svbt_packet_random

class svbt_packet_stress extends svbt_packet;

constraint keep_address_fixed { address inside {2'b00, 2'b01, 2'b10}; }
constraint keep_cmd_fixed { cmd inside {2'b00, 2'b01, 2'b10}; }
constraint keep_length_fixed { length inside {[1:8]}; }
constraint keep_delay { delay == 0; } // ZERO DELAY
constraint keep_error_flags { bad_parity == 0; mid_packet_drop == 0; }

virtual function svbt_packet copy();
    svbt_packet_stress h;
    h = new();
    this.copy_data(h);
    return h;
endfunction: copy

endclass: svbt_packet_stress

program test;
   svbt_environment env;
   
   svbt_packet_basic      pkt_basic;
   svbt_packet_stress     pkt_stress;
   svbt_packet_bad_parity pkt_parity;
   svbt_packet_random     pkt_rand;
   svbt_packet_err_addr   pkt_err_addr;
   svbt_packet_functional pkt_functional;
   svbt_packet_mid_drop   pkt_mid_drop;
   
   initial begin
      $display("[%0t] [TEST_TOP] Incepem ...", $time);
      
      
      env = new(15, "Environment_CVLSI", 25);
      
     
//      pkt_basic = new();
//      env.data_in_generator.curent_packet = pkt_basic;
//      $display("START BASIC TEST)", $time);

      pkt_stress = new();
      env.data_in_generator.curent_packet = pkt_stress;
      $display("START STRESS TEST", $time);
      
//      pkt_parity = new();
//      env.data_in_generator.curent_packet = pkt_parity;
//      $display(" START BAD PARITY TEST");
      
//        pkt_rand = new();
//        env.data_in_generator.curent_packet = pkt_rand;
//        $display(" START RANDOM TEST");
        
//        pkt_err_addr = new();
//        env.data_in_generator.curent_packet = pkt_err_addr;
//        $display(" START ERROR ADDR TEST");
        
//        pkt_functional = new();
//        env.data_in_generator.curent_packet = pkt_functional;
//        $display(" START FUNCTIONAL TEST");
        
       // pkt_mid_drop = new();
      //  env.data_in_generator.curent_packet = pkt_mid_drop;
      //  $display(" START MID DROP TEST");
      
      env.run();
      
   end
endprogram