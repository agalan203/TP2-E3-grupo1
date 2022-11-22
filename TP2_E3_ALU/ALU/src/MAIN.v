//-----------------------------------------------------------------------------
//
// Title       : MAIN
// Design      : ALU
// Author      : Albertina Galan
// Company     : itba
//
//-----------------------------------------------------------------------------
//
// File        : C:\My_Designs\TP2_E3_ALU\ALU\src\MAIN.v
// Generated   : Mon Nov  7 18:14:48 2022
// From        : interface description file
// By          : Itf2Vhdl ver. 1.22
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

//{module {MAIN}}
module MAIN (tipo, number, clk, ovf, sign, dispdig, D1, D2, D3, D4);	
	
	input wire tipo;
	input wire [3:0] number;
	input wire clk;
	
	output wire ovf;
	output wire sign;
	output wire [7:0] dispdig;
	output wire D1;
	output wire D2;
	output wire D3;
	output wire D4;
	
	//conexiones FSM-SAVE
	wire [1:0] register;
	wire reset;
	wire [2:0] OE; 
	wire [3:0] save;
	
	//conexiones SAVE-ALU
	wire [15:0] reg1; 
	wire [15:0] reg2;
	wire regop;
	
	//conexiones ALU-DISPLAY
	wire [15:0] result;
	
	FSM theFSM ( .tipo(tipo), .number(number), .clk(clk), .register(register), .reset(reset), .OE(OE), .save(save), .state(state));
	Save theSAVE (.nr(save), .regi(register), .reset(reset), .reg1(reg1), .reg2(reg2), .regop(regop));
	ALU theALU (.reg1(reg1), .reg2(reg2), .regop(regop), .res(result), .ovf(ovf), .sign(sign));
	DISPLAY theDISPLAY (.reg1(reg1), .reg2(reg2), .res(result), .OE(OE), .clk(clk), .dispdig(dispdig), .D1(D1), .D2(D2),.D3(D3), .D4(D4));

endmodule  

module test_main ();
	reg tipo;
	reg [3:0] number;
	reg clk;
	reg [15:0] result;
	reg ovf;
	reg sign;
	reg [15:0] reg1; 
	reg [15:0] reg2;
	reg regop;
	reg reset;
	reg [2:0] state;
	reg [3:0] save;
	
	MAIN my_main (tipo, number, clk, ovf, sign, dispdig, D1, D2, D3, D4);
	
	initial
		begin
			clk = 0;
			tipo = 1;
			number = 4'b1111;
		end
		
	always #5ns clk = ~clk;
		
	initial
		begin	
			//Prueba insertar un número	
			#30ns;
			#1ns number = 1;	   //Primer número
						tipo = 0;
			#30ns;
			#5ns number = 2;
			#20ns;
			#5ns tipo = 1;
				   number = 4'b1010; 	 //Operando 
			#30ns;
			#5ns   tipo = 0;
				   number = 7;	    //Segundo número
			#30ns;
				   tipo = 0; //puse tipo = 1 y funcionó también 
				   number = 4'bz;	    //Número no válido
			#30ns;
				   number = 8;	        //Segundo número
			#30ns;
			#5ns   tipo = 1;
				   number = 4'b1100;     //Igual
			#30ns;
			       number = 4'b1111;  //Reset
			#30ns;	
			#5ns   tipo = 1;
				   number = 4'b1100;	    //Operando al comienzo
			#40ns;
			#5ns   tipo = 0;
				   number = 8;	    //Ingresar nuevo número después de reset
			#30ns;
			$finish;
		end			
endmodule
