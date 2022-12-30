class comparator_class extends uvm_component;
  
  `uvm_component_utils(comparator_class);
  
  function new (string name = "comparator_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Instantiations
  uvm_nonblocking_put_imp#(output_transaction_class, comparator_class) put_port_inst;
  uvm_blocking_get_port#(output_transaction_class) get_port_inst;
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_port_inst = new("put_port_inst", this);
    get_port_inst = new("get_port_inst", this);
  endfunction: build_phase

  virtual function bit try_put(output_transaction_class t);
    output_transaction_class ot;
    get_port_inst.get(ot);
    return 1;
  endfunction: try_put

  virtual function bit can_put();
  endfunction: can_put
  
endclass: comparator_class
