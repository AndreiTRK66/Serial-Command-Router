module top();
    reg clock;
    reg reset;
    reg packet_valid;
    reg [7:0] data;
    wire [7:0] rdata;
    wire ready;
    wire busy;
    wire suspend_data_in;
    wire err;
    
    router_top router_top1(
        .clk (clock), // input
        .rst (reset),// input
        .packet_valid (packet_valid),//input
        .data (data), //input
        .ready (ready), //output
        .err (err), //output
        .busy (busy), //output
        .suspend_data_in (suspend_data_in),
        .rdata (rdata)
    );
    
    reset_intf reset_intf(
        .clock(clock),
        .reset(reset)
    );
    
    input_intf input_intf(
        .clock(clock),
        .packet_valid (packet_valid),
        .data (data),
        .busy (busy),
        .suspend_data_in (suspend_data_in),
        .err(err)
    );
    
    
    output_intf output_intf(
        .clock(clock),
        .rdata(rdata),
        .ready(ready)
    );
    //generam clok
    
    initial begin
        clock =0;
        forever begin
            #50 clock = !clock;
        end
    end  
    test my_test();
endmodule
