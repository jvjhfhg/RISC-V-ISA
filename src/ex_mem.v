module ex_mem(
    input wire                  clk,
    input wire                  rst,
    
    input wire[`REG_ADDR_BUS]   ex_wd,
    input wire                  ex_wreg,
    input wire[`REG_BUS]        ex_wdata,
    
    output wire[`REG_ADDR_BUS]  mem_wd,
    output wire                 mem_wreg,
    output wire[`REG_BUS]       mem_wdata
);
    always @ (posedge clk) begin
        if (rst == `ENABLE) begin
            mem_wd      <= `NOP_REG_ADDR;
            mem_wreg    <= `DISABLE;
            mem_wdata   <= `ZERO_32;
        end else begin
            mem_wd      <= ex_wd;
            mem_wreg    <= ex_wreg;
            mem_wdata   <= ex_wdata;
        end
    end
endmodule
