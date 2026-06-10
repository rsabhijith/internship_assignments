`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 21:49:19
// Design Name: 
// Module Name: seqdetect_001_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
///////////////////////////////////////////////////////////
module top_module(input clk,rst,input [7:0] s_in,output [7:0] d_out
);

  wire [7:0] s_out, data_out;
wire rd_enb, full, empty;
face_module dut(clk,s_in,s_out);
  fifo ff1(clk,rst,1'b1,rd_enb,s_out,full,empty,data_out);
  out_module om1(clk,rst,data_out,rd_enb,d_out);

endmodule
