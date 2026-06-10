`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 18:28:12
// Design Name: 
// Module Name: fifo_tb
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


module fifo_tb(

    );
    reg clk_tb,rst_tb,wrenb_tb,rdenb_tb;
    reg [7:0]data_in_tb;
    wire [7:0]data_out_tb;
    wire full_tb,empty_tb;
    fifo dut(clk_tb,rst_tb,wrenb_tb,rdenb_tb,data_in_tb,data_out_tb,full_tb,empty_tb);
    always #5 clk_tb=~clk_tb;
    initial
    begin
    {clk_tb,rst_tb,wrenb_tb,rdenb_tb,data_in_tb}=0;
    end
    initial
    begin
    rst_tb=1;
    #10
    rst_tb=0;
    wrenb_tb=1;
    data_in_tb=8'h10;
    #10
    data_in_tb=8'h20;
    #10
    data_in_tb=8'h30;
    #10
    data_in_tb=8'h40;
    #10
    data_in_tb=8'h50;
    #10
    data_in_tb=8'h60;
    #10
    data_in_tb=8'h70;
    #10
    wrenb_tb=0;
    #10
    rdenb_tb=1;
    #70
    rdenb_tb=0;
    end
endmodule
