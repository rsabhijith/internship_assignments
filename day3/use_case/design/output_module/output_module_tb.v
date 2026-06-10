`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 21:11:12
// Design Name: 
// Module Name: output_module_tb
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


module output_module_tb(

    );
    reg [7:0]d_in_tb;
    reg clk_tb;
    wire [7:0]d_out_tb;
    output_module dut (d_in_tb,clk_tb,d_out_tb);
    always #5 clk_tb=~clk_tb;
    initial
    begin
    {d_in_tb,clk_tb}=0;
    end
    initial
    begin
    #10 
    d_in_tb = 8'h10;
    #10 
    d_in_tb = 8'h20;
    #10 
    d_in_tb = 8'h30;
    #10 
    d_in_tb = 8'h40;
    #10 
    d_in_tb = 8'h50;
    #10 
    d_in_tb = 8'h60;
    #10 
    d_in_tb = 8'h70;
    #10 
    d_in_tb = 8'h80;

    end
    
endmodule

