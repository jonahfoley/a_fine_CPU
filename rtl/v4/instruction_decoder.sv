`include "opcodes.sv"

module instruction_decoder #(
    parameter OPCODE_WIDTH = 3
) (
    input  logic [OPCODE_WIDTH-1:0] opcode,                  
    output logic                    f_add,            
    output logic                    wr_res,         
    output logic [4:0]              ALU_reg_en
);

always_comb 
begin
    case(opcode)    
        `MOV : begin
            f_add      = '1; 
            wr_res     = '1; 
            ALU_reg_en = 5'b11111; // C, A
        end
        `MAC : begin 
            f_add      = '0;
            wr_res     = '1; 
            ALU_reg_en = 5'b00101; // C, A
        end
        `WAIT: begin
            f_add      = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b00000;
        end
        `SETB: begin
            f_add      = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b00010; 
        end
        `SETD: begin
            f_add      = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b01000;
        end
        `SETE: begin
            f_add      = '0;
            wr_res     = '0;
            ALU_reg_en = 5'b10000;
        end
        default : begin
            f_add      = '0;
            wr_res     = '0;
            ALU_reg_en = '0;
        end
    endcase 
end 

endmodule