module bricks_rom (
	input logic clock,
	input logic [9:0] address,
	output logic [7:0] q
);

logic [7:0] memory [0:1023] /* synthesis ram_init_file = "./bricks/bricks.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
