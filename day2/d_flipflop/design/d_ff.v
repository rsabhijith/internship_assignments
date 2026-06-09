`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 19:02:56
// Design Name: 
// Module Name: d_ff
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


module d_ff(input d,clk,rst,output reg q,output qbar

    );
    assign qbar=~q;
    always@(posedge clk)
    begin
    if (rst)
    q<=1'b0;
    else
    q<=d;
    end
endmodule
