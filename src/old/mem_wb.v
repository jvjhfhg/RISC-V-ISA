module mem_wb(
    input wire                  clk,
    input wire                  rst,
    
    input wire[`REG_ADDR_BUS]   mem_wd,
    input wire                  mem_wreg,
    input wire[`REG_BUS]        mem_wdata,
    
    output reg[`REG_ADDR_BUS]   wb_wd,
    output reg                  wb_wreg,
    output reg[`REG_BUS]        wb_wdata
);
    always @ (posedge clk) begin
        if (rst == `ENABLE) begin
            wb_wd       <= `NOP_REG_ADDR;
            wb_wreg     <= `DISABLE;
            wb_wdata    <= `ZERO_32;
        end else begin
            wb_wd       <= mem_wd;
            wb_wreg     <= mem_wreg;
            wb_wdata    <= mem_wdata;
        end
    end
endmodule
