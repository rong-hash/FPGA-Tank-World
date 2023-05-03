//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------

`define TANK_WIDTH 			32
`define TANK_HEIGHT 		32
`define TANK_NUM 			2
`define DEFAULT_SPEED 		1

module update_base(
	input logic [7:0] keycode,
	input logic [9:0] tank_x, tank_y,
	input logic [2:0] base_direction,
	input logic [31:0] wall_pos_reg[16],
	input logic [9:0] speed,
	output logic [9:0] next_tank_x_out, next_tank_y_out,
	output logic [2:0] next_base_direction
);

    parameter [9:0] tank_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] tank_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] tank_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] tank_Y_Max=479;     // Bottommost point on the Y axis
	logic leftstop;
	logic rightstop;
	logic upstop;
	logic downstop;
	logic overlap[16];
	logic [9:0] next_tank_x, next_tank_y;
	always_comb begin
		next_tank_x = tank_x;
		next_tank_y = tank_y;
		next_base_direction = base_direction;
		case (keycode)
			// A
			8'h1: begin
				if (tank_x <= tank_X_Min) begin
					next_tank_x = tank_X_Min;
				end

				else begin
					next_tank_x = tank_x - speed;
				end
				next_base_direction = 3'h2;
			end
			// S
			8'h2: begin
				if (tank_y + 32 >= tank_Y_Max) begin
					next_tank_y = tank_Y_Max - 32;
				end
				else begin
					next_tank_y = tank_y + speed;
				end
				next_base_direction = 3'h4;
			end
			// W
			8'h3: begin
				if (tank_y <= tank_Y_Min) begin
					next_tank_y = tank_Y_Min;
				end
				else begin
					next_tank_y = tank_y - speed;
				end
				next_base_direction = 3'h0;
			end
			// D
			8'h4: begin
				if (tank_x + 32 >= tank_X_Max) begin
					next_tank_x = tank_X_Max - 32;
				end
				else begin
					next_tank_x = tank_x + speed;
				end
				next_base_direction = 3'h6;
			end
			default: ;
		endcase
	end
	check_wall cw0(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[0]), .overlap(overlap[0]));
	check_wall cw1(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[1]), .overlap(overlap[1]));
	check_wall cw2(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[2]), .overlap(overlap[2]));
	check_wall cw3(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[3]), .overlap(overlap[3]));
	check_wall cw4(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[4]), .overlap(overlap[4]));
	check_wall cw5(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[5]), .overlap(overlap[5]));
	check_wall cw6(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[6]), .overlap(overlap[6]));
	check_wall cw7(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[7]), .overlap(overlap[7]));
	check_wall cw8(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[8]), .overlap(overlap[8]));
	check_wall cw9(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[9]), .overlap(overlap[9]));
	check_wall cw10(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[10]), .overlap(overlap[10]));
	check_wall cw11(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[11]), .overlap(overlap[11]));
	check_wall cw12(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[12]), .overlap(overlap[12]));
	check_wall cw13(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[13]), .overlap(overlap[13]));
	check_wall cw14(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[14]), .overlap(overlap[14]));
	check_wall cw15(.x(next_tank_x), .y(next_tank_y), .wall_pos_reg(wall_pos_reg[15]), .overlap(overlap[15]));
	always_comb begin
		if (overlap[0] || overlap[1] || overlap[2] || overlap[3] || overlap[4] || overlap[5] || overlap[6] || overlap[7] || overlap[8] || overlap[9] || overlap[10] || overlap[11] || overlap[12] || overlap[13] || overlap[14] || overlap[15]) begin
			next_tank_x_out = tank_x;
			next_tank_y_out = tank_y;
		end
		else begin
			next_tank_x_out = next_tank_x;
			next_tank_y_out = next_tank_y;
		end
	end
endmodule


module update_turret(
	input logic [7:0] keycode,
	input logic [7:0] turret_direction,
	input  logic fire,
	input logic [7:0]  fire_scc,
	output logic [7:0] next_turret_direction,
	output logic next_fire,
	output logic [7:0] next_fire_scc
);
	assign next_fire_scc = fire_scc + 1;
	always_comb begin
		next_turret_direction = turret_direction;
		next_fire = fire;
		case (keycode)
			// J
			8'h1: begin
				next_turret_direction = (turret_direction + 1) ;
			end
			// K
			8'h2: begin
				next_turret_direction = (turret_direction - 1) ;
			end
			// space
			8'h3: begin
				next_fire = fire | 1'b1;
			end
			default: ;
		endcase

	end

endmodule


module  ball (input logic [31:0] bullet,
			input logic [9:0] tank_x[`TANK_NUM], tank_y[`TANK_NUM],
			input logic [31:0] wall_pos_reg[16],
			output logic [31:0] next_bullet,
			output logic hit[`TANK_NUM]
);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	logic [9:0] next_Ball_X_Pos, next_Ball_X_Motion, next_Ball_Y_Pos, next_Ball_Y_Motion;
	logic [7:0] dir, next_dir;
	logic overlap[16];
	logic is_overlap;
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign Ball_Size = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	int k;

	always_comb
    begin 
		// bullet[i] = (bullet_array[i][hole_ind[i]] & 1) | (turret_direction[i] << 1) | (tank_x[i] << 9) | (tank_y[i] << 19)
		Ball_X_Pos = (bullet >> 9) & 1023;
		Ball_Y_Pos = (bullet >> 19) & 1023;
		next_dir = dir;
		dir = (bullet >> 1) & 7;

		for(k = 0; k < `TANK_NUM; k = k + 1) begin
			if((bullet & 1) && Ball_X_Pos >= tank_x[k] && Ball_X_Pos < tank_x[k] + `TANK_WIDTH &&
				Ball_Y_Pos >= tank_y[k] && Ball_Y_Pos < tank_y[k] + `TANK_HEIGHT 
			) 
				hit[k] = 1'b1;
			else  
				hit[k] = 1'b0;
		end

		//@note dir 0 is up, 1 is up left, 2 is left, 3 is down left, 4 is down, 5 is down right, 6 is right, 7 is up right
		case (dir)
			// up
			3'h0: begin
				Ball_X_Motion = 0;
				Ball_Y_Motion = ~(Ball_Y_Step) + 1;
			end
			// up left
			3'h1: begin
				Ball_X_Motion = ~(Ball_X_Step) + 1;
				Ball_Y_Motion = ~(Ball_Y_Step) + 1;
			end
			// left
			3'h2: begin
				Ball_X_Motion = ~(Ball_X_Step) + 1;
				Ball_Y_Motion = 0;
			end
			// down left
			3'h3: begin
				Ball_X_Motion = ~(Ball_X_Step) + 1;
				Ball_Y_Motion = Ball_X_Step;
			end
			// down
			3'h4: begin
				Ball_X_Motion = 0;
				Ball_Y_Motion = Ball_Y_Step;
			end
			// down right
			3'h5: begin
				Ball_X_Motion = Ball_X_Step;
				Ball_Y_Motion = Ball_Y_Step;
			end
			// right
			3'h6: begin
				Ball_X_Motion = Ball_X_Step;
				Ball_Y_Motion = 0;
			end
			// up right
			3'h7: begin
				Ball_X_Motion = Ball_X_Step;
				Ball_Y_Motion = ~(Ball_Y_Step) + 1;
			end
			default: ;
		endcase

		next_Ball_Y_Motion = Ball_Y_Motion;
		next_Ball_X_Motion = Ball_X_Motion;
		
		
		if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
			next_Ball_Y_Motion = (~ (Ball_Y_Step) + 1'b1);  // 2's complement.
			
		else if ( (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
			next_Ball_Y_Motion = Ball_Y_Step;
			
		else if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max )  // Ball is at the Right edge, BOUNCE!
			next_Ball_X_Motion = (~ (Ball_X_Step) + 1'b1);  // 2's complement.
			
		else if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min )  // Ball is at the Left edge, BOUNCE!
			next_Ball_X_Motion = Ball_X_Step;

		next_Ball_Y_Pos = (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
		next_Ball_X_Pos = (Ball_X_Pos + Ball_X_Motion);
		
		// encode it back into next_dir
		if (next_Ball_X_Motion == 0) begin
			// Ball is moving vertically
			if (next_Ball_Y_Motion == Ball_Y_Step) next_dir = 3'h4; // down
			else next_dir = 3'h0; // up
			// If next_Ball_Y_Motion is 0, next_direction remains unchanged
		end 
		else if (next_Ball_Y_Motion == 0) begin
			// Ball is moving horizontally
			if (next_Ball_X_Motion == Ball_X_Step) next_dir = 3'h6; // right
			else  next_dir = 3'h2; // left
			// If next_Ball_X_Motion is 0, next_direction remains unchanged
		end 
		else begin
			// Ball is moving diagonally
			if (next_Ball_X_Motion == Ball_X_Step) begin
				if (next_Ball_Y_Motion == Ball_Y_Step) next_dir = 3'h5; // down right
				else next_dir = 3'h7; // up right
			end else begin
				if (next_Ball_Y_Motion == Ball_Y_Step) next_dir = 3'h3; // down left
				else next_dir = 3'h1; // up left
			end
		end

    end
	ball_check_wall bcw0(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[0]), .overlap(overlap[0]));
	ball_check_wall bcw1(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[1]), .overlap(overlap[1]));
	ball_check_wall bcw2(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[2]), .overlap(overlap[2]));
	ball_check_wall bcw3(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[3]), .overlap(overlap[3]));
	ball_check_wall bcw4(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[4]), .overlap(overlap[4]));
	ball_check_wall bcw5(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[5]), .overlap(overlap[5]));
	ball_check_wall bcw6(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[6]), .overlap(overlap[6]));
	ball_check_wall bcw7(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[7]), .overlap(overlap[7]));
	ball_check_wall bcw8(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[8]), .overlap(overlap[8]));
	ball_check_wall bcw9(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[9]), .overlap(overlap[9]));
	ball_check_wall bcw10(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[10]), .overlap(overlap[10]));
	ball_check_wall bcw11(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[11]), .overlap(overlap[11]));
	ball_check_wall bcw12(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[12]), .overlap(overlap[12]));
	ball_check_wall bcw13(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[13]), .overlap(overlap[13]));
	ball_check_wall bcw14(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[14]), .overlap(overlap[14]));
	ball_check_wall bcw15(.x(next_Ball_X_Pos), .y(next_Ball_Y_Pos), .wall_pos_reg(wall_pos_reg[15]), .overlap(overlap[15]));
	assign is_overlap = overlap[0] || overlap[1] || overlap[2] || overlap[3] || overlap[4] || overlap[5] || overlap[6] || overlap[7] || overlap[8] || overlap[9] || overlap[10] || overlap[11] || overlap[12] || overlap[13] || overlap[14] || overlap[15];

	// if bullet existed and doesn't hit any tanks, update bullet position, otherwise set it to 0
	assign next_bullet = (((bullet & 1) && !hit[0] && !hit[1]) && (is_overlap == 1'b0)) ? ((bullet & 1) | (next_dir << 1) | (next_Ball_X_Pos << 9) | (next_Ball_Y_Pos << 19)) : 0;

endmodule

module check_wall(
	input logic [9:0] x, // tank_x or ball_x
	input logic [9:0] y, // tank_y or ball_y
	input logic [31:0] wall_pos_reg,
	output logic overlap
);
	logic [31:0] wall_x, wall_y;
	assign wall_x = wall_pos_reg[10:1];
	assign wall_y = wall_pos_reg[20:11];
	// check if the rectangle with upper left corner (x, y) and the wall rectangle 
	// with upper left corner (wall_x, wall_y) overlap
	assign overlap = (x < (wall_x + 32)) && ((x + 32) > wall_x) && (y < (wall_y + 32)) && ((y + 32) > wall_y);

endmodule

module ball_check_wall(
	input logic [9:0] x, // tank_x
	input logic [9:0] y, // tank_y
	input logic [31:0] wall_pos_reg,
	output logic overlap
);
	// x, y is the center coordinate of the ball
	logic ball_size = 4;
	logic [31:0] wall_x, wall_y;
	assign wall_x = wall_pos_reg[10:1];
	assign wall_y = wall_pos_reg[20:11];
	// check if the ball with center (x, y) and the wall rectangle with upper left corner (wall_x, wall_y) overlap
	assign overlap = (x >= wall_x - ball_size) && (x <= (wall_x + 32 + ball_size)) && (y >= wall_y - ball_size) && (y <= (wall_y + 32 + ball_size));
endmodule

module tank_position_direction(
	input logic[31:0] keycode,
	input logic Reset, frame_clk,
	input logic [31:0] wall_pos_reg[16],
	input logic to_speed[`TANK_NUM],
	output logic [9:0] tank_x1out, tank_y1out, tank_x2out, tank_y2out, 
	output logic[2:0] base1_directionout, turret1_directionout, base2_directionout, turret2_directionout,
	output logic [31:0] bullet_array[2][8],
	output logic [7:0] hole_ind[2],
	output logic hit[tank_num * ARRAY_SIZE][tank_num], // hit[i][j] = 1 means bullet i hit tank j
	output logic speed_up
	// output logic fire[2]
);
	
	// key code 
	// 0 - 7: tank2_turret
	// 8 - 15: tank2_base
	// 16 - 23: tank1_turret
	// 24 - 31: tank1_base
	parameter [1:0] tank_num = 2;
	parameter [1:0] keycode_num = 3;
	parameter [3:0] direction_num = 8;
    parameter [9:0] tank_X1_initial=200;  // Center position on the X axis
    parameter [9:0] tank_Y1_initial=200;  // Center position on the Y axis
	parameter [9:0] tank_X2_initial=400;  // Center position on the X axis
    parameter [9:0] tank_Y2_initial=400;  // Center position on the Y axis
	parameter [2:0] base_direction_initial = 0;
	parameter [7:0]	turret_direction_initial = 0;
    parameter [9:0] tank_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] tank_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] tank_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] tank_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] tank_X_Step=1;      // Step size on the X axis
    parameter [9:0] tank_Y_Step=1;      // Step size on the Y axis
	parameter [9:0] tank_width = 32;
	parameter [9:0] tank_height = 32;
	parameter [7:0] ARRAY_SIZE = 8;
	parameter [7:0] fire_scc_num = 16;   // every 8 frames, fire a bullet. Must be a power of 2

	logic [9:0] tank_x[tank_num];
	logic [9:0] tank_y[tank_num];
	logic [2:0] base_direction[tank_num];
	logic [7:0] turret_direction[tank_num];
	logic fire[tank_num];
	logic [9:0] next_tank_x[tank_num];
	logic [9:0] next_tank_y[tank_num];
	logic [2:0] next_base_direction[tank_num];
	logic [7:0] next_turret_direction[tank_num];
	logic [31:0] next_bullet_array[tank_num][ARRAY_SIZE];
	logic next_fire[tank_num];
	logic [1:0] index;
	logic [7:0] keys[4];
	logic [7:0] key;
	logic [7:0] tank2_turret;
	logic [7:0] tank2_base;
	logic [7:0] tank1_turret;
	logic [7:0] tank1_base;

	logic [7:0] fire_scc[tank_num]; // fire slow clock counter
	logic [7:0] next_fire_scc[tank_num]; // fire slow clock counter


	// attribute registers for tank
	logic [9:0] alive_bullet_cnt[tank_num][ARRAY_SIZE]; // not 0 means alive, incremented by 1 every frame

	logic [9:0] speed[`TANK_NUM];
	
	assign tank2_turret = keycode[7:0];
	assign tank2_base = keycode[15:8];
	assign tank1_turret = keycode[23:16];
	assign tank1_base = keycode[31:24];
    // shouldn't reuse 
	logic [7:0] i;
	logic [7:0] idx[tank_num]; 
	// logic [7:0]  hole_ind[tank_num];
	

    always_ff @ (posedge Reset or posedge frame_clk )
	begin
		if (Reset)  // Asynchronous Reset
        begin 
			tank_x[0]    <= tank_X1_initial;
			tank_y[0]    <= tank_Y1_initial;
			tank_x[1]	   <= tank_X2_initial;
			tank_y[1]	   <= tank_Y2_initial;
			base_direction[0] <= base_direction_initial;
			turret_direction[0] <= turret_direction_initial;
			base_direction[1] <= base_direction_initial;
			turret_direction[1] <= turret_direction_initial;
			fire[0] <= 0;
			fire[1] <= 0;
			fire_scc[0] <= 0;
			fire_scc[1] <= 0;
			speed[0] <= `DEFAULT_SPEED;
			speed[1] <= `DEFAULT_SPEED;
			for(i = 0; i < tank_num; i++) begin
				for(idx[i] = 0; idx[i] < ARRAY_SIZE; idx[i]++) begin
					bullet_array[i][idx[i]] <= 0;
					alive_bullet_cnt[i][idx[i]] <= 0;
				end
				hole_ind[i] <= ARRAY_SIZE;
			end
        end
		else begin
			for(i = 0; i < tank_num; i++) begin // for each tank
				tank_x[i] <= next_tank_x[i];
				tank_y[i] <= next_tank_y[i];
				base_direction[i] <= next_base_direction[i];
				turret_direction[i] <= next_turret_direction[i];
				if(1 == (fire_scc[i] & (fire_scc_num - 1)) ) fire[i] <= 0; // reset in the first frame
				else fire[i] <= next_fire[i];

				fire_scc[i] <= next_fire_scc[i];
				
				if(to_speed[i]) speed[i] <= speed[i] << 1;

				if(fire[i] && !(fire_scc[i] & (fire_scc_num - 1)) ) begin
					// check for hole in bullet array, at ARRAY_SIZE, it's a dummy node meaning it must be a hole
					// for(idx[i] = ARRAY_SIZE + 1; idx[i] > 0; idx[i] = idx[i] - 1)
					// 	if(!(bullet_array[i][idx[i] - 1] & 1)) 
					// 	begin
					// 		hole_ind[i] <= idx[i] - 1;
					// 	end 
					if(!(bullet_array[i][0] & 1)) 
						hole_ind[i] <= 0;
					else if(!(bullet_array[i][1] & 1)) 
						hole_ind[i] <= 1;
					else if(!(bullet_array[i][2] & 1)) 
						hole_ind[i] <= 2;
					else if(!(bullet_array[i][3] & 1)) 
						hole_ind[i] <= 3;
					else if(!(bullet_array[i][4] & 1)) 
						hole_ind[i] <= 4;
					else if(!(bullet_array[i][5] & 1)) 
						hole_ind[i] <= 5;
					else if(!(bullet_array[i][6] & 1)) 
						hole_ind[i] <= 6;
					else if(!(bullet_array[i][7] & 1)) 
						hole_ind[i] <= 7;
					else
						hole_ind[i] <= ARRAY_SIZE;
				end else begin
					hole_ind[i] <= ARRAY_SIZE;
				end

				for(idx[i] = 0; idx[i] < ARRAY_SIZE; idx[i]++) // if not a hole, and it exists, update it
					if(idx[i] != hole_ind[i]) begin // we've already cleared next_bullet_array when current bullet doesn't exist
						if((bullet_array[i][idx[i]] & 1) && alive_bullet_cnt[i][idx[i]]) begin
							bullet_array[i][idx[i]] <= next_bullet_array[i][idx[i]];	
							alive_bullet_cnt[i][idx[i]] <= alive_bullet_cnt[i][idx[i]] + 1;
						end else begin 
							alive_bullet_cnt[i][idx[i]] <= 0;
							bullet_array[i][idx[i]] <= 0;
						end
					
					end
					else begin
						case (turret_direction[i][6:4]) //@note dir 0 is up, 1 is up left, 2 is left, 3 is down left, 4 is down, 5 is down right, 6 is right, 7 is up right
							7: bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | ( (tank_x[i] + tank_width) << 9) | ((tank_y[i] - 1) << 19));
							6: bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | ( (tank_x[i] + tank_width) << 9) | ((tank_y[i] + (tank_width >> 1)) << 19));
							5: bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | ( (tank_x[i] + tank_width) << 9) | ((tank_y[i] + tank_height) << 19));
							4: bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | ( (tank_x[i] + (tank_width >> 1))<< 9) | ((tank_y[i] + tank_height) << 19));
							3: bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | ( (tank_x[i] - 1) << 9) | ((tank_y[i] + tank_height) << 19));
							2: bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | ( (tank_x[i] - 1) << 9) | ((tank_y[i] + (tank_width >> 1)) << 19));
							1: bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | ( (tank_x[i] - 1) << 9) | ((tank_y[i] - 1) << 19));
							0: bullet_array[i][hole_ind[i]] <= (1'b1 | (turret_direction[i][6:4] << 1) | ( (tank_x[i] + (tank_width >> 1))<< 9) | ((tank_y[i] - 1) << 19));
						endcase
						alive_bullet_cnt[i][hole_ind[i]] <= 1;
					end
			end
			if(!speed_up && (to_speed[0] || to_speed[1])) speed_up <= 1;
			else speed_up <= 0;
		end
	end
	
	// Below are always_comb blocks : they are used to calculate the next state of the tank position and direction
	
	// tank base
	update_base base1(.keycode(tank1_base), .tank_x(tank_x[0]), .tank_y(tank_y[0]), .base_direction(base_direction[0]),  .wall_pos_reg(wall_pos_reg), .speed(speed[0]),
					.next_tank_x_out(next_tank_x[0]), .next_tank_y_out(next_tank_y[0]), .next_base_direction(next_base_direction[0]));
	update_base base2(.keycode(tank2_base), .tank_x(tank_x[1]), .tank_y(tank_y[1]), .base_direction(base_direction[1]),  .wall_pos_reg(wall_pos_reg), .speed(speed[1]),
					.next_tank_x_out(next_tank_x[1]), .next_tank_y_out(next_tank_y[1]), .next_base_direction(next_base_direction[1]));
	// tank turrent
	update_turret turret1(.keycode(tank1_turret), .turret_direction(turret_direction[0]), .fire(fire[0]), .fire_scc(fire_scc[0]), 
	.next_turret_direction(next_turret_direction[0]), .next_fire(next_fire[0]), .next_fire_scc(next_fire_scc[0]));
	update_turret turret2(.keycode(tank2_turret), .turret_direction(turret_direction[1]), .fire(fire[1]), .fire_scc(fire_scc[1]),
	.next_turret_direction(next_turret_direction[1]), .next_fire(next_fire[1]), .next_fire_scc(next_fire_scc[1]));
	// tank bullet : allow each tank to have up to 8 bullets on the screen at once 
	ball ball01(.bullet(bullet_array[0][0]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[0][0]), 
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[0]));
	ball ball02(.bullet(bullet_array[0][1]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[0][1]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[1]));
	ball ball03(.bullet(bullet_array[0][2]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[0][2]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[2]));
	ball ball04(.bullet(bullet_array[0][3]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[0][3]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[3]));
	ball ball05(.bullet(bullet_array[0][4]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[0][4]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[4]));
	ball ball06(.bullet(bullet_array[0][5]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[0][5]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[5]));
	ball ball07(.bullet(bullet_array[0][6]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[0][6]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[6]));
	ball ball08(.bullet(bullet_array[0][7]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[0][7]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[7]));
	ball ball11(.bullet(bullet_array[1][0]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[1][0]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[8]));
	ball ball12(.bullet(bullet_array[1][1]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[1][1]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[9]));
	ball ball13(.bullet(bullet_array[1][2]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[1][2]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[10]));
	ball ball14(.bullet(bullet_array[1][3]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[1][3]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[11]));
	ball ball15(.bullet(bullet_array[1][4]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[1][4]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[12]));
	ball ball16(.bullet(bullet_array[1][5]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[1][5]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[13]));
	ball ball17(.bullet(bullet_array[1][6]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[1][6]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[14]));
	ball ball18(.bullet(bullet_array[1][7]), .wall_pos_reg(wall_pos_reg), .next_bullet(next_bullet_array[1][7]),
	.tank_x(tank_x), .tank_y(tank_y), .hit(hit[15]));

    assign tank_x1out = tank_x[0];
	assign tank_x2out = tank_x[1];
	assign tank_y1out = tank_y[0];
	assign tank_y2out = tank_y[1];
	assign base1_directionout = base_direction[0];
	assign base2_directionout = base_direction[1];
	assign turret1_directionout = turret_direction[0][6:4];
	assign turret2_directionout = turret_direction[1][6:4];

endmodule





