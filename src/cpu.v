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
    
    output wire[31:0]           dbgreg_dout     // cpu register output (debugging demo)
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
    
    reg[31:0] regs[0:31];
    reg[31:0] pc;
    reg[31:0] inst;
    reg[3:0] stage;
    
    initial stage = 4'h0;
    
    /* reg[6:0] opcode;
    reg[2:0] funct3;
    reg[6:0] funct7; */
    
    always @ (posedge clk_in) begin
        if (rst_in == 1'b1) begin
            pc      <= 32'b0;
            stage   <= 4'b0;
        end else if (rdy_in == 1'b0) begin
            
        end else begin
            case (stage)
                4'h0: begin // IF stage 1
                    mem_wr      <= 1'b0;
                    mem_a       <= pc;
                    
                    stage       <= stage + 1;
                end
                
                4'h1: begin // IF stage 2
                    mem_wr      <= 1'b0;
                    mem_a       <= pc + 1;
                    
                    stage       <= stage + 1;
                end
                
                4'h2: begin // IF stage 3
                    mem_wr      <= 1'b0;
                    mem_a       <= pc + 2;
                    
                    inst[7:0]   <= mem_din;
                    
                    stage       <= stage + 1;
                end
                
                4'h3: begin // IF stage 4
                    mem_wr      <= 1'b0;
                    mem_a       <= pc + 3;
                    
                    inst[15:8]  <= mem_din;
                    
                    pc          <= pc + 4;
                    stage       <= stage + 1;
                end
                
                4'h4: begin // IF stage 5
                    inst[23:16] <= mem_din;
                    
                    stage       <= stage + 1;
                end
                
                4'h5: begin // IF stage 6
                    inst[31:24] <= mem_din;
                    
                    stage       <= stage + 1;
                end
                
                default: begin // IF ends
                    case (inst[6:0])
                        7'b0110111: begin // LUI
                            case (stage)
                                4'h6: begin // WB stage
                                    regs[inst[11:7]]    <= {inst[31:12], 12'b0};
                                    stage               <= 4'h0;
                                end
                            endcase
                        end
                        
                        7'b0010111: begin // AUIPC
                            case (stage)
                                4'h6: begin // WB stage
                                    regs[inst[11:7]]    <= pc - 4 + {inst[31:12], 12'b0};
                                    stage               <= 4'h0;
                                end
                            endcase
                        end
                        
                        7'b1101111: begin // JAL
                            case (stage)
                                4'h6: begin // WB stage
                                    regs[inst[11:7]]    <= pc;
                                    pc                  <= pc - 4 + {12{inst[31]}, inst[19:12], inst[20], inst[30:21], 1'b0};
                                    stage               <= 4'h0;
                                end
                            endcase
                        end
                        
                        7'b1100111: begin // JALR
                            
                        end
                        
                        7'b1100011: begin // BEQ BNE BLT BGE BLTU BGEU
                            
                        end
                        
                        7'b0000011: begin // LB LH LW LBU LHU
                            
                        end
                        
                        7'b0100011: begin // SB SH SW
                            
                        end
                        
                        7'b0010011: begin // ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI
                            
                        end
                        
                        7'b0110011: begin // ADD SUB SLL SLT SLTU XOR SRL SRA OR AND
                            
                        end
                    endcase
                end
            endcase
        end
    end
endmodule
