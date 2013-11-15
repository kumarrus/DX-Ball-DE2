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
	reg [7:0] new_posX = 8'b00110011; // Start x coordinate
	reg [6:0] new_posY = 7'b0000100; // Start y coordinate
	reg [7:0] old_posX;
	reg [6:0] old_posY;
	reg [7:0] oldPaddleX;
	reg [7:0] paddleX = 'd100;
	

	always @ (*) begin

		if (object == ballObj) begin
			 newX = new_posX;
			 newY = new_posY;
			 oldX = old_posX;
			 oldY = old_posY;
			 sizeX = 2 * ball_Radius;
			 sizeY = 2 * ball_Radius;
		end else if (object == paddleObj) begin
			 newX = paddleX;
			 newY = 7'b0000010;
			 oldX = oldPaddleX;
			 oldY = 7'b0000010;
			 sizeX = paddleLength;
			 sizeY = 1'b1;
		end else begin
			 newX = 8'b0;
			 newY = 7'b0000010;
			 oldX = 8'b0;
			 oldY = 7'b0000010;
			 sizeX = 8'b0;
			 sizeY = 7'b0;	
		end
	end

	always@(posedge clk)
	begin
		//startPlot <= 1'b1;
		if(count == ballCyclesToUpdate) //approx 1/60th of a second
			begin
				object = 2'b00;
				count = 0;
				
				/* UPDATE */
				if((new_posX) >= (159-4))
					RIGHT <= 1'b0;
				if((new_posX) <= 1)
					RIGHT <= 1'b1;
				if((new_posY) >= (119-4)) begin
					DOWN <= 1'b0;
					if ( ((new_posX + ball_Radius) > paddleX) && ((new_posX + ball_Radius) < paddleX) )
						;
					else if ( ((new_posX + 2 * ball_Radius) > paddleX) && RIGHT)
						RIGHT <= ~RIGHT;
					else if ( (new_posX < (paddleX + paddleLength)) && ~RIGHT)
						RIGHT <= ~RIGHT;
				end
				if((new_posY) <= 1) begin
					DOWN <= 1'b1;
				end if(RIGHT) begin
					old_posX <= new_posX;
					new_posX <= new_posX + V_x;
				end else begin
					old_posX <= new_posX;
					new_posX <= new_posX - V_x;
				end
				if(DOWN) begin
					old_posY <= new_posY;
					new_posY <= new_posY + V_y;
				end else begin
					old_posY <= new_posY;
					new_posY <= new_posY - V_y;
				end
				
				startPlot <= 1'b1;
			end
		else if (count == paddleCyclesToUpdate)
			begin
				object = 2'b01;
				count = 0;
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
		else 
			begin
				startPlot <= 1'b0;
				object = noObj;
				count = count + 1;
			end
	end
	
endmodule
