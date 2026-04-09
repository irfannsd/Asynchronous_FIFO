
`include "read_ptr.v"
`include "write_ptr.v"
`include "synchronize.v"
`include "fifo_memory.v"


module async_fifo #(
    parameter DATA_WIDTH = 8, 
    parameter DEPTH = 16
)(
    input wire wclk, rclk, wrst_n, rrst_n,
    input wire w_en, r_en,
    input wire [DATA_WIDTH-1:0] wdata,
    
    output wire [DATA_WIDTH-1:0] rdata,
    output wire full, empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Interconnect wires
    wire [ADDR_WIDTH-1:0] b_waddr, b_raddr;
    wire [ADDR_WIDTH:0]   g_wptr, g_rptr;
    wire [ADDR_WIDTH:0]   g_wptr_sync, g_rptr_sync;

    // 1. Memory Instantiation
    fifo_memory #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_inst (
        .wclk(wclk), .w_en(w_en), .full(full), .w_addr(b_waddr), .wdata(wdata),
        .rclk(rclk), .r_en(r_en), .empty(empty), .r_addr(b_raddr), .rdata(rdata)
    );

    // 2. Write Domain Logic
    write_handler #(.DEPTH(DEPTH)) wr_inst (
        .wclk(wclk), .wrst_n(wrst_n), .w_en(w_en), .g_rptr_sync(g_rptr_sync),
        .b_waddr(b_waddr), .g_wptr(g_wptr), .full(full)
    );

    // 3. Read Domain Logic
    read_handler #(.DEPTH(DEPTH)) rd_inst (
        .rclk(rclk), .rrst_n(rrst_n), .r_en(r_en), .g_wptr_sync(g_wptr_sync),
        .b_raddr(b_raddr), .g_rptr(g_rptr), .empty(empty)
    );

    // 4. Synchronize Read Pointer into Write Domain
    synchronizer #(.WIDTH(ADDR_WIDTH + 1)) sync_r2w (
        .clk(wclk), .rst_n(wrst_n), .async_in(g_rptr), .sync_out(g_rptr_sync)
    );

    // 5. Synchronize Write Pointer into Read Domain
    synchronizer #(.WIDTH(ADDR_WIDTH + 1)) sync_w2r (
        .clk(rclk), .rst_n(rrst_n), .async_in(g_wptr), .sync_out(g_wptr_sync)
    );

endmodule