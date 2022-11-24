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
module MAIN (
	input wire gpio_12,	
	input wire gpio_21,
	input wire gpio_13,
	input wire gpio_19,
	input wire gpio_47,
	
	output wire gpio_18,
	output wire gpio_11,
	output wire gpio_9,
	output wire gpio_6,
	
	output wire gpio_2, 
	output wire gpio_46, 
	output wire gpio_23, 
	output wire gpio_25, 
	output wire gpio_26, 
	output wire gpio_27, 
	output wire gpio_32, 
	output wire gpio_35, 
	output wire gpio_31, 
	output wire gpio_37, 
	output wire gpio_34, 
	output wire gpio_43, 
	output wire gpio_36, 
	output wire gpio_42);
	
	//INPUTS				
	wire Treset;
	wire [0:3] fil_codigo;
	
	//Assign inputs	  
	assign Treset = gpio_47; //resetTotal
	assign fil_codigo = {gpio_12, gpio_21, gpio_13, gpio_19};   //filas
	
	//OUTPUTS
	wire ovf;
	wire sign;
	wire [7:0] dispdig;
	wire D1;
	wire D2;
	wire D3;
	wire D4;
	
	//Assign outputs
	assign ovf = gpio_2;
	assign sign = gpio_46;
	assign dispdig[0] = gpio_23;   //a
	assign dispdig[1] = gpio_25;   //b
	assign dispdig[2] = gpio_26;   //c
	assign dispdig[3] = gpio_27;   //d
	assign dispdig[4] = gpio_32;   //e
	assign dispdig[5] = gpio_35;   //f
	assign dispdig[6] = gpio_31;   //g
	assign dispdig[7] = gpio_37;   //decimal
	assign D1 = gpio_34;
	assign D2 = gpio_43;
	assign D3 = gpio_36;
	assign D4 = gpio_42;
	 
	wire [0:3]col_codigo = {gpio_18, gpio_11, gpio_9, gpio_6}; 	//columnas
	
	//CLK
	wire clk;
	SB_LFOSC u_SV_HFOSC(.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(clk));
	
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
	
	Teclado theTECLADO (.col_codigo(col_codigo), .fil_codigo(fil_codigo), .Num(number), .tipo_out(tipo), .clk(clk), .reset(Treset));
	FSM theFSM ( .tipo(tipo), .number(number), .clk(clk), .register(register), .reset(reset), .OE(OE), .save(save));
	Save theSAVE (.nr(save), .regi(register), .reset(reset), .reg1(reg1), .reg2(reg2), .regop(regop));
	ALU theALU (.reg1(reg1), .reg2(reg2), .regop(regop), .res(result), .ovf(ovf), .sign(sign));
	DISPLAY theDISPLAY (.reg1(reg1), .reg2(reg2), .res(result), .OE(OE), .clk(clk), .dispdig(dispdig), .D1(D1), .D2(D2),.D3(D3), .D4(D4));

endmodule 

module test_main ();
	reg tipo;
	reg [3:0] number;
	reg clk;
	
	reg ovf;
	reg sign;
	reg [7:0] dispdig; 
	reg D1;
	reg D2;
	reg D3;
	reg D4;
	
	MAIN my_main (tipo, number, ovf, sign, dispdig, D1, D2, D3, D4);
	
	initial
		begin
			tipo = 1;
			number = 4'b1111;
		end
		
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
