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

module color_mapper(
    input logic CLK, pixel_clk,
    input logic [9:0] tank1_x, tank1_y, tank2_x, tank2_y, DrawX, DrawY,
    input logic [2:0] base1_direction, turret1_direction, base2_direction, turret2_direction,
    input logic blank,
    input logic [31:0] bullet_array[2][8], 
    output logic [7:0] Red, Green, Blue
);

    parameter [5:0] img_width = 32;
    parameter [5:0] img_height = 32;
    parameter [1:0] tank_num = 2;
    parameter [7:0] ARRAY_SIZE = 8;
    
    parameter [31:0] Ball_Size = 4;

    logic [9:0] base_x, base_y;
    logic [7:0] Rb[8];
    logic [7:0] Gb[8];
    logic [7:0] Bb[8];
    logic [7:0] Rt[8];
    logic [7:0] Gt[8];
    logic [7:0] Bt[8];
    logic [7:0] redout, greenout, blueout;
    logic [9:0] BallX[tank_num][ARRAY_SIZE], BallY[tank_num][ARRAY_SIZE];
    logic ball_on[tank_num][ARRAY_SIZE];
    int DistX[tank_num][ARRAY_SIZE], DistY[tank_num][ARRAY_SIZE];

    logic [7:0] i;
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

    
    base0_example base0(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[0]), .green(Gb[0]), .blue(Bb[0]));
    base1_example base1(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[1]), .green(Gb[1]), .blue(Bb[1]));
    base2_example base2(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[2]), .green(Gb[2]), .blue(Bb[2]));
    base3_example base3(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[3]), .green(Gb[3]), .blue(Bb[3]));
    base4_example base4(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[4]), .green(Gb[4]), .blue(Bb[4]));
    base5_example base5(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[5]), .green(Gb[5]), .blue(Bb[5]));
    base6_example base6(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[6]), .green(Gb[6]), .blue(Bb[6]));
    base7_example base7(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rb[7]), .green(Gb[7]), .blue(Bb[7]));
    turret0_example turret0(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[0]), .green(Gt[0]), .blue(Bt[0]));
    turret1_example turret1(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[1]), .green(Gt[1]), .blue(Bt[1]));
    turret2_example turret2(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[2]), .green(Gt[2]), .blue(Bt[2]));
    turret3_example turret3(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[3]), .green(Gt[3]), .blue(Bt[3]));
    turret4_example turret4(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[4]), .green(Gt[4]), .blue(Bt[4]));
    turret5_example turret5(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[5]), .green(Gt[5]), .blue(Bt[5]));
    turret6_example turret6(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[6]), .green(Gt[6]), .blue(Bt[6]));
    turret7_example turret7(.DrawX(base_x), .DrawY(base_y), .vga_clk(CLK), .blank(1'b1), .red(Rt[7]), .green(Gt[7]), .blue(Bt[7]));
    // ram needed here (OCM) : needs import dual ports out for software 
    // then every time we get Draw X and Draw Y we check corresponding bytes to get pixel information.
    always_comb
    begin
        base_x = 0;
        base_y = 0;
        ball_ind = tank_num * ARRAY_SIZE;
        if (blank) begin
            // @todo :  check VRAM if draw text, then  we draw text instead of tanks and background
            // tank1 highest priority
            if (DrawX >= tank1_x && DrawX < tank1_x + img_width &&
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
                        redout = 8'he9;
                        greenout = 8'hd8;
                        blueout = 8'he4;
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
                        redout = 8'he9;
                        greenout = 8'hd8;
                        blueout = 8'he4;
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


                if(ball_ind != tank_num * ARRAY_SIZE) begin
                    redout = 8'hff;
                    greenout = 8'h55;
                    blueout = 8'h00;
                end 
                else begin
                    redout = 8'he9;
                    greenout = 8'hd8;
                    blueout = 8'he4;
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