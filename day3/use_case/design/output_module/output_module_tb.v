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
    reg clk_tb,rst_tb;
    reg [7:0]d_in_tb;
    wire rd_enb_tb;
    wire [7:0]d_out_tb;
    output_module dut (clk_tb,rst_tb,d_in_tb,rd_enb_tb,d_out_tb);
    always #5 clk_tb=~clk_tb;
    initial
    begin
    {clk_tb,rst_tb,d_in_tb}=0;
    end
    initial
    begin
    rst_tb=1;
    #10 
    rst_tb=0;
    d_in_tb = 8'h10;
    #30 
    d_in_tb = 8'h20;
    #30 
    d_in_tb = 8'h30;
    #30 
    d_in_tb = 8'h40;
    #30 
    d_in_tb = 8'h50;
    #30 
    d_in_tb = 8'h60;
    #30 
    d_in_tb = 8'h70;
    #30 
    d_in_tb = 8'h80;

    end
    
endmodule
