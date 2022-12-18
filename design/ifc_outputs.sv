// Interface name: Global Outputs
// Duty: Connecting the machine to its outputs

interface ifc_outputs ();
  logic stalledx3;
  logic dataoutvx3;
  t_data dataoutx3;
  
  modport driver (output stalledx3,
                   output dataoutvx3,
                   output dataoutx3);
endinterface
