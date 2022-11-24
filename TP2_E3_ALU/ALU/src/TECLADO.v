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
	output wire [7:0] dispdig,
	output reg D1,
	output reg D2,
	output reg D3,
	output reg D4
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




//-----------------------------------------------------------------test
module test_EN_logic;
	reg EN;
	reg [0:3] F;
	wire EN_logic;
	integer i;
	Enable_logic Ux (EN,F,EN_logic);   
	
	initial
		begin 
			EN = 1;
			F = 4'b0000;
		end
	
	always
		begin
			#10ns EN = 0;
			for(i=0;i<15;i=i+1)
				#2ns F = F + 1;
		end
	
endmodule

module test_color_logic;
	reg EN;
	reg [0:1]Fb,Cb;
	wire tipo;			  
	
	integer i,j;
	
	color_logic Ux (EN,Fb,Cb,tipo);
	
	initial
		begin 
			EN = 1;
			Fb = 2'bzz;	
			Cb = 2'bzz;	
			i=0;
			j=0;
		end
	
	always
		begin
			#10ns EN = 0;
			Fb = 2'b00;	
			Cb = 2'b00;
			for(i=0;i<4;i=i+1)
				begin 
					#2ns Fb = Fb + 1;
					for(j=0;j<4;j=j+1)
					#2ns Cb = Cb + 1;
				end		
		end
endmodule	 

module test_encoder;
	reg EN;
	reg [0:3] F;
	wire [0:1] out_bin;				   
	integer i;
	encoder_4_2 Ux (EN,F,out_bin);
	
	initial
		begin 
			EN = 1;
			F = 4'b0000; 
			i = 0;
		end
	
	always
		begin
			#10ns EN = 0;
			for(i=0;i<15;i=i+1)
				#2ns F = F + 1;
		end
	
endmodule		

module test_salida_teclado;
	reg [0:1]Fb,Cb;
	wire [0:3]Num_out;
	integer i,j;
	Salida_teclado Ux (Fb, Cb, Num_out);
	
	
	initial
		begin 
			Fb = 2'b00;	
			Cb = 2'b00;	
			i=0;
			j=0;
		end
	
	always
		begin
			
			for(i=0;i<4;i=i+1)
				begin 
					#2ns Cb = Cb + 1;
					for(j=0;j<4;j=j+1)
					#2ns Fb = Fb + 1;
				end	
		end
endmodule	


module test_fsm_teclado;	 
	reg reset,clk;
	reg EN_logic;
	reg [0:1]fil_bin, col_bin;
	reg tipo_in;
	
	wire [0:2] test_CS, test_NS;
	wire tipo_out;
	wire [0:3]Num; 
	
	FSM_lectura_teclado Ux (reset, clk, EN_logic, Num, tipo_out, fil_bin, col_bin, tipo_in);			
	
	initial 
		begin 
			reset = 0;
			clk = 0;
			EN_logic = 1;
			fil_bin = 2'b11;
			col_bin = 2'b01;
			tipo_in = 1'b0;
		end		  
		
	always
		begin 
			#22ns clk = !clk; 
		end					
		
	always
		begin
			reset = 1;
			#1ns reset = 0;
			#200ns reset = 1;
		end
	always
		begin
			#4ns EN_logic = 0;
			#4ns EN_logic = 1;	   
		end
	
endmodule	 

module test_lectura;
	reg [0:3] col_codigo, fil_codigo;
	reg EN;
	wire EN_logic;
	wire [0:1] fil_bin, col_bin; 
	wire tipo;
	integer i,j;
	input_read Ux (col_codigo, fil_codigo, EN_logic, fil_bin, col_bin, tipo, EN);
	
	initial 
		begin 
			EN=1;
			col_codigo = 4'b1111;
			fil_codigo = 4'b0000;
			i=0;
			j=0;
		end	
		
	always
		begin
			EN = 0;
				begin 
					#2ns col_codigo = 4'b1110;
					for(j=0;j<4;j=j+1)
						#2ns fil_codigo = fil_codigo + 1; 
						
					#2ns col_codigo = 4'b1101;
					for(j=0;j<4;j=j+1)
						#2ns fil_codigo = fil_codigo + 1;
						
					#2ns col_codigo = 4'b1011;
					for(j=0;j<4;j=j+1)
						#2ns fil_codigo = fil_codigo + 1;
						
					#2ns col_codigo = 4'b0111;
					for(j=0;j<4;j=j+1)
						#2ns fil_codigo = fil_codigo + 1;
				end	
		end
	
	
endmodule

module test_barrido;
	reg [0:3]col_cod;
	reg clk,reset;
	
	barrido_col Ux (col_cod,clk,reset);
	
	initial
		begin 
			clk = 0;
			reset = 0;
		end		 
		
	always 
		begin
			#1ns reset = 1;
			#1ns reset = 0;
			#300ns reset = 1;
		end					
		
	always 
		#1ns clk = !clk;
	
endmodule	 

module test_teclado;	  
	wire [0:3] col_codigo;
	reg [0:3] fil_codigo;
	reg clk,reset;
	wire tipo_out;
	
	Teclado Ux (col_codigo, fil_codigo, Num, tipo_out, clk, reset);	
	
	
	initial
		begin 
			clk = 0;
			reset = 0;
		end		 
		
	always 
		begin
			#1ns reset = 1;
			#1ns reset = 0;
			#300ns reset = 1;
		end					
		
	always 
		#1ns clk = !clk;
		
		
endmodule