`timescale 1ns / 1ps

module tag_array #(
    parameter TAG_WIDTH   = 26,
    parameter INDEX_WIDTH = 4,
    parameter NUM_LINES   = 16
)(
    input                       clk,
    input                       rst,

    // Write Interface
    input                       write_en,
    input  [INDEX_WIDTH-1:0]    index,
    input  [TAG_WIDTH-1:0]      tag_in,
    input                       valid_in,

    // Read Interface
    output [TAG_WIDTH-1:0]      tag_out,
    output                      valid_out
);

    // Tag memory
    reg [TAG_WIDTH-1:0] tag_mem [0:NUM_LINES-1];

    // Valid bit memory
    reg                 valid_mem [0:NUM_LINES-1];

    integer i;

    //----------------------------------------------------------
    // Reset and Write Logic
    //----------------------------------------------------------
    always @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < NUM_LINES; i = i + 1) begin
                tag_mem[i]   <= {TAG_WIDTH{1'b0}};
                valid_mem[i] <= 1'b0;
            end

        end
        else if (write_en) begin

            tag_mem[index]   <= tag_in;
            valid_mem[index] <= valid_in;

        end

    end

    //----------------------------------------------------------
    // Read Logic (Combinational)
    //----------------------------------------------------------
    assign tag_out   = tag_mem[index];
    assign valid_out = valid_mem[index];

endmodule