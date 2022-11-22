//-----------------------------------------------------------------------------
//
// Title       : ALU
// Design      : calculadora
// Author      : Albertina Galan
// Company     : itba
//
//-----------------------------------------------------------------------------
//
// File        : C:\My_Designs\TP2_E3_ALU\calculadora\src\ALU.v
// Generated   : Mon Oct 31 17:20:29 2022
// From        : interface description file
// By          : Itf2Vhdl ver. 1.22
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

//{module {ALUv2}}
module ALU(reg1, reg2, regop, res, ovf, sign);
input [15:0] reg1;
	input wire [15:0] reg2;
	input wire regop;
	output reg [15:0] res;
	output reg ovf;
	output reg sign;

	wire [15:0] temp_n1;
	wire [15:0] temp_n2;
	reg [16:0] temp_answ;
	
	integer i;
	
	bcd2bin convertbcdbinreg1(.A(reg1[15:12]), .B(reg1[11:8]), .C(reg1[7:4]), .D(reg1[3:0]), .bin(temp_n1));
	bcd2bin convertbcdbinreg2(.A(reg2[15:12]), .B(reg2[11:8]), .C(reg2[7:4]), .D(reg2[3:0]), .bin(temp_n2));
	
	always @(reg1 or reg2 or regop)
		begin
			if (regop) //suma
				begin
					temp_answ = temp_n1 + temp_n2;
					if (temp_answ >= 14'b10011100010000) //se fija si es mayor a 10000
						ovf = 1;
					else
						ovf = 0;
				end
			else
				begin
					temp_answ = temp_n1 - temp_n2;
					if (temp_n2 > temp_n1)
						begin
							temp_answ = ~temp_answ + 1;
							sign = 1;
						end
					else
						sign = 0;
				end
		end
	
	always @(temp_answ) 	//convert bin to bcd 
		begin
		    res=0;		 	
		    for (i=0;i<14;i=i+1) 
				begin					//Iterate once for each bit in input number
				    if (res[3:0] >= 5) res[3:0] = res[3:0] + 3;		//If any BCD digit is >= 5, add three
					if (res[7:4] >= 5) res[7:4] = res[7:4] + 3;
					if (res[11:8] >= 5) res[11:8] = res[11:8] + 3;
					if (res[15:12] >= 5) res[15:12] = res[15:12] + 3;
					res = {res[14:0],temp_answ[13-i]};				//Shift one bit, and shift in proper bit from input 
				end
		end

endmodule

//MODULE FROM https://www.realdigital.org/doc/6dae6583570fd816d1d675b93578203d
//bcd to binary converter
module bcd2bin //number = ABCD
   (
    input wire [3:0] A, 
    input wire [3:0] B, 
    input wire [3:0] C, 
    input wire [3:0] D, 
    output wire [15:0] bin
   );

   assign bin = (A * 10'd1000) + (B*7'd100) + (C*4'd10) + D;

endmodule

module test_ALU();
	reg [15:0] reg1;
	reg [15:0] reg2;
	reg regop;
	reg [15:0] res;
	reg ovf;
	reg sign;
	
	ALU myalu(.reg1(reg1), .reg2(reg2), .regop(regop), .res(res), .ovf(ovf), .sign(sign));
	
	initial
		begin
			#5ns 
			assign reg1 = 16'b0000000000010000;
			assign reg2 = 16'b0000000000010101;
			assign regop = 1;
			#5ns 
			assign reg1 = 16'b0000000000001000;
			assign reg2 = 16'b0000000000000011;
			assign regop = 0; 
			#5ns 
			assign reg1 = 16'b0001000000000111;
			assign reg2 = 16'b0000001000010100;
			assign regop = 0;
			#5ns 
			assign reg1 = 16'b1001100001110110;
			assign reg2 = 16'b0000001000000000;
			assign regop = 1;
		end
	
endmodule