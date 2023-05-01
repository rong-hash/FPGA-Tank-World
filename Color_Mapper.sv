/**
* Drawing Engine
* Color Mapper.sv :
* Motion Engine puts drawing related information into this module so that it can draw the image on the screen.
* Position, DrawX, DrawY -[check condition(position / related information in VRAM(composed by registers, OCM possibly SDRAM))]-> font rom ->
 R, G, B -[VGA]-> Screen 
* Layer 0 : background and props
* Layer 1 : Tanks and bullets and special effect
* Layer 2 : Text-granular sprites
*/

`define NUM_PALETTE     8
`define COIN_NUM        3
`define WALL_NUM        16
`define WALL_WIDTH      32
`define WALL_HEIGHT     32
`define POS_MASK        ((1<<10) - 1)

module color_mapper(
    input logic CLK, pixel_clk,
    input logic [9:0] tank1_x, tank1_y, tank2_x, tank2_y, DrawX, DrawY,
    input logic [2:0] base1_direction, turret1_direction, base2_direction, turret2_direction,
    input logic blank,
    input logic [31:0] bullet_array[2][8], 
    input logic [15:0] char,
    input logic [7:0] font_data,
    input logic [31:0] palette[`NUM_PALETTE],
    input logic [31:0] coin_attr_reg[`COIN_NUM],
    input logic [31:0] wall_pos_reg[`WALL_NUM],
    output logic [7:0] Red, Green, Blue
);

    parameter [5:0] img_width = 32;
    parameter [5:0] img_height = 32;
    parameter [1:0] tank_num = 2;
    parameter [7:0] ARRAY_SIZE = 8;
    
    parameter [31:0] Ball_Size = 4;

    logic [9:0] base_x, base_y, background_x, background_y, coin_x[`COIN_NUM], coin_y[`COIN_NUM], wall_x[`WALL_NUM], wall_y[`WALL_NUM];
    logic [7:0] Rb[8];
    logic [7:0] Gb[8];
    logic [7:0] Bb[8];
    logic [7:0] Rt[8];
    logic [7:0] Gt[8];
    logic [7:0] Bt[8];
    logic [7:0] Rba, Gba, Bba; // background R G B
    logic [7:0] Rcg, Gcg, Bcg; // gold coin R G B
    logic [7:0] Rcs, Gcs, Bcs; // silver coin R G B
    logic [7:0] Rcc, Gcc, Bcc; // copper coin R G B
    logic [7:0] Rw[`WALL_NUM], Gw[`WALL_NUM], Bw[`WALL_NUM]; // wall R G B
    logic [7:0] redout, greenout, blueout;
    logic [9:0] BallX[tank_num][ARRAY_SIZE], BallY[tank_num][ARRAY_SIZE];
    logic ball_on[tank_num][ARRAY_SIZE];
    int DistX[tank_num][ARRAY_SIZE], DistY[tank_num][ARRAY_SIZE];

    logic [7:0] i, j, k; // @note all oocupied, if want new iterator, use k, ...
	logic [7:0] idx[tank_num], ball_ind;

    always_comb begin 
        for (i = 0; i < tank_num; i = i + 1) begin
            for(idx[i] = 0; idx[i] < ARRAY_SIZE; idx[i] = idx[i] + 1) begin
                BallX[i][idx[i]] = bullet_array[i][idx[i]][18:9];
                BallY[i][idx[i]] = bullet_array[i][idx[i]][28:19];
                DistX[i][idx[i]] = DrawX - BallX[i][idx[i]];
                DistY[i][idx[i]] = DrawY - BallY[i][idx[i]];

                if ( ( DistX[i][idx[i]]*DistX[i][idx[i]] + DistY[i][idx[i]]*DistY[i][idx[i]]) <= (Ball_Size * Ball_Size) ) begin
                    ball_on[i][idx[i]] = bullet_array[i][idx[i]][0]; // only draw if the bullet is on (valid bit set to 1)
                    // ball_ind = bullet_array[i][idx[i]][0] ? ((idx[i] << 1) | i) : 0;
                end
                else 
                    ball_on[i][idx[i]] = 1'b0;
            end
        end
    end


    // tank's base rom
    base0_example base0(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[0]), .green(Gb[0]), .blue(Bb[0]));
    base1_example base1(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[1]), .green(Gb[1]), .blue(Bb[1]));
    base2_example base2(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[2]), .green(Gb[2]), .blue(Bb[2]));
    base3_example base3(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[3]), .green(Gb[3]), .blue(Bb[3]));
    base4_example base4(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[4]), .green(Gb[4]), .blue(Bb[4]));
    base5_example base5(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[5]), .green(Gb[5]), .blue(Bb[5]));
    base6_example base6(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[6]), .green(Gb[6]), .blue(Bb[6]));
    base7_example base7(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[7]), .green(Gb[7]), .blue(Bb[7]));
    // tank's turrent rom
    turret0_example turret0(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[0]), .green(Gt[0]), .blue(Bt[0]));
    turret1_example turret1(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[1]), .green(Gt[1]), .blue(Bt[1]));
    turret2_example turret2(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[2]), .green(Gt[2]), .blue(Bt[2]));
    turret3_example turret3(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[3]), .green(Gt[3]), .blue(Bt[3]));
    turret4_example turret4(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[4]), .green(Gt[4]), .blue(Bt[4]));
    turret5_example turret5(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[5]), .green(Gt[5]), .blue(Bt[5]));
    turret6_example turret6(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[6]), .green(Gt[6]), .blue(Bt[6]));
    turret7_example turret7(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[7]), .green(Gt[7]), .blue(Bt[7]));
    // background (bricks) rom
    bricks_example bricks(.DrawX(background_x), .DrawY(background_y), .vga_clk(CLK), 
    .blank(1'b1), .red(Rba), .green(Gba), .blue(Bba));
    // Wall Rom
    stone_example wall_0(.DrawX(wall_x[0]), .DrawY(wall_y[0]), .vga_clk(CLK), .blank(1'b1), .red(Rw[0]), .green(Gw[0]), .blue(Bw[0]));
    stone_example wall_1(.DrawX(wall_x[1]), .DrawY(wall_y[1]), .vga_clk(CLK), .blank(1'b1), .red(Rw[1]), .green(Gw[1]), .blue(Bw[1]));
    stone_example wall_2(.DrawX(wall_x[2]), .DrawY(wall_y[2]), .vga_clk(CLK), .blank(1'b1), .red(Rw[2]), .green(Gw[2]), .blue(Bw[2]));
    stone_example wall_3(.DrawX(wall_x[3]), .DrawY(wall_y[3]), .vga_clk(CLK), .blank(1'b1), .red(Rw[3]), .green(Gw[3]), .blue(Bw[3]));
    stone_example wall_4(.DrawX(wall_x[4]), .DrawY(wall_y[4]), .vga_clk(CLK), .blank(1'b1), .red(Rw[4]), .green(Gw[4]), .blue(Bw[4]));
    stone_example wall_5(.DrawX(wall_x[5]), .DrawY(wall_y[5]), .vga_clk(CLK), .blank(1'b1), .red(Rw[5]), .green(Gw[5]), .blue(Bw[5]));
    stone_example wall_6(.DrawX(wall_x[6]), .DrawY(wall_y[6]), .vga_clk(CLK), .blank(1'b1), .red(Rw[6]), .green(Gw[6]), .blue(Bw[6]));
    stone_example wall_7(.DrawX(wall_x[7]), .DrawY(wall_y[7]), .vga_clk(CLK), .blank(1'b1), .red(Rw[7]), .green(Gw[7]), .blue(Bw[7]));
    stone_example wall_8(.DrawX(wall_x[8]), .DrawY(wall_y[8]), .vga_clk(CLK), .blank(1'b1), .red(Rw[8]), .green(Gw[8]), .blue(Bw[8]));
    stone_example wall_9(.DrawX(wall_x[9]), .DrawY(wall_y[9]), .vga_clk(CLK), .blank(1'b1), .red(Rw[9]), .green(Gw[9]), .blue(Bw[9]));
    stone_example wall_10(.DrawX(wall_x[10]), .DrawY(wall_y[10]), .vga_clk(CLK), .blank(1'b1), .red(Rw[10]), .green(Gw[10]), .blue(Bw[10]));
    stone_example wall_11(.DrawX(wall_x[11]), .DrawY(wall_y[11]), .vga_clk(CLK), .blank(1'b1), .red(Rw[11]), .green(Gw[11]), .blue(Bw[11]));
    stone_example wall_12(.DrawX(wall_x[12]), .DrawY(wall_y[12]), .vga_clk(CLK), .blank(1'b1), .red(Rw[12]), .green(Gw[12]), .blue(Bw[12]));
    stone_example wall_13(.DrawX(wall_x[13]), .DrawY(wall_y[13]), .vga_clk(CLK), .blank(1'b1), .red(Rw[13]), .green(Gw[13]), .blue(Bw[13]));
    stone_example wall_14(.DrawX(wall_x[14]), .DrawY(wall_y[14]), .vga_clk(CLK), .blank(1'b1), .red(Rw[14]), .green(Gw[14]), .blue(Bw[14]));
    stone_example wall_15(.DrawX(wall_x[15]), .DrawY(wall_y[15]), .vga_clk(CLK), .blank(1'b1), .red(Rw[15]), .green(Gw[15]), .blue(Bw[15]));

    //  gold example
    coin_gold_example coin_gold(.DrawX(coin_x[0]), .DrawY(coin_y[0]), .vga_clk(CLK), .blank(1'b1), 
    .red(Rcg), .green(Gcg), .blue(Bcg));

    // silver example
    coin_silver_example coin_silver(.DrawX(coin_x[1]), .DrawY(coin_y[1]), .vga_clk(CLK), .blank(1'b1),
    .red(Rcs), .green(Gcs), .blue(Bcs));

    // copper example
    coin_copper_example coin_copper(.DrawX(coin_x[2]), .DrawY(coin_y[2]), .vga_clk(CLK), .blank(1'b1),
    .red(Rcc), .green(Gcc), .blue(Bcc));

    // ram needed here (OCM) : needs import dual ports out for software 
    // then every time we get Draw X and Draw Y we check corresponding bytes to get pixel information.
    always_comb
    begin
        base_x = 0;
        base_y = 0;
        // because 32x32 is the smallest unit of the background brick
        background_x = (DrawX & (img_width - 1)) * 20; // mod 32
        background_y = (DrawY & (img_height - 1)) * 15; // mod 32
        // coin_x, coin_y also incorporate the frame number (coin_attr_reg >> 21) which should be within [0, 7]
        for(j = 0; j < `COIN_NUM; j = j + 1) begin
            // @note 4-30-2023 : haor2 : right now, ROMs for coins are changed so that DrawX and DrawY are directly the same 
            // DrawX and DrawY in this module, no need to scale 
            // (coin_attr_reg[j][10:1] - 8, coin_attr_reg[j][20:11] - 8) should be upper left corner of the coin 8 is half of the coin width / height
            coin_x[j] = (DrawX - (coin_attr_reg[j][10:1] - 8) + coin_attr_reg[j][23:21]* 16); 
            coin_y[j] = (DrawY - (coin_attr_reg[j][20:11]  - 8));
        end

        for(k = 0; k < `WALL_NUM ; k = k + 1) begin
            wall_x[k] = (DrawX - wall_pos_reg[k][10:1]) * 20;
            wall_y[k] = (DrawY - wall_pos_reg[k][20:11]) * 15;
        end

        ball_ind = tank_num * ARRAY_SIZE;
        if (blank) begin
            // @todo :  check VRAM if draw text, then  we draw text instead of tanks and background
            // tank1 highest priority
            if(char) begin // if software decide to occupy current position as a port of text

                if (font_data[7 - DrawX[2:0]] ^ char[15]) begin // if, after exerting inverse logic, it's foreground.
                    case (char[4])
                        0 : begin  
                            redout <= palette[char[7:5]][11:8];
                            greenout <= palette[char[7:5]][7:4];
                            blueout <= palette[char[7:5]][3:0];
                        end 
                        1 : begin 
                            redout <= palette[char[7:5]][27:24];
                            greenout <= palette[char[7:5]][23:20];
                            blueout <= palette[char[7:5]][19:16];
                        end
                        default : ;
                    endcase
                end
                else begin // if, after exerting inverse logic, it's background
                    case (char[0])
                        0 : begin  
                            redout <= palette[char[3:1]][11:8];
                            greenout <= palette[char[3:1]][7:4];
                            blueout <= palette[char[3:1]][3:0];
                        end 
                        1 : begin 
                            redout <= palette[char[3:1]][27:24];
                            greenout <= palette[char[3:1]][23:20];
                            blueout <= palette[char[3:1]][19:16];
                        end
                        default : ;
                    endcase
                end

            end else if (DrawX >= tank1_x && DrawX < tank1_x + img_width &&
                DrawY >= tank1_y && DrawY < tank1_y + img_height) begin
                    base_x = (DrawX - tank1_x) * 20;
                    base_y = (DrawY - tank1_y) * 15;
                    if ((Rt[turret1_direction] | Gt[turret1_direction] | Bt[turret1_direction]) != 8'h0) begin
                        redout = Rt[turret1_direction];
                        greenout = Gt[turret1_direction];
                        blueout = Bt[turret1_direction];
                    end
                    else if (Rb[base1_direction] | Gb[base1_direction] | Bb[base1_direction] != 8'h0) begin
                        redout = Rb[base1_direction];
                        greenout = Gb[base1_direction];
                        blueout = Bb[base1_direction];
                    end
                    else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
            end
            // tank2 second priority
            else if (DrawX >= tank2_x && DrawX < tank2_x + img_width &&
                    DrawY >= tank2_y && DrawY < tank2_y + img_height) begin
                    base_x = (DrawX - tank2_x) * 20;
                    base_y = (DrawY - tank2_y) * 15;
                    // if turret is transparent
                    if ((Rt[turret2_direction] | Gt[turret2_direction] | Bt[turret2_direction]) != 8'h0) begin
                        redout = Rt[turret2_direction];
                        greenout = Gt[turret2_direction];
                        blueout = Bt[turret2_direction];
                    end
                    else if (Rb[base2_direction] | Gb[base2_direction] | Bb[base2_direction] != 8'h0) begin
                        redout = Rb[base2_direction];
                        greenout = Gb[base2_direction];
                        blueout = Bb[base2_direction];
                    end
                    else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
            end 
            else begin
                

                if(ball_on[0][0]) ball_ind = 0;
                else if(ball_on[0][1]) ball_ind = 1;
                else if(ball_on[0][2]) ball_ind = 2;
                else if(ball_on[0][3]) ball_ind = 3;
                else if(ball_on[0][4]) ball_ind = 4;
                else if(ball_on[0][5]) ball_ind = 5;
                else if(ball_on[0][6]) ball_ind = 6;
                else if(ball_on[0][7]) ball_ind = 7;
                else if(ball_on[1][0]) ball_ind = 8;
                else if(ball_on[1][1]) ball_ind = 9;
                else if(ball_on[1][2]) ball_ind = 10;
                else if(ball_on[1][3]) ball_ind = 11;
                else if(ball_on[1][4]) ball_ind = 12;
                else if(ball_on[1][5]) ball_ind = 13;
                else if(ball_on[1][6]) ball_ind = 14;
                else if(ball_on[1][7]) ball_ind = 15;
                else ball_ind = tank_num * ARRAY_SIZE;

                // tank and prop layer

                if(ball_ind != tank_num * ARRAY_SIZE) begin
                    redout = 8'hff;
                    greenout = 8'h55;
                    blueout = 8'h00;
                end 
                else if( (coin_attr_reg[0] & 1) // if gold coin exist
                    // and within drawing point is inside the coin (centered at (x,y))
                    && DrawX >= coin_attr_reg[0][10:1] - 8
                    && DrawX < coin_attr_reg[0][10:1] + 8
                    && DrawY >= coin_attr_reg[0][20:11]  - 8
                    && DrawY < coin_attr_reg[0][20:11] + 8
                 ) begin // gold coin
                    if((Rcg | Gcg | Bcg) != 8'h0) begin
                        redout = Rcg;
                        greenout = Gcg;
                        blueout = Bcg;
                    end
                    else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                 end else if( (coin_attr_reg[1] & 1)
                 && DrawX >= coin_attr_reg[1][10:1] - 8
                && DrawX < coin_attr_reg[1][10:1] + 8
                && DrawY >= coin_attr_reg[1][20:11]  - 8
                && DrawY < coin_attr_reg[1][20:11] + 8
                ) begin // silver coin
                    if((Rcs | Gcs | Bcs) != 8'h0) begin
                        redout = Rcs;
                        greenout = Gcs;
                        blueout = Bcs;
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if( (coin_attr_reg[2] & 1) 
                && DrawX >= coin_attr_reg[2][10:1] - 8
                && DrawX < coin_attr_reg[2][10:1] + 8
                && DrawY >= coin_attr_reg[2][20:11]  - 8
                && DrawY < coin_attr_reg[2][20:11] + 8
                ) begin // copper coin
                    if((Rcc | Gcc | Bcc) != 8'h0) begin
                        redout = Rcc;
                        greenout = Gcc;
                        blueout = Bcc;
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[0][0]
                && DrawX >= wall_pos_reg[0][10:1]
                && DrawX < wall_pos_reg[0][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[0][20:11]
                && DrawY < wall_pos_reg[0][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[0] | Gw[0] | Bw[0]) != 8'h0) begin
                        redout = Rw[0];
                        greenout = Gw[0];
                        blueout = Bw[0];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[1][0]
                && DrawX >= wall_pos_reg[1][10:1]
                && DrawX < wall_pos_reg[1][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[1][20:11]
                && DrawY < wall_pos_reg[1][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[1] | Gw[1] | Bw[1]) != 8'h0) begin
                        redout = Rw[1];
                        greenout = Gw[1];
                        blueout = Bw[1];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[2][0]
                && DrawX >= wall_pos_reg[2][10:1]
                && DrawX < wall_pos_reg[2][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[2][20:11]
                && DrawY < wall_pos_reg[2][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[2] | Gw[2] | Bw[2]) != 8'h0) begin
                        redout = Rw[2];
                        greenout = Gw[2];
                        blueout = Bw[2];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[3][0]
                && DrawX >= wall_pos_reg[3][10:1]
                && DrawX < wall_pos_reg[3][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[3][20:11]
                && DrawY < wall_pos_reg[3][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[3] | Gw[3] | Bw[3]) != 8'h0) begin
                        redout = Rw[3];
                        greenout = Gw[3];
                        blueout = Bw[3];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[4][0]
                && DrawX >= wall_pos_reg[4][10:1]
                && DrawX < wall_pos_reg[4][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[4][20:11]
                && DrawY < wall_pos_reg[4][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[4] | Gw[4] | Bw[4]) != 8'h0) begin
                        redout = Rw[4];
                        greenout = Gw[4];
                        blueout = Bw[4];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[5][0]
                && DrawX >= wall_pos_reg[5][10:1]
                && DrawX < wall_pos_reg[5][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[5][20:11]
                && DrawY < wall_pos_reg[5][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[5] | Gw[5] | Bw[5]) != 8'h0) begin
                        redout = Rw[5];
                        greenout = Gw[5];
                        blueout = Bw[5];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[6][0]
                && DrawX >= wall_pos_reg[6][10:1]
                && DrawX < wall_pos_reg[6][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[6][20:11]
                && DrawY < wall_pos_reg[6][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[6] | Gw[6] | Bw[6]) != 8'h0) begin
                        redout = Rw[6];
                        greenout = Gw[6];
                        blueout = Bw[6];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[7][0]
                && DrawX >= wall_pos_reg[7][10:1]
                && DrawX < wall_pos_reg[7][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[7][20:11]
                && DrawY < wall_pos_reg[7][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[7] | Gw[7] | Bw[7]) != 8'h0) begin
                        redout = Rw[7];
                        greenout = Gw[7];
                        blueout = Bw[7];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[8][0]
                && DrawX >= wall_pos_reg[8][10:1]
                && DrawX < wall_pos_reg[8][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[8][20:11]
                && DrawY < wall_pos_reg[8][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[8] | Gw[8] | Bw[8]) != 8'h0) begin
                        redout = Rw[8];
                        greenout = Gw[8];
                        blueout = Bw[8];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[9][0]
                && DrawX >= wall_pos_reg[9][10:1]
                && DrawX < wall_pos_reg[9][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[9][20:11]
                && DrawY < wall_pos_reg[9][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[9] | Gw[9] | Bw[9]) != 8'h0) begin
                        redout = Rw[9];
                        greenout = Gw[9];
                        blueout = Bw[9];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[10][0]
                && DrawX >= wall_pos_reg[10][10:1]
                && DrawX < wall_pos_reg[10][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[10][20:11]
                && DrawY < wall_pos_reg[10][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[10] | Gw[10] | Bw[10]) != 8'h0) begin
                        redout = Rw[10];
                        greenout = Gw[10];
                        blueout = Bw[10];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[11][0]
                && DrawX >= wall_pos_reg[11][10:1]
                && DrawX < wall_pos_reg[11][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[11][20:11]
                && DrawY < wall_pos_reg[11][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[11] | Gw[11] | Bw[11]) != 8'h0) begin
                        redout = Rw[11];
                        greenout = Gw[11];
                        blueout = Bw[11];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[12][0]
                && DrawX >= wall_pos_reg[12][10:1]
                && DrawX < wall_pos_reg[12][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[12][20:11]
                && DrawY < wall_pos_reg[12][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[12] | Gw[12] | Bw[12]) != 8'h0) begin
                        redout = Rw[12];
                        greenout = Gw[12];
                        blueout = Bw[12];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[13][0]
                && DrawX >= wall_pos_reg[13][10:1]
                && DrawX < wall_pos_reg[13][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[13][20:11]
                && DrawY < wall_pos_reg[13][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[13] | Gw[13] | Bw[13]) != 8'h0) begin
                        redout = Rw[13];
                        greenout = Gw[13];
                        blueout = Bw[13];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[14][0]
                && DrawX >= wall_pos_reg[14][10:1]
                && DrawX < wall_pos_reg[14][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[14][20:11]
                && DrawY < wall_pos_reg[14][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[14] | Gw[14] | Bw[14]) != 8'h0) begin
                        redout = Rw[14];
                        greenout = Gw[14];
                        blueout = Bw[14];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end else if(wall_pos_reg[15][0]
                && DrawX >= wall_pos_reg[15][10:1]
                && DrawX < wall_pos_reg[15][10:1] + `WALL_WIDTH
                && DrawY >= wall_pos_reg[15][20:11]
                && DrawY < wall_pos_reg[15][20:11] + `WALL_HEIGHT
                ) begin // wall
                    if((Rw[15] | Gw[15] | Bw[15]) != 8'h0) begin
                        redout = Rw[15];
                        greenout = Gw[15];
                        blueout = Bw[15];
                    end else begin
                        redout = Rba;
                        greenout = Gba;
                        blueout = Bba;
                    end
                end 
                else begin // background : the last layer
                    redout = Rba;
                    greenout = Gba;
                    blueout = Bba;
                end
            end
        end
        else begin
            redout = 8'h0;
            greenout = 8'h0;
            blueout = 8'h0;
        end
    end

    always_ff @ (posedge pixel_clk) begin
        Red <= redout;
        Green <= greenout;
        Blue <= blueout;
    end
endmodule


