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
	parameter ball_Radius = 2;
	parameter maxX = 159;
	parameter maxY = 119;
	parameter paddleLength = 20;
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
	reg [7:0] oldPaddleX;
	reg [7:0] paddleX = 'd100;
	
	/* Send proper values to mux */
	always @ (posedge clk) begin
		
		if (object == ballObj) begin
			 newX = newPosX;
			 newY = newPosY;
			 oldX = oldPosX;
			 oldY = oldPosY;
			 sizeX = 2 * ball_Radius;
			 sizeY = 2 * ball_Radius;
		end else if (object == paddleObj) begin
			 newX = paddleX;
			 newY = 7'b1110011;
			 oldX = oldPaddleX;
			 oldY = 7'b1110011;
			 sizeX = paddleLength;
			 sizeY = 1'b1;
		end /*else begin
			 newX = 8'b0;
			 newY = 7'b1110011;
			 oldX = 8'b0;
			 oldY = 7'b1110011;
			 sizeX = 8'b0;
			 sizeY = 7'b0;	
		end */
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
					
				//if((newPosY) >= (119-4)) begin //collide with bottom
				if ( ((newPosX + ball_Radius) > paddleX) && ((newPosX + ball_Radius) < (paddleX + paddleLength)) ) 
				begin //touches paddle
					DOWN <= 1'b0;
				end
				//end //end collide with bottom
				
				if((newPosY) <= 1) //collide with top
					DOWN <= 1'b1;
				
				if(RIGHT) begin
					oldPosX <= newPosX;
					newPosX <= newPosX + V_x;
				end else begin
					oldPosX <= newPosX;
					newPosX <= newPosX - V_x;
				end if(DOWN) begin
					oldPosY <= newPosY;
					newPosY <= newPosY + V_y;
				end else begin
					oldPosY <= newPosY;
					newPosY <= newPosY - V_y;
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
		else 
			begin
				startPlot <= 1'b0;
				//object = 2'b00;
				count = count + 1;
			end
	end
	
endmodule
