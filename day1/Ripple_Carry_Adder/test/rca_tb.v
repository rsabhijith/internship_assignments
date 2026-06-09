`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2026 22:05:55
// Design Name: 
// Module Name: rca_tb
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


module rca_tb(

    );
    reg A0,A1,A2,A3,B0,B1,B2,B3,Cin;
    wire S0,S1,S2,S3,Cout;
    rca dut(A0,A1,A2,A3,B0,B1,B2,B3,Cin,S0,S1,S2,S3,Cout);
    initial
    begin
    {A0,A1,A2,A3,B0,B1,B2,B3,Cin}=0;
    end
    initial
    begin
    {A3,A2,A1,A0}=4'b0000;
    {B3,B2,B1,B0}=4'b0000;
    Cin=1'b0;
    #1                              //A=4,B=4 => 8 (1000)
    {A3,A2,A1,A0}=4'b0100;
    {B3,B2,B1,B0}=4'b0100;
    Cin=1'b0;
    #1                             //A=6,B=3 => 9  (1001)
    {A3,A2,A1,A0}=4'b0110;
    {B3,B2,B1,B0}=4'b0011;
    Cin=1'b0;
    #1                            //A=7,B=5 => 12   (1100)
    {A3,A2,A1,A0}=4'b0111;
    {B3,B2,B1,B0}=4'b0101;
    Cin=1'b0;
    #1                            //A=9,B=8 =>17    (1 0001)
    {A3,A2,A1,A0}=4'b1001;
    {B3,B2,B1,B0}=4'b1000;
    Cin=1'b0;
    #1                            //A=11,B=8 =>12    (1 0111)
    {A3,A2,A1,A0}=4'b1011;
    {B3,B2,B1,B0}=4'b1100;
    Cin=1'b0;
    
    $monitor("A=%b%b%b%b B=%b%b%b%b Cin=%b S=%b%b%b%b Cout=%b",A3,A2,A1,A0,B3,B2,B1,B0,Cin,S3,S2,S1,S0,Cout);
    end
    
endmodule

