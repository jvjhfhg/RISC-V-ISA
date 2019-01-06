/* Global */

`define ENABLE              1'b1
`define DISABLE             1'b0
`define VALID               1'b1
`define INVALID             1'b0
`define TRUE                1'b1
`define FALSE               1'b0

`define ZERO_32             32'b0

`define ALU_OP_BUS          7:0
`define ALU_SEL_BUS         2:0

/* Instructions Related */

`define EXE_NOP             7'b0000000
`define EXE_LUI             7'b0110111

// AluOp

`define EXE_NOP_OP          8'b00000000
`define EXE_OR_OP           8'b00100101

// AluSel

`define EXE_RES_NOP         3'b000
`define EXE_RES_LOGIC       3'b001

/* ROM Related */

`define INST_ADDR_BUS       31:0
`define INST_BUS            31:0
`define INST_MEM_NUM        131071
`define INST_MEM_NUM_LOG2   17

/* Regfile Related */

`define REG_ADDR_BUS        4:0
`define REG_BUS             31:0
`define REG_WIDTH           32
`define DOUBLE_REG_WIDTH    64
`define DOUBLE_REG_BUS      63:0
`define REG_NUM             32
`define REG_NUM_LOG2        5
`define NOP_REG_ADDR        5'b00000

