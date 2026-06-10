`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 20:23:35
// Design Name: 
// Module Name: face_module_tb
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


module face_module_tb(

    );
    reg clk_tb;
    reg [7:0] s_in_tb;
    wire [7:0] s_out_tb;

face_module dut(s_in_tb,clk_tb,s_out_tb);
always #5 clk_tb = ~clk_tb;
initial
begin
{clk_tb,s_in_tb}=0;
end
initial
begin
#10 
s_in_tb = 8'h10;
#10 
s_in_tb = 8'h20;
#10 
s_in_tb = 8'h30;
#10 
s_in_tb = 8'h40;

end
endmodule
