module Save(
    input wire [3:0] nr,
    input wire [1:0] regi,
    input wire reset,
    output reg [15:0] reg1,
    output reg [15:0] reg2,
    output reg regop
    );

    always @(nr or regi or reset)
        begin
            if (reset==1)
                begin
                    reg1 = 0;
                    reg2 = 0;
					regop = 0;
                end
            else
                begin
                    case(regi)
                        1 : begin
							if (nr < 4'b1010)
								begin
                                reg1[15:12] = reg1[11:8];
                                reg1[11:8] = reg1[7:4];
                                reg1[7:4] = reg1[3:0];
                                reg1[3:0] = nr;
								end
                            end
                        2 : begin
							if (nr < 4'b1010)
								begin
                                reg2[15:12] = reg2[11:8];
                                reg2[11:8] = reg2[7:4];
                                reg2[7:4] = reg2[3:0];
                                reg2[3:0] = nr;
								end
                            end
                        3 : if (nr==4'b1010) regop = 1;
							else if (nr==4'b1011) regop = 0;
                    endcase
                end
        end
endmodule


module TestSave();

    reg [3:0] nr;
    reg [1:0] regi;
    reg reset;
    reg [15:0] reg1;
    reg [15:0] reg2;
    reg regop;

    Save my_save(.nr(nr), .regi(regi), .reset(reset), .reg1(reg1), .reg2(reg2), .regop(regop));

    initial
        begin
			assign reset = 1;
            #5ns
            assign nr = 4'b0011;
            assign regi = 0;
            assign reset = 0;
            #15ns
            assign nr = 4'b0101;
            assign regi = 0;
            assign reset = 0;
            #15ns 
            assign nr = 4'b0001;
            assign regi = 1;
            assign reset = 0;
            #15ns 
            assign reset = 1;
			#15ns 
            assign nr = 4'b1010;
            assign regi = 2;
            assign reset = 0;
        end
endmodule