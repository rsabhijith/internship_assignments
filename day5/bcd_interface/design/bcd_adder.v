`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2026 20:43:48
// Design Name: 
// Module Name: bcd_adder
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


// Code your design here
module fulladd(input A,B,Cin,output sum,carry

    );
wire w1,w2,w3;
xor(sum,A,B,Cin);
and(w1,A,B);
and(w2,B,Cin);
and(w3,A,Cin);
or(carry,w1,w2,w3);
endmodule

module rca(input A0,A1,A2,A3,B0,B1,B2,B3,Cin,output S0,S1,S2,S3,Cout
    );
    wire w1,w2,w3;
    fulladd FA1(A0,B0,Cin,S0,w1);
    fulladd FA2(A1,B1,w1,S1,w2);
    fulladd FA3(A2,B2,w2,S2,w3);
    fulladd FA4(A3,B3,w3,S3,Cout);
endmodule

module bcd(input A0,A1,A2,A3,B0,B1,B2,B3,Cin,output S0,S1,S2,S3,Cout

    );
    wire w1,w2,w3,w4,w5,w6,w7,w8;
    rca r1(A0,A1,A2,A3,B0,B1,B2,B3,Cin,w8,w7,w6,w5,w4);
    and(w1,w5,w6);
    and(w2,w5,w7);
    or(w3,w4,w1,w2);
    rca r2(w8,w7,w6,w5,1'b0,w3,w3,1'b0,1'b0,S0,S1,S2,S3);
    assign Cout=w3;
endmodule
