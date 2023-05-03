/*
 * text_mode_vga_color.c
 * Minimal driver for text mode VGA support
 * This is for Week 2, with color support
 *
 *  Created on: Oct 25, 2021
 *      Author: zuofu
 */

#include <system.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alt_types.h>
#include "text_mode_vga.h"
#include "game.h"

void textVGAColorClr()
{
	for (int i = 0; i<(ROWS*COLUMNS) * 2; i++)
	{
			vga_ctrl->VRAM[i] = 0x00;
	}
}

void textVGADrawColorText(char* str, int x, int y, alt_u8 background, alt_u8 foreground)
{
	int i = 0;
	while (str[i]!=0)
	{
		vga_ctrl->VRAM[(y*COLUMNS + x + i) * 2] = foreground << 4 | background;
		vga_ctrl->VRAM[(y*COLUMNS + x + i) * 2 + 1] = str[i];
		i++;
	}
}
/**
 * @brief Set the Color Palette 
 * @param color : the color index
 * @param red : the red value
 * @param green : the green value
 * @param blue 	: the blue value
 */
void setColorPalette (alt_u8 color, alt_u8 red, alt_u8 green, alt_u8 blue)
{
	//fill in this function to set the color palette starting at offset 0x0000 2000 (from base)
	 //0x0000 2000 - 0x0000 201F Palette- 8 words of 2 colors each, for 16-color palette
	 // For example in word address 0x800, that is 0x2000 to 0x2001 in byte address, we have following color palette
	 // now for each byte the R G B are at lowest 12 bits
	alt_u32 val = ((alt_u32)red << 8) | (green << 4) | blue;
	if (color % 2 == 0) {
		vga_ctrl->PALETTE[color >> 1] = val;
	} else {
		vga_ctrl->PALETTE[color >> 1] |= val << 16;
	}
}

// keycode
// low 2 bytes reserved
void ramsetctl(long code)
{
	vga_ctrl->CTRL = code;
}

void mem_test() {
	vga_ctrl->VRAM[0x123] = 0x45;
	vga_ctrl->VRAM[0x321] = 0x45;
	alt_32 sum = 0;
	for(int i = 0; i < 0x333; i++) {
		sum += vga_ctrl->VRAM[i];
	}
	if(sum != 0x45 * 2) {
		printf("Memory test failed!\n");
	} else {
		printf("mem test passed\n");
	}
}

/**
 * @brief Initialize the VGA controller, clear the screen, and configure the palette
 * 
 */
void text_VGA_init(void) {
	textVGAColorClr();
	//initialize palette
	for (int i = 0; i < 16; i++)
		setColorPalette (i, colors[i].red, colors[i].green, colors[i].blue);
}

void textVGAColorScreenSaver()
{
	//This is the function you call for your week 2 demo
	char color_string[80];
    int fg, bg, x, y;
    text_VGA_init();
	while (1)
	{
		fg = rand() % 16;
		bg = rand() % 16;
		while (fg == bg)
		{
			fg = rand() % 16;
			bg = rand() % 16;
		}
		sprintf(color_string, "Drawing %s text with %s background", colors[fg].name, colors[bg].name);
		x = rand() % (80-strlen(color_string));
		y = rand() % 30;
		textVGADrawColorText (color_string, x, y, bg, fg);
		usleep (100000);
	}
}
