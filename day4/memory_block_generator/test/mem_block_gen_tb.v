`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2026 20:15:13
// Design Name: 
// Module Name: mem_block_gen_tb
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


module mem_block_gen_tb(

    );
    reg clk_tb,arstn_tb,wrenb_tb;
    reg [7:0]wraddress_tb;
    reg [7:0]rdaddress_tb;
    reg [7:0]data_in_tb;
    wire [7:0]data_out_tb;
    mem_block_gen dut (clk_tb,arstn_tb,wrenb_tb,wraddress_tb,rdaddress_tb,data_in_tb,data_out_tb);
    always #5 clk_tb=~clk_tb;
    initial 
    begin
    {clk_tb,arstn_tb,wrenb_tb,wraddress_tb,rdaddress_tb,data_in_tb}=0;
    end
    initial
    begin
    arstn_tb=0;
    #10
    arstn_tb=1;
    wrenb_tb=1;
    wraddress_tb=8'h00;
    data_in_tb=8'h10;
    #10
    wraddress_tb=8'h01;
    data_in_tb=8'h20;
    #10
    wraddress_tb=8'h02;
    data_in_tb=8'h30;
    #10
    wraddress_tb=8'h03;
    data_in_tb=8'h40;
    #10
    wraddress_tb=8'h04;
    data_in_tb=8'h50;
    #10
    wraddress_tb=8'h05;
    data_in_tb=8'h60;
    #10
    wraddress_tb=8'h06;
    data_in_tb=8'h70;
    #10
    wraddress_tb=8'h07;
    data_in_tb=8'h80;
    #10
    wrenb_tb=0;
    #10
    rdaddress_tb=8'h00;
    #10
    rdaddress_tb=8'h01;
    #10
    rdaddress_tb=8'h02;
    #10
    rdaddress_tb=8'h03;
    #10
    rdaddress_tb=8'h04;
    #10
    rdaddress_tb=8'h05;
    #10
    rdaddress_tb=8'h06;
    #10
    rdaddress_tb=8'h07;
    #10
    $finish;
    end
endmodule
