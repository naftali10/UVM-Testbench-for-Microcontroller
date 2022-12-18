class subscriber_class extends uvm_subscriber#(transaction_class);
  
  `uvm_component_utils(subscriber_class)
  
  // Declarations
  logic instv;
  t_opcode opcode;
  t_data imm;
  t_reg_name src1, src2;
  t_reg_name dst;
  logic stalledx3;
  logic dataoutvx3;
  t_data dataoutx3;
  
  // Coverage
  covergroup covergroup_type;
    coverpoint instv;
    coverpoint opcode;
    coverpoint imm;
    coverpoint src1;
    coverpoint src2;
    coverpoint dst;
  endgroup: covergroup_type
  
  function new (string name = "subscriber_class", uvm_component parent = null);
    super.new(name, parent);
    covergroup_type = new();
  endfunction: new
    
  // Write
  function void write (transaction_class t);
    instv = t.instv;
    opcode = t.opcode;
    imm = t.imm;
    src1 = t.src1;
    src2 = t.src2;
    dst = t.dst;
    stalledx3 = t.stalledx3;
    dataoutvx3 = t.dataoutvx3;
    dataoutx3 = t.dataoutx3;
    covergroup_type.sample();
  endfunction: write
  
  // Report phase
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("Coverage = %0.2f %%", covergroup_type.imm.get_coverage());
  endfunction
  
endclass
