`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 12:05:43
// Design Name: 
// Module Name: fifo
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


module fifo(input clk,rst,wrenb,rdenb,
input [7:0]data_in,
output reg [7:0]data_out,
output reg full,empty
    );
    reg [7:0] mem [7:0];
    reg [2:0]wr_ptr;
    reg [2:0]rd_ptr;
    integer i;
    always@(posedge clk)
    begin
    if(rst) begin
    for (i=0;i<8;i=i+1)
    mem[i]<=0;
    wr_ptr<=3'b000;
    rd_ptr<=3'b000;
    data_out <= 8'b0;
    full <= 1'b0;
    empty <= 1'b1;
    end
    else 
    begin
    if(wrenb==1 && full==0) begin
    mem[wr_ptr]<=data_in;
    wr_ptr<=wr_ptr+3'b001;
    end
    if(rdenb==1 && empty==0) begin
    data_out<=mem[rd_ptr];
    rd_ptr<=rd_ptr+3'b001;
    end
    if ((wr_ptr+3'b001)==rd_ptr)
     full<=1;
    else
     full<=0;
    if(wr_ptr==rd_ptr)
     empty<=1;
    else
     empty<=0;
     
    end
   end
    
    
endmodule
