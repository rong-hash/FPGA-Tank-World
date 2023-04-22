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

struct TEXT_VGA_STRUCT {
	alt_u8 VRAM [ROWS*COLUMNS];
	alt_u32 CTRL;
	alt_u32 padding0 [847];
	alt_u32 PALETTE [8];
	alt_u32 padding1 [2040];
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


void textVGAColorClr();
void textVGADrawColorText(char* str, int x, int y, alt_u8 background, alt_u8 foreground);
void setColorPalette (alt_u8 color, alt_u8 red, alt_u8 green, alt_u8 blue);
void textVGAColorScreenSaver(); //Call this for your demo

#endif /* TEXT_MODE_VGA_H_ */
