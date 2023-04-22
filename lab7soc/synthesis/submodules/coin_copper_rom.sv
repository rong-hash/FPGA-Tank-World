module coin_copper_rom (
	input logic clock,
	input logic [10:0] address,
	output logic [7:0] q
);

logic [7:0] memory [0:2047] /* synthesis ram_init_file = "./coin_copper/coin_copper.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
