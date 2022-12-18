// Module name: Output stage
// Duty: Auxiliary module for driving machines outputs.

module Output (reg_out.receiver reg_out_,
               ifc_outputs.driver ifc_outputs_);
  assign ifc_outputs_.stalledx3 = reg_out_.stalledx3;
  assign ifc_outputs_.dataoutvx3 = reg_out_.dataoutvx3;
  assign ifc_outputs_.dataoutx3 = reg_out_.dataoutx3;
endmodule
