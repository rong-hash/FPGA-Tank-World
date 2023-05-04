`define SOUND_START_REG_END             1
// each time we feeed 24 bits package to the module, it will update(feed) 1 bit data_out every sclk neg edge
// the output will be digested every posedge of sclk    
module i2s(
    input logic CLK, sclk, lrclk, RESET, start,
    // Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
    output logic data_out
);
    logic pre_sclk, pre_lrclk;
    logic [8:0] pkg;
    logic [14:0] addr;
    logic [7:0] data;
    logic hold, lock;
    logic start_reg;
    always_ff @(posedge CLK or posedge RESET) begin
        if(RESET) begin
            start_reg <= 0;
        end else
        if(AVL_WRITE && AVL_CS) begin
            // if(AVL_ADDR[0] < `SOUND_START_REG_END) begin
                start_reg <= AVL_WRITEDATA[0];
            // end 
        end
        else if(AVL_READ && AVL_CS) begin
            // if(AVL_ADDR[0] < `SOUND_START_REG_END) begin
                AVL_READDATA <= {31'b0, start_reg};
            // end 
        end
    end

    explosion_rom sample_cache(
        .clk(CLK),
        .addr(addr),
        .q(data)
    );

    always_ff @ (posedge CLK or posedge RESET) begin
        if(RESET) begin
            pkg <= 9'b0;
            addr <= 15'b0;
            lock <= 0;
            hold <= 0;
        end else if(hold || !start_reg) begin
            pkg <= 9'b0;
            addr <= 15'b0;
            if(start_reg && !lock) hold <= 0;
            else if(!start_reg) lock <= 0;
        end else if(pre_lrclk && !lrclk) begin // lrclk negedge @note : it implies an sclk negedge
            pkg <= {data, 1'b0};
            data_out <= 0;
            lock <= 1;
        end else if(!pre_lrclk && lrclk) begin // lrclk posedge @note : it implies an sclk negedge
            pkg <= {data, 1'b0};
            data_out <= 0;
            lock <= 1;
            if(addr < 22050) begin // it's the end of explosion
                addr <= addr + 1'b1;
            end else hold <= 1;
        end else if(pre_sclk && !sclk) begin // sclk negedge
            data_out <= pkg[8];
            pkg <= {pkg[7:0], 1'b0};
            lock <= 1;
        end
        pre_sclk <= sclk;
        pre_lrclk <= lrclk;
    end
endmodule