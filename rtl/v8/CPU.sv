module CPU #(
    parameter INSTR_WIDTH      = 24,
    parameter OPCODE_WIDTH     = 3,
    parameter INSTR_ADDR_WIDTH = 4, 
    parameter REG_ADDR_WIDTH   = 2, 
    parameter BUS_WIDTH        = 8
) (
    input  logic                 clk,  
    input  logic                 n_reset,
    input  logic [BUS_WIDTH-1:0] in_port,
    input  logic                 ready_in,
    output logic [BUS_WIDTH-1:0] out_port
);       

//the macro to dump signals   
`ifdef COCOTB_SIM
initial begin
    $dumpfile ("CPU.vcd");
    $dumpvars (0, CPU);
    #1;
end
`endif

// input switch handshaking
logic ready_in_p, pattern_match;
always_ff @(posedge clk)
    ready_in_p <= ready_in;

logic [1:0][BUS_WIDTH-1:0] sw;
always_ff @(posedge clk)
    sw <= {sw[0], in_port};

assign pattern_match = (~ready_in_p & ready_in);

// -- instr counter
logic [INSTR_ADDR_WIDTH-1:0] PC_count;
logic PC_en, PC_comparator;

mux_21 #(
    1
) PC_en_mux (
    .s  (instr[3]     ), // differentiate between instr[5:3] == 001 (pattern) / 000 (rdy)
    .a  (pattern_match), // 001 -> pattern
    .b  (ready_in     ), // 000 -> ready in 
    .out(PC_comparator)
);

assign PC_en = ~(f_wait & (PC_comparator ^ instr[0]));

program_counter #(
   INSTR_ADDR_WIDTH
) pc (
   .clk    (clk     ),
   .n_reset(n_reset ),
   .en     (PC_en   ),
   .count  (PC_count)
);

// -- program ROM
logic [INSTR_WIDTH-1:0] instr;

program_memory #(
    INSTR_ADDR_WIDTH,
    INSTR_WIDTH
) pm (
    .addr (PC_count),
    .instr(instr   )
);

// -- reg file
logic wr_res;
logic we;
logic [REG_ADDR_WIDTH-1:0] wr_addr;
logic [BUS_WIDTH-1:0] rd_data_a, rd_data_b;

always_ff @(posedge clk) 
begin
    we      <= wr_res;
    wr_addr <= instr[7:6];
end

register_file #(
    BUS_WIDTH,
    3
) rf (
	.clk      (clk       ),  
    .we       (we        ),
 	.wr_addr  (wr_addr   ),
	.wr_data  (ALU_result),
 	.rd_addr_a(instr[4:3]), 
    .rd_addr_b(instr[1:0]),
 	.rd_data_a(rd_data_a ), 
    .rd_data_b(rd_data_b )
);

// -- decoder
logic f_reg_e, f_load, f_wait;
logic [2:0] reg_en; 

instruction_decoder #(
    OPCODE_WIDTH
) id (
    .opcode    (instr[11:9]),                  
    .f_reg_e   (f_reg_e    ), 
    .f_wait    (f_wait     ),            
    .f_load    (f_load     ),            
    .f_clr     (f_clr      ),            
    .wr_res    (wr_res     ),         
    .ALU_reg_en(reg_en     )
);

// -- ALU
logic [BUS_WIDTH-1:0] ALU_result;
logic ALU_reg_e;

always_ff @(posedge clk)
    ALU_reg_e <= f_reg_e;

ALU_v2 #(
    BUS_WIDTH
) alu (
    .clk    (clk       ), 
    .sw     (sw        ), 
    .imm    (instr[7:0]),
    .data_a (rd_data_a ),
    .data_b (rd_data_b ),   
    .reg_en (reg_en    ),
    .f_reg_e(ALU_reg_e ),
    .f_load (f_load    ),
    .f_clr  (f_clr     ),
    .result (ALU_result)
);    

assign out_port = ALU_result;

endmodule
