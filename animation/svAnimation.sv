// Animation

module animation
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							//	Push Button[3:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		LEDR
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					//	Button[3:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output [17:0]LEDR;
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the color, x, y and writeEn wires that are inputs to the controller.
	wire writeEn; // PLOT AND BLANK
	wire startPlot;// = ~KEY[1]
	wire [7:0] address; // Address in ROM/RAM
	wire [2:0] color, 
				  drawColor, 
				  eraseColor,
				  drawBall,
				  drawPaddle;
	wire [7:0] pos_x; // x coordinate , start x
	wire [6:0] pos_y; // y coordinate , start y
	wire [7:0] new_posX; // new x coordinate
	wire [6:0] new_posY; // new y coordinate
	wire [7:0] old_posX; // old x coordinate
	wire [6:0] old_posY; // old y coordinate
	wire [7:0] Q_X, Q_Y; // Pixel coordinate of image
	
	wire [7:0] sizeX;
	wire [6:0] sizeY;
	wire objCode;
	
	fsm_draw_logic FSM(
			// INPUTS
			.clk(CLOCK_50),
			.reset(resetn),
			.go(startPlot),
			.eraseColor(eraseColor),
			.drawColor(drawColor),
			.old_posX(old_posX),
			.old_posY(old_posY),
			.new_posX(new_posX),
			.new_posY(new_posY),
			.SIZEOF_X(sizeX),
			.SIZEOF_Y(sizeY),
			// OUTPUTS
			.writeEn(writeEn),
			.address(address),
			.color(color),
			.Q_x(Q_X),
			.Q_y(Q_Y),
			.pos_x(pos_x),
			.pos_y(pos_y));

	gameLogic dxBall
	(
		.moveLeft(~KEY[3]),
		.moveRight(~KEY[2]),
		.clk(CLOCK_50),
		.newX(new_posX),
		.newY(new_posY),
		.oldX(old_posX),
		.oldY(old_posY),
		.sizeX(sizeX),
		.sizeY(sizeY),
		.startPlot(startPlot),
		.object(objCode)
	);
	
	draw_mux colorMux(
		.objCode(objCode),
		.drawBall(drawBall),
		.drawPaddle(drawPaddle),
		.drawColor(drawColor)
	);
	
	//ROM that holds the image of the ball
	newRom myRom(
		.address(address),
		.clock(CLOCK_50),
		.q(drawBall));
	//ROM that holds the image that needs to be chosen while erasing
	//This will be the background of the screen
	newRom2 blankRom(
		.address(address),
		.clock(CLOCK_50),
		.q(eraseColor));
	
	newRom3 paddleRom(
		.address(address),
		.clock(CLOCK_50),
		.q(drawPaddle));
	
	assign LEDR[3:2] = objCode;
	//assign LEDR[15:8] = Q_Y[7:0];

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(pos_x + Q_X),
			.y(pos_y + Q_Y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "blk_bg.mif";
			
	// Put your code here. Your code should produce signals x,y,color and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.

	wire enable,
			collision,
				DOWN,RIGHT;
	wire [7:0]posX, 
					brickLength = 8'b00001010;
						//bricks_x[1:0] = {8'b11110000,8'b11001100};
	wire [6:0]posY, 
					brickHeight = 7'b0000101; 
						//bricks_y[1:0] = {7'b0110110, 7'b0101101};

/*brickCollisionLogic bcl
	(
		// INPUT
		~KEY[1],
		new_posX,
		new_posY,
		{8'b11110000,8'b11001100},
		{7'b0110110, 7'b0101101},
		brickLength,
		brickHeight,
		//OUTPUT
		collision,
		DOWN,
		RIGHT
	);*/
	
endmodule

module draw_mux
	(
		objCode,
		drawBall,
		drawPaddle,
		drawColor
	);
	
	input [1:0] objCode;
	input [2:0] drawBall,drawPaddle;
	output reg [2:0] drawColor;
	
	always@(*)
	begin
		case(objCode)
			2'b00: drawColor = drawBall; // BALL
			2'b01: drawColor = drawPaddle; // PADDLE
			2'b10: drawColor = 3'b100; // BRICK
			2'b11: drawColor = 3'b100; // DRAW NOTHING
		endcase
	end
	
endmodule

module fsm_draw_logic 
	(  // INPUTS
		clk,
		reset,
		go,
		eraseColor,
		drawColor,
		old_posX,
		old_posY,
		new_posX,
		new_posY,
		SIZEOF_X,
		SIZEOF_Y,
		// OUTPUTS
		writeEn,
		address,
		color,
		Q_x,
		Q_y,
		pos_x,
		pos_y
	);
//------------Input Ports--------------
	input clk, reset, go;
	input [2:0] eraseColor, drawColor;
	input [7:0] new_posX; // Start x coordinate
	input [6:0] new_posY; // Start y coordinate
	input [7:0] old_posX;
	input [6:0] old_posY;
	input [8:0] SIZEOF_X;
	input [7:0] SIZEOF_Y;
//----------Output Ports--------------
	output reg writeEn;
	output reg [7:0] address;
	output reg [7:0] Q_x = 8'b0;
	output reg [6:0] Q_y = 7'b0;
	output reg [2:0] color;
	output reg [7:0] pos_x; // Start x coordinate
	output reg [6:0] pos_y; // Start y coordinate
//------------Internal Variables--------
	parameter IDLE = 3'b000,
				 DRAW = 3'b001,
				 ERASE = 3'b010,
				 HSYNC = 3'b011,
				 VSYNC = 3'b100;

	reg [2:0] state = IDLE, next_state = IDLE;
	reg blankEn = 1'b0;
//-------------Code Starts Here-------
//-------------Change state-----------
	always@(posedge clk or negedge reset)
	begin
		if (!reset) 
		  state <= IDLE;
		else
		  state <= next_state;
	end
//-------------Next State Logic--------
	always@(state, go, Q_x, Q_y, SIZEOF_X, SIZEOF_Y, blankEn)
	begin
		case(state)
			IDLE: begin
						//if(blankEn == 1'b1)
						//	next_state = DRAW;
						//else
						//begin
							if(go == 1'b1)
								next_state = ERASE;
							else
								next_state = IDLE;
						//end
					end
			DRAW: begin
						next_state = HSYNC;
					end
			ERASE: begin
						next_state = HSYNC;
					 end
			HSYNC: begin
						 if(Q_x < (SIZEOF_X-1))
							next_state = HSYNC;
						 else
						 begin
							if(Q_y == (SIZEOF_Y - 1))
							begin
								if(blankEn == 1'b1)
									next_state = DRAW;
								else
									next_state = IDLE;
							 end
							 else
								next_state = VSYNC;
						 end
					 end
			VSYNC: begin
						next_state = HSYNC;
					 end
		endcase
	end
//-------------Counter----------------
	always@(posedge clk or negedge reset)
	begin
		if (!reset) 
		begin
			Q_x <= 8'b0;
			Q_y <= 7'b0;
		end
		else 
		begin
			case(next_state)
				IDLE: begin
							writeEn <= 1'b0;
							blankEn <= 1'b0;
							Q_x <= 8'b0;
							Q_y <= 7'b0;
						end
				DRAW: begin
							blankEn <= 1'b0;
							Q_x <= 8'b0;
							Q_y <= 7'b0;
							pos_x <= new_posX;
							pos_y <= new_posY;
						end
				ERASE: begin
							 writeEn <= 1'b1;
							 blankEn <= 1'b1;
							 Q_x <= 8'b0;
							 Q_y <= 7'b0;
							 pos_x <= old_posX;
							 pos_y <= old_posY;
						 end
				HSYNC: begin
							Q_x <= Q_x + 1;
						 end
				VSYNC: begin
							 Q_x <= 8'b0;
							 Q_y <= Q_y + 1;
						 end
			endcase
		end
	end
	
	always@(*)
	begin
		address = ((SIZEOF_X*Q_y) + Q_x) + 1; // ROW MAJOR, TO GET THE ADDRESS IN MEMORY/RAM
		if(blankEn == 1'b1)
				color = eraseColor;
			else
				color = drawColor;
	end

endmodule