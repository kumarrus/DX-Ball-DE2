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
                object,
					 userStart,
					 userReset,
					 gameOver,
					 LED
        );
        
        parameter ballCyclesToUpdate = 750000;
        parameter paddleCyclesToUpdate = 2250000;
        parameter brickCyclesToUpdate = 1500000;
        parameter ball_Radius = 2;
        parameter boxesPerRow = 10;
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
			parameter numRows = 2;
			parameter paddleSpeedZone = 5;
        
//------------Input Ports--------------
        input clk;
        input moveLeft;
        input moveRight;
		  input userStart;
		  input gameOver;
		  input userReset;
//----------Output Ports--------------
        
        output reg [7:0] newX = 'b0;
        output reg [6:0] newY = 'b0;
        output reg [7:0] oldX = 'b0;
        output reg [6:0] oldY = 'b0;
        output reg [7:0] sizeX = 'b0;
        output reg [6:0] sizeY = 'b0;
        output reg [1:0] object = 'b11;
        
        output reg startPlot;
		  output [17:14]LED;
		  assign LED = state;
//------------Internal Variables--------
        integer count = 0;
        reg [7:0] V_x = 8'b1; // Velocity x
        reg [6:0] V_y = 7'b1; // Velocity y
        reg RIGHT = 1'b1;
        reg DOWN = 1'b0;
        reg [7:0] newPosX = 8'b00110011; // Start x coordinate
        reg [6:0] newPosY = 7'b1110101; // Start y coordinate
        reg [7:0] oldPosX = 8'b00110011;
        reg [6:0] oldPosY = 7'b1110101;
        reg [7:0] oldPaddleX = 7'b1110101;
        reg [7:0] paddleX = 'd100;
        reg [6:0] paddleY = 7'b1110101; // paddle Y location : 117
        //reg [7:0] newPosXCentre;
		  //reg [7:0] newPosXRight;
		  //reg [6:0] newPosYCentre;
		  //reg [6:0] newPosYBottom;
        reg [7:0]topLeft_X, topRight_X;
        reg [6:0]topLeft_Y, bottomLeft_Y;
        reg [3:0] blockCol, blockRow;
        reg [14:0] blockAddr;
        reg collision = 1'b0;
		  reg [3:0] state;
		  reg [5:0] blockIndex = 0;
		  reg gameStarted = 0;
		reg [boxesPerRow*numRows-1:0] brickLayout = 'b11111111111111111111;
		
	always@(*)
	begin
		
	end


parameter 	STATE_GAMESTART = 4'b0000,	
				STATE_INITIALIZE = 4'b0001,
				STATE_RESET = 4'b0010,
				STATE_DRAWBLOCKS = 4'b0011,
				STATE_DRAWBALL = 4'b0100,
				STATE_DRAWPADDLE = 4'b0101,
				STATE_IDLE = 4'b0110,
				STATE_START = 4'b0111;
				
parameter maxBlockIndex = 'd2;


always @ (posedge clk) begin
	case (state)
		STATE_GAMESTART : begin
			if (gameStarted == 0) begin
				gameStarted <= 1;
				state <= STATE_INITIALIZE;
			end else begin
				if (userStart) begin
					state <= STATE_INITIALIZE;
					count <= 0;
				end
			end
		end
		
		STATE_INITIALIZE : begin
			//initialize data here
			state <= STATE_RESET;
		end
		
		STATE_RESET : begin
			//draw noObj for x cycles
			if (count == 0) begin
				count <= count + 1;
				newX = 0;
				newY = 0;
				oldX = 0;
				oldY = 0;
				sizeX = maxX + 1;
				sizeY = maxY + 1;
				object = noObj;
				startPlot <= 1;
				//draw noObj, size = all screen, x = 0, y = 0
			end else if (count == 'd50000) begin
				state <= STATE_DRAWBLOCKS;
				count <= 0;
				blockCol <= 0;
				blockRow <= 0;
			end else begin
				count <= count + 1'b1;
				startPlot <= 0;
			end
			
		end
		
		STATE_DRAWBLOCKS : begin
			//if (blockIndex > maxBlockIndex) begin
			//	state <= STATE_DRAWBALL;
			//end else begin
				if (count == 0) begin
					count <= count + 1;
					newX = boxLength * (blockCol);
					newY = boxHeight * (blockRow);
					oldX = boxLength * (blockCol);
					oldY = boxHeight * (blockRow);
					sizeX = boxLength;
					sizeY = boxHeight;
					if (brickLayout[blockCol + (blockRow * boxesPerRow)] == 1'b1)
						object = blockObj;
					else
						object = noObj;
					startPlot <= 1;
				end else if (count == 'd1000) begin //time to draw one block
					if (blockCol == 9) begin
						blockCol = 0;
						if (blockRow == 1)
							state <= STATE_DRAWBALL;
						else
							blockRow = blockRow + 1;
					end
					else
						blockCol = blockCol + 1;
					count <= 0;
				end else begin
					count <= count + 1;
					startPlot <= 0;
				end
			//end
		end
		
		STATE_DRAWBALL : begin
			if (count == 0) begin
				 object = ballObj;
				 newX = newPosX;
				 newY = newPosY;
				 oldX = oldPosX;
				 oldY = oldPosY;
				 sizeX = 2 * ball_Radius;
				 sizeY = 2 * ball_Radius;
				 startPlot <= 1;
				count <= count + 1;
			end else if (count == 'd100) begin
				state <= STATE_DRAWPADDLE;
				count <= 0;
			end else begin
				count <= count + 1;
				startPlot <= 0;
			end	
		end
		
		STATE_DRAWPADDLE : begin
			if (count == 0) begin
				 newX = paddleX;
				 newY = paddleY;
				 oldX = oldPaddleX;
				 oldY = paddleY;
				 sizeX = paddleLength;
				 sizeY = paddleHeight;
				 object = paddleObj;
				 startPlot <= 1;
				count <= count + 1;
			end else if (count == 'd200) begin
				state <= STATE_IDLE;
				count <= 0;
			end else
				count <= count + 1;
				startPlot <= 0;
		end
		
		STATE_IDLE: begin
			if (userStart) begin
				state <= STATE_START;
				count <= 0;
			end
		end
		
		STATE_START: begin
			
			if (gameOver || userReset) begin
				state <= STATE_GAMESTART;
				count <= 0;
			end else begin
			
			
			if(count == ballCyclesToUpdate) 
			begin
				object = ballObj;
				//count = 0;
				count = count + 1;
				if((newPosX) >= (maxX - (2*ball_Radius + V_x - 1)-1)) //collide with right wall
					RIGHT <= 1'b0;
				if((newPosX) <= V_x) //collide with left wall
					RIGHT <= 1'b1;
					
				if((newPosY) == (paddleY-1-(2*ball_Radius))) begin //collide with paddle
					if ( (newPosX >= paddleX + paddleSpeedZone) && ((newPosX + 2*ball_Radius) < (paddleX + paddleLength-paddleSpeedZone))) 
					begin //touches paddle
						DOWN <= 1'b0;
						V_x = 8'd1;
					end
					else if((newPosX + 2*ball_Radius) >= paddleX-1 && newPosX < (paddleX + paddleSpeedZone))
					begin
						DOWN <= 1'b0;
						RIGHT <= 1'b0;
						V_x = 8'd1;
					end
					else if((newPosX + 2*ball_Radius) >= (paddleX + paddleLength - paddleSpeedZone) && newPosX <= (paddleX + paddleLength))
					begin
						DOWN <= 1'b0;
						RIGHT <= 1'b1;
						V_x = 8'd1;
					end
				end //end collide with bottom
				
				if((newPosY) <= V_y+1) //collide with top
					DOWN <= 1'b1;
				
				if(RIGHT) begin
					oldPosX <= newPosX;
					newPosX <= newPosX + V_x;
					//newPosXCentre <= newPosX + V_x + ball_Radius;
					//newPosXRight <= newPosX + V_x + 2 * ball_Radius;					
				end else begin
					oldPosX <= newPosX;
					newPosX <= newPosX - V_x;
					//newPosXCentre <= newPosX - V_x + ball_Radius;
					//newPosXRight <= newPosX - V_x + 2 * ball_Radius;
				end if(DOWN) begin
					oldPosY <= newPosY;
					newPosY <= newPosY + V_y;
					//newPosYCentre <= newPosY + V_y + ball_Radius;
					//newPosYBottom <= newPosY + V_y + 2 * ball_Radius;
				end else begin
					oldPosY <= newPosY;
					newPosY <= newPosY - V_y;
					//newPosYCentre <= newPosY - V_y + ball_Radius;
					//newPosYBottom <= newPosY - V_y + 2 * ball_Radius;
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
			end //end if update paddle
			
			else if (count == brickCyclesToUpdate)
			begin
				count = count + 1;
				object = noObj;
				//Test Logic - stage 2
				topLeft_X = newPosX;
				topRight_X = newPosX + (2*ball_Radius) - 1;
				topLeft_Y = newPosY;
				bottomLeft_Y = newPosY + (2*ball_Radius) - 1;

				if((newPosY >= 7'd0 && newPosY <= 7'd20)) 
				begin
					blockCol = newPosX[7:4];
					if(newPosY < 7'd10)
					begin
						blockRow = 4'd0;
					end
					else if(newPosY >= 7'd10 && newPosY < 7'd20)
					begin
						blockRow = 4'd1;
						//blockAddr = (boxesPerRow * blockRow) + blockCol;
					end
					else
						blockRow = 4'd2;
						
					blockAddr = (boxesPerRow * blockRow) + blockCol;
					//#5
					//COLLISON WITH LEFT/RIGHT
					case(RIGHT)
						1'b1: begin
							//COMPARE RIGHT BLOCK
							if(topRight_X == (16*(blockCol+1)-1)  && ~(blockCol == 4'd9) && brickLayout[blockAddr+1] == 1'b1) // It is hitting the left edge of the next block
							begin
								//collision = 1'b1;
								RIGHT = 1'b0;
								blockCol = blockCol+1;
								brickLayout[blockAddr+1] = 1'b0;
								//blockAddr = (boxesPerRow * blockRow) + blockCol;
								startPlot <= 1'b1;
							end
						end
						1'b0: begin
							if(topLeft_X == 16*(blockCol) && ~(blockCol == 4'd0) && brickLayout[blockAddr-1] == 1'b1) // It is hitting the right edge of the next block
							begin
								//collision = 1'b1;
								RIGHT = 1'b1;
								blockCol = blockCol-1;
								brickLayout[blockAddr-1] = 1'b0;
								startPlot <= 1'b1;
							end
						end
					endcase
					//#10
					//COLLISON WITH UP/DOWN
					case(DOWN)
						1'b1: begin
							 if(bottomLeft_Y == (10*(blockRow+1)-1) && ~(blockRow == 4'd2) && brickLayout[blockAddr+boxesPerRow] == 1'b1) // It is hitting the top edge of the next block
							 begin
								 //collision = 1'b1;
								 DOWN = 1'b0;
								 blockRow = blockRow+1;
								 brickLayout[blockAddr+boxesPerRow] = 1'b0;
								 startPlot <= 1'b1;
							 end
						end
						1'b0: begin
						 if(topLeft_Y == 10*(blockRow) && ~(blockRow == 4'd0) && brickLayout[blockAddr-boxesPerRow] == 1'b1) // It is hitting the bottom edge of the next block
						 begin
							 //collision = 1'b1;
							 DOWN = 1'b1;
							 blockRow = blockRow-1;
							 brickLayout[blockAddr-boxesPerRow] = 1'b0;
							 startPlot <= 1'b1;
						 end
					end
					endcase
				end
			end	
		else 
			begin
				startPlot <= 1'b0;
				//object = 2'b00;
				count = count + 1;
			end		
		
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
		end else if (object == noObj) begin		
			//if box in in second row, then make necessary adjostments to x position (essentially boxLength * (boxToDelete % boxesPerRow)
			//if box is in second row, then boxToDelete >= boxesPerRow -- adjust y position
			//newX = boxLength * (boxToDelete - ((boxToDelete >= boxesPerRow) * boxesPerRow));
			//newY = boxHeight * (boxToDelete >= boxesPerRow);
			//oldX = boxLength * (boxToDelete - ((boxToDelete >= boxesPerRow) * boxesPerRow));
			//oldY = boxHeight * (boxToDelete >= boxesPerRow);
			newX = boxLength * (blockCol);
			newY = boxHeight * (blockRow);
			oldX = boxLength * (blockCol);
			oldY = boxHeight * (blockRow);
			sizeX = boxLength;
			sizeY = boxHeight;
		end	
							
		end //end if gameOver ||
	
end
		
	endcase
end

endmodule