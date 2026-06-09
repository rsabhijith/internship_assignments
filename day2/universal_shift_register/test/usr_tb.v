`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 21:02:46
// Design Name: 
// Module Name: usr_tb
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


module usr_tb(

    );
    reg clk_tb;
    reg rst_tb;
    reg sin_tb;
    reg [3:0]pin_tb;
    reg shift_tb;
    reg load_tb;
    reg [1:0]mod_tb;
    wire sout_tb;
    wire [3:0]pout_tb;
    usr dut(clk_tb,rst_tb,sin_tb,pin_tb,shift_tb,load_tb,mod_tb,sout_tb,pout_tb);
always #5 clk_tb=~clk_tb;
initial
begin
{clk_tb,rst_tb,sin_tb,pin_tb,shift_tb,load_tb,mod_tb}=0;
end
initial
begin
rst_tb=1;
#10
rst_tb=0;
mod_tb=2'b00;
shift_tb=1;
sin_tb=1;
#10
sin_tb=0;
#10
sin_tb=1;
#10
sin_tb=0;
#10
shift_tb=0;

mod_tb=2'b01;
shift_tb=1;
sin_tb=1;
#10
sin_tb=1;
#10
sin_tb=0;
#10
sin_tb=1;
#10
shift_tb=0;
load_tb=1;
#10
load_tb=0;

mod_tb=2'b10;
pin_tb=4'b1011;
load_tb=1;
#10
load_tb=0;
shift_tb=1;
#40
shift_tb=0;

mod_tb=2'b11;
pin_tb=4'b1100;
load_tb=1;
#10
load_tb=0;

end
endmodule
