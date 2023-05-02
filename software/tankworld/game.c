
#include "game.h"
#include <stdio.h>

// GAME
#define SET_GAME_ATTR_START(x)          (x)
// MAP_NUM: 1: wait to choose 2: U 4: I 8: C 
#define SET_GAME_ATTR_MAP_NUM(x)        (x<<1)
#define SET_GAME_ATTR_HEALTH(x)         (x<<5)
#define SET_GAME_ATTR_SETTING(x)        (x<<10)
#define MAX_HEALTH_DEFAULT          5

// WALL
#define GET_WALL_POS(x,y)           (1 | (x<<1) | (y<<11))

// MAP_NUM
#define UMAP                        1
#define IMAP                        2
#define CMAP                        4


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
#define WIN_COLOR                   4 // red

// STATUS BARS
#define STATUS_BAR_LEN              10

#define TANK_1_STATUS_BAR_Y         1
#define TANK_1_STATUS_BAR_X         1

#define TANK_2_STATUS_BAR_X         (TEXT_SCREEN_X - STATUS_BAR_LEN - 2)
#define TANK_2_STATUS_BAR_Y         1

// SCORE PANEL
#define SCORE_PANEL_X               ((TEXT_SCREEN_X - SCORE_PANEL_WIDTH) >> 1)
#define SCORE_PANEL_Y               5

#define SCORE_PANEL_HEIGHT          22
#define SCORE_PANEL_WIDTH           40


#define SCORE_PANEL_UPER_PADDING    4
#define SCORE_PANEL_PADDING_1       6
#define SCORE_PANEL_PADDING_2       2




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
void show_menu(int choice, int is_map) {
    char color_string[80]; // maximum 80 characters per line, each character is 8x16 pixels
    int i, y;
    char start_back = PADDING_COLOR;
    char start_font = FONT_COLOR;
    char map_back = PADDING_COLOR;
    char map_font = FONT_COLOR;
    char setting_back = PADDING_COLOR;
    char setting_font = FONT_COLOR;
    y = MENU_STARTING_ROW;
    switch (choice)
    {
    case START:
        start_back = HIGH_LIGHT_PADDING_COLOR;
        start_font = HIGH_LIGHT_FONT_COLOR;
        break;
    case MAP:
        map_back = HIGH_LIGHT_PADDING_COLOR;
        map_font = HIGH_LIGHT_FONT_COLOR;
        break;
    case SETTING:
        setting_back = HIGH_LIGHT_PADDING_COLOR;
        setting_font = HIGH_LIGHT_FONT_COLOR;
        break;
    default:
        break;
    }
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
    if (is_map == 0){
        // draw 3 menu items "START", "MAP", "SETTINGS"
        sprintf(color_string, "                START                   ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, start_back, start_font);
        sprintf(color_string, "                 MAP                    ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, map_back, map_font);
        sprintf(color_string, "              SETTINGS                  ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, setting_back, setting_font);
    }
    else{
        // draw 3 menu items "U MAP", "I MAP", "C MAP"
        sprintf(color_string, "                U MAP                   ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, start_back, start_font);
        sprintf(color_string, "                I MAP                   ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, map_back, map_font);
        sprintf(color_string, "                C MAP                   ");
        textVGADrawColorText(color_string, MENU_LEFT_PADDING, y++, setting_back, setting_font);
    }
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

void draw_wall(void) {
    int map_type = (vga_ctrl->game_attr >> 1) & 0xF;
    int x_leftinitial, y_initial, x_rightinitial, y_bottom, x_bottomleft;
    int x_middle, y_up;
    printf("map type: %d\n", map_type);
    switch (map_type){
    case 1:
        x_leftinitial = 240;
        y_initial = 144;
        x_rightinitial = 368;
        y_bottom = 304;
        x_bottomleft = 272;
        // draw left vertical line of 'U'
        for (int i = 0; i < 6; i++){
            vga_ctrl->wall_pos[i] = GET_WALL_POS(x_leftinitial, y_initial + i * 32);
        }
        // draw right vertical line of 'U'
        for (int i = 0; i < 6; i++){
            vga_ctrl->wall_pos[i + 6] = GET_WALL_POS(x_rightinitial, y_initial + i * 32);
        }
        // draw bottom horizontal line of 'U'
        for (int i = 0; i < 3; i++){
            vga_ctrl->wall_pos[i + 12] = GET_WALL_POS(x_bottomleft + i * 32, y_bottom);
        }
        break;
    case 2:
        x_leftinitial = 272;
        y_initial = 112;
        y_bottom = 336;
        x_middle = 304;
        y_up = 144;
        // draw the upper horizontal line
        for (int i = 0; i < 3; i++){
            vga_ctrl->wall_pos[i] = GET_WALL_POS(x_leftinitial + i * 32, y_initial);
        }
        // draw the lower horizontal line
        for (int i = 0; i < 3; i++){
            vga_ctrl->wall_pos[i+3] = GET_WALL_POS(x_leftinitial + i * 32, y_bottom);
        }
        // draw the middel vertical line
        for (int i = 0; i < 6; i++){
            vga_ctrl->wall_pos[i+6] = GET_WALL_POS(x_middle + i * 32, y_up);
        }
        break;
    case 4:
        x_middle = 272;
        y_up = 160;
        y_bottom = 288;
        x_leftinitial = 240;
        // draw the upper horizontal line
        for (int i = 0; i < 4; i++){
            vga_ctrl->wall_pos[i] = GET_WALL_POS(x_middle + i * 32, y_up);
        }
        // draw the lower horizontal line
        for (int i = 0; i < 4; i++){
            vga_ctrl->wall_pos[i+4] = GET_WALL_POS(x_middle + i * 32, y_bottom);
        }
        // draw the left vertical line
        for (int i = 0; i < 5; i++){
            vga_ctrl->wall_pos[i+8] = GET_WALL_POS(x_leftinitial, y_up + i * 32);
        }
        break;
    default:
        x_leftinitial = 272;
        y_initial = 112;
        y_bottom = 336;
        x_middle = 304;
        y_up = 144;
        // draw the upper horizontal line
        for (int i = 0; i < 3; i++){
            vga_ctrl->wall_pos[i] = GET_WALL_POS(x_leftinitial + i * 32, y_initial);
        }
        // draw the lower horizontal line
        for (int i = 0; i < 3; i++){
            vga_ctrl->wall_pos[i+3] = GET_WALL_POS(x_leftinitial + i * 32, y_bottom);
        }
        // draw the middel vertical line
        for (int i = 0; i < 6; i++){
            vga_ctrl->wall_pos[i+6] = GET_WALL_POS(x_middle, y_up + i * 32);
        }
        break;
    }
}

void draw_score_panel(void) {
    char color_string[80];
    int y;
    y = SCORE_PANEL_Y;
    if(vga_ctrl->health[0]) {// player left wins,  display "WIN  LOSE" split string into 2 length 20 string, center WIN, LOSE respectively
        sprintf(color_string, "        WIN         ");
        textVGADrawColorText(color_string, SCORE_PANEL_X, y, PADDING_COLOR, WIN_COLOR);
        sprintf(color_string, "        LOSE        ");
        textVGADrawColorText(color_string, SCORE_PANEL_X + 20, y++, PADDING_COLOR, FONT_COLOR);
    }
    else {// player right wins, display "LOSE  WIN"
        sprintf(color_string, "        LOSE        ");
        textVGADrawColorText(color_string, SCORE_PANEL_X, y, PADDING_COLOR, FONT_COLOR);
        sprintf(color_string, "        WIN         ");
        textVGADrawColorText(color_string, SCORE_PANEL_X + 20, y++, PADDING_COLOR, WIN_COLOR);
    }
    // draw padding 1
    for(int i = 0; i < SCORE_PANEL_PADDING_1; i++) {
        sprintf(color_string, "                                        ");
        textVGADrawColorText(color_string, SCORE_PANEL_X, y++, PADDING_COLOR, PADDING_COLOR);
    }
    // draw the score
    
    sprintf(color_string, "     SCORE: %03lu     ", vga_ctrl->score[0]);
    textVGADrawColorText(color_string, SCORE_PANEL_X, y, PADDING_COLOR, FONT_COLOR);
    sprintf(color_string, "     SCORE: %03lu     ", vga_ctrl->score[1]);
    textVGADrawColorText(color_string, SCORE_PANEL_X + 20, y++, PADDING_COLOR, FONT_COLOR);

    // draw padding 2
    for(int i = 0; i < SCORE_PANEL_PADDING_2; i++) {
        sprintf(color_string, "                                        ");
        textVGADrawColorText(color_string, SCORE_PANEL_X, y++, PADDING_COLOR, PADDING_COLOR);
    }

    // draw the health
    sprintf(color_string, "     HEALTH:  %01lu     ", vga_ctrl->health[0]);
    textVGADrawColorText(color_string, SCORE_PANEL_X, y, PADDING_COLOR, FONT_COLOR);
    sprintf(color_string, "     HEALTH:  %01lu     ", vga_ctrl->health[1]);
    textVGADrawColorText(color_string, SCORE_PANEL_X + 20, y++, PADDING_COLOR, FONT_COLOR);
    
    // draw padding 3
    for(int i = 0; i < SCORE_PANEL_Y + SCORE_PANEL_HEIGHT - y; i++) {
        sprintf(color_string, "                                        ");
        textVGADrawColorText(color_string, SCORE_PANEL_X, y++, PADDING_COLOR, PADDING_COLOR);
    }
}

/**
 * @brief take at most four @param key0 @param key1 @param key2 @param key3 keys and handle the menu
 * @note currently only enter will work
 * @todo add logics for map and settings
 */
void menu_control(char* key) {
    int i;
    if (key[0] == last_key)
        return ;
    else
        last_key = key[0];
    printf("menu state: %d\n", menu_state);
	printf("game attr: %x\n", vga_ctrl->game_attr);
    for(i = 0; i < 1; i++) {
        switch (menu_state){
        case 0:
            switch (key[i]) {
            case 40: // enter
                // set the game bit 1 to start the game
                // clear the VRAM
                text_VGA_init();
                // draw the draw_status_bars
                draw_status_bars();

                // game_init();
                vga_ctrl->game_attr |= SET_GAME_ATTR_START(1);
                break;
            case 81: // down
                // redraw the menu
                // show the high light on map
                // change the game status
                menu_state = 1;
                show_menu(MAP, 0);
                break;

            default:
                printf("oops, unknown key pressed for menu\n");
                break;
            }
            break;
        // wait to choose map
        case 1: 
            switch (key[i]) {
            case 40: // enter
                // flip the wait to choose bit
                show_menu(1, 1);
                menu_state = 3;
                break;
            case 81: // down
                // redraw the menu
                // show the high light on setting
                // change the game status
                show_menu(SETTING, 0);
                menu_state = 2;
                break;

            case 82: // up
                // redraw the menu
                // show the high light on start
                // change the game status
                show_menu(START, 0);
                menu_state = 0;
                break;
            default:
                printf("oops, unknown key pressed for menu\n");
                break;
            }
            break;

        case 2:
            switch (key[i]) {
            // wait to implement SETTING
            // case 40: // enter
            //     // set the game bit 1 to start the game
            //     // clear the VRAM
            //     text_VGA_init();
            //     // draw the draw_status_bars
            //     draw_status_bars();

            //     game_init();
            //     vga_ctrl->game_attr |= SET_GAME_ATTR_START(1);
            //     break;
            case 82: // up
                // redraw the menu
                // show the high light on map
                // change the game status
                show_menu(MAP, 0);
                menu_state = 1;
                break;
            default:
                printf("oops, unknown key pressed for menu\n");
                break;
            }
            break;
        case 3:
            switch (key[i]) {
            case 40: // enter
                menu_state = 1;
                // vga_ctrl->game_attr &= 0xFFE1;
                vga_ctrl->game_attr = vga_ctrl->game_attr | 2;
                show_menu(MAP, 0);
                break;
            case 81: // down
                // redraw the menu
                // show the high light on map
                // change the game status
                menu_state = 4;
                show_menu(2, 1);
                break;

            default:
                printf("oops, unknown key pressed for menu\n");
                break;
            }
            break;
        case 4:
            switch (key[i]) {
            case 40: // enter
                menu_state = 1;
                // vga_ctrl->game_attr &= 0xFFE1;
                vga_ctrl->game_attr |= 4;
                show_menu(MAP, 0);
                break;
            case 81: // down
                // redraw the menu
                // show the high light on map
                // change the game status
                menu_state = 5;
                show_menu(3, 1);
                break;
            
            case 82: // up
                // redraw the menu
                // show the high light on map
                // change the game status
                menu_state = 3;
                show_menu(1, 1);
                break;

            default:
                printf("oops, unknown key pressed for menu\n");
                break;
            }
            break;
        case 5:
            switch (key[i]) {
            case 40: // enter
                menu_state = 1;
                // vga_ctrl->game_attr &= 0xFFE1;
                vga_ctrl->game_attr |= 8;
                show_menu(MAP, 0);
                break;
            case 82: // up
                // redraw the menu
                // show the high light on map
                // change the game status
                menu_state = 4;
                show_menu(2, 1);
                break;

            default:
                printf("oops, unknown key pressed for menu\n");
                break;
            }
            break;
        default:
            printf("oops, menu state error\n");
            break;
        }
    }
}

