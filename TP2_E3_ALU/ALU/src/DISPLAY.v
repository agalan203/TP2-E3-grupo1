//-----------------------------------------------------------------------------
//
// Title       : DISPLAY
// Design      : ALU
// Author      : Albertina Galan
// Company     : itba
//
//-----------------------------------------------------------------------------
//
// File        : C:\My_Designs\TP2_E3_ALU\ALU\src\DISPLAY.v
// Generated   : Fri Nov 18 16:19:26 2022
// From        : interface description file
// By          : Itf2Vhdl ver. 1.22
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

//{module {DISPLAY}}
module DISPLAY (
	input wire [15:0] reg1,
	input wire [15:0] reg2,
	input wire [15:0] res,
	input wire [2:0] OE,
	input wire clk,
	output reg [7:0] dispdig,
	output reg D1,
	output reg D2,
	output reg D3,
	output reg D4,
	); 	
	
	reg [15:0] temp;
	reg [3:0] bcddig;
	
	parameter [2:0] dispD1 = 0;
	parameter [2:0] dispD2 = 1;
	parameter [2:0] dispD3 = 2;
	parameter [2:0] dispD4 = 3;
	
	reg [2:0] state;
	
	BCDto7segment convert (.bcddig(bcddig), .sevenseg(dispdig));
	
	always @ (OE or reg1 or reg2 or res)
		begin
			case(OE)
				0: temp = 16'bz;
				1: temp = reg1;
				2: temp = reg2;
				3: temp = res;
				default temp = temp;
			endcase
			state = dispD1;
		end
	
	always @ (negedge clk)
		begin
			case (state)
				dispD1:
				begin
					D1=1;
					D2=0;
					D3=0;
					D4=0;
					bcddig=temp[15:12];
				end
				dispD2:
				begin
					D1=0;
					D2=1;
					D3=0;
					D4=0;
					bcddig=temp[11:8]; 
				end		
				dispD3:  
				begin    
					D1=0;
					D2=0;
					D3=1;
					D4=0;
					bcddig=temp[7:4]; 
				end
				dispD4:
				begin
					D1=0;
					D2=0;
					D3=0;
					D4=1;
					bcddig=temp[3:0]; 
				end
				default
				begin
					D1=D1;
					D2=D2;
					D3=D3;
					D4=D4;
					bcddig=bcddig; 
				end
			endcase
			if(state==dispD4)
				state = dispD1;
			else
				state = state + 1;
				
			if(!OE)
				begin
					D1=0;
					D2=0;
					D3=0;
					D4=0;
					bcddig=4'bz;
				end
		end

endmodule  

module BCDto7segment(
	input wire [3:0] bcddig,
	output reg [7:0] sevenseg
	);
	
	always @ (bcddig)
		begin
			case (bcddig)
				0: sevenseg='b11111100;
				1: sevenseg=8'b01100000;
				2: sevenseg=8'b11011010;
				3: sevenseg=8'b11110010;
				4: sevenseg=8'b01100110;
				5: sevenseg=8'b10110110;
				6: sevenseg=8'b00111110;
				7: sevenseg=8'b11100000;
				8: sevenseg=8'b11111110;
				9: sevenseg=8'b11100110;
				10:	sevenseg=8'bz;
				11: sevenseg=8'bz;
				12: sevenseg=8'bz;
				13: sevenseg=8'bz;
				14: sevenseg=8'bz;
				15: sevenseg=8'bz;
				default sevenseg=8'bz;
			endcase		
		end
	
endmodule

module testdisp ();
	
	reg [15:0] reg1;
	reg [15:0] reg2;
	reg [15:0] res;
	reg [2:0] OE;
	reg clk;
	reg [7:0] dispdig;
	reg D1;
	reg D2;
	reg D3;
	reg D4;    
	
	DISPLAY mydisp (reg1,reg2,res,OE,clk,dispdig,D1,D2,D3,D4);
	
	initial
		begin
			clk = 0;
			reg1 = 16'b0001001001110100;
			reg2 = 16'b0101001001010010;
			res = 16'b0110010100100110;
			OE = 0;
		end
		
	always #5ns clk = ~clk;	
		
	initial
		begin
			#10ns OE = 1;
			#60ns OE = 2;
			#60ns OE = 3;
			#20ns res = 16'b0101001001010010;
			#70ns OE = 0;
			#50ns;
			$finish;
		end	
endmodule
