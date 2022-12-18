// Interface name: Instruction Decode to Execution Register
// Duty: Transferring signals from ID stage to EX stage in the pipeline.
//		 Shifting signals' clock.

interface reg_IDtoEX (input logic clock);
  logic wr_enx0;
  logic wr_enx1;
  logic dataoutvx0, dataoutvx1;
  t_ALUsrc_ctrl ALUsrc1x0, ALUsrc2x0, ALUsrc1x1, ALUsrc2x1;
  t_opcode ALUopx0, ALUopx1;
  t_data immx0, immx1, dat1x0, dat1x1, dat2x0, dat2x1;
  t_RFadrs dstx0;
  t_RFadrs dstx1;
  
  always_ff @(posedge clock) begin
    wr_enx1 <= wr_enx0;
    ALUsrc1x1 <= ALUsrc1x0;
    ALUsrc2x1 <= ALUsrc2x0;
    ALUopx1 <= ALUopx0;
    immx1 <= immx0;
    dat1x1 <= dat1x0;
    dat2x1 <= dat2x0;
    dstx1 <= dstx0;
    dataoutvx1 <= dataoutvx0;
  end
  
  modport driver (output wr_enx0,
                  output ALUsrc1x0,
                  output ALUsrc2x0,
                  output ALUopx0,
                  output immx0,
                  output dat1x0,
                  output dat2x0,
                  output dstx0,
                  output dataoutvx0);
  modport receiver (input wr_enx1,
                    input ALUsrc1x1,
                    input ALUsrc2x1,
                    input ALUopx1,
                    input immx1,
                    input dat1x1,
                    input dat2x1,
                    input dstx1,
                    input dataoutvx1);
endinterface
