//-----------------------------------------------------------------------------
//
// Title       : FSM
// Design      : TP02_G2
// Author      : 
// Subject     : E3
//
//-----------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
//
// Description : Máquina de estado de interpretación de las teclas ingresadas por el usuario
//
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ps

//{{ Section below this comment is automatically maintained
//   and may be overwritten
//{module {FSM}}
module FSM ( tipo,			//Tipo de tecla	: azul  = 0 (número) y rojo = 1 (signo)
			 number, 		//Número de tecla
			 clk,
			 register,		//Registro de memoria
			 reset, 		//Activo alto
			 OE,			//Enable display
			 save);			//le pasa el numero a guardar	
		   //Definición de estados
	parameter [2:0] WAITING = 3'b000;	  //Espera a que se seleccione una tecla
	parameter [2:0] SAVENUMBER = 3'b001;   //Recibe un número
	parameter [2:0] SAVEOP = 3'b010;		  //Recibe +/-
	parameter [2:0] EQUAL = 3'b011;        //Recibe =
	parameter [2:0] RESET = 3'b100;
	
	//In and Out
	input tipo;						//Tipo de tecla	: azul  = 0 (número) y rojo = 1 (signo)
	input [3:0] number; 			//Número de tecla
	input clk;
	output reg [1:0] register;		//Registro de memoria
	output reg reset; 				//Activo alto
	output reg [2:0] OE;
	output reg [3:0] save;
	
	//Registros y constantes
    reg op = 0;  					    //Determina si se tocó una operación aritmética válida
	reg counter_num = 0;				//Determina si ya se presionó un número válido
	reg [2:0] curr_y = WAITING;			//Current state
	reg [2:0] next_Y;					//Next state

	
	
   //Tema teclas:
   // + =  1010
   // - = 1011
   // = = 1100
   // reset = 1111
   always @(tipo, curr_y, number)
	   begin   
        case (curr_y)
            WAITING: 
			begin 
				OE = 0;	       //No se muestra en display
				reset = 0;				  
				register = 0;  //No se guarda nada
				if (tipo)      //Si es un signo
					begin
						case(number)
						  4'b1010, 4'b1011:         //Si es + o -  
							  if (!op && counter_num) next_Y = SAVEOP;	  //Y todavía no se hizo una operación
							   else next_Y = WAITING;
						  4'b1100: 	next_Y = EQUAL;	  //Si es  =
						  4'b1111: next_Y = RESET;	  //Si es reset
						  default: next_Y = WAITING;
						endcase
					end
				else 
					begin 
					  	if (number === 4'bz) next_Y = WAITING;   //No se presionó ninguna tecla
						else
							begin
							next_Y = SAVENUMBER;
							register = 0;
							end
					end
             end
            SAVENUMBER: 
				begin 
					reset = 0;
					counter_num = 1;
	         		if (!op)                //Si es el primer número
						 begin
							 register = 1;	//Se guarda en registro 1
							 OE = 1;        //Mostrar primer número en display
						 end
					else					//Si es el segundo número
						begin
							register = 2;  	//Se guarda en registro 2
							OE = 2;		   	//Mostrar segundo número en display
						end
					next_Y = WAITING;		 
                end
            SAVEOP:  
				begin
				  op = 1;    
         		  OE = 0;
				  register = 3;	   //Se guarda en el registro de resultado
				  reset = 0;
				  next_Y = WAITING;
			    end
            EQUAL:
				begin
					register = 0;
					reset = 0;
					
	         			if(!op)							//Si no se presionó un operando aritmético válido
							 begin
							 	if(counter_num) 		//y se presionó algún número válido
									begin
										OE = 1;			//Mostrar primer número en display 
										next_Y = WAITING;
									end
								 else		           	//No se presionó ningún número
									 begin
										OE = 0;			//No se muestra display	 
										next_Y = WAITING;								 
							  		 end  
							end 
						else 		      				//Se presionó un operando aritmético válido
							begin
								OE = 3;     			//Mostrar resultado en display
								if( number == 4'b1111) next_Y = RESET; 
								else next_Y = EQUAL;	//Se queda mostrando resultado hasta reset													
							end
				   
				end
            RESET: 
				begin 
         		  OE = 0;
				  register = 0;
				  reset = 1;
				  op = 0;
				  counter_num =0;
				  next_Y = WAITING;
				end 
			
        endcase	
	end	
	//Transición de estados	
   	always @( posedge clk)
		 begin
		 curr_y <= next_Y;
		 save = number;
		 end

 endmodule

 
 module text_FSM();
		reg tipo;				//Tipo de tecla	: azul  = 0 (número) y rojo = 1 (signo)
		reg [3:0] number; 		//Número de tecla
		reg clk;
		reg [1:0] register;		//Registro de memoria
		reg reset; 				//Activo alto
		reg [2:0] OE; 
		reg [2:0] state;
		reg [3:0] save;
		
		FSM U1( .tipo(tipo),		//Tipo de tecla	: azul  = 0 (número) y rojo = 1 (signo)
			 .number(number), 		//Número de tecla
			 .clk(clk),
			 .register(register),		//Registro de memoria
			 .reset(reset), 				//Activo alto
			 .OE(OE), .save(save));	 
		initial 
			
			begin
				assign clk = 0;
				assign tipo = 0;
				assign number = 4'bz;  
				
				//Prueba de n°
				//#5ns assign clk = ~clk;
		 		//#5ns assign tipo = 0;
				//     assign clk = ~clk;
		 		//#5ns assign number = 6;
				     //assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//Prueba signo válido
				//#5ns assign tipo = 1;
				//#1ns assign number = 4'b1010;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;	
				//Prueba signo no válido
				//#1ns assign number = 4'b1110;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//Prueba no se presiona un número
				//#1ns assign number = 4'bz;
							//tipo = 0;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				
				//Prueba insertar un número
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#1ns assign number = 1;	   //Primer número
							tipo = 0;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign number = 2;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;;
				#5ns assign tipo = 1;
				assign number = 4'b1011; 	 //Operando 
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign tipo = 1;
				assign number = 4'b1010; 	 //Operando (+ - después de uno presionado) 
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
  				#5ns assign tipo = 0;
				assign number = 7;	    //Segundo número
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				assign tipo = 0; //puse tipo = 1 y funcionó también 
				assign number = 4'bz;	    //Número no válido
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				assign number = 8;	        //Segundo número
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign tipo = 1;
				//#5ns assign tipo = 1;
				//assign number = 4'b1111;     //Reset en el medio
				//#5ns assign clk = ~clk;	 
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				//#5ns assign clk = ~clk;
				assign number = 4'b1100;     //Igual
				#5ns assign clk = ~clk;	 
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				     assign number = 4'b1111;  //Reset
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;	
				  #5ns assign tipo = 1;
				assign number = 4'b1100;	    //Operando al comienzo
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
  				#5ns assign tipo = 0;
				assign number = 8;	    //Ingresar nuevo número después de reset
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				#5ns assign clk = ~clk;
				


		 	end
endmodule