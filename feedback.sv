/**
* @file feedback.sv
* @brief from hardware, we gather information, reporting to software.
* @note This will NOT support write to those registers through avalon bus.
* IMPORTANT: DO NOT WRITE TO THOSE REGISTERS THROUGH AVALON BUS : this is caused by the fact that we're updating all
* register in frame clock. Even we enable write, the request will be ignored(unless you are super lucky).
*/
`define NUM_REGS 						601 //80*30 characters / 4 characters per register
`define CTRL_REG 						600 //index of control register
`define NUM_PALETTE 					8
`define PALETTE_END  					2055
`define CTRL_REG_END 					2056
`define GAME_ATTR_REG_END 				2057
`define COIN_ATTR_REG_END 				2060
`define HEALTH_ATTR_REG_END				2062
`define SCORE_ATTR_REG_END 				2064
`define INIT_POS_REG_END 				2066
`define WALL_POS_REG_END 				2082
`define BULLET_NUM_REG_END 				2084
`define TANK_POS_REG_END 				2086
`define INIT_HEALTH                     5

`define COIN_NUM 						3
`define TANK_NUM 						2
`define BULLET_NUM                      8
`define WALL_NUM 					    16

// below are READ ONLY registers : DO NOT WRITE TO THEM
module feedback(
    input logic Reset, frame_clk,            // Clock and Reset
    input  logic AVL_WRITE,					// Avalon-MM Write
    input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
    input logic  [31:0] bullet_array[`TANK_NUM][`BULLET_NUM],  // bullet array
    input logic [9:0] tank_x[`TANK_NUM], tank_y[`TANK_NUM],
    input logic hit[`TANK_NUM * `BULLET_NUM][`TANK_NUM], // hit[i][j] = 1 means bullet i hit tank j
    output logic [31:0] bullet_num_reg[`TANK_NUM], tank_pos_reg[`TANK_NUM],
    output logic [31:0] health_attr_reg_out[`TANK_NUM]
);  

logic [31:0] health_attr_reg[`TANK_NUM];

always_ff @(posedge Reset or posedge frame_clk ) begin
	int i, j, k;
    if(Reset) begin
        // initialize bullet number register and tank position register
        for(i = 0; i < `TANK_NUM; i = i + 1) begin
            bullet_num_reg[i] <= 0;
            tank_pos_reg[i] <= 0;
            health_attr_reg[i] <= 5;
        end
    end else begin
        
        // get bullet number and put it into corresponding register
        for(i = 0; i < `TANK_NUM; i = i + 1) begin
            bullet_num_reg[i] <= `BULLET_NUM - (bullet_array[i][0][0] + bullet_array[i][1][0] + bullet_array[i][2][0] 
                                + bullet_array[i][3][0] + bullet_array[i][4][0] + bullet_array[i][5][0] 
                                + bullet_array[i][6][0] + bullet_array[i][7][0]);
        end

        // get tank position and put it into corresponding register
        for(i = 0; i < `TANK_NUM; i = i + 1) 
            tank_pos_reg[i] <= 1 | (tank_x[i] << 1) | (tank_y[i] << 11);
        
        // have to make this read only because hit is updated every frame clock cycle
        for(k = 0; k < `TANK_NUM; k = k + 1) begin
            health_attr_reg[k] <= health_attr_reg[k] - hit[0][k] - hit[1][k] - hit[2][k] - 
            hit[3][k] - hit[4][k] - hit[5][k] - hit[6][k] - hit[7][k] - hit[8][k] - hit[9][k] - 
            hit[10][k] - hit[11][k] - hit[12][k] - hit[13][k] - hit[14][k] - hit[15][k];
        end

        
    end
end

assign health_attr_reg_out = health_attr_reg;


endmodule