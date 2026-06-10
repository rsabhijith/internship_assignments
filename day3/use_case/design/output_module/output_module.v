`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 20:57:58
// Design Name: 
// Module Name: output_module
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


module output_module(input [7:0]d_in,
input clk, output reg [7:0]d_out

    );
    reg [1:0]m=0;
    always@(posedge clk)
    begin
    if(m==2) begin
    d_out<=d_in;
    m<=0;
    end
    else
    m<=m+1;
    end
    initial
    d_out<=0;
endmodule

