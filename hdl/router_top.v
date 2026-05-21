module router_top #(parameter N_SLAVES = 3) (
    input clk, rst,
    input packet_valid,
    input [7:0] data,
    output ready, err, busy, suspend_data_in,
    output [7:0] rdata
);
    wire [1:0] cmd_w, addr_w;
    wire [7:0] p_xor, p_last, s_rdata_bus;
    wire packet_ready, exec_start, exec_done, cmd_err;
    wire [2:0] s_op_dec, s_sel_dec;
    wire [7:0] s_wdata_dec;
    
    wire [N_SLAVES-1:0] s_sel_bus;
    wire [2:0] s_op_bus;
    wire [7:0] s_wdata_bus;
    tri0 [7:0] s_rdata_phys; 
    tri0       s_ack_phys;

    assign suspend_data_in = busy;

    router_fsm fsm_inst (
        .clk(clk), .rst(rst), .valid_mux(packet_valid), .data_mux(data),
        .busy(busy), .packet_ready(packet_ready), .cmd_out(cmd_w), .addr_out(addr_w),
        .payload_xor(p_xor), .payload_last(p_last), .exec_done(exec_done),
        .cmd_err(cmd_err), .ready(ready), .err(err)
    );

    cmd_decoder dec_inst (
        .clk(clk), .rst(rst), .packet_ready(packet_ready), .cmd(cmd_w), .addr(addr_w),
        .payload_xor(p_xor), .payload_last(p_last), .exec_done(exec_done),
        .exec_start(exec_start), .s_op(s_op_dec), .s_sel_id(s_sel_dec),
        .s_wdata(s_wdata_dec), .cmd_err(cmd_err), .s_rdata_bus(s_rdata_bus), 
        .rdata(rdata) // Conectat direct la portul extern
    );

    bus_controller #(.N_SLAVES(N_SLAVES)) bus_inst (
        .clk(clk), .rst(rst), .exec_start(exec_start), .s_op_in(s_op_dec),
        .s_sel_id(s_sel_dec), .s_wdata_in(s_wdata_dec), .s_sel(s_sel_bus),
        .s_op(s_op_bus), .s_wdata(s_wdata_bus), .s_rdata(s_rdata_phys),
        .s_ack(s_ack_phys), .exec_done(exec_done), .s_rdata_bus(s_rdata_bus)
    );

    genvar i;
    generate
        for (i=0; i<N_SLAVES; i=i+1) begin : slaves
            slave #(.SLAVE_ID(i), .N_SLAVES(N_SLAVES)) slv (
                .clk(clk), .s_sel(s_sel_bus), .s_op(s_op_bus), 
                .s_wdata(s_wdata_bus), .s_rdata(s_rdata_phys), .s_ack(s_ack_phys)
            );
        end
    endgenerate
endmodule