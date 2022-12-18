class scoreboard_class extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard_class)
  
  function new (string name = "scoreboard_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Declarations
  reference_model_class reference_model_inst;
  comparator_class comparator_inst;
  uvm_analysis_export#(transaction_class) analysis_port_inst;
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reference_model_inst = reference_model_class::type_id::create("reference_model_inst", this);
    comparator_inst = comparator_class::type_id::create("comparator_inst", this);
    analysis_port_inst = new("analysis_port_inst", this);
  endfunction: build_phase
  
  // Connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    analysis_port_inst.connect(reference_model_inst.analysis_port_inst);
    reference_model_inst.put_port_inst.connect(comparator_inst.put_port_inst);
  endfunction: connect_phase
  
  // Check phase
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
  endfunction: check_phase
  
endclass: scoreboard_class
