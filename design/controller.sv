// Module name: Main Controller
// Duty: Managing data flow in the whole system
//		 by generating control signals.

module controller (
  input  logic         clock,
  input  logic         reset,
  input  t_opcode      opcode,
  input  logic         instv,          // validity of instruction.
  input  t_reg_name    src1,           // register name or immediate,
  input  t_reg_name    src2,           // meaning it can be {R0-4 or IMM}.
  input  t_reg_name    dst,            // Destination register name.
  output logic         internal_reset, // zeros signal down the pipeline.
  output logic         clk_en_reg_IDtoEX,     // gates pipeline clock.
  output t_ALUsrc_ctrl ALUsrc1,        // tells muxes on ALU's inputs to take register
  output t_ALUsrc_ctrl ALUsrc2,        // or immediate. can be {takeGPR or takeIMM}.
  output t_opcode      ALUop,          // identical to opcode.
  output logic         wr_en,          // enables RF writing.
  output logic         dataoutv,       // for outside world.
  output logic         stalled         // for outside world.
);
  
  enum {OP, STALL_EX, STALL_WB} state, next_state;
  enum {LOAD, OUTP, ALU} opcode_type;
  t_ALUsrc_ctrl src1_type, src2_type;
  t_ALUdst_ctrl dst_type;
  
  always_ff @(posedge clock)
    state = reset?OP:next_state;

always_comb begin

  // Default values for outputs
  internal_reset = 0;
  clk_en_reg_IDtoEX = 1;
  ALUsrc1 = takeGPR;
  ALUsrc2 = takeGPR;
  ALUop = LD;
  wr_en = 0;
  dataoutv = 0;
  stalled = 0;
  next_state = OP;

  // Determine variables for Case statement
  src1_type = src1==IMM ? takeIMM : takeGPR;
  src2_type = src2==IMM ? takeIMM : takeGPR;
  dst_type  = dst ==IMM ? toIMM   : toGPR;
  opcode_type = (opcode==LD) ? LOAD : (opcode==OUT) ? OUTP : ALU;

  case 
    (
    {reset, instv, state, opcode_type, src1_type, dst_type}
    ) inside
    {1'b1,  1'b?,  32'b?, 32'b?,       1'b?,      1'b?    }: begin : external_reset
      internal_reset = 1;
      clk_en_reg_IDtoEX = 0;
    end
    {1'b0,  1'b0,  32'b?, 32'b?,       1'b?,      1'b?    }: begin : invalid_instruction
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {1'b0,  1'b1,  OP,    LOAD,        takeIMM,   toGPR   }: begin : valid_LD
      next_state = STALL_EX;
      ALUsrc1 = takeIMM;
      ALUop = LD;
      wr_en = 1;
    end
    {1'b0,  1'b1,  OP,    LOAD,        takeGPR,   1'b?    }: begin : invalid_LD1
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {1'b0,  1'b1,  OP,    LOAD,        32'b?,     toIMM   }: begin : invalid_LD2
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {1'b0,  1'b1,  OP,    OUTP,        takeGPR,   1'b?    }: begin : valid_OUT
      next_state = STALL_EX;
      ALUsrc1 = takeGPR;
      ALUop = OUT;
      dataoutv = 1;
    end
    {1'b0,  1'b1,  OP,    OUTP,        takeIMM,   1'b?    }: begin : invalid_OUT
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {1'b0,  1'b1,  OP,    ALU,         1'b?,      toIMM   }: begin : invalid_ALU
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {1'b0,  1'b1,  OP,    ALU,         1'b?,      toGPR   }: begin : valid_ALU
      next_state = STALL_EX;
      ALUop = opcode;
      wr_en = 1;
      dataoutv = 0;
      ALUsrc1 = src1_type;
      ALUsrc2 = src2_type;
    end
  endcase

  stalled = (next_state == STALL_EX || next_state == STALL_WB);

end


endmodule
