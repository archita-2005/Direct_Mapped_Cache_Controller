`timescale 1ns / 1ps

module data_array #(
    parameter DATA_WIDTH  = 32,
    parameter INDEX_WIDTH = 4,
    parameter NUM_LINES   = 16
)(
    input                       clk,
    input                       rst,

    // Write Interface
    input                       write_en,
    input  [INDEX_WIDTH-1:0]    index,
    input  [DATA_WIDTH-1:0]     data_in,

    // Read Interface
    output [DATA_WIDTH-1:0]     data_out
);

    // Data Memory
    reg [DATA_WIDTH-1:0] data_mem [0:NUM_LINES-1];

    integer i;

    //----------------------------------------------------------
    // Reset and Write Logic
    //----------------------------------------------------------
    always @(posedge clk) begin

        if (rst) begin

            for(i = 0; i < NUM_LINES; i = i + 1)
                data_mem[i] <= {DATA_WIDTH{1'b0}};

        end
        else if(write_en) begin

            data_mem[index] <= data_in;

        end

    end

    //----------------------------------------------------------
    // Read Logic (Combinational)
    //----------------------------------------------------------
    assign data_out = data_mem[index];

endmodule