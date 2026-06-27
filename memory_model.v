`timescale 1ns / 1ps

module memory_model #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 256
)(
    input                       clk,
    input                       rst,

    input                       mem_read,
    input                       mem_write,

    input  [ADDR_WIDTH-1:0]     mem_addr,
    input  [DATA_WIDTH-1:0]     mem_wdata,

    output reg [DATA_WIDTH-1:0] mem_rdata,
    output reg                  mem_ready
);

    // Main Memory
    reg [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1];

    integer i;

    //----------------------------------------------------------
    // Memory Initialization
    //----------------------------------------------------------
    always @(posedge clk) begin

        if (rst) begin

            mem_ready <= 1'b0;
            mem_rdata <= {DATA_WIDTH{1'b0}};

            for(i = 0; i < MEM_DEPTH; i = i + 1)
                memory[i] <= i;

        end

        else begin

            mem_ready <= 1'b0;

            // Write Operation
            if(mem_write) begin

                memory[mem_addr[9:2]] <= mem_wdata;
                mem_ready <= 1'b1;

            end

            // Read Operation
            else if(mem_read) begin

                mem_rdata <= memory[mem_addr[9:2]];
                mem_ready <= 1'b1;

            end

        end

    end

endmodule