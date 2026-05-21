interface reset_intf(
    input wire clock,
    output logic reset
);

//BFM conduce resetul pe negedge - regula din pdf 5.
    clocking drv_cb@(negedge clock);
        output reset;
    endclocking
    modport drv(clocking drv_cb, input clock);
    // Monitorul observa resetul pe pos, odata cu dut
    clocking rcv_cb@(posedge clock);
        input reset;
    endclocking
    modport rcv(clocking rcv_cb, input clock);
    
endinterface: reset_intf

interface input_intf(
    input wire clock,
    output bit packet_valid,
    output bit [7:0] data,
    input bit err,
    input bit suspend_data_in,
    input bit busy
);
    //clocking block used for driving
    //driverul simuleaza dut pe negedge
    clocking drv_cb @(negedge clock);
        output packet_valid;
        output data;
    endclocking
    modport drv(clocking drv_cb, input clock);
    
    
    //clocking block used for monitoring
    //monitorul esantioneaza pe posedge pentru acuratete la nivelul de ciclu
    clocking rcv_cb @(posedge clock);
        input packet_valid;
        input data;
        input suspend_data_in;
        input busy;
        input err;
    endclocking
    modport rcv(clocking rcv_cb, input clock);
    
    endinterface: input_intf
    
interface output_intf(
    input wire clock,
    input bit [7:0] rdata,
    input bit ready
);
    clocking drv_cb @(negedge clock);
    endclocking
    modport drv(clocking drv_cb, input clock);
    
    clocking rcv_cb @(posedge clock);
        input rdata;
        input ready;
    endclocking
    modport rcv(clocking rcv_cb, input clock);
    
endinterface: output_intf
