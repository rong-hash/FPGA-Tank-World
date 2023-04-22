module coin_silver_rom (
	input logic clock,
	input logic [10:0] address,
	output logic [7:0] q
);

logic [7:0] memory [0:2047] /* synthesis ram_init_file = "./coin_silver/coin_silver.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
