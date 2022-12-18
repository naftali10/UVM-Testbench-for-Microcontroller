// Interface name: Execution to Write Back Register
// Duty: Transferring signals from EX stage to WB stage in the pipeline.
//		 Shifting signals' clock.

interface reg_EXtoWB (input logic clock);
  logic wr_enx1;
  logic wr_enx2;
  logic dataoutvx1, dataoutvx2;
  t_RFadrs dstx1;
  t_RFadrs dstx2;
  t_data dataoutx1;
  t_data dataoutx2;
  
  always_ff @(posedge clock) begin
    wr_enx2 <= wr_enx1;
    dstx2 <= dstx1;
    dataoutx2 <= dataoutx1;
    dataoutvx2 <= dataoutvx1;
  end
  
  modport driver (output wr_enx1,
                  output dstx1,
                  output dataoutx1,
                  output dataoutvx1);
  modport receiver (input wr_enx2,
                    input dstx2,
                    input dataoutx2,
                    input dataoutvx2);
endinterface
