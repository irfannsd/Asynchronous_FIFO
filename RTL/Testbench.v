`include "Async_FIFO.v"
`timescale 1ns/1ps

module tb_async_fifo;

    // Parameters matching the DUT
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    // Testbench Signals
    reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg w_en, r_en;
    reg [DATA_WIDTH-1:0] wdata;
    
    wire [DATA_WIDTH-1:0] rdata;
    wire full, empty;

    // -----------------------------------------------------------
    // 1. Device Under Test (DUT) Instantiation
    // -----------------------------------------------------------
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .wclk(wclk), 
        .rclk(rclk), 
        .wrst_n(wrst_n), 
        .rrst_n(rrst_n),
        .w_en(w_en), 
        .r_en(r_en),
        .wdata(wdata),
        .rdata(rdata),
        .full(full), 
        .empty(empty)
    );

    // -----------------------------------------------------------
    // 2. Clock Generation (Asynchronous Domains)
    // -----------------------------------------------------------
    // Write Clock: 100 MHz (10ns period)
    always #5 wclk = ~wclk;   

    // Read Clock: ~41.6 MHz (24ns period)
    // Using a strange frequency ensures clock edges slide past each other
    always #12 rclk = ~rclk;  

    // -----------------------------------------------------------
    // 3. Write and Read Tasks
    // -----------------------------------------------------------
    task write_word(input [DATA_WIDTH-1:0] data);
    begin
        @(posedge wclk);
        // Wait if the FIFO is full
        while (full) begin
            $display("[%0t] WRITE WAITING: FIFO is Full", $time);
            @(posedge wclk);
        end
        w_en  <= 1'b1;
        wdata <= data;
        
        @(posedge wclk);
        w_en  <= 1'b0;
        $display("[%0t] WROTE: %d", $time, data);
    end
    endtask

    task read_word();
    begin
        @(posedge rclk);
        // Wait if the FIFO is empty
        while (empty) begin
            $display("[%0t] READ WAITING: FIFO is Empty", $time);
            @(posedge rclk);
        end
        r_en <= 1'b1;
        
        @(posedge rclk);
        r_en <= 1'b0;
        // Wait 1ns for data to stabilize on the output port
        #1 $display("[%0t] READ : %d", $time, rdata);
    end
    endtask


    // -----------------------------------------------------------
    // 4. Main Simulation Sequence
    // -----------------------------------------------------------
    integer i;

    initial begin
        // Setup VCD dumping for waveform viewers (like GTKWave)
        $dumpfile("async_fifo.vcd");
        $dumpvars(0, tb_async_fifo);

        // Initialize all signals
        wclk = 0; rclk = 0;
        w_en = 0; r_en = 0;
        wdata = 0;
        
        // Assert Asynchronous Resets (Active Low)
        wrst_n = 0; rrst_n = 0;
        #30;
        
        // Release Resets safely on their respective clock edges
        @(negedge wclk) wrst_n = 1;
        @(negedge rclk) rrst_n = 1;
        #50;

        $display("\n=================================");
        $display(" PHASE 1: BURST WRITE TO FULL");
        $display("=================================");
        
        // FIX: Only write 16 words so we don't deadlock the sequential block!
        for (i = 0; i < 16; i = i + 1) begin
            write_word(i);
        end

        #100;

        $display("\n=================================");
        $display(" PHASE 2: BURST READ TO EMPTY");
        $display("=================================");
        // Read out all 16 items currently in the FIFO
        for (i = 0; i < 16; i = i + 1) begin
            read_word();
        end

        #100;

        $display("\n=================================");
        $display(" PHASE 3: CONCURRENT READ & WRITE");
        $display("=================================");
        // Fork-Join runs these two blocks simultaneously
        // Fork-Join runs these two blocks simultaneously
        fork
            begin : WRITE_THREAD
                // Using global integer 'i'
                for (i = 100; i < 150; i = i + 1) begin
                    write_word(i);
                    #($urandom % 10); 
                end
            end
            
            begin : READ_THREAD
                integer j; // <-- FIX: Declare a local integer for this thread
                // Using local integer 'j' so it doesn't fight with 'i'
                for (j = 0; j < 50; j = j + 1) begin
                    read_word();
                    #($urandom % 100);
                end
            end
        join

        $display("\n=================================");
        $display(" SIMULATION COMPLETE");
        $display("=================================");
        #100;
        $finish;
    end

    // Failsafe timeout just in case of an infinite loop
    initial begin
        #100000;
        $display("\nTIMEOUT EXCEEDED - FORCING SHUTDOWN");
        $finish;
    end

endmodule