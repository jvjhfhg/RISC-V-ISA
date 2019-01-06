module mem(
    input wire                  rst,
    
    input wire[`REG_ADDR_BUS]   wd_i,
    input wire                  wreg_i,
    input wire[`REG_BUS]        wdata_i,
    
    output reg[`REG_ADDR_BUS]   wd_o,
    output reg                  wreg_o,
    output reg[`REG_BUS]        wdata_o
);
    always @ (*) begin
        if (rst == `ENABLE) begin
            wd_o    <= `NOP_REG_ADDR;
            wreg_o  <= `DISABLE;
            wdata_o <= `ZERO_32;
        end else begin
            wd_o    <= wd_i;
            wreg_o  <= wreg_i;
            wdata_o <= wdata_i;
        end
    end
endmodule
