constraint svbt_packet::keep_address_fixed {address == 0;}
constraint svbt_packet::keep_length_small {length < 10;}

program test;
    svbt_packet pkt;
    
    initial begin
        pkt = new();
        pkt.display("Initial");
        if(pkt.randomize()) begin
            pkt.display("Dupa randomizare");
        end
        
        if(pkt.randomize() with { address == 2'b00;}) begin
            pkt.display("Randomizare Inline");
        end
    end
endprogram