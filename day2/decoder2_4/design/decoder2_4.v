`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 19:58:55
// Design Name: 
// Module Name: decoder2_4
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


module decoder2_4(input [1:0]a,output reg [3:0]y

    );
    always@(*)
    begin
    if(a==2'b00)
    y=4'b0001;
    else if(a==2'b01)
    y=4'b0010;
    else if(a==2'b10)
    y=4'b0100;
    else
    y=4'b1000;
    end
endmodule

