`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
   );
   
	wire green_block;
	wire red_triangle;
	wire blue_circle; 
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] gxpos, gypos, rxpos, rypos, bxpos, bypos;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter BLUE  = 12'b0000_0000_1111;
	parameter WHITE = 12'b1111_1111_1111;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (red_triangle) 
			rgb = RED; 
		else if (green_block)
			rgb = GREEN;
		else if (blue_circle)
			rgb = BLUE;
		else	
			rgb= WHITE;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign green_block=vCount>=(gypos-10) && vCount<=(gypos+10) && hCount>=(gxpos-5) && hCount<=(gxpos+5);
	assign red_triangle=vCount>=(rypos-10) && vCount<=(2*(hCount-rxpos)+5) && vcount<=(-2*(hCount-rxpos)+5);
	assign blue_circle=vCount<=((5-(hCount-bxpos))**(1/2)+bypos) && vCount>=(-(5-(hCount-bxpos))**(1/2)+bypos);
	
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
			//rough values for center of screen
			gxpos<=149;
			gypos<=45;
			rxpos<=788;
			rypos<=525;
			bxpos<=450;
			bypos<=300;
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			if(right) begin
				rxpos<=rxpos+2; //change the amount you increment to make the speed faster 
				gxpos<=gxpos+2;
				bxpos<=bxpos+2;

				if(gxpos==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					gxpos<=150;
				if(rxpos==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					rxpos<=150;
				if(bxpos==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					bxpos<=150;
			end
			else if(left) begin
				gxpos<=gxpos-2;
				rxpos<=rxpos-2;
				bxpos<=bxpos-2;
				if(gxpos==150)
					gxpos<=800;
				if(rxpos==150)
					rxpos<=800;
				if(bxpos==150)
					bxpos<=800;
			end
			else if(up) begin
				gypos<=gypos-2;
				rypos<=rypos-2;
				bypos<=bypos-2;
				if(gypos==34)
					gypos<=514;
				if(rypos==34)
					rypos<=514;
				if(bypos==34)
					bypos<=514;
			end
			else if(down) begin
				rypos<=rypos+2;
				gypos<=gypos+2;
				bypos<=bypos+2;
				if(rypos==514)
					rypos<=34;
				if(gypos==514)
					gypos<=34;
				if(bypos==514)
					bypos<=34;
			end
		end
	end
	

	
	
endmodule
