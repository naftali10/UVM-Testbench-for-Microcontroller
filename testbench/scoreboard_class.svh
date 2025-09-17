class scoreboard_class extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard_class)
  
  function new (string name = "scoreboard_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Declarations
  reference_model_class reference_model_inst;
  comparator_class comparator_inst;
  uvm_analysis_export#       (input_transaction_class)  DUT_inputs_tlm;
  uvm_nonblocking_put_export#(output_transaction_class) DUT_outputs_tlm;
  uvm_blocking_put_export#   (reset_transaction_class)  reset_tlm;
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reference_model_inst = reference_model_class::type_id::create("reference_model_inst", this);
    comparator_inst = comparator_class::type_id::create("comparator_inst", this);
    DUT_inputs_tlm  = new("DUT_inputs_tlm",  this);
    DUT_outputs_tlm = new("DUT_outputs_tlm", this);
    reset_tlm       = new("reset_tlm",       this);
  endfunction: build_phase
  
  // Connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    DUT_inputs_tlm.connect                    (reference_model_inst.DUT_inputs_tlm);
    reset_tlm.connect                         (reference_model_inst.reset_tlm);
    comparator_inst.refmod_outputs_tlm.connect(reference_model_inst.refmod_outputs_tlm);
    DUT_outputs_tlm.connect                   (comparator_inst.DUT_outputs_tlm);
  endfunction: connect_phase
  
  // Check phase
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
  endfunction: check_phase
  
endclass: scoreboard_class
