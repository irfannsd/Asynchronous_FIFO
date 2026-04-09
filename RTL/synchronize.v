// synchronizes


module synchronizer #(
    parameter WIDTH = 4
)(
    input wire clk, 
    input wire rst_n, 
    input wire [WIDTH-1:0] async_in, 
    output reg [WIDTH-1:0] sync_out
);
    
    reg [WIDTH-1:0] q1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= 0;
            sync_out <= 0;
        end else begin
            q1 <= async_in;
            sync_out <= q1;
        end
    end
endmodule