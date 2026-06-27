`timescale 1ns / 1ps

module cache_top_tb;

    //====================================================
    // Testbench Signals
    //====================================================

    reg         clk;
    reg         rst;

    reg         cpu_read;
    reg         cpu_write;

    reg  [31:0] cpu_addr;
    reg  [31:0] cpu_wdata;

    wire [31:0] cpu_rdata;
    wire        cpu_ready;

    //====================================================
    // Instantiate DUT
    //====================================================

    cache_top DUT (

        .clk(clk),
        .rst(rst),

        .cpu_read(cpu_read),
        .cpu_write(cpu_write),

        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),

        .cpu_rdata(cpu_rdata),
        .cpu_ready(cpu_ready)

    );

    //====================================================
    // Clock Generation
    //====================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //====================================================
    // CPU Read Task
    //====================================================

    task cpu_read_task;

        input [31:0] address;

        begin

            @(posedge clk);

            cpu_read  <= 1'b1;
            cpu_write <= 1'b0;
            cpu_addr  <= address;

            @(posedge clk);

            cpu_read <= 1'b0;

            wait(cpu_ready);

            @(posedge clk);

            $display("[%0t ns] READ  Address = %h  Data = %h",
                      $time, address, cpu_rdata);

        end

    endtask

    //====================================================
    // CPU Write Task
    //====================================================

    task cpu_write_task;

        input [31:0] address;
        input [31:0] data;

        begin

            @(posedge clk);

            cpu_write <= 1'b1;
            cpu_read  <= 1'b0;

            cpu_addr  <= address;
            cpu_wdata <= data;

            @(posedge clk);

            cpu_write <= 1'b0;

            wait(cpu_ready);

            @(posedge clk);

            $display("[%0t ns] WRITE Address = %h  Data = %h",
                      $time, address, data);

        end

    endtask

    //====================================================
    // Stimulus
    //====================================================

    initial begin

        $display("==============================================");
        $display(" Direct Mapped Cache Controller Simulation");
        $display("==============================================");

        //--------------------------------------------
        // Initialize
        //--------------------------------------------

        rst       = 1'b1;

        cpu_read  = 1'b0;
        cpu_write = 1'b0;

        cpu_addr  = 32'd0;
        cpu_wdata = 32'd0;

        //--------------------------------------------
        // Reset
        //--------------------------------------------

        #20;
        rst = 1'b0;

        //--------------------------------------------
        // Test 1 : Cache Miss
        //--------------------------------------------

        $display("\nTEST 1 : READ 0x20 (Expected MISS)");
        cpu_read_task(32'h00000020);

        //--------------------------------------------
        // Test 2 : Cache Hit
        //--------------------------------------------

        $display("\nTEST 2 : READ 0x20 (Expected HIT)");
        cpu_read_task(32'h00000020);

        //--------------------------------------------
        // Test 3 : Another Miss
        //--------------------------------------------

        $display("\nTEST 3 : READ 0x40 (Expected MISS)");
        cpu_read_task(32'h00000040);

        //--------------------------------------------
        // Test 4 : Write
        //--------------------------------------------

        $display("\nTEST 4 : WRITE 0x40");
        cpu_write_task(
            32'h00000040,
            32'hDEADBEEF
        );

        //--------------------------------------------
        // Test 5 : Read Written Data
        //--------------------------------------------

        $display("\nTEST 5 : READ 0x40 (Expected HIT)");
        cpu_read_task(32'h00000040);

        //--------------------------------------------
        // Test 6 : Read Again
        //--------------------------------------------

        $display("\nTEST 6 : READ 0x40 Again");
        cpu_read_task(32'h00000040);

        //--------------------------------------------
        // Test 7 : New Address
        //--------------------------------------------

        $display("\nTEST 7 : READ 0x80 (Expected MISS)");
        cpu_read_task(32'h00000080);

        //--------------------------------------------
        // End Simulation
        //--------------------------------------------

        #100;

        $display("\n==============================================");
        $display(" Simulation Completed Successfully");
        $display("==============================================");

        $finish;

    end

endmodule