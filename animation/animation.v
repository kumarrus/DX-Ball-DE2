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

	wire [2:0] color, myImg, blankImg;
	wire [7:0] pos_x; // x coordinate , start x
	wire [6:0] pos_y; // y coordinate , start y
	wire [7:0] new_posX; // x coordinate
	wire [6:0] new_posY; // y coordinate
	wire writeEn; // PLOT AND BLANK
	wire [7:0] addr; // Address in ROM/RAM
	wire [7:0] Q_X, Q_Y; // Pixel coordinate of image
	wire startPlot;// = ~KEY[1]
	
	vga_fsm FSM(
			.clk(CLOCK_50),
			.reset(resetn),
			.go(startPlot),
			.Q_x(Q_X),
			.Q_y(Q_Y),
			.enableX(writeEn),
			.address(addr),
			.myImg(myImg),
			.blankImg(blankImg),
			.color(color),
			.pos_x(pos_x),
			.pos_y(pos_y),
			.new_posX(new_posX),
			.new_posY(new_posY));

	Plotter animatePlot(
		.clk(CLOCK_50),
		.new_posX(new_posX),
		.new_posY(new_posY),
		.startPlot(startPlot));
	//ROM that holds the image of the ball
	newRom myRom(
		.address(addr),
		.clock(CLOCK_50),
		.q(myImg));
	//ROM that holds the image that needs to be chosen while erasing
	//This will be the background of the screen
	newRom2 blankRom(
		.address(addr),
		.clock(CLOCK_50),
		.q(blankImg));
	
	assign LEDR[7:0] = addr;
	assign LEDR[15:8] = Q_Y[7:0];

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
	
	
endmodule

module vga_fsm 
	(
		clk,
		reset,
		go,
		Q_x,
		Q_y,
		enableX,
		address,
		myImg,
		blankImg,
		color,
		new_posX,
		new_posY,
		pos_x,
		pos_y
	);
//------------Input Ports--------------
	input clk, reset, go;
	input [2:0] myImg, blankImg;
	input [7:0] new_posX; // Start x coordinate
	input [6:0] new_posY; // Start y coordinate
//----------Output Ports--------------
	output reg enableX;
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
	reg blankX = 1'b0;
	reg [7:0] old_posX = 8'b00110011;
	reg [6:0] old_posY = 7'b0011001;
	//reg [7:0] V_x = 8'b1; // Velocity x
	//reg [6:0] V_y = 7'b0; // Velocity y
	//reg [7:0] Q_x, Q_y;
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
	always@(state, go, Q_x, Q_y, blankX)
	begin
		case(state)
			IDLE: begin
						if(go == 1'b1)
							next_state = ERASE;
						else
							next_state = IDLE;
					end
			DRAW: begin
						next_state = HSYNC;
					end
			ERASE: begin
						next_state = HSYNC;
					 end
			HSYNC: begin
						 if(Q_x < 8'd4)
							next_state = HSYNC;
						 else
							next_state = VSYNC;
					 end
			VSYNC: begin
						 if(Q_y > 7'd3)
						 begin
							if(blankX == 1'b1)
								next_state = DRAW;
							else
								next_state = IDLE;
						 end
						 else
						 begin
							next_state = HSYNC;
						 end
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
							enableX <= 1'b0;
							blankX <= 1'b0;
							Q_x <= 8'b0;
							Q_y <= 7'b0;
						end
				DRAW: begin
							blankX <= 1'b0;
							Q_x <= 8'b0;
							Q_y <= 7'b0;
							pos_x <= new_posX;
							pos_y <= new_posY;
							old_posX <= new_posX;
							old_posY <= new_posY;
						end
				ERASE: begin
							 enableX <= 1'b1;
							 blankX <= 1'b1;
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
		address = ((4*Q_y) + Q_x); // ROW MAJOR, TO GET THE ADDRESS IN MEMORY/RAM
		if(blankX == 1'b1)
				color = blankImg;
			else
				color = myImg;
	end

endmodule

module Plotter
	(
		clk,
		new_posX,
		new_posY,
		startPlot
	);
	
	param ballCyclesToUpdate = 5000000;
	param paddleCyclesToUpdate = 5000000;
	param ball_Radius = 2;
	param maxX = 159;
	param maxY = 119;
	param paddleLength = 20;
	param ballObj = 0;
	param paddleObj = 1;
	param blockObj = 2;
	param noObj = 3;
	
//------------Input Ports--------------
	input clk;
//----------Output Ports--------------
	
	output [7:0] newX;
	output [6:0] newY;
	output [7:0] oldX;
	output [6:0] oldY;
	output [1:0] object;
	
	output reg startPlot;
//------------Internal Variables--------
	integer count = 0;
	reg [7:0] V_x = 8'b1; // Velocity x
	reg [6:0] V_y = 7'b1; // Velocity y
	reg RIGHT = 1'b1;
	reg DOWN = 1'b1;
	
	reg [7:0] new_posX = 8'b00110011; // Start x coordinate
	reg [6:0] new_posY = 7'b0011001; // Start y coordinate
	
	always@(posedge clk)
	begin
		//startPlot <= 1'b1;
		if(count == ballCyclesToUpdate) //approx 1/60th of a second
			begin
				count = 0;
				if((new_posX) >= (159-4))
					RIGHT <= 1'b0;
				if((new_posX) <= 1)
					RIGHT <= 1'b1;
				if((new_posY) >= (119-4))
					DOWN <= 1'b0;
				if((new_posY) <= 1)
					DOWN <= 1'b1;
				if(RIGHT)
					new_posX <= new_posX + V_x;
				else
					new_posX <= new_posX - V_x;
				if(DOWN)
					new_posY <= new_posY + V_y;
				else
					new_posY <= new_posY - V_y;
				startPlot <= 1'b1;
			end
		else
			begin
				startPlot <= 1'b0;
				count = count + 1;
			end
	end
	
endmodule
