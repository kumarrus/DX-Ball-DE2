
module PS2_Demo (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	left, right, start
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
wire[6:0]	HEX0;
wire		[6:0]	HEX1;
wire		[6:0]	HEX2;
wire		[6:0]	HEX3;
wire		[6:0]	HEX4;
wire		[6:0]	HEX5;
wire		[6:0]	HEX6;
wire		[6:0]	HEX7;
wire		[6:0] LEDG;


output left;
output right;
output start;
wire continue;
wire reset;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;
reg [50:0] count = 'd0;
reg [50:0] delay = 'd0;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)

	begin

		if (count == delay) begin
			if (ps2_key_pressed == 1'b1) begin
					last_data_received <= ps2_key_data;
					delay <= 0;
					count <= 0;
			end else if (ps2_key_data == 8'b11110000) begin
					last_data_received <= 8'h00;
					delay <= 'd100000;
			end
		end else begin
			count <= count + 1;
		end
			
	end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
assign HEX7 = 7'h7F;

assign left = (last_data_received == 8'b01101011);
assign right = (last_data_received == 8'b01110100);
assign start = (last_data_received == 8'b00011011);
assign continue = (last_data_received == 8'b00100001);
assign reset = (last_data_received == 8'b00101101);

assign LEDG[1] = left;
assign LEDG[0] = right;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(last_data_received[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(last_data_received[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);

Hexadecimal_To_Seven_Segment Segment2 (
	// Inputs
	.hex_number			(start),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX2)
);

Hexadecimal_To_Seven_Segment Segment3 (
	// Inputs
	.hex_number			(reset),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX3)
);

Hexadecimal_To_Seven_Segment Segment4 (
	// Inputs
	.hex_number			(continue),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX4)
);

Hexadecimal_To_Seven_Segment Segment5 (
	// Inputs
	.hex_number			(left),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX5)
);

Hexadecimal_To_Seven_Segment Segment6 (
	// Inputs
	.hex_number			(right),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX6)
);



endmodule
