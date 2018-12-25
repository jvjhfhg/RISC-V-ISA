`include "defines.v"

module if_id(
    input wire clk,
    input wire rst,
    
    input wire[`INST_ADDR_BUS]  if_pc,
    input wire[`INST_BUS]       if_inst,
    
    output reg[`INST_ADDR_BUS]  id_pc,
    output reg[`INST_BUS]       id_inst
};
    always @ (posedge clk) begin
        if (res == `ENABLE) begin
            id_pc <= `ZERO_32;
            id_inst <= `ZERO_32;
        end else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule
