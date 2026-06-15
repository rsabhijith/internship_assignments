`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2026 13:09:00
// Design Name: 
// Module Name: bcd_interface
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


interface bcd_if;
    logic [3:0] A;
    logic [3:0] B;
    logic Cin;
    logic [3:0] S;
    logic Cout;
endinterface
module bcd_tb;
    bcd_if aif();
    bcd dut(aif.A[0],aif.A[1],aif.A[2],aif.A[3],aif.B[0],aif.B[1],aif.B[2],aif.B[3],aif.Cin,aif.S[0],aif.S[1],aif.S[2],aif.S[3],aif.Cout);

    initial begin
    aif.A   = 4'd4;
    aif.B   = 4'd4;
    aif.Cin = 0;
    #1;
    aif.A   = 4'd6;
    aif.B   = 4'd3;
    #1;
    aif.A   = 4'd7;
    aif.B   = 4'd5;
    #1;
    aif.A   = 4'd9;
    aif.B   = 4'd8;
    #1;
    aif.A   = 4'd9;
    aif.B   = 4'd9;
    #1;
    end
    initial begin
    $monitor("A=%d B=%d Cin=%b Sum=%b Cout=%b",aif.A, aif.B, aif.Cin, aif.S, aif.Cout);
    #5;
    $finish;
    end
endmodule
