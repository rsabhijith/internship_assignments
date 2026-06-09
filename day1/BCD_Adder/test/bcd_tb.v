timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2026 23:01:12
// Design Name: 
// Module Name: bcd_tb
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


module bcd_tb(

    );
    reg A0_tb,A1_tb,A2_tb,A3_tb,B0_tb,B1_tb,B2_tb,B3_tb,Cin_tb;
    wire S0_tb,S1_tb,S2_tb,S3_tb,Cout_tb;
    bcd dut(A0_tb,A1_tb,A2_tb,A3_tb,B0_tb,B1_tb,B2_tb,B3_tb,Cin_tb,S0_tb,S1_tb,S2_tb,S3_tb,Cout_tb);
    initial
    begin
    {A0_tb,A1_tb,A2_tb,A3_tb,B0_tb,B1_tb,B2_tb,B3_tb,Cin_tb}=0;
    end
    initial
    begin
    {A3_tb,A2_tb,A1_tb,A0_tb}=4'b0000;
    {B3_tb,B2_tb,B1_tb,B0_tb}=4'b0000;
    Cin_tb=1'b0;
    #1                              //A=4,B=4 => 8 (1000)
    {A3_tb,A2_tb,A1_tb,A0_tb}=4'b0100;
    {B3_tb,B2_tb,B1_tb,B0_tb}=4'b0100;
    Cin_tb=1'b0;
    #1                             //A=6,B=3 => 9  (1001)
    {A3_tb,A2_tb,A1_tb,A0_tb}=4'b0110;
    {B3_tb,B2_tb,B1_tb,B0_tb}=4'b0011;
    Cin_tb=1'b0;
    #1                            //A=7,B=5 => 12   (1 0010)
    {A3_tb,A2_tb,A1_tb,A0_tb}=4'b0111;
    {B3_tb,B2_tb,B1_tb,B0_tb}=4'b0101;
    Cin_tb=1'b0;
    #1                            //A=9,B=8 =>17    (1 0111)
    {A3_tb,A2_tb,A1_tb,A0_tb}=4'b1001;
    {B3_tb,B2_tb,B1_tb,B0_tb}=4'b1000;
    Cin_tb=1'b0;
    #1                            //A=9,B=9 =>18    (1 1000)
    {A3_tb,A2_tb,A1_tb,A0_tb}=4'b1001;
    {B3_tb,B2_tb,B1_tb,B0_tb}=4'b1001;
    Cin_tb=1'b0;
    $monitor("A_tb=%b%b%b%b B_tb=%b%b%b%b Cin_tb=%b S_tb=%b%b%b%b Cout_tb=%b",A3_tb,A2_tb,A1_tb,A0_tb,B3_tb,B2_tb,B1_tb,B0_tb,Cin_tb,S3_tb,S2_tb,S1_tb,S0_tb,Cout_tb);
    end
endmodule
