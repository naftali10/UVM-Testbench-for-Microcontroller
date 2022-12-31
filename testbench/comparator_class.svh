class comparator_class extends uvm_component;
  
  `uvm_component_utils(comparator_class);
  
  function new (string name = "comparator_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Instantiations
  uvm_nonblocking_put_imp#(output_transaction_class, comparator_class) put_imp_inst;
  uvm_nonblocking_get_port#(output_transaction_class) get_port_inst;
  output_transaction_class refmod_output_transaction_inst;
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_imp_inst = new("put_imp_inst", this);
    get_port_inst = new("get_port_inst", this);
    refmod_output_transaction_inst = output_transaction_class::type_id::create("refmod_output_transaction_inst");
  endfunction: build_phase

  virtual function bit try_put(output_transaction_class monitor_output_transaction_inst);
    if (!get_port_inst.try_get(refmod_output_transaction_inst))
      `uvm_fatal(get_name(), "Reference model failed sending transaction to Comparator")
    if(monitor_output_transaction_inst.dataoutv == 1'b1 || refmod_output_transaction_inst.dataoutv == 1'b1)
      if(!monitor_output_transaction_inst.compare(refmod_output_transaction_inst)) begin
        `uvm_error(get_name(), "Outputs of DUT and reference model are not identical:")
        monitor_output_transaction_inst.print();
        refmod_output_transaction_inst.print();
      end
    return 1;
  endfunction: try_put

  virtual function bit can_put();
  endfunction: can_put
  
endclass: comparator_class
