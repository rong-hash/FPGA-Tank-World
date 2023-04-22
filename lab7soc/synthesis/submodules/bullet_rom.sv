module bullet_rom (
	input logic clock,
	input logic [5:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:63] /* synthesis ram_init_file = "./bullet/bullet.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
