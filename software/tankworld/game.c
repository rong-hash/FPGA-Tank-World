
#include "game.h"
#include <stdio.h>

// GAME
#define SET_GAME_ATTR_START(x)          (x)
#define SET_GAME_ATTR_MAP_NUM(x)        (x<<1)
#define SET_GAME_ATTR_HEALTH(x)         (x<<5)
#define MAX_HEALTH_DEFAULT          5

// TANK
#define TANK_NUM                    2
#define GET_POS(x,y)                (x | (y<<10))
#define TANK_1_DEAULT_X             200
#define TANK_1_DEAULT_Y             200
#define TANK_2_DEAULT_X             400
#define TANK_2_DEAULT_Y             400

// COIN
#define COIN_TYPES                  3
#define GET_POS_COIN(x,y)           (1 | (x<<1) | (y<<11))

#define GOLD_COIN                   0
#define SILVER_COIN                 1
#define BRONZE_COIN                 2

#define GOLD_COIN_VAL               30
#define SILVER_COIN_VAL             20
#define BRONZE_COIN_VAL             10

#define GOLD_COIN_DEFAULT_X         320
#define GOLD_COIN_DEFAULT_Y         240

#define SILVER_COIN_DEFAULT_X       320
#define SILVER_COIN_DEFAULT_Y       100

#define BRONZE_COIN_DEFAULT_X       320
#define BRONZE_COIN_DEFAULT_Y       380

// MENU
#define TEXT_SCREEN_X               80
#define TEXT_SCREEN_Y               30
#define MENU_HEIGHT                 22
#define MENU_WIDTH                  40

// MENU : line spacing
#define MENU_STARTING_ROW           4
#define MENU_UPPER_PADDING          2
#define MENU_PADDING_1              3

#define MENU_LEFT_PADDING           ((TEXT_SCREEN_X - MENU_WIDTH) >> 1)

#define MENU_START_ROW_IND          0
#define MENU_MAP_ROW_IND            1
#define MENU_SETTINGS_ROW_IND       2

// COLOR CODES
#define PADDING_COLOR               3  // cyan
#define FONT_COLOR                  6  // brown
#define HIGH_LIGHT_PADDING_COLOR    1  // blue
#define HIGH_LIGHT_FONT_COLOR       15 // white

// STATUS BARS
#define STATUS_BAR_LEN              10

#define TANK_1_STATUS_BAR_Y         1
#define TANK_1_STATUS_BAR_X         1

#define TANK_2_STATUS_BAR_X         (TEXT_SCREEN_X - STATUS_BAR_LEN - 1)
#define TANK_2_STATUS_BAR_Y         1

static int cursor_pos = MENU_START_ROW_IND; // cursor position, 0 for start, 1 for map, 2 for settings


void game_init(void) {
    int i;
    // set the game attributes : not started, map 0, maximum health 5
    vga_ctrl->game_attr = SET_GAME_ATTR_START(0) | SET_GAME_ATTR_MAP_NUM(0) | SET_GAME_ATTR_HEALTH(MAX_HEALTH_DEFAULT);
    // mark all the coins present with default positions
    vga_ctrl->coin_attr[GOLD_COIN] = GET_POS_COIN(GOLD_COIN_DEFAULT_X, GOLD_COIN_DEFAULT_Y);
    vga_ctrl->coin_attr[SILVER_COIN] = GET_POS_COIN(SILVER_COIN_DEFAULT_X, SILVER_COIN_DEFAULT_Y);
    vga_ctrl->coin_attr[BRONZE_COIN] = GET_POS_COIN(BRONZE_COIN_DEFAULT_X, BRONZE_COIN_DEFAULT_Y);
    // health is read only
    for(i=0; i<TANK_NUM; i++) vga_ctrl->score[i] = 0;
    vga_ctrl->init_pos[0] = GET_POS(TANK_1_DEAULT_X, TANK_1_DEAULT_Y);
    vga_ctrl->init_pos[1] = GET_POS(TANK_2_DEAULT_X, TANK_2_DEAULT_Y);
    // @todo
    // currently no walls, will be added 
    for(i=0; i<16; i++) vga_ctrl->wall_pos[i] = 0;
}

/**
 * @brief We show menu by displaying equal length of string, blank should be padded with space.
 * Should not use black color as both background and foreground color.
 * textVGADrawColorText (color_string, x, y, bg, fg) will show the string with upper left corner at (x,y), 
 * with background color bg and foreground color fg. Definition of colors are in text_mode_vga.h.
 * @todo : currently only start will work, map and settings are not implemented.
 */
void show_menu(void) {
    char color_string[80]; // maximum 80 characters per line, each character is 8x16 pixels
    int i, y;
    y = MENU_STARTING_ROW;
    // draw the upper padding rows
    for(i=0; i<MENU_UPPER_PADDING; i++) {
        sprintf(color_string, "                                        ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, PADDING_COLOR, PADDING_COLOR);
    }
    // draw the menu rows, center "MENU"
    sprintf(color_string, "                MENU                    ");
    textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, PADDING_COLOR, FONT_COLOR);
    // draw padding 1
    for(i=0; i<MENU_PADDING_1; i++) {
        sprintf(color_string, "                                        ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, PADDING_COLOR, PADDING_COLOR);
    }
    // draw 3 menu items "START", "MAP", "SETTINGS"
    sprintf(color_string, "                START                   ");
    textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, HIGH_LIGHT_PADDING_COLOR, HIGH_LIGHT_FONT_COLOR);
    sprintf(color_string, "                 MAP                    ");
    textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, PADDING_COLOR, FONT_COLOR);
    sprintf(color_string, "              SETTINGS                  ");
    textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, PADDING_COLOR, FONT_COLOR);
    // draw lower padding
    for(i = 0; i < MENU_STARTING_ROW + MENU_HEIGHT - y; i++) {
        sprintf(color_string, "                                        ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, PADDING_COLOR, PADDING_COLOR);
    }
}

/**
 * @brief Status bar shows the HEALTH, SCORE, and BULLETS of the tank.
 */
void draw_status_bars(void) {
    // draw the status bar for tank 0
    char color_string[80];
    int y;
    y = TANK_1_STATUS_BAR_Y;
    // pad the string to length of STATUS_BAR_LEN
    sprintf(color_string, "HEALTH:  %01lu", vga_ctrl->health[0]);
    textVGADrawColorText(color_string, TANK_1_STATUS_BAR_X, y++, PADDING_COLOR, FONT_COLOR);
    // keep pad the score to 3 digits
    sprintf(color_string, "SCORE: %03lu", vga_ctrl->score[0]);
    textVGADrawColorText(color_string, TANK_1_STATUS_BAR_X, y++, PADDING_COLOR, FONT_COLOR);
    // keep pad the bullets to 1 digits
    sprintf(color_string, "BULLETS: %01lu", vga_ctrl->bullet_num[0]);
    textVGADrawColorText(color_string, TANK_1_STATUS_BAR_X, y++, PADDING_COLOR, FONT_COLOR);

    // do the same for tank2
    y = TANK_2_STATUS_BAR_Y;
    sprintf(color_string, "HEALTH:  %01lu", vga_ctrl->health[1]);
    textVGADrawColorText(color_string, TANK_2_STATUS_BAR_X, y++, PADDING_COLOR, FONT_COLOR);
    sprintf(color_string, "SCORE: %03lu", vga_ctrl->score[1]); 
    textVGADrawColorText(color_string, TANK_2_STATUS_BAR_X, y++, PADDING_COLOR, FONT_COLOR);
    sprintf(color_string, "BULLETS: %01lu", vga_ctrl->bullet_num[1]);
    textVGADrawColorText(color_string, TANK_2_STATUS_BAR_X, y++, PADDING_COLOR, FONT_COLOR);
}

/**
 * @brief take at most four @param key0 @param key1 @param key2 @param key3 keys and handle the menu
 * @note currently only enter will work
 * @todo add logics for map and settings
 */
void menu_control(char* key) {
    int i;
    for(i = 0; i < 6; i++) {
        switch (key[i]) {
        case 40: // enter
            // set the game bit 1 to start the game
            // clear the VRAM
            text_VGA_init();
            // draw the draw_status_bars
            draw_status_bars();

            game_init();
            vga_ctrl->game_attr |= SET_GAME_ATTR_START(1);
            break;
        
        default:
            printf("oops, unknown key pressed for menu\n");
            break;
        }
    }
}
