// Interface name: Outputs Register
// Duty: Preparing signals for exiting the macine.
//		 Shifting signal's clock.

interface reg_out (input logic clock);
  logic dataoutvx2, dataoutvx3;
  t_data dataoutx2;
  t_data dataoutx3;
  
  always_ff @(posedge clock) begin
    dataoutvx3 <= dataoutvx2;
    dataoutx3 <= dataoutx2;
  end
  
  modport driver (output dataoutvx2,
                  output dataoutx2);
  modport receiver (input dataoutvx3,
                    input dataoutx3);  
endinterface
