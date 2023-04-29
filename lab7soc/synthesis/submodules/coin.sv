/**
* @file coins.sv
* @brief coins event engine : update coin and score
* gold coin will have value 3, silver and copper will have value 2 and 1 respectively
* We have tanks position and coins's position, then we can update the score correspondingly
*/
`define COIN_NUM        3
`define TANK_NUM        2
// real value of coins(on screen) will be 10 times of the value below
// that's done by software
`define GOLD_COIN_VAL   3
`define SILVER_COIN_VAL 2
`define BRONZE_COIN_VAL 1

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

`define COUNTER_MASK                    ((1<<21) - 1)
`define COUNTER_INC                     (1<<21)


module coins(
    input logic Reset, CLK,
    input  logic AVL_WRITE,					// Avalon-MM Write
    input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
    input logic [9:0] tank_x[`TANK_NUM], tank_y[`TANK_NUM],
    output logic [31:0] score_attr_reg[`TANK_NUM],
    output logic [31:0] coin_attr_reg_out[`COIN_NUM]
);
    logic [9:0] coin_x[`COIN_NUM], coin_y[`COIN_NUM];
    logic [31:0] coin_attr_reg[`COIN_NUM]; // 0 is gold, 1 is silver, 2 is copper : (valid bit, x, y) from LSB to MSB, other bits are reserved
    logic [3:0] i, j, k, p;
    logic [25:0] coin_cnt; // 50MHz clock counter for coin make frame advance every second

    parameter [9:0] tank_width = 32;
	parameter [9:0] tank_height = 32;
    always_ff @(posedge Reset or posedge CLK) begin
        if(Reset) begin
            for(i = 0; i < `TANK_NUM; i = i + 1) begin
                score_attr_reg[i] <= 0;
            end
            for(k = 0; k < `COIN_NUM; k = k + 1) begin
                coin_attr_reg[k] <= 0;
            end
            coin_cnt <= 0;
        end else if(AVL_WRITE && AVL_ADDR[11] && AVL_ADDR <=`COIN_ATTR_REG_END && AVL_ADDR > `GAME_ATTR_REG_END)  // avoid multi-driver by putting AVALON write and hardware write together
            coin_attr_reg[AVL_ADDR - `GAME_ATTR_REG_END - 1] <= AVL_WRITEDATA;
        else if (AVL_WRITE && AVL_ADDR[11] && AVL_ADDR <= `SCORE_ATTR_REG_END && AVL_ADDR > `HEALTH_ATTR_REG_END) // avoid multi-driver by putting AVALON write and hardware write together
            score_attr_reg[AVL_ADDR - `HEALTH_ATTR_REG_END - 1] <= AVL_WRITEDATA;
        else begin
            for(p = 0; p < `COIN_NUM; p = p + 1) begin
                coin_x[p] <= coin_attr_reg[p][10:1];
                coin_y[p] <= coin_attr_reg[p][20:11];
            end
            // if coin is in the tank's range, then update the score, tank's upper left corner is tank_x, tank_y
            if(coin_attr_reg[0][0] && coin_x[0] >= tank_x[0] && coin_x[0] < tank_x[0] + tank_width 
            && coin_y[0] >= tank_y[0] && coin_y[0] < tank_y[0] + tank_height) begin // if tank 0 hits any coins
                score_attr_reg[0] <= score_attr_reg[0] + `GOLD_COIN_VAL;
                // remove the coin, set the coin's valid bit to 0
                coin_attr_reg[0][0] <= 1'b0;
            end 
            else if(coin_attr_reg[0][0] && coin_x[0] >= tank_x[1] && coin_x[0] < tank_x[1] + tank_width
            && coin_y[0] >= tank_y[1] && coin_y[0] < tank_y[1] + tank_height) begin // if tank 1 hits any coins
                score_attr_reg[1] <= score_attr_reg[1] + `GOLD_COIN_VAL;
                // remove the coin, set the coin's valid bit to 0
                coin_attr_reg[0][0] <= 1'b0;
            end 

            // for coin 2 silver coin 
            else if(coin_attr_reg[1][0] && coin_x[1] >= tank_x[0] && coin_x[1] < tank_x[0] + tank_width
            && coin_y[1] >= tank_y[0] && coin_y[1] < tank_y[0] + tank_height) begin // if tank 0 hits any coins
                score_attr_reg[0] <= score_attr_reg[0] + `SILVER_COIN_VAL;
                // remove the coin, set the coin's valid bit to 0
                coin_attr_reg[1][0] <= 1'b0;
            end 
            else if(coin_attr_reg[1][0] && coin_x[1] >= tank_x[1] && coin_x[1] < tank_x[1] + tank_width
            && coin_y[1] >= tank_y[1] && coin_y[1] < tank_y[1] + tank_height) begin // if tank 1 hits any coins
                score_attr_reg[1] <= score_attr_reg[1] + `SILVER_COIN_VAL;
                // remove the coin, set the coin's valid bit to 0
                coin_attr_reg[1][0] <= 1'b0;
            end 

            // for coin 3 copper coin
            else if(coin_attr_reg[2][0] && coin_x[2] >= tank_x[0] && coin_x[2] < tank_x[0] + tank_width
            && coin_y[2] >= tank_y[0] && coin_y[2] < tank_y[0] + tank_height) begin // if tank 0 hits any coins
                score_attr_reg[0] <= score_attr_reg[0] + `BRONZE_COIN_VAL;
                // remove the coin, set the coin's valid bit to 0
                coin_attr_reg[2][0] <= 1'b0;
            end 
            else if(coin_attr_reg[2][0] && coin_x[2] >= tank_x[1] && coin_x[2] < tank_x[1] + tank_width
            && coin_y[2] >= tank_y[1] && coin_y[2] < tank_y[1] + tank_height) begin // if tank 1 hits any coins
                score_attr_reg[1] <= score_attr_reg[1] + `BRONZE_COIN_VAL;
                // remove the coin, set the coin's valid bit to 0
                coin_attr_reg[2][0] <= 1'b0;
            end 
            // no tank hits any coins, so update the coin's frame number
            else begin 
                coin_cnt <= coin_cnt + 1;
                if(coin_cnt == 0) begin
                    for(j = 0; j < `COIN_NUM; j = j + 1) begin
                        if((coin_attr_reg[j] >> 21) >= 7) coin_attr_reg[j] <= coin_attr_reg[j] & `COUNTER_MASK; // clear the counter 
                        else coin_attr_reg[j] <= coin_attr_reg[j] + `COUNTER_INC; // update coin's frame number
                    end
                end
            end
        end
    end

    assign coin_attr_reg_out = coin_attr_reg;


endmodule

