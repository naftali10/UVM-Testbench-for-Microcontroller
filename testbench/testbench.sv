// Testbench

import uvm_pkg::*;

`include "uvm_macros.svh"
`include "tb_pkg.svh"
`include "design.sv"

module tb_top;
  
  import tb_pkg::*;
  
  // Clock
  bit clock;
  always #`HALF_CYCLE_TIME clock = ~clock;
  initial begin
    clock <= 0;
  end
  
  // Interface instantiation
  ifc_inputs dut_ifc_in(clock);
  ifc_outputs dut_ifc_out(clock);
  
  // Building blocks instantiation
  Processor dut_inst(dut_ifc_in, dut_ifc_out);
  
  // Running the test
  initial begin
    uvm_config_db#(virtual ifc_inputs)::set(null, "*", "dut_vifc_in", dut_ifc_in);
    uvm_config_db#(virtual ifc_outputs)::set(null, "*", "dut_vifc_out", dut_ifc_out);
    run_test ("test_class");
  end
  
  initial begin
  	$dumpvars;
    $dumpfile("dump.vcd");
  end
  
endmodule: tb_top
