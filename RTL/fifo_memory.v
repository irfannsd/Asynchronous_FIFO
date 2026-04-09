module fifo_memory #(
    parameter DATA_WIDTH = 8, 
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input wire wclk, 
    input wire w_en, 
    input wire full,
    input wire [ADDR_WIDTH-1:0] w_addr,
    input wire [DATA_WIDTH-1:0] wdata,

    input wire rclk, 
    input wire r_en, 
    input wire empty,
    input wire [ADDR_WIDTH-1:0] r_addr,
    output reg [DATA_WIDTH-1:0] rdata
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    
    // Write Operation
    always @(posedge wclk) begin
        if (w_en && !full) begin
            mem[w_addr] <= wdata;
        end
    end
    
    // Read Operation
    always @(posedge rclk) begin
        if (r_en && !empty) begin
            rdata <= mem[r_addr];
        end
        else if (r_en && empty) begin
            // NEW: Inject 'x's if an illegal read occurs
            rdata <= {DATA_WIDTH{1'bx}}; 
        end
    end
endmodule