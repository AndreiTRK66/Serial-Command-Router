typedef mailbox svbt_packet_channel;

class svbt_base_unit;

    string name;
    int id;
    
    function new(string name, int id);
        this.name = name;
        this.id = id;
    endfunction: new
    
    function display_name(string name);
        $display("%s",name);
    
    endfunction: display_name
    
    virtual task run;
        
    endtask: run

endclass: svbt_base_unit