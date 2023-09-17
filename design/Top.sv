
// Module name: Pipelined Microcontroller Processor
// Duty: Top lavel of the design.
//		 Connects all interfaces, modules and pipeline registers.

module Processor (ifc_inputs.receiver global_inputs,
                  ifc_outputs.driver global_outputs);
  logic internal_reset, stalled;
  ifc_WB ifc_WB_();
  reg_IDtoEX reg_IDtoEX_(.clock(global_inputs.clock));
  reg_EXtoWB reg_EXtoWB_(.clock(global_inputs.clock));
  reg_out reg_out_ (.clock(global_inputs.clock));
  
  Decode decoder(.ifc_inputs_(global_inputs),
                 .ifc_WB_(ifc_WB_),
                 .reg_IDtoEX_(reg_IDtoEX_),
                 .internal_reset(internal_reset),
                 .stalled(stalled));
  Execute execution (.internal_reset(internal_reset),
                     .reg_IDtoEX_(reg_IDtoEX_),
                     .reg_EXtoWB_(reg_EXtoWB_));
  WriteBack writeback (.internal_reset(internal_reset),
                       .reg_EXtoWB_(reg_EXtoWB_),
                       .reg_out_(reg_out_),
                       .ifc_WB_(ifc_WB_));
  Output output_(.stalled(stalled),
                 .reg_out_(reg_out_),
                 .ifc_outputs_(global_outputs));

  // always @(global_inputs.clock) $display("time = %1t clock = %b stall %b", $time, global_inputs.clock, global_outputs.stalled); // FIXME - nkizner - 2022-12-31 - Delete after debugging
  
endmodule
