`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2026 14:45:21
// Design Name: 
// Module Name: usr
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


module usr(input clk,rst,sin,input [3:0]pin,input shift,load,input [1:0]mod,output reg sout,output reg [3:0]pout
    

    );
    reg [3:0]temp;
    always@(posedge clk)
    begin
    if(rst )
    begin
    temp<=4'b0000;
    sout<=1'b0;
    pout<=4'b0000;
    end
    else
    begin
    case(mod)
    2'b00: begin        //SISO
    if(shift) begin
    sout<=temp[0];
    temp<=temp>>1;
    end
    end
    2'b01: begin       //SIPO
    if(shift)
    temp<=temp>>1;
    if(load)
    pout<=temp;
    end
    2'b10: begin       //PISO
    if(load)
    temp<=pin;
    else if(shift)
    begin
    sout<=temp[0];
    temp<=temp>>1;
    end
    end
    2'b11: begin       //PIPO
    if(load)
    begin
    temp<=pin;
    pout<=pin;
    end
    end
    
    
            
            
    
    endcase
    end
    end
