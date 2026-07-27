module slave #(
    parameter SLAVE_ID = 0,
    parameter N_SLAVES = 3
)(
    input                    clk,
    input  [N_SLAVES-1:0]    s_sel,
    input  [2:0]             s_op,
    input  [7:0]             s_wdata,
    output [7:0]             s_rdata,
    output                   s_ack
);
    reg [7:0] data_reg, status_reg, rdata_reg;
    reg ack_reg, exec_done_reg;
    wire selected = s_sel[SLAVE_ID];

    reg [7:0] next_data; 

    initial begin
        data_reg = 8'h00; 
        status_reg = {SLAVE_ID[2:0], 3'b000, 1'b0, 1'b0}; // ID, rez, parity=0, lock=0
        ack_reg = 1'b0; 
        exec_done_reg = 1'b0;
    end

    always @(posedge clk) begin
        if (selected) begin
            ack_reg <= 1'b1;
            if (!exec_done_reg) begin
                case (s_op)
                    3'b000: begin // WRITE
                        if (!status_reg[0]) begin 
                            data_reg <= s_wdata;
                            // ACTUALIZARE PARITATE:
                            status_reg[1] <= ^s_wdata; 
                        end
                    end
                    3'b010: begin // INCREMENT
                        if (!status_reg[0]) begin
                            next_data = data_reg + s_wdata;
                            data_reg <= next_data;
                            // ACTUALIZARE PARITATE:
                            status_reg[1] <= ^next_data;
                        end
                    end
                    3'b011: begin // RESET
                        data_reg <= 8'h00;
                        status_reg[0] <= 1'b0; // Unlock
                        status_reg[1] <= 1'b0; // Parity of 0 is 0
                    end
                    3'b101: status_reg[0] <= 1'b1; // LOCK
                    3'b110: status_reg[0] <= 1'b0; // UNLOCK
                endcase
                exec_done_reg <= 1'b1;
            end
            rdata_reg <= (s_op == 3'b001) ? data_reg : (s_op == 3'b100) ? status_reg : 8'h00;
        end else begin
            ack_reg <= 1'b0; 
            exec_done_reg <= 1'b0;
        end
    end

    assign s_rdata = selected ? rdata_reg : 8'bz;
    assign s_ack   = selected ? ack_reg   : 1'bz;
endmodule