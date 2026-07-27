

program test;
   svbt_environment env;
   initial begin
     $display("=== START ERROR TEST (Mid-Packet Drop) ===");
     env = new(5, "Environment_Err_Drop", 4);
     env.run();
   end
endprogram