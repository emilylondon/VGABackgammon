//////////////////////////////////////////////////////////////////////////////////
// Author:			Shideh Shahidi, Bilal Zafar, Gandhi Puvvada
// Create Date:   02/25/08, 10/13/08
// File Name:		ee354_GCD.v 
// Description: 
//
//
// Revision: 		2.1
// Additional Comments:  
// 10/13/2008 SCEN has been added by Gandhi
//  3/1/2010  Signal names are changed in line with the divider_verilog design
//           `define is replaced by localparam construct
//  02/24/2020 Nexys-3 to Nexys-4 conversion done by Yue (Julien) Niu and reviewed by Gandhi
//////////////////////////////////////////////////////////////////////////////////


module ee354_GCD(Clk, SCEN, Reset, Start, Ack, Ain, Bin, A, B, AB_GCD, i_count, q_I, q_Sub, q_Mult, q_Done);


	/*  INPUTS */
	input	Clk, SCEN, Reset, Start, Ack;
	input [7:0] Ain;
	input [7:0] Bin;
	
	// i_count is a count of number of factors of 2	. We do not need an 8-bit counter. 
	// However, in-line with other variables, this has been made an 8-bit item.
	/*  OUTPUTS */
	// store the two inputs Ain and Bin in A and B . These (A, B) are also continuously output to the higher module. along with the AB_GCD
	output reg [7:0] A, B, AB_GCD, i_count;		// the result of the operation: GCD of the two numbers
	// store current state
	output q_I, q_Sub, q_Mult, q_Done;
	reg [3:0] state;	
	assign {q_Done, q_Mult, q_Sub, q_I} = state;
		
	localparam 	
	I = 4'b0001, SUB = 4'b0010, MULT = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX;
	
	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin : my_GCD
		if(Reset) 
		  begin
			state <= I;
			i_count <= 8'bx;  	// ****** TODO ******
			A <= 8'bxxxxxxxx;		  	// complete the 3 lines
			B <= 8'bxxxxxxxx;
			AB_GCD <=8'bxxxxxxxx;			
		  end
		else				// ****** TODO ****** complete several parts
				// variables:
				// fish_timer, y, rpos, fpos, up, down, left, right, center (will map to reset)

				// States:
				// I, F1, C1, F2, C2, F3, C3, F4, C4, Done
				
				case(state)	
					
					I:
					begin
						// state transfers
						if (Start) 
						begin
							state <= F1;
						end;
						// data transfers
						
						// Bottom y position
						y <= 390
						
						//Initialize to 0
						fish_timer <= 0;
						fpos <= -20;

					end	
						
					F1:
					begin
						// state transfers

						//first fish is 20 pixels long
						if( ((rpos>= fpos) && (rpos <= fpos + 20)) && (up) )
						begin
							state <= C1
							fish_timer <= 0;
						end
						if(up && ((rpos<= fpos) || (rpos >= fpos + 20)) )
						begin
							state <= I;
						end
						// data transfers

						ypos <= 390;

						if(left||right )
						begin
							fish_timer <= fish_timer + 1;
							if(fish_timer >= 500)
							begin
								
								// move/scan the fish CODE HERE
								
							end
						end
					
					end

					C1:
					begin
						// state transfers

						// need to replace 140 with top water level condition
						if(ypos <= 155)
						begin
							state<=F2;
							ypos <= 300;
							fish_timer <= 0;
							fpos <= -15;
						end
						// data transfers
						if(up)
						begin
							ypos <= ypos - 2;
						end

					end

					F2:
					begin
						// state transfers

						//first fish is 20 pixels long
						if( ((rpos>= fpos) && (rpos <= fpos + 15)) && (up) )
						begin
							state <= C2
							fish_timer <= 0;
						end
						if(up && ((rpos<= fpos) || (rpos >= fpos + 15)) )
						begin
							state <= I;
						end
						// data transfers

						ypos <= 390;

						if(left||right)
						begin
							fish_timer <= fish_timer + 1;
							if(fish_timer >= 500)
							begin
								
								// move/scan the fish CODE HERE
								
							end
						end
					
					end

					C2:
					begin
						// state transfers
						if(ypos <= 155)
						begin
							state<=F3;
							ypos <= 210;
							fish_timer <= 0;
							fpos <= -10;
						end
						
						// data transfers
						if(up)
						begin
							ypos <= ypos - 2;
						end
					end
					
					
					DONE:
						if (Ack)	state <= I;
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
