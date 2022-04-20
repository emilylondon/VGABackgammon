`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
   );

	wire head; wire larm; wire rarm; wire lleg; wire rleg; wire torso; wire rod; wire jut; wire line; 
	wire fish1; wire fish2; wire fish3; wire fish4; 
	wire buoy; wire lbuoy; wire rbuoy;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] rpos, ypos;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter BLUE  = 12'b0000_0000_1111;
	parameter WHITE = 12'b1111_1111_1111;
	parameter ORANGE = 12'b1110_1001_0100;
	parameter BROWN = 12'b0110_0010_0001;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (head || larm || rarm || lleg || rleg || torso) 
			rgb = RED; 
		else if (buoy || rbuoy || lbuoy)
			rgb = BROWN;
		else if (rod || jut || line)
			rgb = GREEN;
		else if ((fish1 && ypos>=425 && ypos<515) || (fish2 && ypos>=335 && ypos<425) ||
		         (fish3 && ypos>=245 && ypos<335) || (fish4 && ypos>=155 && ypos<245))
			rgb = ORANGE; 
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
	assign rod=vCount>=75 && vCount<=155 && hCount>=(rpos-60) && hCount<=(rpos-50);
	assign jut=vCount>=75 && vCount<=80 && hCount>=(rpos-50) && hCount<=(rpos-5);
	assign line=vCount>=75 && vCount<=ypos && hCount>=(rpos-5) && hCount<=rpos;
	assign fish1=vCount>=460 && vCount<=480 && hCount>=fpos && hCount<=(fpos+60);
	assign fish2=vCount>=372 && vCount<=388 && hCount>=fpos && hCount<=(fpos+40);
	assign fish3=vCount>=285 && vCount<=295 && hCount>=fpos && hCount<=(fpos+20);
	assign fish4=vCount>=197 && vCount<=203 && hCount>=fpos && hCount<=(fpos+10);
	
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
			//rough values for center of screen
			rpos<=450;
			ypos<=155;
			fpos<=798;
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			fpos<=fpos-2;
			if (fpos==312) 
				fpos=798;
			if(right) begin
				if(rpos<=798) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					rpos<=rpos+2;
			end
			else if(left) begin
				if(rpos>=312)
					rpos<=rpos-2;
			end
			else if(up) begin
				if (ypos>=155)
					ypos<=ypos-2;
			end
			else if(down) begin
				if(ypos<=514)
					ypos<=ypos+2;
			end
		end
	end
	

	
	
endmodule
