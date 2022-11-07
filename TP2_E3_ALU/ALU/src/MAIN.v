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
module MAIN (tipo, number, clk, result, ovf, sign);	
	
	input wire tipo;
	input wire [3:0] number;
	input wire clk;
	output wire [15:0] result;
	output wire ovf;
	output wire sign;
	
	//conexiones FSM-SAVE
	wire [1:0] register;
	wire reset;
	wire [2:0] OE; 
	
	//conexiones SAVE-ALU
	wire [15:0] reg1; 
	wire [15:0] reg2;
	wire regop;

	FSM theFSM ( .tipo(tipo), .number(number), .clk(clk), .register(register), .reset(reset), .OE(OE));
	Save theSAVE (.nr(number), .regi(register), .reset(reset), .reg1(reg1), .reg2(reg2), .regop(regop));
	ALU theALU (.reg1(reg1), .reg2(reg2), .regop(regop), .res(result), .ovf(ovf), .sign(sign));

endmodule  

module test_main ();
	reg tipo;
	reg [3:0] number;
	reg clk;
	reg [15:0] result;
	reg ovf;
	reg sign; 
	
	MAIN my_main (tipo, number, clk, result, ovf, sign);
	
	initial
		begin
			clk = 0;
			tipo = 0;
			number = 4'b1111;
		end
		
	always #5ns clk = ~clk;
		
	initial
		begin	
			//Prueba insertar un número
			#20ns;
			#1ns number = 1;	   //Primer número
						tipo = 0;
			#20ns;
			#5ns number = 2;
			#20ns;
			#5ns tipo = 1;
				   number = 4'b1011; 	 //Operando 
			#20ns;
			#5ns   tipo = 0;
				   number = 7;	    //Segundo número
			#20ns;
				   tipo = 0; //puse tipo = 1 y funcionó también 
				   number = 4'bz;	    //Número no válido
			#20ns;
				   number = 8;	        //Segundo número
			#20ns;
			#5ns   tipo = 1;
				   number = 4'b1100;     //Igual
			#20ns;
			       number = 4'b1111;  //Reset
			#20ns;	
			#5ns   tipo = 1;
				   number = 4'b1100;	    //Operando al comienzo
			#40ns;
			#5ns   tipo = 0;
				   number = 8;	    //Ingresar nuevo número después de reset
			#20ns;
			$finish;
		end			
endmodule
