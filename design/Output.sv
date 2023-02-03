// Module name: Output stage
// Duty: Auxiliary module for driving machines outputs.

module Output (input logic stalled,
               reg_out.receiver reg_out_,
               ifc_outputs.driver ifc_outputs_);
  assign ifc_outputs_.stalled = stalled;
  assign ifc_outputs_.dataoutvx3 = reg_out_.dataoutvx3;
  assign ifc_outputs_.dataoutx3 = reg_out_.dataoutx3;
endmodule
