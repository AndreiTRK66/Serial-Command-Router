class svbt_environment extends svbt_base_unit;

    int number_of_packets;
    svbt_base_unit units[$];
    svbt_packet_channel packet_mbox, data_in_mbox,data_out_mbox;
    
    svbt_data_in_generator data_in_generator;
    svbt_data_in_bfm data_in_bfm;
    svbt_monitor_in monitor_in;
    
    svbt_reset_bfm reset_bfm;
    
    svbt_monitor_out monitor_out;
    svbt_scoreboard scoreboard;
    
    
    bit force_read_enable_deasserted;
    
    
    
    
    function new ( int unsigned number_of_packets ,string name, int id);
        super.new(name, id);
        this.number_of_packets = number_of_packets;
        
        reset_bfm = new(top.reset_intf.drv, "RESET_BFM",0);
        units.push_back(reset_bfm);
        
        packet_mbox = new();
        
        data_in_generator = new(packet_mbox, number_of_packets,"DATA_IN_GENERATOR", 1);
        units.push_back(data_in_generator);
        
        data_in_bfm = new(packet_mbox, top.input_intf.drv, top.input_intf.rcv, top.reset_intf.rcv,"DATA_IN_BFM",2);
        units.push_back(data_in_bfm);
        
        data_in_mbox = new();
        monitor_in = new(top.input_intf.rcv, top.reset_intf.rcv, data_in_mbox, "MONITOR_IN", 3);
        units.push_back(monitor_in);
        
        data_out_mbox = new();
        monitor_out = new(top.output_intf.rcv, top.reset_intf.rcv, data_out_mbox, "MONITOR_OUT",4);
        units.push_back(monitor_out);
        
        scoreboard = new("SCOREBOARD", 5, data_in_mbox,data_out_mbox, top.input_intf.rcv);
        units.push_back(scoreboard);
        
    endfunction: new
    
    
    
    
    
    task run();
        
       units[0].run();
       
       for(int i = 1; i < units.size(); i++) begin
            fork
                automatic int k = i;
                begin
                    units[k].run();
                end
            join_none       
       end
        #20000
        scoreboard.check_empty();
        
        if(scoreboard.errors == 0) begin
            $display("TEST PASSED");
            $display(" TOTAL PACKETS: %0d", scoreboard.total_packets);
        end else begin
            $display("TEST FAILED  %0d ERRORS",scoreboard.errors);    
            end
        $finish(1);
    endtask: run

endclass: svbt_environment