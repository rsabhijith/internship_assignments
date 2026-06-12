`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.06.2026 20:57:58
// Design Name: 
// Module Name: output_module
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


module output_module(
    input clk,
    input rst,
    input [7:0] d_in,
    output reg rd_enb,
    output reg [7:0] d_out
);

parameter idle = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;

reg [1:0] state;

always @(posedge clk)
begin
if(rst)
begin
state <= idle;
rd_enb <= 1'b0;
d_out <= 8'h00;
end
else
begin
case(state)
idle:
begin
rd_enb <= 1'b0;
state <= S1;
end
S1:
begin
rd_enb <= 1'b0;
state <= S2;
end
S2:
begin
rd_enb <= 1'b1;
d_out <= d_in;
state <= idle;
end
default:
begin
rd_enb <= 1'b0;
state <= idle;
end
endcase
end
end
endmodule
