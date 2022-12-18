// Interface name: Write Back
// Duty: connecting the RF with the WB stage

interface ifc_WB ();
  logic wr_enx2;
  t_RFadrs dstx2;
  t_data dataoutx2;
  
  modport driver (output wr_enx2,
                  output dstx2,
                  output dataoutx2);
  modport receiver (input wr_enx2,
                    input dstx2,
                    input dataoutx2);
endinterface
