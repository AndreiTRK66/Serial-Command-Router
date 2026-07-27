class svbt_scoreboard extends svbt_base_unit;

    svbt_packet_channel mbx_monitor_in;
    svbt_packet_channel mbx_monitor_out;
    
    int total_packets, errors;
    virtual input_intf.rcv smp_rcv;

    bit [7:0] slv_reg [3]  = '{8'h00, 8'h00, 8'h00};
    bit slv_lock [3] = '{1'b0,  1'b0,  1'b0};

    function new(string name, int id,
                 svbt_packet_channel mbx_monitor_in,
                 svbt_packet_channel mbx_monitor_out,
                 virtual input_intf.rcv smp_rcv);
        super.new(name,id);
        this.mbx_monitor_in = mbx_monitor_in;
        this.mbx_monitor_out = mbx_monitor_out;
        this.smp_rcv = smp_rcv;
        this.total_packets = 0;
        this.errors = 0;
    endfunction: new
    
    task run();
        forever begin
            check_packets();
        end
    endtask: run
    
    task check_packets();
        svbt_packet drv_packet;
        svbt_packet rcv_packet;
        
        // Asteptam pachetul de la iesire si cel de la intrare
        mbx_monitor_out.get(rcv_packet);
        mbx_monitor_in.get(drv_packet); 
            
        rcv_packet.id = drv_packet.id;
        
        // Verificam daca paritatea generata coincidea cu cea calculata
        check_err(drv_packet);
        
        //Logica de verificare
        begin
            bit [1:0] cmd  = drv_packet.cmd;
            bit [1:0] addr = drv_packet.address;

            case(cmd)
                2'b00: begin // WRITE
                    if(addr < 3 && !slv_lock[addr]) begin
                        bit [7:0] xor_sum = 0;
                        foreach(drv_packet.data[i]) xor_sum ^= drv_packet.data[i];
                        slv_reg[addr] = xor_sum;
                        $display("[%0t] [SCOREBOARD] CMD WRITE: Am calculat XOR %0h si am scris in slaveul %0d", $time, xor_sum, addr);
                    end else if (addr < 3 && slv_lock[addr]) begin
                        $display("[%0t] [SCOREBOARD] CMD WRITE: Silent Drop. slaveul %0d este LOCK.", $time, addr);
                    end
                end
                
                2'b01: begin // READ
                    if(addr < 3) begin
                        $display("[%0t] [SCOREBOARD] CMD READ : Se citeste slaveul %0d. Asteptat: %0h | Primit (rdata): %0h", $time, addr, slv_reg[addr], rcv_packet.data[0]);
                        // DOAR AICI COMPARAM RDATA!
                        if(rcv_packet.data[0] != slv_reg[addr]) begin
                            $display("[%0t] [SCOREBOARD] EROARE READ! Pachet %0d *** Asteptat: %0h | Primit: %0h", $time, drv_packet.id, slv_reg[addr], rcv_packet.data[0]);
                            errors++;
                        end
                    end
                end
                
                2'b10: begin // INCREMENT
                    if(addr < 3 && !slv_lock[addr]) begin
                        bit [7:0] last_byte = drv_packet.data[drv_packet.length - 1];
                        slv_reg[addr] = slv_reg[addr] + last_byte;
                        $display("[%0t] [SCOREBOARD] CMD INC  : Slaveul %0d a fost incrementat. Valoare noua: %0h", $time, addr, slv_reg[addr]);
                    end
                end
                
                2'b11: begin // SPECIAL
                    if(addr < 3) begin // RESET SLAVE
                        slv_reg[addr] = 8'h00;
                        slv_lock[addr] = 1'b0;
                        $display("[%0t] [SCOREBOARD] CMD RESET: Slaveul %0d a fost resetat si deblocat", $time, addr);
                    end else if(addr == 3) begin // LOCK / UNLOCK
                        bit [1:0] op = drv_packet.data[0][7:6];
                        bit [1:0] ss = drv_packet.data[0][1:0];
                        if(ss < 3) begin
                            if(op == 2'b00) begin
                                slv_lock[ss] = 1'b1;
                                $display("[%0t] [SCOREBOARD] CMD LOCK : slaveul %0d a fost BLOCAT", $time, ss);
                            end else if(op == 2'b01) begin
                                slv_lock[ss] = 1'b0;
                                $display("[%0t] [SCOREBOARD] CMD UNLCK: Slaveul %0d a fost DEBLOCAT", $time, ss);
                            end
                        end
                    end
                end
            endcase
        end
            
        total_packets++;
    endtask: check_packets
    
    task check_err(svbt_packet drv_packet);
        bit[7:0] expected_parity;
        expected_parity = drv_packet.compute_parity();
        if(expected_parity != drv_packet.parity) begin
            $display("[%0t] %s: [INFO] Pachetul %0d a fost trimis cu o paritate corupta intentionat", $time, super.name, drv_packet.id);
        end
    endtask: check_err
    
    task check_empty();
        if(mbx_monitor_in.num()!= 0) begin
            $display("[%0t] %s: EROARE, MBX_MONITOR_IN mai are %0d pachete neprocesate la final", $time, super.name, mbx_monitor_in.num());
            errors++;
        end
        if(mbx_monitor_out.num() != 0) begin
             $display("[%0t] %s: EROARE, MBX_MONITOR_OUT mai are %0d pachete neprocesate la final", $time, super.name, mbx_monitor_out.num());
            errors++;
        end
    endtask: check_empty

endclass: svbt_scoreboard