module coin_gold_rom (
	input logic clock,
	input logic [12:0] address,
	output logic [2:0] q
);

logic [2:0] memory [0:8191] /* synthesis ram_init_file = "./coin_gold/coin_gold.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
