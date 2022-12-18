// Module name: Write Back Stage
// Duty: Instruction Execution stage of the pipeline.
//		 Writes results to the register file.
//		 Also prepares results for output.
//		 Includes a reset mux.

module WriteBack (input logic internal_reset,
                  input logic stalled,
                  reg_EXtoWB.receiver reg_EXtoWB_,
                  reg_out.driver reg_out_,
                  ifc_WB.driver ifc_WB_);
  assign reg_out_.stalled = stalled;
  assign reg_out_.dataoutvx2 = internal_reset?0:reg_EXtoWB_.dataoutvx2;
  assign reg_out_.dataoutx2 = reg_EXtoWB_.dataoutx2;
  
  assign ifc_WB_.wr_enx2 = internal_reset?0:reg_EXtoWB_.wr_enx2;
  assign ifc_WB_.dstx2 = reg_EXtoWB_.dstx2;
  assign ifc_WB_.dataoutx2 = reg_EXtoWB_.dataoutx2;
endmodule
