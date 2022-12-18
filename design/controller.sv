// Module name: Main Controller
// Duty: Managing data flow in the whole system
//		 by generating control signals.

module controller (
  input logic clock,
  input logic reset,
  input t_opcode opcode,
  input logic instv,					// validity of instruction.
  input t_reg_name src1,				// register name or immediate,
  input t_reg_name src2,				// meaning it can be {R0-4 or IMM}.
  output logic internal_reset,			// zeros signal down the pipeline.
  output t_ALUsrc_ctrl ALUsrc1,			// tells muxes on ALU's inputs to take register
  output t_ALUsrc_ctrl ALUsrc2,			// or immediate. can be {takeGPR or takeIMM}.
  output t_opcode ALUop,				// identical to opcode.
  output logic wr_en,					// enables RF writing.
  output logic dataoutv,				// for outside world.
  output logic stalled					// for outside world.
);
  enum {OP, STALL_EX, STALL_WB} state, next_state;
  always_ff @(posedge clock)
    state = reset?OP:next_state;
  
  always_comb
  	if (reset) begin
      internal_reset = 1;
      wr_en = 0;
      dataoutv = 0;
      stalled = 0;
    end
  	else begin
      case (state)
        
        OP: begin
          if (~instv) begin : invalid_instruction
            next_state = OP;
            internal_reset = 0;
            wr_en = 0;
            dataoutv = 0;
            stalled = 0;
          end : invalid_instruction
          else begin : valid_instruction
            case (opcode)
              LD: begin
                if (src1==IMM) begin
                  next_state = STALL_EX;
                  internal_reset = 0;
                  ALUsrc1 = takeIMM;
                  ALUop = LD;
                  wr_en = 1;
                  dataoutv = 0;
                  stalled = 1;
              	end
                else begin // error: LD without immediate value
                  next_state = OP;
                  internal_reset = 0;
                  wr_en = 0;
                  dataoutv = 0;
                  stalled = 0;
                end
              end
              OUT: begin
                if (src1==R0 || src1==R1 || src1==R2 || src1==R3) begin
                  next_state = STALL_EX;
                  internal_reset = 0;
                  ALUsrc1 = takeGPR;
                  ALUop = OUT;
                  wr_en = 0;
                  dataoutv = 1;
                  stalled = 1;
                end
                else begin // error: OUT without GPR
                  next_state = OP;
                  internal_reset = 0;
                  wr_en = 0;
                  dataoutv = 0;
                  stalled = 0;
                end
              end
              ADD, SUB, NAND, NOR, XOR, SHFL: begin
                next_state = STALL_EX;
                internal_reset = 0;
                ALUop = opcode;
                wr_en = 1;
                dataoutv = 0;
                stalled = 1;
                case (src1)
                  R0,R1,R2,R3: ALUsrc1 = takeGPR;
                  IMM: ALUsrc1 = takeIMM;
                endcase
                case (src2)
                  R0,R1,R2,R3: ALUsrc2 = takeGPR;
                  IMM: ALUsrc2 = takeIMM;
                endcase
              end
            endcase
          end: valid_instruction
        end
            
        STALL_EX: begin
          next_state = STALL_WB;
          internal_reset = 0;
          wr_en = 0;
          dataoutv = 0;
          stalled = 1;
        end
        STALL_WB: begin
          next_state = OP;
          internal_reset = 0;
          wr_en = 0;
          dataoutv = 0;
          stalled = 0;
        end
      endcase
	end
endmodule
