module bus_controller #(parameter N_SLAVES = 3) (
    input clk, rst,
    input exec_start,
    input [2:0] s_op_in, s_sel_id,
    input [7:0] s_wdata_in,
    output reg [N_SLAVES-1:0] s_sel,
    output reg [2:0] s_op,
    output reg [7:0] s_wdata,
    input [7:0] s_rdata,
    input s_ack,
    output reg exec_done,
    output reg [7:0] s_rdata_bus
);

    reg [1:0] state;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= 0; s_sel <= 0; exec_done <= 0;
        end else begin
            exec_done <= 1'b0;
            case (state)
                0: if (exec_start) begin
                    $display("[%0t] BUS: Selectez Slave %d (OP=%b)", $time, s_sel_id, s_op_in);
                    s_sel   <= (1 << s_sel_id);
                    s_op    <= s_op_in;
                    s_wdata <= s_wdata_in;
                    state   <= 1;
                end
                1: begin
                    if (s_ack === 1'b1) begin
                        $display("[%0t] BUS: Slave-ul a raspuns cu ACK", $time);
                        s_rdata_bus <= s_rdata;
                        s_sel <= 0;
                        state <= 2;
                    end
                end
                2: begin
                    exec_done <= 1'b1;
                    state <= 0;
                end
            endcase
        end
    end
endmodule