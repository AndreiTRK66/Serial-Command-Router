typedef enum {SMALL, MEDIUM, LARGE} packet_length;

class svbt_packet;

    int id;
    
    rand bit [1:0] cmd;
    rand bit [1:0] address;
    rand bit [3:0] length;
    rand bit [7:0] data [$];
     rand int delay;
     
    rand bit bad_parity;
    rand bit mid_packet_drop;
    
    //extern constraint keep_cmd_fixed;
    //extern constraint keep_address_fixed;
    //extern constraint keep_length_fixed;
    //extern constraint keep_delay;
    //extern constraint keep_error_flags;
    //constraint keep_address1 { (cmd!=2'b11) -> address != 2'b11 ;}
    //constraint keep_address2 {(address == 2'b11) -> cmd == 2'b11;}
    
    
    constraint keep_length { length > 0;}
    constraint order { solve length before data;}
    constraint keep_data_size { data.size() == length;}

    
    
    //constraint keep_length_small;
    
 
  
    constraint data_lock { (cmd == 2'b11 && address == 2'b11) ->{
         data[0][7:6] inside {2'b00, 2'b01};
         data[0][5:2] == 4'b0000;  
         data[0][1:0] inside {0, 1, 2};
    }}
    
    bit [7:0] parity;
    bit [7:0] header;
   
    //constraint keep_delay {delay inside {[15:20]};}
    
    rand packet_length pkt_length;
    constraint keep_pkt_length;
    constraint packet_length_c{
        (length == 1) -> pkt_length == SMALL;
        (length inside {[2:5]}) -> pkt_length == MEDIUM;
        (length > 5) -> pkt_length == LARGE; }
    
    
    //functii
    
    function void post_randomize();
        header = {cmd, address, length};
        parity = compute_parity();
        
    endfunction: post_randomize
    
    virtual function svbt_packet copy();
        svbt_packet h;
        h = new();
        this.copy_data(h);
        return h;
    endfunction: copy
    
    function void copy_data(svbt_packet copy2);
        copy2.id = this.id;
        copy2.cmd = this.cmd;
        copy2.address = this.address;
        copy2.length = this.length;
        copy2.data = this.data;
        copy2.parity = this.parity;
        copy2.delay = this.delay;
        copy2.pkt_length = this.pkt_length;
        copy2.header = this.header;
    endfunction: copy_data
    
    function void display(string prefix);
    
        string str, ddata ="";
        foreach(this.data[i]) begin
            str.hextoa(data[i]);
            ddata = { ddata, "h' ",str};
        end
        $display("[%0t] %s : packet ID: %0d | CMD = %0d | ADDRESS = %0d | LENGTH = %0d | PAYLOAD is %s | PARITY = %0h | DELAY = %0d ", $time, prefix, id, cmd, address, length, ddata, parity, delay);
    
    endfunction: display
    
    function bit[7:0] compute_parity();
    // { , } bit concatenation operator
        compute_parity = header;
        foreach(data[i]) begin
            compute_parity ^= data[i];
        end
        
    endfunction: compute_parity
    
endclass: svbt_packet