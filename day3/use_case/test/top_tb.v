module top_tb;
reg clk_tb,rst_tb;
reg [7:0] s in_tb;
wire [7:0] d out_tb;
top dut(clk_tb,rst_tb,s_in_tb,d_out_tb);
initial
begin
clk_tb = 0;
rst_tb = 1;
s_in_tb = 0;
#12 rst_tb = 0;
end
always #5 clk_tb = ~clk_tb;
initial
begin
#15 
s_in_tb = 8'h4f;
#10
s_in_tb = 8'h23;
#10 
s_in_tb = 8'h74;
#10 
s_in_tb = 8'h5d;
#10
s_in_tb = 8'ha3;
#10
s_in_tb = 8'h69;
#10
s_in_tb = 8'h10;
#10
s_in_tb = 8'h56;
#10
#250;
$finish;
end
endmodule
