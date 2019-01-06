// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,         // system clock signal
    input  wire                 rst_in,         // reset signal
    input  wire                 rdy_in,         // ready signal, pause cpu when low
    
    input  wire[7:0]            mem_din,        // data input bus
    output wire[7:0]            mem_dout,       // data output bus
    output wire[31:0]           mem_a,          // address bus (only 17:0 is used)
    output wire                 mem_wr,         // write/read signal (1 for write)
    
    output wire [31:0]          dbgreg_dout     // cpu register output (debugging demo)
);
    // Specifications:
    // - Pause cpu (freeze pc, registers, etc.) when rdy_in is low
    // - Memory read takes 2 cycles (wait till next cycle), write takes 1 cycle (no need to wait)
    // - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
    // - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
    // - 0x30000 read: read a byte from input
    // - 0x30000 write: write a byte to output (write 0x00 is ignored)
    // - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
    // - 0x30004 write: indicates program stop (will output '\0' through uart tx)
    
    // connecting module id
    
    wire[`INST_ADDR_BUS]    pc;
    wire[`INST_ADDR_BUS]    id_pc_i;
    wire[`INST_BUS]         id_inst_i;
    
    wire[`ALU_OP_BUS]       id_aluop_o;
    wire[`ALU_SEL_BUS]      id_alusel_o;
    wire[`REG_BUS]          id_reg1_o;
    wire[`REG_BUS]          id_reg2_o;
    wire                    id_wreg_o;
    wire[`REG_ADDR_BUS]     id_wd_o;
    
    // connecting module ex
    
    wire[`ALU_OP_BUS]       ex_aluop_i;
    wire[`ALU_SEL_BUS]      ex_alusel_i;
    wire[`REG_BUS]          ex_reg1_i;
    wire[`REG_BUS]          ex_reg2_i;
    wire[`REG_ADDR_BUS]     ex_wd_i;
    wire                    ex_wreg_i;
    
    wire[`REG_ADDR_BUS]     ex_wd_o;
    wire                    ex_wreg_o;
    wire[`REG_BUS]          ex_wdata_o;
    
    // connecting module mem
    
    wire[`REG_ADDR_BUS]     mem_wd_i,
    wire                    mem_wreg_i,
    wire[`REG_BUS]          mem_wdata_i,
    
    wire[`REG_ADDR_BUS]     mem_wd_o,
    wire                    mem_wreg_o,
    wire[`REG_BUS]          mem_wdata_o
    
    // connecting module 
    
    always @ (posedge clk_in) begin
        if (rst_in == 1'b1) begin
            
        end else if (rdy_in == 1'b0) begin
            
        end else begin
            
        end
    end
    
    always @ (*) begin
        
    end
endmodule
