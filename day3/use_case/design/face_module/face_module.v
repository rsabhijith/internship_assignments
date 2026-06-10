`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 20:15:30
// Design Name: 
// Module Name: face_module
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
//////////////////////////////////////////////////////////////////////////////////


module face_module(input [7:0]s_in,
input clk,
output reg [7:0]s_out

    );
    always@(posedge clk)
    begin
    s_out<=s_in;
    end
endmodule
