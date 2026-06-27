`timescale 1ns / 1ps

module cache_top(

    input clk,
    input rst,

    //=========================================
    // CPU Interface
    //=========================================
    input         cpu_read,
    input         cpu_write,
    input  [31:0] cpu_addr,
    input  [31:0] cpu_wdata,

    output [31:0] cpu_rdata,
    output        cpu_ready

);

    //=========================================
    // Internal Wires
    //=========================================

    // Tag Array
    wire [25:0] tag_out;
    wire        valid_out;

    wire        tag_write_en;
    wire [25:0] tag_in;
    wire        valid_in;

    wire [3:0] index;

    // Data Array
    wire [31:0] data_out;
    wire        data_write_en;
    wire [31:0] data_in;

    // Memory Model
    wire        mem_read;
    wire        mem_write;

    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;

    wire        mem_ready;

    //=========================================
    // Tag Array
    //=========================================

    tag_array TAG_ARRAY(

        .clk(clk),
        .rst(rst),

        .write_en(tag_write_en),

        .index(index),

        .tag_in(tag_in),

        .valid_in(valid_in),

        .tag_out(tag_out),

        .valid_out(valid_out)

    );

    //=========================================
    // Data Array
    //=========================================

    data_array DATA_ARRAY(

        .clk(clk),
        .rst(rst),

        .write_en(data_write_en),

        .index(index),

        .data_in(data_in),

        .data_out(data_out)

    );

    //=========================================
    // Memory Model
    //=========================================

    memory_model MEMORY(

        .clk(clk),
        .rst(rst),

        .mem_read(mem_read),
        .mem_write(mem_write),

        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),

        .mem_rdata(mem_rdata),

        .mem_ready(mem_ready)

    );

    //=========================================
    // Cache Controller
    //=========================================

    cache_controller CONTROLLER(

        .clk(clk),
        .rst(rst),

        // CPU Interface
        .cpu_read(cpu_read),
        .cpu_write(cpu_write),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),

        .cpu_rdata(cpu_rdata),
        .cpu_ready(cpu_ready),

        // Tag Array
        .tag_out(tag_out),
        .valid_out(valid_out),

        .tag_write_en(tag_write_en),
        .tag_in(tag_in),
        .valid_in(valid_in),
        .index(index),

        // Data Array
        .data_out(data_out),

        .data_write_en(data_write_en),
        .data_in(data_in),

        // Memory Interface
        .mem_read(mem_read),
        .mem_write(mem_write),

        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),

        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready)

    );

endmodule