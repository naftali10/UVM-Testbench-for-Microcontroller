class scoreboard_class extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard_class)
  
  function new (string name = "scoreboard_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Declarations
  reference_model_class reference_model_inst;
  comparator_class comparator_inst;
  uvm_analysis_export#(input_transaction_class) input_analysis_port_inst;
  uvm_nonblocking_put_export#(output_transaction_class) output_put_export_inst;
  uvm_blocking_put_export#(reset_transaction_class) reset_put_export_inst;
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reference_model_inst = reference_model_class::type_id::create("reference_model_inst", this);
    comparator_inst = comparator_class::type_id::create("comparator_inst", this);
    input_analysis_port_inst = new("input_analysis_port_inst", this);
    output_put_export_inst = new("output_put_export_inst", this);
    reset_put_export_inst = new("reset_put_export_inst", this);
  endfunction: build_phase
  
  // Connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    input_analysis_port_inst.connect(reference_model_inst.analysis_imp_inst);
    output_put_export_inst.connect(comparator_inst.put_imp_inst);
    reset_put_export_inst.connect(reference_model_inst.put_imp_inst);
    comparator_inst.get_port_inst.connect(reference_model_inst.get_imp_inst);
  endfunction: connect_phase
  
  // Check phase
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
  endfunction: check_phase
  
endclass: scoreboard_class
