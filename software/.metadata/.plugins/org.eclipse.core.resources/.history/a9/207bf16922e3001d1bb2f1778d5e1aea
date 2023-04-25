#ifndef _GAME_H_
#define _GAME_H_

#include <system.h>
#include <alt_types.h>

#include "text_mode_vga.h"

#define GET_START_GAME()              (vga_ctrl->game_attr & 1)

void game_init(void);

void show_menu(void);
void draw_status_bars(void);

void menu_control(char* key);
#endif /*_GAME_H_*/