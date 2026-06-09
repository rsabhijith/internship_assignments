`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2026 11:53:31
// Design Name: 
// Module Name: fulladd
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


module fulladd(input A,B,Cin,output sum,carry

    );
wire w1,w2,w3;
xor(sum,A,B,Cin);
and(w1,A,B);
and(w2,B,Cin);
and(w3,A,Cin);
or(carry,w1,w2,w3);
endmodule
