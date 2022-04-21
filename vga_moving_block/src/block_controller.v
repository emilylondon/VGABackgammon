`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb);
	wire q_F1, q_C1, q_F2, q_C2, q_F3, q_C3, q_F4, q_C4, q_W;
    reg[8:0] state;
	assign {q_W, q_C4, q_F4, q_C3, q_F3, q_C2, q_F2, q_C1, q_F1} = state;

	wire head; wire larm; wire rarm; wire lleg; wire rleg; wire torso; wire rod; wire jut; wire line; 
	wire fish1; wire fish2; wire fish3; wire fish4; 
	wire buoy; wire lbuoy; wire rbuoy;
	wire sun;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] rpos, ypos, fypos, fpos, fish_timer;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter BLUE  = 12'b0000_0000_1111;
	parameter WHITE = 12'b1111_1111_1111;
	parameter ORANGE = 12'b1110_1001_0100;
	parameter BROWN = 12'b0110_0010_0001;
	parameter YELLOW = 12'b1111_1111_0000;
	
	localparam  
		F1 = 9'b000000001,
		C1 = 9'b000000010,
		F2 = 9'b000000100,
		C2 = 9'b000001000,
		F3 = 9'b000010000,
		C3 = 9'b000100000,
		F4 = 9'b001000000,
		C4 = 9'b010000000,
		W  = 9'b100000000;
		

	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (buoy || rbuoy || lbuoy)
			rgb = BROWN;
		else if (head || larm || rarm || lleg || rleg || torso) 
			rgb = RED; 
		else if (fish1 && state==F1 || fish1 && state==C1 || (fish2 && (state==F2 || state==C2)) ||
		         (fish3 && (state==F3 || state==C3)) || (fish4 && (state==F4 || state==C4)))
			rgb = ORANGE; 
		else if (rod || jut || line)
			rgb = GREEN;
		else if (sun && state==W) 
			rgb=YELLOW;
		else if (vCount>=155)
			rgb = BLUE;
		else	
			rgb= WHITE;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign head=vCount>=75 && vCount<=85 && hCount>=(rpos-120) && hCount<=(rpos-100);
	assign torso=vCount>=85 && vCount<=115 && hCount>=(rpos-140) && hCount<=(rpos-80);
	assign larm=vCount>=85 && vCount<=125 && hCount>=(rpos-160) && hCount <=(rpos-140);
	assign rarm=vCount>=85 && vCount<=125 && hCount>=(rpos-80) && hCount <=(rpos-60);
	assign lleg=vCount>=115 && vCount<=155 && hCount>=(rpos-140) && hCount<=(rpos-120);
	assign rleg=vCount>=115 && vCount<=155 && hCount>=(rpos-100) && hCount<=(rpos-80);
	assign buoy=vCount>=145 && vCount<=155 && hCount>=(rpos-150) && hCount<=(rpos-70);
	assign lbuoy=vCount>=135 && vCount<=155 && hCount>=(rpos-170) && hCount<=(rpos-150);
	assign rbuoy=vCount>=135 && vCount<=155 && hCount>=(rpos-70) && hCount<=(rpos-50);
	assign rod=vCount>=75 && vCount<=125 && hCount>=(rpos-60) && hCount<=(rpos-50);
	assign jut=vCount>=75 && vCount<=80 && hCount>=(rpos-50) && hCount<=(rpos-5);
	assign line=vCount>=75 && vCount<=ypos && hCount>=(rpos-5) && hCount<=rpos;
	assign fish1=vCount>=(fypos-10) && vCount<=(fypos+10) && hCount>=fpos && hCount<=(fpos+60);
	assign fish2=vCount>=(fypos-8) && vCount<=(fypos+8) && hCount>=fpos && hCount<=(fpos+40);
	assign fish3=vCount>=(fypos-5) && vCount<=(fypos+5) && hCount>=fpos && hCount<=(fpos+20);
	assign fish4=vCount>=(fypos-3) && vCount<=(fypos+3) && hCount>=fpos && hCount<=(fpos+10);
	assign sun=vCount>=55 && vCount<=95 && hCount>=720 && hCount<=760;
	
	//f1ypos = 470, f2ypos = 380, f3ypos=290, f3ypos=200

	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
			//rough values for center of screen
			rpos<=450;
			ypos<=155;
			fpos<=798;
			fypos<=470;
			state<=F1;
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			case(state)

				F1:
				begin 
					fpos<=fpos-2;
					if (fpos==144) 
						fpos<=798;
					if (ypos<=466)
						ypos<=ypos+4;
					if (up && rpos>=fpos && rpos<=(fpos+15) && ypos>=(fypos-10) && ypos<=(fypos+10))
						state<=C1;
					if(right) begin
						if(rpos<=798) 
							rpos<=rpos+2;
					end
					else if(left) begin
						if(rpos>=312)
							rpos<=rpos-2;
					end
				end

				C1:
				begin
					if (fypos<=105)
						state<=F2;
						fpos<=798;
						fypos<=380;
					if(up) begin
						fypos<=fypos-2;
						ypos<=ypos-2;
					end
				end 

				F2: 
				begin
					fypos <= 380;
					fpos<=fpos-2;
					if(fpos==144)
						fpos<=798;
					if (ypos<=376)
						ypos<=ypos+4;
					if (up && rpos>=fpos && rpos<=(fpos+10) && ypos>=(fypos-8) && ypos<=(fypos+8))
						state<=C2;
					if(right) begin
						if(rpos<=798) 
							rpos<=rpos+2;
					end
					else if(left) begin
						if(rpos>=312)
							rpos<=rpos-2;
					end
				end 

				C2: 
				begin
					if (fypos<=105)
						state<=F3;
						fpos<=798;
						fypos<=290;
					if(up) begin
						fypos<=fypos-2;
						ypos<=ypos-2;
					end
				end
					
				F3: 
				begin
					fypos <= 290;
					fpos<=fpos-2;
					if(fpos==144)
						fpos<=798;
					if (ypos<=286)
						ypos<=ypos+4;
					if (up && rpos>=fpos && rpos<=(fpos+5) && ypos>=(fypos-5) && ypos<=(fypos+5))
						state<=C3;
					if(right) begin
						if(rpos<=798) 
							rpos<=rpos+2;
					end
					else if(left) begin
						if(rpos>=312)
							rpos<=rpos-2;
					end
				end 

				C3: 
				begin
					if (fypos<=105)
						state<=F4;
						fpos<=798;
						fypos<=200;
					if(up) begin
						fypos<=fypos-2;
						ypos<=ypos-2;
					end
				end	

				F4: 
				begin
					fypos <= 200;
					fpos<=fpos-2;
					if(fpos==144)
						fpos<=798;
					if (ypos<=296)
						ypos<=ypos+4;
					if (up && rpos>=fpos && rpos<=(fpos+3) && ypos>=(fypos-3) && ypos<=(fypos+3))
						state<=C4;
					if(right) begin
						if(rpos<=798) 
							rpos<=rpos+2;
					end
					else if(left) begin
						if(rpos>=312)
							rpos<=rpos-2;
					end
				end 

				C4: 
				begin
					if (fypos<=105)
						state<=W;
					if(up) begin
						fypos<=fypos-2;
						ypos<=ypos-2;
					end
				end	

				W: 
				begin
					if (up || down || right || left)
						state<=F1;
				end 
			endcase
			
		end
	end
	

	
	
endmodule
