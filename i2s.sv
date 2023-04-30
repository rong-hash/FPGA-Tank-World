// each time we feeed 24 bits package to the module, it will update(feed) 1 bit data_out every sclk neg edge
// the output will be digested every posedge of sclk    
module i2s(
    input logic clk, sclk, lrclk, rst, start,
    output logic data_out
);
    logic pre_sclk, pre_lrclk;
    logic [8:0] pkg;
    logic [14:0] addr;
    logic [7:0] data;
    logic hold, lock;

    explosion_rom sample_cache(
        .clk(clk),
        .addr(addr),
        .q(data)
    );

    always_ff @ (posedge clk or posedge rst) begin
        if(rst) begin
            pkg <= 9'b0;
            addr <= 15'b0;
            lock <= 0;
        end else if(hold) begin
            pkg <= 9'b0;
            addr <= 15'b0;
            if(start && !lock) hold <= 0;
            if(!start) lock <= 0;
        end else if(pre_lrclk && !lrclk) begin // lrclk negedge
            pkg <= {1'b0, data};
            lock <= 1;
        end else if(!pre_lrclk && lrclk) begin // lrclk posedge
            pkg <= {1'b0, data};
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

