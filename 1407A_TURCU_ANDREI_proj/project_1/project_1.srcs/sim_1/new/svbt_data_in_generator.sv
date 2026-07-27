class svbt_data_in_generator extends svbt_base_unit;
    
    int max_number_of_packets;
    int pkts_counter;
    svbt_packet_channel packet_mbox;
    svbt_packet curent_packet;
    
    function new(svbt_packet_channel packet_mbox,
                int max_number_of_packets,
                string name,
                int id);
        super.new(name,id);
        this.packet_mbox = packet_mbox;
        this.max_number_of_packets = max_number_of_packets;
        this.pkts_counter = 0;
        curent_packet = new;
     endfunction: new
        
    task run();
    
        svbt_packet pkt2send;
        
        $display("[%0t] %s Starting to generate %0d packets...", $time, super.name,max_number_of_packets);
        
        while(pkts_counter < max_number_of_packets) begin
            pkt2send = get_packet(pkts_counter);
            packet_mbox.put(pkt2send);
            pkts_counter++;
        end
    
    endtask: run
    
    function svbt_packet get_packet(int pkts_counter);
        svbt_packet pkt;
        //pkt.id = pkts_counter;
        
        assert(curent_packet.randomize()) else $display("RANDOMIZATION FAIL");
        pkt = curent_packet.copy();
        pkt.id = pkts_counter;
        pkt.display("[GEN]");
        return pkt;
    
    endfunction: get_packet
    
    
endclass: svbt_data_in_generator