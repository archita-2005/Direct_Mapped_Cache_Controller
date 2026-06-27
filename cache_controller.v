`timescale 1ns / 1ps

module cache_controller #(
    parameter ADDR_WIDTH  = 32,
    parameter DATA_WIDTH  = 32,
    parameter TAG_WIDTH   = 26,
    parameter INDEX_WIDTH = 4
)(
    input                       clk,
    input                       rst,

    //=========================
    // CPU Interface
    //=========================
    input                       cpu_read,
    input                       cpu_write,
    input  [ADDR_WIDTH-1:0]     cpu_addr,
    input  [DATA_WIDTH-1:0]     cpu_wdata,

    output reg [DATA_WIDTH-1:0] cpu_rdata,
    output reg                  cpu_ready,

    //=========================
    // Tag Array Interface
    //=========================
    input  [TAG_WIDTH-1:0]      tag_out,
    input                       valid_out,

    output reg                  tag_write_en,
    output reg [TAG_WIDTH-1:0]  tag_in,
    output reg                  valid_in,
    output reg [INDEX_WIDTH-1:0] index,

    //=========================
    // Data Array Interface
    //=========================
    input  [DATA_WIDTH-1:0]     data_out,

    output reg                  data_write_en,
    output reg [DATA_WIDTH-1:0] data_in,

    //=========================
    // Main Memory Interface
    //=========================
    output reg                  mem_read,
    output reg                  mem_write,
    output reg [ADDR_WIDTH-1:0] mem_addr,
    output reg [DATA_WIDTH-1:0] mem_wdata,

    input      [DATA_WIDTH-1:0] mem_rdata,
    input                       mem_ready

);

//======================================================
// Internal Signals
//======================================================

// Current state and next state
reg [2:0] current_state;
reg [2:0] next_state;

// Decoded address fields
wire [TAG_WIDTH-1:0]   addr_tag;
wire [INDEX_WIDTH-1:0] addr_index;
wire [1:0]             addr_offset;

// Cache hit signal
wire hit;

//======================================================
// FSM State Encoding
//======================================================

localparam IDLE         = 3'b000,
           COMPARE_TAG  = 3'b001,
           READ_MEMORY  = 3'b010,
           UPDATE_CACHE = 3'b011,
           RESPOND      = 3'b100;

//======================================================
// Address Decoder
//======================================================

assign addr_tag    = cpu_addr[31:6];
assign addr_index  = cpu_addr[5:2];
assign addr_offset = cpu_addr[1:0];
//======================================================
// Cache Hit Logic
//======================================================

assign hit = valid_out && (tag_out == addr_tag);

//======================================================
// State Register
//======================================================

always @(posedge clk) begin

    if (rst)
        current_state <= IDLE;
    else
        current_state <= next_state;

end

//======================================================
// Next-State Logic
//======================================================

always @(*) begin

    // Default: stay in current state
    next_state = current_state;

    case (current_state)

        //--------------------------------------------------
        // Wait for CPU request
        //--------------------------------------------------
        IDLE: begin

            if (cpu_read || cpu_write)
                next_state = COMPARE_TAG;
            else
                next_state = IDLE;

        end

        //--------------------------------------------------
        // Compare Cache Tag
        //--------------------------------------------------
        COMPARE_TAG: begin

            if (hit)
                next_state = RESPOND;
            else
                next_state = READ_MEMORY;

        end

        //--------------------------------------------------
        // Wait for Main Memory
        //--------------------------------------------------
        READ_MEMORY: begin

            if (mem_ready)
                next_state = UPDATE_CACHE;
            else
                next_state = READ_MEMORY;

        end

        //--------------------------------------------------
        // Update Cache
        //--------------------------------------------------
        UPDATE_CACHE: begin

            next_state = RESPOND;

        end

        //--------------------------------------------------
        // Send Data to CPU
        //--------------------------------------------------
        RESPOND: begin

            next_state = IDLE;

        end

        //--------------------------------------------------
        // Safety
        //--------------------------------------------------
        default: begin

            next_state = IDLE;

        end

    endcase

end

//======================================================
// Output Logic
//======================================================

always @(*) begin

    //--------------------------------------------------
    // Default Outputs
    //--------------------------------------------------

    cpu_ready     = 1'b0;
    cpu_rdata     = 32'b0;

    tag_write_en  = 1'b0;
    tag_in        = addr_tag;
    valid_in      = 1'b0;

    data_write_en = 1'b0;
    data_in       = mem_rdata;

    index         = addr_index;

    mem_read      = 1'b0;
    mem_write     = 1'b0;
    mem_addr      = cpu_addr;
    mem_wdata     = cpu_wdata;

    //--------------------------------------------------
    // State Actions
    //--------------------------------------------------

    case(current_state)

        //----------------------------------------------
        // IDLE
        //----------------------------------------------
        IDLE: begin
            // Wait for request
        end

        //----------------------------------------------
        // COMPARE TAG
        //----------------------------------------------
        COMPARE_TAG: begin

            if(hit) begin
                cpu_rdata = data_out;
                cpu_ready = 1'b1;
            end

        end

        //----------------------------------------------
        // READ FROM MEMORY
        //----------------------------------------------
        READ_MEMORY: begin

            mem_read = 1'b1;

        end

        //----------------------------------------------
        // UPDATE CACHE
        //----------------------------------------------
        UPDATE_CACHE: begin

            tag_write_en  = 1'b1;
            valid_in      = 1'b1;

            data_write_en = 1'b1;
            data_in        = mem_rdata;

        end

        //----------------------------------------------
        // RESPOND TO CPU
        //----------------------------------------------
        RESPOND: begin

            cpu_ready = 1'b1;

            if(hit)
                cpu_rdata = data_out;
            else
                cpu_rdata = mem_rdata;

        end

    endcase

end
endmodule