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


module output_module_tb;

reg clk_tb;
reg rst_tb;
reg [7:0] din_tb;

wire rd_enb_tb;
wire [7:0] dout_tb;

output_module dut(
    clk_tb,
    rst_tb,
    din_tb,
    rd_enb_tb,
    dout_tb
);

always #5 clk_tb = ~clk_tb;

initial
begin
    {clk_tb,rst_tb,din_tb} = 0;
end

initial
begin
    rst_tb = 1;
    #10
    rst_tb = 0;

    #10 
    din_tb = 8'h10;
    #10 
    din_tb = 8'h20;
    #10 
    din_tb = 8'h30;
    #10 
    din_tb = 8'h40;
    #10 
    din_tb = 8'h50;
    #10 
    din_tb = 8'h60;
    #10 
    din_tb = 8'h70;
    #10 
    din_tb = 8'h80;

    #100
    $finish;
end

endmodule
