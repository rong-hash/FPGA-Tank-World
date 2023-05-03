#ifndef _GAME_H_
#define _GAME_H_

#include <system.h>
#include <alt_types.h>

#include "text_mode_vga.h"

#define GET_START_GAME()              (vga_ctrl->game_attr & 1)

// MENU
#define START   1
#define MAP     2
#define SETTING 3

static volatile int menu_state;
static volatile char last_key;

void check_gears(void);
void game_init(void);

void show_menu(int choice, int is_map);
void draw_status_bars(void);

void menu_control(char* key);

void draw_score_panel(void);
void draw_wall(void);
#endif /*_GAME_H_*/