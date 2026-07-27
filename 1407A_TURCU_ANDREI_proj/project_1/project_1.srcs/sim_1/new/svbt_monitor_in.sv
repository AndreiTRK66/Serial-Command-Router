class svbt_monitor_in extends svbt_base_unit;

    svbt_packet curent_packet;
    svbt_packet_channel packet_mbox;
    virtual input_intf.rcv smp;
    virtual reset_intf.rcv smp_reset;
    int pkt_id;
    
    covergroup cg_router_traffic;
        option.per_instance = 1;
    
        cp_cmd: coverpoint curent_packet.cmd {
            bins CMD_WRITE = {2'b00};
            bins CMD_READ = {2'b01};
            bins CMD_INC = {2'b10};
            bins CMD_SPE = {2'b11};
        }
        
        cp_addr: coverpoint curent_packet.address{
            bins SLAVE_0 = {0};
            bins SLAVE_1 = {1};
            bins SLAVE_2 = {2};
            bins SECURITY = {3};
        }
        
        cp_length: coverpoint curent_packet.length{
            bins SMALL = {[0:3]};
            bins MEDIUM = {[4:8]};
            bins LARGE = {[9:15]};
    }
        cross_cmd_addr: cross cp_cmd, cp_addr{
            ignore_bins illegal_ops = binsof(cp_cmd) intersect { 2'b00, 2'b01, 2'b10} && binsof(cp_addr) intersect {3};
        }    
        
        endgroup
    
    function new(virtual input_intf.rcv smp, virtual reset_intf.rcv smp_reset, svbt_packet_channel packet_mbox, string name, int id);
        super.new(name, id);
        this.smp = smp;
        this.smp_reset = smp_reset;
        this.packet_mbox = packet_mbox;
        pkt_id = 0;
        
        cg_router_traffic = new();
        cg_router_traffic.set_inst_name("cg_router_traffic");
        
    endfunction: new

    task run();
        forever begin
          
            @(smp.rcv_cb);
            
           
            if(smp.rcv_cb.packet_valid == 1'b1) begin
                curent_packet = new;
                curent_packet.id = pkt_id;
            
               curent_packet.cmd     = smp.rcv_cb.data[7:6];
               curent_packet.address = smp.rcv_cb.data[5:4];
               curent_packet.length  = smp.rcv_cb.data[3:0];
               
               curent_packet.header = smp.rcv_cb.data;
              
               for(int i = 0; i < curent_packet.length; i++) begin
                    @(smp.rcv_cb);
                    curent_packet.data.push_back(smp.rcv_cb.data);
               end
               
               
               @(smp.rcv_cb);
               curent_packet.parity = smp.rcv_cb.data;
               
               cg_router_traffic.sample();
               
               void'(curent_packet.display("DATA_IN_MONITOR"));
               pkt_id++;
               packet_mbox.put(curent_packet);
            end
            
        end
    endtask: run
    
endclass: svbt_monitor_in