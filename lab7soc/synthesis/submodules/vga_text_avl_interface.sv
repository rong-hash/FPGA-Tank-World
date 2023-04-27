/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 						601 //80*30 characters / 4 characters per register
`define CTRL_REG 						600 //index of control register
`define NUM_PALETTE 					8
`define PALETTE_END  					2055
`define CTRL_REG_END 					2056
`define GAME_ATTR_REG_END 				2057
`define COIN_ATTR_REG_END 				2060
`define HEALTH_ATTR_REG_END				2062
`define SCORE_ATTR_REG_END 				2064
`define INIT_POS_REG_END 				2066
`define WALL_POS_REG_END 				2082
`define BULLET_NUM_REG_END 				2084
`define TANK_POS_REG_END 				2086

`define COIN_NUM 						3
`define TANK_NUM 						2
`define WALL_NUM 					    16

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,					// VGA HS/VS
	output logic [7:0] debug1, debug2		// Debug signals
);

//put other local variables here
// VGA signals
logic pixel_clk, blank, sync; // VGA signals
logic [9:0] DrawX, DrawY; // VGA signals
// FONT ROM signals
logic [10:0] font_addr;
logic [7:0] font_data;

logic [11:0] location;
logic [31:0] RD_DATA1, RD_DATA2;
logic [10:0] index;
logic [15:0] char;
logic [31:0] TEMP_WRITEDATA;
logic [31:0] char_data;
logic [31:0] palette[`NUM_PALETTE];
logic [9:0] tank_x[`TANK_NUM], tank_y[`TANK_NUM];
logic [2:0] base1_direction, base2_direction, turret1_direction, turret2_direction;
logic [31:0] bullet_array[2][8];
logic hit[`TANK_NUM * `BULLET_NUM][`TANK_NUM]; // hit[i][j] = 1 means bullet i hit tank j

// Software Driven Signals : Signals mainly sent by software to hardware
logic [31:0] control_reg;
logic [31:0] game_attr_reg;
logic [31:0] coin_attr_reg[`COIN_NUM];
logic [31:0] health_attr_reg[`TANK_NUM];
logic [31:0] score_attr_reg[`TANK_NUM];
logic [31:0] init_pos_reg[`TANK_NUM];
logic [31:0] wall_pos_reg[`WALL_NUM];
// Hardware Driven Signals : Signals mainly sent by hardware to software
logic [31:0] bullet_num_reg[`TANK_NUM];
logic [31:0] tank_pos_reg[`TANK_NUM];


// logic fire[2];
logic [7:0]  hole_ind[2];
//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller vga_control(.Clk(CLK), .Reset(RESET), .hs(hs), .vs(vs), 
							.pixel_clk(pixel_clk), .blank(blank), .sync(sync), 
							.DrawX(DrawX), .DrawY(DrawY));

							
font_rom font_rom(.addr(font_addr), .data(font_data));


// allow both port a and port b write and read
// port a responsible for AVL READ and WRITE
// port b responsible for read char from ram
ram my_vram(.address_a(AVL_ADDR[10:0]), .address_b(index), .byteena_a(AVL_BYTE_EN), .clock(CLK), .data_a(AVL_WRITEDATA), .data_b(TEMP_WRITEDATA), 
			.rden_a(AVL_CS & AVL_READ & (~AVL_ADDR[11])), .rden_b(1'b1), .wren_a(AVL_CS & AVL_WRITE & (~AVL_ADDR[11])), .wren_b(1'b0), .q_a(RD_DATA1), .q_b(char_data));


// write into control register
// always_ff @(posedge CLK)  
// begin
// 	if (AVL_CS & AVL_WRITE && (AVL_ADDR == CTRL_REG_ADDR))
// 		control_reg <= AVL_WRITEDATA;
// end


// palette : before control register and after vram
// RD_DATA2 stores the data after VRAM (with word address >= 2048)
// VRAM starts with a palette, following a series of attribute registers
// RD_DATA2 is to avoid multi-driver, so AVL_WRITE data doesn't have this problem
// see a series of defines to see the address range of each register
always_ff @(posedge CLK ) begin
	if(AVL_WRITE && AVL_ADDR[11]) begin
		if(AVL_ADDR <= `PALETTE_END)
			palette[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
		else if(AVL_ADDR <= `CTRL_REG_END)
			control_reg <= AVL_WRITEDATA;
		else if(AVL_ADDR <= `GAME_ATTR_REG_END)
			game_attr_reg[AVL_ADDR - `CTRL_REG_END - 1] <= AVL_WRITEDATA;
		else if(AVL_ADDR > `COIN_ATTR_REG_END) begin 
			if(AVL_ADDR > `SCORE_ATTR_REG_END) begin
				if(AVL_ADDR <= `INIT_POS_REG_END)
					init_pos_reg[AVL_ADDR - `SCORE_ATTR_REG_END - 1] <= AVL_WRITEDATA;
				else if(AVL_ADDR <= `WALL_POS_REG_END)
					wall_pos_reg[AVL_ADDR - `INIT_POS_REG_END - 1] <= AVL_WRITEDATA;
			end
		end
	end else if(AVL_READ && AVL_ADDR[11]) begin
		if(AVL_ADDR <= `PALETTE_END)
			RD_DATA2 <= palette[AVL_ADDR[2:0]];
		else if(AVL_ADDR <= `CTRL_REG_END)
			RD_DATA2 <= control_reg;
		else if(AVL_ADDR <= `GAME_ATTR_REG_END)
			RD_DATA2 <= game_attr_reg[AVL_ADDR - `CTRL_REG_END - 1];
		else if(AVL_ADDR <= `COIN_ATTR_REG_END)
			RD_DATA2 <= coin_attr_reg[AVL_ADDR - `GAME_ATTR_REG_END - 1];
		else if(AVL_ADDR <= `HEALTH_ATTR_REG_END)
			RD_DATA2 <= health_attr_reg[AVL_ADDR - `COIN_ATTR_REG_END - 1];
		else if(AVL_ADDR <= `SCORE_ATTR_REG_END)
			RD_DATA2 <= score_attr_reg[AVL_ADDR - `HEALTH_ATTR_REG_END - 1];
		else if(AVL_ADDR <= `INIT_POS_REG_END)
			RD_DATA2 <= init_pos_reg[AVL_ADDR - `SCORE_ATTR_REG_END - 1];
		else if(AVL_ADDR <= `WALL_POS_REG_END)
			RD_DATA2 <= wall_pos_reg[AVL_ADDR - `INIT_POS_REG_END - 1];
		else if(AVL_ADDR <= `BULLET_NUM_REG_END)
			RD_DATA2 <= bullet_num_reg[AVL_ADDR - `WALL_POS_REG_END - 1];
		else if(AVL_ADDR <= `TANK_POS_REG_END)
			RD_DATA2 <= tank_pos_reg[AVL_ADDR - `BULLET_NUM_REG_END - 1];
	end
end



// This is address splitter splitter VRAM (OCM) and other registers (not necessarily OCM)
always_comb begin
	unique case (AVL_ADDR[11]) 
		1'b0: AVL_READDATA = RD_DATA1;
		1'b1: AVL_READDATA = RD_DATA2;
	endcase
end

// This will calculate the address of the font related information
my_text my_text(.DrawX(DrawX), .DrawY(DrawY),  .char_data(char_data), .index(index), .char(char), .location(location));

// char is on upper bit right now, so bit[15] has inv information, while bit[14:8] is original(lab71) bit[6:0]
assign font_addr = {char[14:8], DrawY[3:0]};

// below are motion engines (input keycode, output tank position and direction)
tank_position_direction my_tank(.keycode(control_reg), .Reset(RESET), .frame_clk(vs), 
			.tank_x1out(tank_x[0]), .tank_y1out(tank_y[0]), .tank_x2out(tank_x[1]), .tank_y2out(tank_y[1]),
			.base1_directionout(base1_direction), .turret1_directionout(turret1_direction), 
			.base2_directionout(base2_direction), .turret2_directionout(turret2_direction),
			.bullet_array(bullet_array), .hole_ind(hole_ind), .hit(hit));

color_mapper mapper(.CLK(CLK), .pixel_clk(pixel_clk), .DrawX(DrawX), .DrawY(DrawY), 
					.tank1_x(tank_x[0]), .tank2_x(tank_x[1]), .tank1_y(tank_y[0]), .tank2_y(tank_y[1]),
					.base1_direction(base1_direction), .turret1_direction(turret1_direction), 
					.base2_direction(base2_direction), .turret2_direction(turret2_direction),
					.bullet_array(bullet_array),
					.char(char), .font_data(font_data), .palette(palette), .coin_attr_reg(coin_attr_reg),
					.blank(blank), .Red(red), .Green(green), .Blue(blue));

feedback feedback(.frame_clk(vs), .Reset(RESET), .AVL_WRITE(AVL_WRITE), .AVL_ADDR(AVL_ADDR),
					.AVL_WRITEDATA(AVL_WRITEDATA), .bullet_array(bullet_array), .tank_x(tank_x), 
					.tank_y(tank_y), .hit(hit), .bullet_num_reg(bullet_num_reg), 
					.tank_pos_reg(tank_pos_reg), .health_attr_reg_out(health_attr_reg));

coins coins(.Reset(RESET), .CLK(CLK), .AVL_WRITE(AVL_WRITE), .AVL_ADDR(AVL_ADDR), 
			.AVL_WRITEDATA(AVL_WRITEDATA), .tank_x(tank_x), .tank_y(tank_y), 
			.score_attr_reg(score_attr_reg), .coin_attr_reg_out(coin_attr_reg));


// assign debug1 = {bullet_array[0][0][0], bullet_array[0][1][0], bullet_array[0][2][0], bullet_array[0][3][0], bullet_array[0][4][0], bullet_array[0][5][0], bullet_array[0][6][0], bullet_array[0][7][0]};
// assign debug2 = {bullet_array[1][0][0], bullet_array[1][1][0], bullet_array[1][2][0], bullet_array[1][3][0], bullet_array[1][4][0], bullet_array[1][5][0], bullet_array[1][6][0], bullet_array[1][7][0]};
// assign debug1 = {bullet_array[0][7][8:1]};
// assign debug2 = {bullet_array[1][7][8:1]};

assign debug1 = coin_attr_reg[0][7:0]; // 1 | (x<<1)
assign debug2 = coin_attr_reg[0][18:11]; // y


endmodule

module my_text (
	input logic [9:0] DrawX, DrawY,
	input logic [31:0] char_data,
	output logic [10:0] index,
	output logic [15:0] char,
	output logic [11:0] location

);
	always_comb begin
		// screen: 30 rows 80 columns
		// DrawX: represent column, 640 in total
		// DrawY: represent row, 480 in total
		location = DrawY[9:4] * 80 + DrawX[9:3];
		// haor2 originally divide by 4 because 1 word = 4 chars, currently each char has 1 extra byte so / 2
		index = location[11:1];
		// then we choose wether we plot 1st / 2nd char
		case (location[0])
			1'b0: char = char_data[15:0];
			1'b1: char = char_data[31:16];
		endcase
		
	end
endmodule
