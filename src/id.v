`include "defines.v"

module id(
    input wire                  rst,
    input wire[`INST_ADDR_BUS]  pc_i,
    input wire[`INST_BUS]       inst_i,
    
    input wire[`REG_BUS]        reg1_data_i,
    input wire[`REG_BUS]        reg2_data_i,
    
    output reg                  reg1_read_o,
    output reg                  reg2_read_o,
    output reg[`REG_ADDR_BUS]   reg1_addr_o,
    output reg[`REG_ADDR_BUS]   reg2_addr_o,
    
    output reg[`ALU_OP_BUS]     aluop_o,
    output reg[`ALU_SEL_BUS]    alusel_o,
    output reg[`REG_BUS]        reg1_o,
    output reg[`REG_BUS]        reg2_o,
    output reg[`REG_ADDR_BUS]   wd_o,
    output reg                  wreg_o
);
    wire[5:0] op = inst_i[31:26];
    wire[4:0] op2 = inst_i[10:6];
    wire[5:0] op3 = inst_i[5:0];
    wire[4:0] op4 = inst_i[20:16];
    
    reg[`RegBus] imm;
    
    reg inst_valid;
    
    always @ (*) begin
        if (rst == `ENABLE) begin
            aluop_o     <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o        <= `NOP_REG_ADDR;
            wreg_o      <= `DISABLE;
            inst_valid  <= `INVALID;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NOP_REG_ADDR;
            reg2_addr_o <= `NOP_REG_ADDR;
            imm         <= `ZERO_32;
        end else begin
            aluop_o     <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o        <= inst_i[15:11];
            wreg_o      <= `DISABLE;
            inst_valid  <= `INVALID;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_i[25:21];
            reg2_addr_o <= inst_i[20:16];
            imm         <= `ZERO_32;
            
            case (op)
                `EXE_OPI: begin
                    wreg_o      <= `ENABLE;
                    aluop_o     <= `EXE_OR_OP;
                    alusel_o    <= `EXE_RES_LOGIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imm         <= {16'h0, inst_i[15:0]};
                    wd_o        <= inst_i[20:16];
                    inst_valid  <= `VALID;
                end
                // TODO
                default:;
            endcase
        end
    end
    
    always @ (*) begin
        if (rst == `ENABLE) begin
            reg1_o <= `ZERO_32;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;
        end else if (reg1_read_o == 1'b0) begin
            reg1_o <= imm;
        end else begin
            reg1_o <= `ZERO_32;
        end
    end
    
    always @ (*) begin
        if (rst == `ENABLE) begin
            reg2_o <= `ZERO_32;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o <= imm;
        end else begin
            reg2_o <= `ZERO_32;
        end
    end
endmodule
