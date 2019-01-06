module pc_reg(
    input wire clk,
    input wire rst,
    
    output reg[`INST_ADDR_BUS]  pc,
    output reg                  ce
);
    always @ (posedge clk) begin
        if (rst == `ENABLE) begin
            ce <= `DISABLE;
        end else begin
            ce <= `ENABLE;
        end
    end
    
    always @ (posedge clk) begin
        if (ce == `DISABLE) begin
            pc <= 32'h00000000;
        end else begin
            pc <= pc + 4'h4;
        end
    end
endmodule
