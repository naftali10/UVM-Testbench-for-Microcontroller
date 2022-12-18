class comparator_class extends uvm_component;
  
  `uvm_component_utils(comparator_class);
  
  function new (string name = "comparator_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  uvm_blocking_put_imp#(refmod_transaction_class, comparator_class) put_port_inst;
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_port_inst = new("put_port_inst", this);
  endfunction: build_phase

  virtual function void put(refmod_transaction_class t);
    `uvm_info("Got it!",$sformatf("stalled = %0d",t.stalled), UVM_NONE)
  endfunction: put
  
endclass: comparator_class
