// Module name: Execution Stage
// Duty: Instruction Execution stage of the pipeline.
//		 Performes desired calculations.
//		 Includes the ALU.

module Execute (input logic internal_reset,
                reg_IDtoEX.receiver reg_IDtoEX_,
                reg_EXtoWB.driver reg_EXtoWB_);
  t_data A, B;
  always_comb begin
    if (reg_IDtoEX_.ALUsrc1x1===takeGPR)
      assign A = reg_IDtoEX_.dat1x1;
    if (reg_IDtoEX_.ALUsrc1x1===takeIMM)
      assign A = reg_IDtoEX_.immx1;
  end
  always_comb begin
    if (reg_IDtoEX_.ALUsrc2x1===takeGPR)
      assign B = reg_IDtoEX_.dat2x1;
    if (reg_IDtoEX_.ALUsrc2x1===takeIMM)
      assign B = reg_IDtoEX_.immx1;
  end
  ALU ALU_inst (.A(A),
                .B(B),
                .op(reg_IDtoEX_.ALUopx1),
                .result(reg_EXtoWB_.dataoutx1));
  
  assign reg_EXtoWB_.wr_enx1 = internal_reset?0:reg_IDtoEX_.wr_enx1;
  assign reg_EXtoWB_.dataoutvx1 = internal_reset?0:reg_IDtoEX_.dataoutvx1;
  assign reg_EXtoWB_.dstx1 = reg_IDtoEX_.dstx1;
endmodule
