typedef enum {SMALL, MEDIUM, LARGE} packet_length;

class svbt_packet;

    int id;
    
    rand bit [1:0] cmd;
    constraint keep_cmd_fixed;
    
    rand bit [1:0] address;
    constraint keep_address1 { (cmd!=2'b11) -> address != 2'b11 ;}
    constraint keep_address2 {(address == 2'b11) -> cmd == 2'b11;}
    constraint keep_address_fixed;
    
    rand bit [3:0] length;
    constraint keep_length { length > 0;}
    //constraint keep_length_fixed;
    constraint keep_length_small;
    
    rand bit [7:0] data [$];
    constraint order { solve length before data;}
    constraint keep_data_size { data.size() == length;}
    constraint data_lock { (cmd == 2'b11 && address == 2'b11) ->{
         data[length-1][7:6] inside {2'b00, 2'b01};
         data[length-1][1:0] < 3;     
    }}
    
    bit [7:0] parity;
    bit [7:0] header;
    rand int delay;
    constraint keep_delay {delay inside {[1:10]};}
    
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
    
    function svbt_packet copy();
        copy = new();
        copy.id = this.id;
        copy.cmd = this.cmd;
        copy.address = this.address;
        copy.length = this.length;
        copy.data = this.data;
        copy.parity = this.parity;
        copy.delay = this.delay;
        copy.pkt_length = this.pkt_length;
        copy.header = this.header;
    
    endfunction: copy
    
    function display(string prefix);
    
        string str, ddata ="";
        foreach(this.data[i]) begin
            str.hextoa(data[i]);
            ddata = { ddata, "h'",str};
        end
        $display("[%0t] %s : packet ID: %0d | CMD = %0d | ADDRESS = %0d | LENGTH = %0d | PAYLOAD is %s | PARITY = %0h | DELAY = %0d", $time, prefix, id, cmd, address, length, ddata, parity, delay);
    
    endfunction: display
    
    function bit[7:0] compute_parity();
    // { , } bit concatenation operator
        compute_parity = header;
        foreach(data[i]) begin
            compute_parity ^= data[i];
        end
        
    endfunction: compute_parity
    
endclass: svbt_packet