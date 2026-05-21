class svbt_environment extends svbt_base_unit;

    int number_of_packets;
    svbt_base_unit units[$];
    svbt_packet_channel packet_mbox, data_in_mbox;
    
    svbt_data_in_generator data_in_generator;
    svbt_data_in_bfm data_in_bfm;
    
    svbt_reset_bfm reset_bfm;
    
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
        #30000
        $finish(1);
    endtask: run

endclass: svbt_environment