`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2026 19:44:20
// Design Name: 
// Module Name: mem_block_gen
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


module mem_block_gen( input clk,arstn,wrenb,
input [7:0]wraddress,
input [7:0]rdaddress,
input [7:0]data_in,
output reg [7:0]data_out

    );
    reg [7:0] mem [255:0];
    integer i;
    always@(posedge clk or negedge arstn)
    begin
    if(arstn==0) begin
    data_out<=0;
    for(i=0;i<256;i=i+1)
    data_out<=0;
    end
    else
    begin
    if(wrenb==1)
    mem[wraddress]<=data_in;
    else
    data_out<=mem[rdaddress];
    end
    end
endmodule
