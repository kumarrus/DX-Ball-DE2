module brickCollisionLogic
	(
		// INPUT
		enable,
		posX,
		posY,
		bricks_x,
		bricks_y,
		brickLength,
		brickHeight,
		//OUTPUT
		collision,
		DOWN,
		RIGHT
	);
	
	input enable;
	input [7:0] posX;
	input [6:0] posY;
	input [7:0] bricks_x [1:0];
	input [6:0] bricks_y [1:0];
	input [7:0] brickLength;
	input [6:0] brickHeight;
	
	output reg collision, DOWN, RIGHT;

	reg [7:0] tempX;
	reg [6:0] tempY;
	integer count = 1'b0;
	
	always@(*) // 
	begin
		topLeft_X = posX;
		topLeft_Y = posY;
		topRight_X = posX + (2*ballRaduis) - 1;
		topRight_Y = posY;
		bottomLeft_X = posX;
		bottomLeft_Y = posY + (2*ballRaduis) - 1;
		bottomRight_X = posX + (2*ballRaduis) - 1;
		bottomRight_Y = posY + (2*ballRaduis) - 1;
		if(enable == 1'b1 && (posY >= 7'd0 && posY <= 7'd20)) 
		begin
			blockCol = posX[7:4];
			if(posY <= 7'd10)
			begin
				blockRow = 4'd0;
				blockAddr = (boxesPerRow * blockRow) + blockCol;
			end
			else if(posY > 7'd10 && posY <= 7'd20)
			begin
				blockRow = 4'd1;
				blockAddr = (boxesPerRow * blockRow) + blockCol;
			end
			
			//COLLISON WITH LEFT/RIGHT
			case(RIGHT)
				1'b1: begin
						
						end
				1'b0:
			endcase
			
			//COLLISON WITH DOWN/UP
			case(DOWN)
				7'd10: begin
						 if(blockState[])
						 end
				7'd20:
			endcase
			
			while(count < 4 && collision == 1'b0)
			begin
					tempX = ;
					tempY = bricks_y[count];
					count = count + 1;
					
					if(posX >= tempX && posX <= (tempX + brickLength)) // Approaching from UP or DOWN
					begin
						if(posY == tempY-1) // Approaching from UP
						begin
							collision = 1'b1;
							DOWN = 1'b0;
						end
						else if(posY == (tempY + brickHeight + 1)) // Approaching from DOWN
						begin
							collision = 1'b1;
							DOWN = 1'b1;
						end
					end
					if(brickStaus[])
					else if(posY >= tempY && posY <= (tempY + brickHeight)) // Approaching from LEFT or RIGHT
					begin
						if(posX == tempX-1) // Approaching from LEFT
						begin
							collision = 1'b1;
							RIGHT = 1'b0;
						end
						else if(posX == (tempX + brickLength + 1)) // Approaching from RIGHT
						begin
							collision = 1'b1;
							RIGHT = 1'b1;
						end
					end
					/*
					// Approaching from CORNERS 
					else if( (posX == (tempX - 1) || posX == (tempX + brickLength + 1)) && 
							(posY == (tempY - 1) || posY == (tempY + brickHeight + 1)) )
					begin
					
					end
					*/
			end
		end
	end

endmodule