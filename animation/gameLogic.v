module gameLogic
	(
		clk,
		newX,
		newY,
		oldX,
		oldY,
		sizeX,
		sizeY,
		startPlot
	);
	
	param ballCyclesToUpdate = 5000000;
	param paddleCyclesToUpdate = 2500000;
	param ball_Radius = 2;
	param maxX = 159;
	param maxY = 119;
	param paddleLength = 16;
	param ballObj = 2'b00;
	param paddleObj = 2'b01;
	param blockObj = 2'b10;
	param noObj = 2'b11;
	
//------------Input Ports--------------
	input clk;
//----------Output Ports--------------
	
	output [7:0] newX;
	output [6:0] newY;
	output [7:0] oldX;
	output [6:0] oldY;
	output [7:0] sizeX;
	output [6:0] sizeY;
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
	reg [7:0] oldPaddleX;
	reg [7:0] paddleX = 'd100;
	

	always @ (*) begin

	if (object == ballObj) begin
		assign newX = new_posX;
		assign newY = new_posY;
		assign oldX = old_posX;
		assign oldY = old_posY;
		assign sizeX = ball_Radius;
		assign sizeY = ball_Radius;
	end else if (object == paddleObj) begin
		assign newX = paddleX;
		assign newY = 7'b0000010;
		assign oldX = oldPaddlEX;
		assign oldY = 7'b0000010;
		assign sizeX = paddleLength;
		assign sizeY = 1'b1;
	end else begin
		assign newX = paddleX;
		assign newY = 7'b0000010;
		assign oldX = oldPaddleX;
		assign oldY = 7'b0000010;
		assign sizeX = paddleLength;
		assign sizeY = 1'b1;
	
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
					else if ( ((new_posX + 2 * ball_Radius) > paddleX) && RIGHT)
						RIGHT <= ~RIGHT;
					else if ( (new_posX < (paddleX + paddleLength)) && ~RIGHT)
						RIGHT <= ~RIGHT;
				end
				if((new_posY) <= 1) begin
					DOWN <= 1'b1;
				if(RIGHT) begin
					old_posX <= new_PosX;
					new_posX <= new_posX + V_x;
				end else begin
					old_PosX <= new_PosX;
					new_posX <= new_posX - V_x;
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
