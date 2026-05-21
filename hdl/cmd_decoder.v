module cmd_decoder (
    input clk, rst,
    input packet_ready,
    input [1:0] cmd, addr,
    input [7:0] payload_xor, payload_last,
    input exec_done,
    output reg exec_start,
    output reg [2:0] s_op, s_sel_id,
    output reg [7:0] s_wdata,
    output reg cmd_err,
    input [7:0] s_rdata_bus,
    output reg [7:0] rdata
);
    reg [1:0] state;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= 0; exec_start <= 0; cmd_err <= 0; rdata <= 0;
        end else begin
            exec_start <= 1'b0;
            
            case (state)
                0: if (packet_ready) begin
                    // Stabilim datele implicite
                    s_wdata <= (cmd == 2'b00) ? payload_xor : payload_last;
                    
                    // DECODARE SPECIALA PENTRU LOCK/UNLOCK
                    if (cmd == 2'b11 && addr == 2'b11) begin
                        // Daca e comanda de securitate, ID-ul slave-ului este in payload [1:0]
                        s_sel_id <= {1'b0, payload_last[1:0]};
                        
                        // Tipul operatiei este in payload [7:6]
                        if (payload_last[7:6] == 2'b00)      s_op <= 3'b101; // LOCK
                        else if (payload_last[7:6] == 2'b01) s_op <= 3'b110; // UNLOCK
                        else                                 s_op <= 3'b011; // Fallback
                    end 
                    // DECODARE NORMALA (WRITE, READ, INC, RESET_SLAVE)
                    else begin
                        s_sel_id <= {1'b0, addr};
                        case(cmd)
                            2'b00: s_op <= 3'b000; // WRITE
                            2'b01: s_op <= 3'b001; // READ
                            2'b10: s_op <= 3'b010; // INC
                            2'b11: s_op <= 3'b011; // RESET
                        endcase
                    end
                    
                    state <= 1;
                end
                
                1: begin
                    exec_start <= 1'b1;
                    state <= 2;
                end
                
                2: if (exec_done) begin
                    if (s_op == 3'b001) rdata <= s_rdata_bus; // Salvam doar daca e READ
                    state <= 0;
                end
            endcase
        end
    end
endmodule