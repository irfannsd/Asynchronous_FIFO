
module write_handler #(
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input wire wclk, 
    input wire wrst_n, 
    input wire w_en, 
    input wire [ADDR_WIDTH:0] g_rptr_sync, 
    
    output wire [ADDR_WIDTH-1:0] b_waddr,  
    output reg [ADDR_WIDTH:0] g_wptr,      
    output reg full // <-- CHANGED: Now a registered output
);

    reg  [ADDR_WIDTH:0] b_wptr;
    wire [ADDR_WIDTH:0] b_wptr_next;
    wire [ADDR_WIDTH:0] g_wptr_next;
    wire full_next; // <-- ADDED: Combinational full calculation

    // Binary next state
    assign b_wptr_next = b_wptr + (w_en & ~full);
    
    // Binary to Gray conversion
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;

    // Full condition (Calculated combinationally based on next pointer)
    assign full_next = (g_wptr_next == {~g_rptr_sync[ADDR_WIDTH:ADDR_WIDTH-1], g_rptr_sync[ADDR_WIDTH-2:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            b_wptr <= 0;
            g_wptr <= 0;
            full   <= 0; // <-- ADDED: Initialize full flag
        end else begin
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
            full   <= full_next; // <-- ADDED: Update full flag safely on clock edge
        end
    end

    assign b_waddr = b_wptr[ADDR_WIDTH-1:0];

endmodule