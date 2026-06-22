`timescale 1ns / 1ps
// =============================================================================
// image_bram.sv  —  Input-image frame buffer
//
// Decouples pixel *storage* from pixel *streaming*. The host (testbench /
// CPU / DMA engine on real hardware) writes one full frame into this BRAM
// at its own pace via wr_en/wr_addr/wr_data, completely independent of
// conv1's pipeline timing. pixel_stream_generator then reads it back out
// in raster order at one pixel/cycle to feed conv1 — the same way pixel
// data would actually arrive from a frame-grabber / AXI-Stream-to-BRAM
// bridge on real hardware, instead of being driven combinationally by a
// testbench every cycle.
//
// Address bus is kept at a fixed [9:0] (1024 words) per project convention,
// matching the reference design this was ported from. Memory depth tracks
// IMG_WIDTH*IMG_HEIGHT from cnn_config_pkg (784 for the default 28x28
// image) so it stays correctly sized if the image geometry changes,
// without altering the address bus width itself.
// -----------------------------------------------------------------------------

module image_bram import cnn_config_pkg::*; #(
    parameter PIX_WIDTH  = cnn_config_pkg::PIX_WIDTH ,
    parameter IMG_WIDTH  = cnn_config_pkg::IMG_WIDTH ,
    parameter IMG_HEIGHT = cnn_config_pkg::IMG_HEIGHT
) (
    input  logic                  clk    ,
    input  logic                  wr_en  ,
    input  logic [9:0]            wr_addr,
    input  logic [PIX_WIDTH-1:0]  wr_data,
    input  logic [9:0]            rd_addr,
    output logic [PIX_WIDTH-1:0]  rd_data
);

    localparam int DEPTH = IMG_WIDTH * IMG_HEIGHT;

    logic [PIX_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (wr_en)
            mem[wr_addr] <= wr_data;
        rd_data <= mem[rd_addr];
    end

endmodule : image_bram
