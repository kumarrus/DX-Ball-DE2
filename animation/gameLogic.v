module gameLogic
	(
		moveLeft,
		moveRight,
		clk,
		newX,
		newY,
		oldX,
		oldY,
		sizeX,
		sizeY,
		startPlot,
		object
	);
	
	parameter ballCyclesToUpdate = 2500000;
	parameter paddleCyclesToUpdate = 5000000;
	parameter brickCyclesToUpdate = 3000000;
	parameter ball_Radius = 2;
	parameter boxesPerRow = 16;
	parameter maxX = 159;
	parameter maxY = 119;
	parameter paddleLength = 20;
	parameter paddleHeight = 1;
	parameter boxLength = 16;
	parameter boxHeight = 10;
	parameter ballObj = 2'b00;
	parameter paddleObj = 2'b01;
	parameter blockObj = 2'b10;
	parameter noObj = 2'b11;
	
//------------Input Ports--------------
	input clk;
	input moveLeft;
	input moveRight;
//----------Output Ports--------------
	
	output reg [7:0] newX = 'b0;
	output reg [6:0] newY = 'b0;
	output reg [7:0] oldX = 'b0;
	output reg [6:0] oldY = 'b0;
	output reg [7:0] sizeX = 'b0;
	output reg [6:0] sizeY = 'b0;
	output reg [1:0] object = 'b0;
	
	output reg startPlot;
//------------Internal Variables--------
	integer count = 0;
	reg [7:0] V_x = 8'b1; // Velocity x
	reg [6:0] V_y = 7'b1; // Velocity y
	reg RIGHT = 1'b1;
	reg DOWN = 1'b1;
	reg [7:0] newPosX = 8'b00110011; // Start x coordinate
	reg [6:0] newPosY = 7'b0000100; // Start y coordinate
	reg [7:0] oldPosX;
	reg [6:0] oldPosY;
	reg [7:0] newPosXCentre;
	reg [7:0] newPosXRight;
	reg [6:0] newPosYCentre;
	reg [6:0] newPosYBottom;
	reg [7:0] oldPaddleX;
	reg [7:0] paddleX = 'd100;
	reg [6:0] paddleY = 7'b1110101; // paddle Y location : 117
	
	/* Send proper values to mux */
	always @ (*) begin
		
		if (object == ballObj) begin
			 newX = newPosX;
			 newY = newPosY;
			 oldX = oldPosX;
			 oldY = oldPosY;
			 sizeX = 2 * ball_Radius;
			 sizeY = 2 * ball_Radius;
		end else if (object == paddleObj) begin
			 newX = paddleX;
			 newY = paddleY;
			 oldX = oldPaddleX;
			 oldY = paddleY;
			 sizeX = paddleLength;
			 sizeY = paddleHeight;
		end else if (object == blockObj) begin		
			//if box in in second row, then make necessary adjostments to x position (essentially boxLength * (boxToDelete % boxesPerRow)
			//if box is in second row, then boxToDelete >= boxesPerRow -- adjust y position
			newX = boxLength * (boxToDelete - ((boxToDelete >= boxesPerRow) * boxesPerRow));
			newY = boxHeight * (boxToDelete >= boxesPerRow);
			oldX = boxLength * (boxToDelete - ((boxToDelete >= boxesPerRow) * boxesPerRow));
			oldY = boxHeight * (boxToDelete >= boxesPerRow);
			sizeX = boxLength;
			sizeY = boxHeight;
		end
	end

		//CLOCK
	always@(posedge clk) begin
	
		//IF WE CAN UPDATE BALL
		if(count == ballCyclesToUpdate) 
		begin
				object = ballObj;
				//count = 0;
				count = count + 1;
				if((newPosX) >= (159-4)) //collide with right wall
					RIGHT <= 1'b0;
				if((newPosX) <= 1) //collide with left wall
					RIGHT <= 1'b1;
					
				if((newPosY) >= (paddleY-1-(2*ball_Radius))) begin //collide with paddle
					if ( ((newPosX + ball_Radius) > paddleX) && ((newPosX + ball_Radius) < (paddleX + paddleLength)) ) 
					begin //touches paddle
						DOWN <= 1'b0;
					end
				end //end collide with bottom
				
				if((newPosY) <= 1) //collide with top
					DOWN <= 1'b1;
				
				if(RIGHT) begin
					oldPosX <= newPosX;
					newPosX <= newPosX + V_x;
					newPosXCentre <= newPosX + V_x + ballRadius;
					newPosXRight <= newPosX + V_x + 2 * ballRadius;					
				end else begin
					oldPosX <= newPosX;
					newPosX <= newPosX - V_x;
					newPosXCentre <= newPosX - V_x + ballRadius;
					newPosXRight <= newPosX - V_x + 2 * balRadius;
				end if(DOWN) begin
					oldPosY <= newPosY;
					newPosY <= newPosY + V_y;
					newPosYCentre <= newPosY + V_y + ballRadius;
					newPosYBottom <= newPosY + V_y + 2 * ballRadius;
				end else begin
					oldPosY <= newPosY;
					newPosY <= newPosY - V_y;
					newPosYCentre <= newPosY - V_y + ballRadius;
					newPosYBottom <= newPosY - V_y + 2 * ballRadius;
				end
				
				startPlot <= 1'b1;
			end
		
		else if (count == paddleCyclesToUpdate)
			begin
				count = 0;
				object = paddleObj;
				//oldPaddleX <= paddleX;
				//paddleX <= paddleX - 1'b1;
				//startPlot <= 1'b1;
				
				if (moveLeft) begin
					if (!(paddleX < 1)) begin
						oldPaddleX <= paddleX;
						paddleX <= paddleX - V_x;
						//startPlot <= 1'b1;
					end
				end else if (moveRight) begin 
					if ((maxX >= (paddleX + paddleLength) ) ) begin
						oldPaddleX <= paddleX;
						paddleX <= paddleX + V_x;
						//startPlot <= 1'b1;
					end
				end
				startPlot <= 1'b1;
				
			end
		else if (count == brickCyclesToUpdate)
			begin
				count = count + 1;
				object = blockObj;
				startPlot <= 1'b1;
			end
		else 
			begin
				startPlot <= 1'b0;
				//object = 2'b00;
				count = count + 1;
			end
	end
	
endmodule
/*
module brick_collision_logic
	(
		// INPUT
		enable,
		posX,
		posY,
		bricks_x,
		bricks_y,
		//OUTPUT
		collision,
		DOWN,
		RIGHT
	);
	
	input enable;
	input [7:0] posX;
	input [6:0] posY;
	input [7:0] bricks_x [19:0];
	input [6:0] bricks_y [19:0];
	
	output reg collision, DOWN, RIGHT;

	reg [7:0] BrickX [19:0];
	reg [6:0] BrickY [19:0];
	reg [7:0] tempX;
	reg [6:0] tempY;
	integer count = 1'b0;
	
	always@(enable) // 
	begin
		if(enable == 1'b1) 
		begin
			BrickX = bricks_x;
			BrickY = bricks_y;
			count = 0;
			while(count < 20 && collision == 1'b0)
			begin
					tempX = BrickX[0];
					tempY = BrickY[0];
					BrickX <= {BrickX[0],BrickX[19:1]};
					BrickY <= {BrickY[0],BrickY[19:1]};
					count = count + 1;
					//TOP AND LEFT
					//BOTTOM AND RIGHT
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
					
			end
		end
	end

endmodule
*/