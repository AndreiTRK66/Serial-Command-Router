module router_fsm (
    input        clk, rst,
    input        valid_mux,
    input  [7:0] data_mux,
    output reg   busy,
    output reg   packet_ready,
    output [1:0] cmd_out,      
    output [1:0] addr_out,     
    output reg [7:0] payload_xor,
    output reg [7:0] payload_last,
    input        exec_done,
    input        cmd_err,
    output reg   ready,
    output reg   err
);

    localparam ST_IDLE        = 3'd0,
               ST_LOAD_DATA   = 3'd1,
               ST_LOAD_PARITY = 3'd2,
               ST_WAIT_EXEC   = 3'd3,
               ST_RESPOND     = 3'd4;

    reg [2:0] state;
    reg [7:0] header_r, parity_acc;
    reg [5:0] count; 
    reg       respond_err_fsm;
    reg       exec_done_q;

    assign cmd_out  = header_r[7:6];
    assign addr_out = header_r[5:4];

    always @(posedge clk) begin
        if (rst || state == ST_IDLE) exec_done_q <= 1'b0;
        else if (exec_done)          exec_done_q <= 1'b1;
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= ST_IDLE; busy <= 0; packet_ready <= 0;
            ready <= 0; err <= 0; respond_err_fsm <= 0;
            payload_xor <= 0; payload_last <= 0;
        end else begin
            packet_ready <= 1'b0; ready <= 1'b0; err <= 1'b0;

            case (state)
                ST_IDLE: begin
                    busy <= 1'b0;
                    if (valid_mux) begin
                        header_r   <= data_mux;
                        parity_acc <= data_mux;
                        
                        count      <= data_mux[3:0]; 
                        busy       <= 1'b1;

                        if (data_mux[7:6] != 2'b11 && data_mux[5:4] == 2'b11) begin
                            respond_err_fsm <= 1'b1;
                        end

                        if (data_mux[3:0] == 0) state <= ST_LOAD_PARITY;
                        else                    state <= ST_LOAD_DATA;
                    end
                end

                ST_LOAD_DATA: begin
                    if (valid_mux) begin
                        parity_acc   <= parity_acc ^ data_mux;
                        
                        payload_xor  <= (count == header_r[3:0]) ? data_mux : payload_xor ^ data_mux;
                        payload_last <= data_mux;
                        
                        if (count <= 1) state <= ST_LOAD_PARITY;
                        else            count <= count - 6'd1;
                    end else begin
                        respond_err_fsm <= 1'b1;
                        state           <= ST_RESPOND;
                    end
                end

                ST_LOAD_PARITY: begin
                    if ((parity_acc ^ data_mux) == 8'h00 && !respond_err_fsm) begin
                        packet_ready <= 1'b1;
                        state        <= ST_WAIT_EXEC;
                    end else begin
                        respond_err_fsm <= 1'b1;
                        state           <= ST_RESPOND;
                    end
                end

                ST_WAIT_EXEC: begin
                    if (exec_done || exec_done_q || cmd_err) begin
                        respond_err_fsm <= cmd_err | respond_err_fsm;
                        state           <= ST_RESPOND;
                    end
                end

                ST_RESPOND: begin
                    if (respond_err_fsm) err <= 1'b1;
                    else                 ready <= 1'b1;
                    
                    busy <= 1'b0;
                    respond_err_fsm <= 1'b0;
                    state <= ST_IDLE;
                end
                
                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule