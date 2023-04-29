module i2s_input(input logic clk, sclk, lrclk, data_in,
				output [31:0] l_out, r_out
//				Uncomment the next line to get single channel
				// output [31:0] Data_Out
				);
				
logic [31:0] sampled_data; 


always_ff @ (posedge sclk) 
	begin
	sampled_data <= {sampled_data[30:0], data_in};
	end

// REMEMBER THAT THE FIRST BIT OF THIS DATA IS USELESS

always_ff @ (posedge lrclk) 
	begin
	l_out <= sampled_data;
	end

always_ff @ (negedge lrclk) 
	begin
	r_out <= sampled_data;
	end

// Technically we do not need LR audio control, so we can just dump the LR all to one register

//Uncomment this Block for single channel at double sampling rate, also we need to modify this to t

//always_ff @ (posedge lrclk or negedge lrclk) 
//	begin
//	Out <= data
//	end
	
endmodule 


module i2s_output (input clk, 
        sclk, 
        lrclk, 
        input [31:0] data_l, data_r,
        output d_out);
    logic [31:0] l_sample, r_sample;

    always_comb
    begin
        if (!lrclk)
        begin
        d_out = l_sample[31];
        end
        else
        begin
        d_out = r_sample[31];
        end
    end

    always_ff @ (posedge sclk)
    begin
        
        if (!lrclk)
            begin
            l_sample <= {l_sample[30:0], 1'b0};
            r_sample <= data_r;
            end
        else
            begin
            r_sample <= {r_sample[30:0], 1'b0};
            l_sample <= data_l;
            end
        
    end

endmodule
