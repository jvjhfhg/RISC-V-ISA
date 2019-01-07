module cpu(
    input  wire                 clk_in,
    input  wire                 rst_in,
    input  wire                 rdy_in,

    input  wire[7:0]            mem_din,
    output reg[7:0]             mem_dout,
    output reg[31:0]            mem_a,
    output reg                  mem_wr,

    output wire[31:0]           dbgreg_dout
);
    // Brute Force is art. 

    reg[31:0] regs[0:31];
    reg[31:0] pc;
    reg[31:0] inst;
    reg[3:0] stage;

    initial stage = 4'h0;

    always @ (posedge clk_in) begin
        if (rst_in == 1'b1) begin
            pc      <= 32'b0;
            stage   <= 4'b0;
            regs[0] <= 32'b0;
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
                            regs[inst[11:7]]    <= {inst[31:12], 12'b0};
                            stage               <= 4'h0;
                        end

                        7'b0010111: begin // AUIPC
                            regs[inst[11:7]]    <= pc - 4 + {inst[31:12], 12'b0};
                            stage               <= 4'h0;
                        end

                        7'b1101111: begin // JAL
                            if (inst[11:7] != 0) begin
                                regs[inst[11:7]]    <= pc;
                            end
                            pc                      <= pc - 4 + {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
                            stage                   <= 4'h0;
                        end

                        7'b1100111: begin // JALR
                            if (inst[11:7] != 0) begin
                                regs[inst[11:7]]    <= pc;
                            end
                            pc                      <= {{21{inst[31]}}, inst[30:20]} + regs[inst[19:15]];
                            stage                   <= 4'h0;
                        end

                        7'b1100011: begin // BEQ BNE BLT BGE BLTU BGEU
                            case (inst[14:12])
                                3'b000: begin // BEQ
                                    if (regs[inst[19:15]] == regs[inst[24:20]]) begin
                                        pc <= pc - 4 + {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                                    end
                                    stage <= 4'h0;
                                end

                                3'b001: begin // BNE
                                    if (regs[inst[19:15]] != regs[inst[24:20]]) begin
                                        pc <= pc - 4 + {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                                    end
                                    stage <= 4'h0;
                                end

                                3'b100: begin // BLT
                                    if ($signed(regs[inst[19:15]]) < $signed(regs[inst[24:20]])) begin
                                        pc <= pc - 4 + {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                                    end
                                    stage <= 4'h0;
                                end

                                3'b101: begin // BGE
                                    if ($signed(regs[inst[19:15]]) >= $signed(regs[inst[24:20]])) begin
                                        pc <= pc - 4 + {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                                    end
                                    stage <= 4'h0;
                                end

                                3'b110: begin // BLTU
                                    if (regs[inst[19:15]] < regs[inst[24:20]]) begin
                                        pc <= pc - 4 + {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                                    end
                                    stage <= 4'h0;
                                end

                                3'b111: begin // BGEU
                                    if (regs[inst[19:15]] >= regs[inst[24:20]]) begin
                                        pc <= pc - 4 + {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                                    end
                                    stage <= 4'h0;
                                end
                            endcase
                        end

                        7'b0000011: begin // LB LH LW LBU LHU
                            case (inst[14:12])
                                3'b000: begin // LB
                                    case (stage)
                                        4'h6: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:20]};
                                            stage                   <= stage + 1;
                                        end

                                        4'h7: begin
                                            stage                   <= stage + 1;
                                        end

                                        4'h8: begin
                                            regs[inst[11:7]]        <= {{24{mem_din[7]}}, mem_din};
                                            stage                   <= 4'h0;
                                        end
                                    endcase
                                end

                                3'b001: begin // LH
                                    case (stage)
                                        4'h6: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:20]};
                                            stage                   <= stage + 1;
                                        end

                                        4'h7: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= mem_a + 1;
                                            stage                   <= stage + 1;
                                        end

                                        4'h8: begin
                                            regs[inst[11:7]][7:0]   <= mem_din;
                                            stage                   <= stage + 1;
                                        end

                                        4'h9: begin
                                            regs[inst[11:7]][31:8]  <= {{16{mem_din[7]}}, mem_din};
                                            stage                   <= 4'h0;
                                        end
                                    endcase
                                end

                                3'b010: begin // LW
                                    case (stage)
                                        4'h6: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:20]};
                                            stage                   <= stage + 1;
                                        end

                                        4'h7: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= mem_a + 1;
                                            stage                   <= stage + 1;
                                        end

                                        4'h8: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= mem_a + 1;
                                            regs[inst[11:7]][7:0]   <= mem_din;
                                            stage                   <= stage + 1;
                                        end

                                        4'h9: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= mem_a + 1;
                                            regs[inst[11:7]][15:8]  <= mem_din;
                                            stage                   <= stage + 1;
                                        end

                                        4'ha: begin
                                            regs[inst[11:7]][23:16] <= mem_din;
                                            stage                   <= stage + 1;
                                        end

                                        4'hb: begin
                                            regs[inst[11:7]][31:24] <= mem_din;
                                            stage                   <= 4'h0;
                                        end
                                    endcase
                                end

                                3'b100: begin // LBU
                                    case (stage)
                                        4'h6: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:20]};
                                            stage                   <= stage + 1;
                                        end

                                        4'h7: begin
                                            stage                   <= stage + 1;
                                        end

                                        4'h8: begin
                                            regs[inst[11:7]]        <= {24'b0, mem_din};
                                            stage                   <= 4'h0;
                                        end
                                    endcase
                                end

                                3'b101: begin // LHU
                                    case (stage)
                                        4'h6: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:20]};
                                            stage                   <= stage + 1;
                                        end

                                        4'h7: begin
                                            mem_wr                  <= 1'b0;
                                            mem_a                   <= mem_a + 1;
                                            stage                   <= stage + 1;
                                        end

                                        4'h8: begin
                                            regs[inst[11:7]][7:0]   <= mem_din;
                                            stage                   <= stage + 1;
                                        end

                                        4'h9: begin
                                            regs[inst[11:7]][31:8]  <= {16'b0, mem_din};
                                            stage                   <= 4'h0;
                                        end
                                    endcase
                                end
                            endcase
                        end

                        7'b0100011: begin // SB SH SW
                            case (inst[14:12])
                                3'b000: begin // SB
                                    mem_wr      <= 1'b1;
                                    mem_a       <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:25], inst[11:7]};
                                    mem_dout    <= regs[inst[24:20]][7:0];
                                    stage       <= 4'h0;
                                end

                                3'b001: begin // SH
                                    case (stage)
                                        4'h6: begin
                                            mem_wr      <= 1'b1;
                                            mem_a       <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:25], inst[11:7]};
                                            mem_dout    <= regs[inst[24:20]][7:0];
                                            stage       <= stage + 1;
                                        end

                                        4'h7: begin
                                            mem_wr      <= 1'b1;
                                            mem_a       <= mem_a + 1;
                                            mem_dout    <= regs[inst[24:20]][15:8];
                                            stage       <= 4'h0;
                                        end
                                    endcase
                                end

                                3'b010: begin // SW
                                    case (stage)
                                        4'h6: begin
                                            mem_wr      <= 1'b1;
                                            mem_a       <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:25], inst[11:7]};
                                            mem_dout    <= regs[inst[24:20]][7:0];
                                            stage       <= stage + 1;
                                        end

                                        4'h7: begin
                                            mem_wr      <= 1'b1;
                                            mem_a       <= mem_a + 1;
                                            mem_dout    <= regs[inst[24:20]][15:8];
                                            stage       <= stage + 1;
                                        end

                                        4'h8: begin
                                            mem_wr      <= 1'b1;
                                            mem_a       <= mem_a + 1;
                                            mem_dout    <= regs[inst[24:20]][23:16];
                                            stage       <= stage + 1;
                                        end

                                        4'h9: begin
                                            mem_wr      <= 1'b1;
                                            mem_a       <= mem_a + 1;
                                            mem_dout    <= regs[inst[24:20]][31:24];
                                            stage       <= 4'h0;
                                        end
                                    endcase
                                end
                            endcase
                        end

                        7'b0010011: begin // ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI
                            case (inst[14:12])
                                3'b000: begin // ADDI
                                    regs[inst[11:7]]    <= regs[inst[19:15]] + {{21{inst[31]}}, inst[30:20]};
                                    stage               <= 4'h0;
                                end

                                3'b010: begin // SLTI
                                    regs[inst[11:7]]    <= $signed(regs[inst[19:15]]) < $signed({{21{inst[31]}}, inst[30:20]}) ? 32'b1 : 32'b0;
                                    stage               <= 4'h0;
                                end

                                3'b011: begin // SLTIU
                                    regs[inst[11:7]]    <= regs[inst[19:15]] < {{21{inst[31]}}, inst[30:20]} ? 32'b1 : 32'b0;
                                    stage               <= 4'h0;
                                end

                                3'b100: begin // XORI
                                    regs[inst[11:7]]    <= regs[inst[19:15]] ^ {{21{inst[31]}}, inst[30:20]};
                                    stage               <= 4'h0;
                                end

                                3'b110: begin // ORI
                                    regs[inst[11:7]]    <= regs[inst[19:15]] | {{21{inst[31]}}, inst[30:20]};
                                    stage               <= 4'h0;
                                end

                                3'b111: begin // ANDI
                                    regs[inst[11:7]]    <= regs[inst[19:15]] & {{21{inst[31]}}, inst[30:20]};
                                    stage               <= 4'h0;
                                end

                                3'b001: begin // SLLI
                                    regs[inst[11:7]]    <= regs[inst[19:15]] << inst[24:20];
                                    stage               <= 4'h0;
                                end

                                3'b101: begin
                                    if (inst[31:25] == 7'b0000000) begin // SRLI
                                        regs[inst[11:7]]    <= regs[inst[19:15]] >> inst[24:20];
                                        stage               <= 4'h0;
                                    end else begin // SRAI
                                        regs[inst[11:7]]    <= $signed(regs[inst[19:15]]) >>> inst[24:20];
                                        stage               <= 4'h0;
                                    end
                                end
                            endcase
                        end

                        7'b0110011: begin // ADD SUB SLL SLT SLTU XOR SRL SRA OR AND
                            case ({inst[31:25], inst[14:12]})
                                10'b0000000000: begin // ADD
                                    regs[inst[11:7]]    <= regs[inst[19:15]] + regs[inst[24:20]];
                                    stage               <= 4'h0;
                                end

                                10'b0100000000: begin // SUB
                                    regs[inst[11:7]]    <= regs[inst[19:15]] - regs[inst[24:20]];
                                    stage               <= 4'h0;
                                end

                                10'b0000000001: begin // SLL
                                    regs[inst[11:7]]    <= regs[inst[19:15]] << regs[inst[24:20]][4:0];
                                    stage               <= 4'h0;
                                end

                                10'b0000000010: begin // SLT
                                    regs[inst[11:7]]    <= $signed(regs[inst[19:15]]) < $signed(regs[inst[24:20]]) ? 32'b1 : 32'b0;
                                    stage               <= 4'h0;
                                end

                                10'b0000000011: begin // SLTU
                                    regs[inst[11:7]]    <= regs[inst[19:15]] < regs[inst[24:20]];
                                    stage               <= 4'h0;
                                end

                                10'b0000000100: begin // XOR
                                    regs[inst[11:7]]    <= regs[inst[19:15]] ^ regs[inst[24:20]];
                                    stage               <= 4'h0;
                                end

                                10'b0000000101: begin // SRL
                                    regs[inst[11:7]]    <= regs[inst[19:15]] >> regs[inst[24:20]][4:0];
                                    stage               <= 4'h0;
                                end

                                10'b0100000101: begin // SRA
                                    regs[inst[11:7]]    <= $signed(regs[inst[19:15]]) >>> regs[inst[24:20]][4:0];
                                    stage               <= 4'h0;
                                end

                                10'b0000000110: begin // OR
                                    regs[inst[11:7]]    <= regs[inst[19:15]] | regs[inst[24:20]];
                                    stage               <= 4'h0;
                                end

                                10'b0000000111: begin // AND
                                    regs[inst[11:7]]    <= regs[inst[19:15]] & regs[inst[24:20]];
                                    stage               <= 4'h0;
                                end
                            endcase
                        end
                    endcase
                end
            endcase
        end
    end
endmodule
