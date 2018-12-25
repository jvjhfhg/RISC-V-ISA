module ex(
    input wire                  rst,
    
    input wire[`ALU_OP_BUS]     aluop_i,
    input wire[`ALU_SEL_BUS]    alusel_i,
    input wire[`REG_BUS]        reg1_i,
    input wire[`REG_BUS]        reg2_i,
    input wire[`REG_ADDR_BUS]   wd_i,
    input wire                  wreg_i,
    
    output reg[`REG_ADDR_BUS]   wd_o,
    output reg                  wreg_o,
    output reg[`REG_BUS]        wdata_o
);
    reg[`REG_BUS] logic_out;
    
    always @ (*) begin
        if (rst == `ENABLE) begin
            logic_out <= `ZERO_32;
        end else begin
            case (aluop_i)
                `EXE_OR_OP: begin
                
                end
            endcase
        end
    end
endmodule
