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

    if (reset) begin
      internal_reset = 1;
      clk_en_reg_IDtoEX = 0;
    end
    else begin

      case (state)
        
        OP: begin
          if (~instv) begin : invalid_instruction
            next_state = OP;
            clk_en_reg_IDtoEX = 0;
          end : invalid_instruction
          else begin : valid_instruction
            case (opcode)
              LD: begin
                if (src1==IMM && dst!=IMM) begin : valid_LD
                  next_state = STALL_EX;
                  ALUsrc1 = takeIMM;
                  ALUop = LD;
                  wr_en = 1;
                end
                else begin : invalid_LD
                  next_state = OP;
                  clk_en_reg_IDtoEX = 0;
                end
              end
              OUT: begin
                if (src1==R0 || src1==R1 || src1==R2 || src1==R3) begin : valid_OUT
                  next_state = STALL_EX;
                  ALUsrc1 = takeGPR;
                  ALUop = OUT;
                  dataoutv = 1;
                end
                else begin : invalid_OUT
                  next_state = OP;
                  clk_en_reg_IDtoEX = 0;
                end
              end
              ADD, SUB, NAND, NOR, XOR, SHFL: begin
                if (dst==IMM) begin : invalid_ALU
                  next_state = OP;
                  clk_en_reg_IDtoEX = 0;
                end
                else begin : valid_ALU
                  next_state = STALL_EX;
                  ALUop = opcode;
                  wr_en = 1;
                  dataoutv = 0;
                  case (src1)
                    R0,R1,R2,R3: ALUsrc1 = takeGPR;
                    IMM: ALUsrc1 = takeIMM;
                  endcase
                  case (src2)
                    R0,R1,R2,R3: ALUsrc2 = takeGPR;
                    IMM: ALUsrc2 = takeIMM;
                  endcase
                end
              end
            endcase
          end: valid_instruction
        end

        STALL_EX: begin
          next_state = STALL_WB;
        end

        STALL_WB: begin
          next_state = OP;
        end

      endcase

      stalled = (next_state == STALL_EX || next_state == STALL_WB);

    end
  end
/*
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

  src1_type = src1==IMM ? takeIMM : takeGPR;
  src2_type = src2==IMM ? takeIMM : takeGPR;
  dst_type =  dst ==IMM ? toIMM   : toGPR;

  case 
    (
    {reset, instv, state, opcode_type, src1_type, dst_type}
    ) inside
    {1,     ?,     ?,     ?,           ?,         ?       }: begin : external_reset
      internal_reset = 1;
      clk_en_reg_IDtoEX = 0;
    end
    {0,     0,     ?,     ?,           ?,         ?       }: begin : invalid_instruction
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {0,     1,     OP,    LOAD,        takeIMM,   toGPR   }: begin : valid_LD
      next_state = STALL_EX;
      ALUsrc1 = takeIMM;
      ALUop = LD;
      wr_en = 1;
    end
    {0,     1,     OP,    LOAD,        takeGPR,   ?       }: begin : invalid_LD1
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {0,     1,     OP,    LOAD,        ?,         toIMM   }: begin : invalid_LD2
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {0,     1,     OP,    OUTP,        takeGPR,   ?       }: begin : valid_OUT
      next_state = STALL_EX;
      ALUsrc1 = takeGPR;
      ALUop = OUT;
      dataoutv = 1;
    end
    {0,     1,     OP,    OUTP,        takeIMM,   ?       }: begin : invalid_OUT
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {0,     1,     OP,    ALU,         ?,         toIMM   }: begin : invalid_ALU
      next_state = OP;
      clk_en_reg_IDtoEX = 0;
    end
    {0,     1,     OP,    ALU,         ?,         toGPR   }: begin : valid_ALU
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
*/

endmodule
