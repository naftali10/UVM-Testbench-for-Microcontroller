// Module name: Decode Stage
// Duty: Instruction decoding stage of the pipeline.
//		 Receives inputs to the machine and interprets them.
//		 Includes the controller and the register file.

module Decode (ifc_inputs.receiver ifc_inputs_,
               ifc_WB.receiver ifc_WB_,
               reg_IDtoEX.driver reg_IDtoEX_,
               output logic internal_reset,
               output logic stalled);
  controller controller_inst (.clock(ifc_inputs_.clock),
                              .reset(ifc_inputs_.reset),
                              .opcode(ifc_inputs_.opcode),
                              .instv(ifc_inputs_.instv),
                              .src1(ifc_inputs_.src1),
                              .src2(ifc_inputs_.src2),
                              .internal_reset(internal_reset),
                              .ALUsrc1(reg_IDtoEX_.ALUsrc1x0),
                              .ALUsrc2(reg_IDtoEX_.ALUsrc2x0),
                              .ALUop(reg_IDtoEX_.ALUopx0),
                              .wr_en(reg_IDtoEX_.wr_enx0),
                              .dataoutv(reg_IDtoEX_.dataoutvx0),
                              .stalled(stalled));
                                                           
  RF RF_inst (.clock(ifc_inputs_.clock),
              .src('{t_RFadrs'(ifc_inputs_.src2),t_RFadrs'(ifc_inputs_.src1)}),
              .dst(ifc_WB_.dstx2),
              .datain(ifc_WB_.dataoutx2),
              .wr_en(ifc_WB_.wr_enx2),
              .dataout('{reg_IDtoEX_.dat2x0,reg_IDtoEX_.dat1x0}));
  
  assign reg_IDtoEX_.immx0 = ifc_inputs_.imm;
  assign reg_IDtoEX_.dstx0 = t_RFadrs'(ifc_inputs_.dst);
endmodule
