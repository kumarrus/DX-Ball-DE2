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
		startPlot
		object
	);
	
	parameter ballCyclesToUpdate = 5000000;
	parameter paddleCyclesToUpdate = 2500000;
	parameter ball_Radius = 2;
	parameter maxX = 159;
	parameter maxY = 119;
	parameter paddleLength = 16;
	parameter ballObj = 2'b00;
	parameter paddleObj = 2'b01;
	parameter blockObj = 2'b10;
	parameter noObj = 2'b11;
	
//------------Input Ports--------------
	input clk;
	input moveLeft;
	input moveRight;
//----------Output Ports--------------
	
	output reg [7:0] newX;
	output reg [6:0] newY;
	output reg [7:0] oldX;
	output reg [6:0] oldY;
	output reg [7:0] sizeX;
	output reg [6:0] sizeY;
	output reg [1:0] object;
	
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
	reg [7:0] oldPaddleX;
	reg [7:0] paddleX = 'd100;
	
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
			 newY = 7'b1111101;
			 oldX = oldPaddleX;
			 oldY = 7'b1111101;
			 sizeX = paddleLength;
			 sizeY = 1'b1;
		end else begin
			 newX = 8'b0;
			 newY = 7'b1111101;
			 oldX = 8'b0;
			 oldY = 7'b1111101;
			 sizeX = 8'b0;
			 sizeY = 7'b0;	
		end


		//CLOCK
	always@(posedge clk) begin
	
		//IF WE CAN UPDATE BALL
		if(count == ballCyclesToUpdate) begin
				object = 2'b00;
				count = 0;
				
				if((newPosX) >= (159-4)) //collide with right wall
					RIGHT <= 1'b0;
				if((newPosX) <= 1) //collide with left wall
					RIGHT <= 1'b1;
					
				if((newPosY) >= (119-4)) begin //collide with bottom
					if ( ((newPosX + ball_Radius) > paddleX) && ((newPosX + ball_Radius) < paddleX) ) begin //inside paddle
						DOWN <= 1'b0;
					end else if ( ((newPosX + 2 * ball_Radius) > paddleX) && RIGHT)) begin //left edge
						DOWN <= 1'b0;
					end else if ( (newPosX < (paddleX + paddleLength)) && ~RIGHT) begin //right edge
						DOWN <= 1'b0;
					end
				end //end collide with bottom
				
				if((newPosY) <= 1) //collide with top
					DOWN <= 1'b1;
				
				if(RIGHT) begin
					oldPosX <= newPosX;
					newPosX <= newPosX + V_x;
				end else begin
					oldPosX <= newPosX;
					newPosX <= newPosX - V_x;
				if(DOWN) begin
					oldPosY <= newPosY;
					newPosY <= newPosY + V_y;
				end else begin
					oldPosY <= newPosY;
					newPosY <= newPosY - V_y;
				end
				
				startPlot <= 1'b1;
			end
		/*
		else if (count == paddleCyclesToUpdate)
			begin
				object = 2'b01;
				if (moveLeft) begin
					if (!(paddleX == 0)) begin
						oldPaddleX <= paddleX;
						paddleX <= paddleX - 1'b1;
					end
				end else if (moveRight) begin 
					if (!(maxY == (paddleX + paddleLength) ) ) begin
						oldPaddleX <= paddleX;
						paddleX <= paddleX + 1'b1;
					end
				end
				startPlot <= 1'b1;
			end
		*/
		else 
			begin
				startPlot <= 1'b0;
				object = 2'b00;
				count = count + 1;
			end
	end
	
endmodule
