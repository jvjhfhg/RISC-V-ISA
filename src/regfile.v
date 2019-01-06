module regfile(
    input wire clk,
    input wire rst,
    
    input wire                  we,
    input wire[`REG_ADDR_BUS]   waddr,
    input wire[`REG_BUS]        wdata,
    
    input wire                  re1,
    input wire[`REG_ADDR_BUS]   raddr1,
    output reg['REG_BUS]        rdata1,
    
    input wire                  re2,
    input wire[`REG_ADDR_BUS]   raddr2,
    output reg[`REG_BUS]        rdata2
);
    reg[`REG_BUS] regs[0:`REG_NUM - 1];
    
    always @ (posedge clk) begin
        if (rst == `ENABLE) begin
            if (we == `ENABLE && waddr != `REG_NUM_LOG2'h0) begin
                regs[waddr] <= wdata;
            end
        end
    end
    
    always @ (*) begin
        if (rst == `ENABLE) begin
            rdata1 <= `ZERO_32;
        end else if (raddr1 == `REG_NUM_LOG2'h0) begin
            rdata1 <= `ZERO_32;
        end else if (raddr1 == waddr && we == `ENABLE && re1 == `ENABLE) begin
            rdata1 <= wdata;
        end else if (re1 == `ENABLE) begin
            rdata1 <= regs[raddr1];
        end else begin
            rdata1 <= `ZERO_32;
        end
    end
    
    always @ (*) begin
        if (rst == `ENABLE) begin
            rdata2 <= `ZERO_32;
        end else if (raddr2 == `REG_NUM_LOG2'h0) begin
            rdata2 <= `ZERO_32;
        end else if (raddr2 == waddr && we == `ENABLE && re2 == `ENABLE) begin
            rdata2 <= wdata;
        end else if (re2 == `ENABLE) begin
            rdata2 <= regs[raddr2];
        end else begin
            rdata2 <= `ZERO_32;
        end
    end
endmodule
