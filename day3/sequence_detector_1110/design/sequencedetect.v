`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 10:30:50
// Design Name: 
// Module Name: sequencedetect
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


module sequencedetect(input clk,rst,din,output reg detected

    );
    parameter idle=2'b00;
    parameter s1=2'b01;
    parameter s2=2'b10;
    parameter s3=2'b11;
    reg [1:0]ps,ns;
    //present state logic
    always@(posedge clk)
    begin
    if(rst) begin
    ps<=idle;
    end
    else
    ps<=ns;
    end
    //next state logic
    always@(*)
    begin
    case(ps)
    idle:begin
    detected=0;
    if(din==0)
    ns=idle;
    else
    ns=s1;
    end
    s1:begin
    if(din==0)
    ns=s2;
    else
    ns=s1;
    end
    s2:begin
    if(din==0)
    ns=idle;
    else
    ns=s3;
    end
    s3:begin
    if(din==0) begin
    ns=idle;
    detected=1;
    end
    else
    ns=s1;
    end
    endcase
    end
endmodule

