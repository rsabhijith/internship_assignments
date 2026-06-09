`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2026 15:32:05
// Design Name: 
// Module Name: rca
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


module rca(input A0,A1,A2,A3,B0,B1,B2,B3,Cin,output S0,S1,S2,S3,Cout

    );
    wire w1,w2,w3;
    fulladd FA1(A0,B0,Cin,S0,w1);
    fulladd FA2(A1,B1,w1,S1,w2);
    fulladd FA3(A2,B2,w2,S2,w3);
    fulladd FA4(A3,B3,w3,S3,Cout);
endmodule
