module ALU_v2 #(
    parameter BUS_WIDTH  = 8
) (
    input  logic                 clk, 
    input  logic [BUS_WIDTH-1:0] imm,
    input  logic [BUS_WIDTH-1:0] data_a,    
    input  logic [BUS_WIDTH-1:0] data_b,    
    input  logic [2:0]           reg_en,
    input  logic                 f_clr,
    output logic [BUS_WIDTH-1:0] result 
);       


// the multiplier part

logic [BUS_WIDTH-1:0] mult_a, mult_b, add_a, add_b;

ALU_mult_stage #(
    BUS_WIDTH
) am1 (
    .clk   (clk      ),
    .f_clr (f_clr    ),
    .b_en  (reg_en[0]), 
    .d_en  (reg_en[1]),
    .data_a(data_a   ),
    .data_b(data_b   ),
    .imm   (imm      ),
    .mult_a(mult_a   ),
    .mult_b(mult_b   )
);

// the adder part 

logic [BUS_WIDTH-1:0] op_e, e_add, coeff;
logic [BUS_WIDTH-1:0] op_e_reg;

always_ff @( posedge clk ) begin
    if (reg_en[2])
        op_e_reg <= imm;
end

sfixed_adder #(
    7, 
    0, 
    7, 
    0,
    7, 
    0
) a0 ( 
    .a  (mult_a), // int
    .b  (mult_b), // int
    .out(add_a )
);

sfixed_adder #(
    7, 
    0, 
    7, 
    0,
    7, 
    0
) a1 (  
    .a  (add_a   ), // int
    .b  (op_e_reg), // int
    .out(result  )
);

endmodule 


