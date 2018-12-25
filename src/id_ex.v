`include "defines.v"

module id_ex(
    input wire                  clk,
    input wire                  rst,
    
    input wire[`ALU_OP_BUS]     id_aluop,
    input wire[`ALU_SEL_BUS]    id_alusel,
    input wire[`REG_BUS]        id_reg1,
    input wire[`REG_BUS]        id_reg2,
    input wire[`REG_ADDR_BUS]   id_wd,
    input wire                  id_wreg,
    
    output reg[`ALU_OP_BUS]     ex_aluop,
    output reg[`ALU_SEL_BUS]    ex_alusel,
    output reg[`REG_BUS]        ex_reg1,
    output reg[`REG_BUS]        ex_reg2,
    output reg[`REG_ADDR_BUS]   ex_wd,
    output reg                  ex_wreg
);
    always @ (posedge clk) begin
        if (rst == `ENABLE) begin
            ex_aluop    <= `EXE_NOP_OP;
            ex_alusel   <= `EXE_RES_NOP;
            ex_reg1     <= `ZERO_32;
            ex_reg2     <= `ZERO_32;
            ex_wd       <= `NOP_REG_ADDR;
            ex_wreg     <= `DISABLE;
        end else begin
            ex_aluop    <= id_aluop;
            ex_alusel   <= id_alusel;
            ex_reg1     <= id_reg1;
            ex_reg2     <= id_reg2;
            ex_wd       <= id_wd;
            ex_wreg     <= id_wreg;
        end
    end
endmodule
