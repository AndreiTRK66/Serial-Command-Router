class svbt_monitor_out extends svbt_base_unit;

    svbt_packet curent_packet;
    
    virtual output_intf.rcv smp;
    virtual reset_intf.rcv smp_reset;
    int pkt_id;
    svbt_packet_channel packet_mbox;
    
    function new(virtual output_intf.rcv smp, virtual reset_intf.rcv smp_reset, svbt_packet_channel packet_mbox, string name, int id);
        super.new(name,id);
        this.smp = smp;
        this.smp_reset = smp_reset;
        this.packet_mbox = packet_mbox;
        pkt_id = 0;
        
    endfunction: new
    
    task run();
        forever begin
            // Asteptam ca Slaveul sa raspunda (ready sa devina 1)
            do begin
                @(smp.rcv_cb);
            end while(smp.rcv_cb.ready !== 1'b1);
            
           
            
            curent_packet = new;
            curent_packet.id = pkt_id;
            
            // Acum, la un Master/Slave, cand ready e 1, rdata are valoarea finala valabila 1 ciclu
            curent_packet.data.push_back(smp.rcv_cb.rdata);
            curent_packet.length = 1; // Un singur octet la iesire intotdeauna
            
            void'(curent_packet.display("MONITOR_OUT"));
            pkt_id++;
            packet_mbox.put(curent_packet);
            
            // Asteptam sa cada ready in 0 inainte sa ascultam iar
            do begin
                @(smp.rcv_cb);
            end while(smp.rcv_cb.ready === 1'b1);
        end
    endtask: run
    
endclass: svbt_monitor_out