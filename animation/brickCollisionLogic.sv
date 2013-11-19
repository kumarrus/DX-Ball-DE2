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
	reg [7:0] topLeft_X, topRight_X;
	reg [6:0] topLeft_Y, bottomLeft_Y;
	reg [3:0] blockCol, blockRow;
	reg [7:0] blockAddr
	
	always@(*) // 
	begin
		topLeft_X = posX;
		topRight_X = posX + (2*ballRaduis) - 1;
		topLeft_Y = posY;
		bottomLeft_Y = posY + (2*ballRaduis) - 1;
		if(enable == 1'b1 && (posY >= 7'd0 && posY <= 7'd20)) 
		begin
			blockCol = posX[7:4];
			if(posY <= 7'd10)
			begin
				blockRow = 4'd0;
			end
			else if(posY > 7'd10 && posY <= 7'd20)
			begin
				blockRow = 4'd1;
				blockAddr = (boxesPerRow * blockRow) + blockCol;
			end
			
			//COLLISON WITH LEFT/RIGHT
			case(RIGHT)
				1'b1: begin
							//COMPARE RIGHT BLOCK
							if(topRight_X == 16*(blockCol+1) - 1) // It is hitting the left edge of the next block
							begin
								collision = 1'b1;
								RIGHT = 1'b0;
								blockAddr = (boxesPerRow * blockRow) + blockCol;
							end
						end
				1'b0: begin
							if(topLeft_X == 16*(blockCol)) // It is hitting the right edge of the next block
							begin
								collision = 1'b1;
								RIGHT = 1'b1;
							end
						end
			endcase
			
			//COLLISON WITH UP/DOWN
			case(DOWN)
				1'b1: begin
							 if(bottomLeft_Y == 10*(blockRow+1) - 1) // It is hitting the top edge of the next block
							 begin
								 collision = 1'b1;
								 DOWN = 1'b0;
							 end
						 end
				1'b0: begin
							 if(topLeft_Y == 10*(blockRow)) // It is hitting the bottom edge of the next block
							 begin
								 collision = 1'b1;
								 DOWN = 1'b1;
							 end
							 else if(topLeft_Y == 10*(blockRow+1)) // It is hitting the bottom edge of the next block
							 begin
								 collision = 1'b1;
								 DOWN = 1'b1;
							 end
						 end
			endcase
			/*
			// Approaching from CORNERS 
			else if( (posX == (tempX - 1) || posX == (tempX + brickLength + 1)) && 
					(posY == (tempY - 1) || posY == (tempY + brickHeight + 1)) )
			begin
			
			end
			*/
		end
	end

endmodule