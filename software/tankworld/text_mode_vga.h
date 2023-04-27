#ifndef TEXT_MODE_VGA_H_
#define TEXT_MODE_VGA_H_

#include <system.h>
#include <alt_types.h>

#define COLUMNS 80
#define ROWS 30

//define some colors
#define WHITE 		0xFFF
#define BRIGHT_RED 	0xF00
#define DIM_RED    	0x700
#define BRIGHT_GRN	0x0F0
#define DIM_GRN		0x070
#define BRIGHT_BLU  0x00F
#define DIM_BLU		0x007
#define GRAY		0x777
#define BLACK		0x000

// all bit pattern format (low_bits .... high_bits)
struct TEXT_VGA_STRUCT {
	alt_u8 VRAM [ROWS*COLUMNS*2]; // video ram, used to store the text mode VGA data
	alt_u32 padding0 [848]; // first 2048 (4B)
	alt_u32 PALETTE [8]; // VGA palette, can support 16 colors
	alt_u32 CTRL;  // tank control register
	alt_u32 game_attr; // game attribute register (start | map_num | maximum health) 
	// coin attr format : (present_bit | coin_x | coin_y | coin_frame) rest of bits are reserved
	alt_u32 coin_attr[3]; // coin attribute register : (gold, silver, bronze) 
	alt_u32 health[2]; // health register
	alt_u32 score[2]; // score register
	alt_u32 init_pos[2]; // initial  position register
	// wall_x and wall_y format : (present_bit | position_x (10 bits) | position_y (10 bits)) 
	// other bits are reserved
	alt_u32 wall_pos[16]; // wall position register
	// ------- below are hardware registers(reigsters' value given by hardware), do not modify -------
	alt_u32 bullet_num[2]; // bullet number register (number of bullets left)
	alt_u32 tank_pos[2]; // tank position register

	alt_u32 padding1 [2009]; // second 2048 (4B)
};


struct COLOR{
	char name [20];
	alt_u8 red;
	alt_u8 green;
	alt_u8 blue;
};


//you may have to change this line depending on your platform designer
static volatile struct TEXT_VGA_STRUCT* vga_ctrl = VGA_TEXT_MODE_CONTROLLER_0_BASE;

//CGA colors with names
static struct COLOR colors[]={
    {"black",          0x0, 0x0, 0x0},
	{"blue",           0x0, 0x0, 0xa},
    {"green",          0x0, 0xa, 0x0},
	{"cyan",           0x0, 0xa, 0xa},
    {"red",            0xa, 0x0, 0x0},
	{"magenta",        0xa, 0x0, 0xa},
    {"brown",          0xa, 0x5, 0x0},
	{"light gray",     0xa, 0xa, 0xa},
    {"dark gray",      0x5, 0x5, 0x5},
	{"light blue",     0x5, 0x5, 0xf},
    {"light green",    0x5, 0xf, 0x5},
	{"light cyan",     0x5, 0xf, 0xf},
    {"light red",      0xf, 0x5, 0x5},
	{"light magenta",  0xf, 0x5, 0xf},
    {"yellow",         0xf, 0xf, 0x5},
	{"white",          0xf, 0xf, 0xf}
};

void text_VGA_init(void);
void textVGAColorClr();
void textVGADrawColorText(char* str, int x, int y, alt_u8 background, alt_u8 foreground);
void setColorPalette (alt_u8 color, alt_u8 red, alt_u8 green, alt_u8 blue);
void textVGAColorScreenSaver(); //Call this for your demo

#endif /* TEXT_MODE_VGA_H_ */
