`define TANK_NUM        2
`define WIDTH           32
`define HEIGHT          32

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
`define CURE_REG_END                    2087
`define SPEED_REG_END				    2088

module health_gear(
    input logic Reset, CLK,
    input logic [9:0] tank_x[`TANK_NUM], tank_y[`TANK_NUM],
    input logic AVL_WRITE,					// Avalon-MM Write
    input logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
    input logic cured,
    output logic to_cure[`TANK_NUM],
    output logic [31:0] cure_reg_out
);
    logic [31:0] cure_reg;
    logic [9:0] cure_x, cure_y;
    int i;
    always_comb begin
        cure_x = cure_reg[10:1] + (`WIDTH >> 1);
        cure_y = cure_reg[20:11] + (`HEIGHT >> 1);
        for(i = 0; i < `TANK_NUM; i = i + 1) begin
            to_cure[i] = (cure_x >= tank_x[i] && cure_x < tank_x[i] + `WIDTH 
            && cure_y >= tank_y[i] && cure_y < tank_y[i] + `HEIGHT) ? cure_reg[0] : 0;
        end
    end

    always_ff @ (posedge Reset or posedge CLK) begin
        if(Reset) begin
            cure_reg <= 0;
        end
        else begin
            if(AVL_WRITE && AVL_ADDR[11] && AVL_ADDR <=`CURE_REG_END && AVL_ADDR > `TANK_POS_REG_END)
                cure_reg <= AVL_WRITEDATA;
            else if(cured) cure_reg <= 0;
            
        end
    end

    assign cure_reg_out = cure_reg;
endmodule

module speed_gear(
    input logic Reset, CLK,
    input logic [9:0] tank_x[`TANK_NUM], tank_y[`TANK_NUM],
    input logic AVL_WRITE,					// Avalon-MM Write
    input logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
    input logic speed_up,
    output logic to_speed[`TANK_NUM],
    output logic [31:0] speed_reg_out
);
    logic [31:0] speed_reg;
    int i;
    logic [9:0] speed_x, speed_y;
    always_comb begin
        speed_x = speed_reg[10:1] + (`WIDTH >> 1);
        speed_y = speed_reg[20:11] + (`HEIGHT >> 1);
        for(i = 0; i < `TANK_NUM; i = i + 1) begin
            to_speed[i] = (speed_x >= tank_x[i] && speed_x < tank_x[i] + `WIDTH
            && speed_y >= tank_y[i] && speed_y < tank_y[i] + `HEIGHT) ? speed_reg[0] : 0;
        end
    end

    always_ff @ (posedge Reset or posedge CLK) begin
        if(Reset) begin
            speed_reg <= 0;
        end
        else begin
            if(AVL_WRITE && AVL_ADDR[11] && AVL_ADDR <=`SPEED_REG_END && AVL_ADDR > `CURE_REG_END)
                speed_reg <= AVL_WRITEDATA;
            else if(speed_up) speed_reg <= 0;

        end
    end

    assign speed_reg_out = speed_reg;
endmodule

