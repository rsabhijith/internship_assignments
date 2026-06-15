`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2026 21:05:11
// Design Name: 
// Module Name: fifo_interface
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


interface fifo_if;
    logic clk;
    logic rst;
    logic wrenb;
    logic rdenb;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic full;
    logic empty;
endinterface

module fifo_tb;
    fifo_if fif();
    fifo dut(fif.clk,fif.rst,fif.wrenb,fif.rdenb,fif.data_in,fif.data_out,fif.full,fif.empty);
    always #5 fif.clk = ~fif.clk;
    initial begin
    {fif.clk,fif.rst,fif.wrenb,fif.rdenb,fif.data_in}=0;
    end
    initial begin
    fif.rst = 1;
    #10;
    fif.rst = 0;
    fif.wrenb = 1;
    fif.data_in = 8'h10; 
    #10;
    fif.data_in = 8'h20; 
    #10;
    fif.data_in = 8'h30; 
    #10;
    fif.data_in = 8'h40; 
    #10;
    fif.data_in = 8'h50; 
    #10;
    fif.data_in = 8'h60; 
    #10;
    fif.data_in = 8'h70; 
    #10;
    fif.wrenb = 0;
    #10;
    fif.rdenb = 1;
    #70;
    fif.rdenb = 0;
    #10;
    $finish;
    end
    initial begin
    $monitor("T=%0t rst=%b wr=%b rd=%b din=%h dout=%h full=%b empty=%b",$time,fif.rst,fif.wrenb,fif.rdenb,fif.data_in,fif.data_out,fif.full,fif.empty);
    end
endmodule
