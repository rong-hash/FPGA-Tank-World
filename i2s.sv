// each time we feeed 24 bits package to the module, it will update(feed) 1 bit data_out every sclk neg edge
// the output will be digested every posedge of sclk    
module i2s_input(
    input logic clk, sclk, lrclk,
    input logic [23:0] l_data, r_data,
    output logic data_out
);
    logic pre_sclk, pre_lrclk;
    logic [24:0] pkg;

    sample_cache sample_cache()

    always_ff(posedge clk) begin
        if(pre_lrclk && !lrclk) begin // lrclk negedge
            pkg <= {1'b0, l_data};
        end else if(!pre_lrclk && lrclk) begin // lrclk posedge
            pkg <= {1'b0, r_data};
        end else if(pre_sclk && !sclk) begin // sclk negedge
            data_out <= pkg[23];
            pkg <= {pkg[23:0], 1'b0};
        end
        pre_sclk <= sclk;
        pre_lrclk <= lrclk;
    end
endmodule
