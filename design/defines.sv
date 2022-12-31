`ifndef DEF
`define DEF
`define ALU_OP_AMT 8	                        // amount of operations ALU can perform
`define ALU_SRC_TYPES 2	                        // amount of types of inputs into ALU (e.g. IMM,GPR)
`define DATA_WIDTH 8	                        // size of data bus
`define REG_AMT 4		                        // amount of regiters in RF
`define READ_PORTS 2	                        // amount of read ports in RF
`define WRITE_PORTS 1	                        // amount of write ports in RF
`define PIPE_LEN 3  	                        // length of pipeline (in clock cycles)
`define HALF_CYCLE_TIME 1  	                    // time of half a cycle (in ns)
`define CYCLE_TIME (`HALF_CYCLE_TIME*2)         // clock cycle time (in ns)
`define PIPE_DELAY (`PIPE_LEN*`CYCLE_TIME)      // length of pipeline (in ns)
`define STALL_DELAY (`PIPE_DELAY-`CYCLE_TIME)   // length of stall (in ns)

package definitions;
typedef enum logic [$clog2(`ALU_OP_AMT)-1:0] {LD='b000,
                                              OUT='b001,
                                              ADD='b010,
                                              SUB='b011,
                                              NAND='b100,
                                              NOR='b101,
                                              XOR='b110,
                                              SHFL='b111} t_opcode;
typedef enum logic [$clog2(`ALU_SRC_TYPES)-1:0] {takeGPR,takeIMM} t_ALUsrc_ctrl;
typedef logic [`DATA_WIDTH-1:0] t_data;
typedef enum logic [$clog2(`REG_AMT+1)-1:0] {R0='b000,
                                           	 R1='b001,
                                           	 R2='b010,
                                           	 R3='b011,
                                           	 IMM='b100}t_reg_name;
typedef logic [$clog2(`REG_AMT)-1:0] t_RFadrs;
endpackage
// -------------------------------- IMPORTANT ----------------------------------
// The following line requires defines.sv to appear first in the whole design!
import definitions::*;
`endif
