`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 19:16:44
// Design Name: 
// Module Name: d_ff_tb
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


module d_ff_tb(

    );
    reg d_tb,clk_tb,rst_tb;
    wire q_tb,qbar_tb;
    d_ff dut(d_tb,clk_tb,rst_tb,q_tb,qbar_tb);
    initial
    begin
    {d_tb,clk_tb,rst_tb}=0;
    end
    always #5 clk_tb=~clk_tb;
    initial
    begin
    rst_tb=1;
    #10
    rst_tb=0;
    #10
    d_tb=1'b1;
    #10
    d_tb=1'b0;
    #10
    d_tb=1'b1;
    end
    
endmodule
