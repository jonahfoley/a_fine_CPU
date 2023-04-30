module register_file #(
    parameter BUS_WIDTH = 8,
    parameter DEPTH     = 3
) (
	input  logic                     clk, 
	input  logic                     we,
 	input  logic [$clog2(DEPTH)-1:0] wr_addr,
	input  logic [BUS_WIDTH-1:0]     wr_data,
 	input  logic [$clog2(DEPTH)-1:0] rd_addr_a, rd_addr_b,
 	output logic [BUS_WIDTH-1:0]     rd_data_a, rd_data_b
);

dual_port_SRAM #(
	BUS_WIDTH,
	DEPTH
) sr0 (
	.clk      (clk      ), 
	.we_a     (we       ),
	.we_b     ('0       ),
 	.wr_addr_a(wr_addr  ),
 	.wr_addr_b('0       ),
	.wr_data_a(wr_data  ),
	.wr_data_b('0       ),
 	.rd_addr_a(rd_addr_a), 
	.rd_addr_b(rd_addr_b),
 	.rd_data_a(rd_data_a), 
	.rd_data_b(rd_data_b)
);

endmodule
