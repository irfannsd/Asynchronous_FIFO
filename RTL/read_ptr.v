
module read_handler #(
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input wire rclk, 
    input wire rrst_n, 
    input wire r_en, 
    input wire [ADDR_WIDTH:0] g_wptr_sync, 
    
    output wire [ADDR_WIDTH-1:0] b_raddr,  
    output reg [ADDR_WIDTH:0] g_rptr,      
    output reg empty // <-- CHANGED: Now a registered output
);

    reg  [ADDR_WIDTH:0] b_rptr;
    wire [ADDR_WIDTH:0] b_rptr_next;
    wire [ADDR_WIDTH:0] g_rptr_next;
    wire empty_next; // <-- ADDED: Combinational empty calculation

    // Binary next state
    assign b_rptr_next = b_rptr + (r_en & ~empty);
    
    // Binary to Gray conversion
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;

    // Empty condition (Calculated combinationally based on next pointer)
    assign empty_next = (g_rptr_next == g_wptr_sync);

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            b_rptr <= 0;
            g_rptr <= 0;
            empty  <= 1'b1; // <-- ADDED: Initialize empty flag to 1!
        end else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
            empty  <= empty_next; // <-- ADDED: Update empty flag safely on clock edge
        end
    end

    assign b_raddr = b_rptr[ADDR_WIDTH-1:0];

endmodule