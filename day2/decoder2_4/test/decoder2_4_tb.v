`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 20:08:22
// Design Name: 
// Module Name: decoder2_4_tb
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


module decoder2_4_tb(

    );
    reg [1:0]a_tb;
    wire [3:0]y_tb;
    decoder2_4 dut(a_tb,y_tb);
    initial
    begin
    {a_tb}=0;
    end
    initial
    begin
    #1
    a_tb=2'b00;
    #1
    a_tb=2'b01;
    #1
    a_tb=2'b10;
    #1
    a_tb=2'b11;
    $monitor("a_tb=%b y_tb=%b",a_tb,y_tb);
    end
endmodule
