class svbt_data_in_bfm extends svbt_base_unit;

    svbt_packet_channel packet_mbox;
    
    virtual input_intf.drv smp_drv;
    virtual input_intf.rcv smp_rcv;
    virtual reset_intf.rcv smp_reset;
    
    function new( svbt_packet_channel packet_mbox,
                  virtual input_intf.drv smp_drv,
                  virtual input_intf.rcv smp_rcv,
                  virtual reset_intf.rcv smp_reset,
                  string name,
                  int id
                  );

        super.new(name,id);
        this.packet_mbox = packet_mbox;
        this.smp_drv = smp_drv;
        this.smp_rcv = smp_rcv;
        this.smp_reset = smp_reset;
    endfunction: new

    task run();
        svbt_packet curent_packet;
        $display("[%0t] %s Starting to drive packets...",$time, super.name);
        
        forever begin
            packet_mbox.get(curent_packet);
            drive_packet(curent_packet);
        end
    
    endtask: run
    
    task drive_packet(svbt_packet pkt);
    //neg edge
        repeat(pkt.delay) @(smp_drv.drv_cb);
        
        while((smp_rcv.rcv_cb.busy == 1'b1) || (smp_reset.rcv_cb.reset == 1'b1)) begin
            @(smp_drv.drv_cb);
        end
        
        smp_drv.drv_cb.packet_valid <= 1'b1;
        //smp_drv.drv_cb.data <= {pkt.cmd , pkt.address , pkt.length};
        smp_drv.drv_cb.data <= pkt.header;
        @(smp_drv.drv_cb);
        
        for(int i = 0; i < pkt.length; i++) begin
            smp_drv.drv_cb.data <=pkt.data[i];
            @(smp_drv.drv_cb);
        
        end
        smp_drv.drv_cb.data <= pkt.parity;
        @(smp_drv.drv_cb);
        //curatam busul
        smp_drv.drv_cb.packet_valid <= 1'b0;
        smp_drv.drv_cb.data <= 8'h00;
        @(smp_drv.drv_cb);
        
    
    endtask: drive_packet
    
endclass: svbt_data_in_bfm