
class test_class extends uvm_test;

  `uvm_component_utils(test_class)

  function new (string name = "test_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Components instantiation
  env_class env_inst;

  // Build phase
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    env_inst = env_class::type_id::create("env_inst", this);
  endfunction: build_phase

  // End of elaboration phase
  virtual function void end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction: end_of_elaboration_phase

  // Run phase
  virtual task run_phase(uvm_phase phase);
    
    sequence_class sequence_inst;
    sequence_inst = sequence_class::type_id::create("sequence_inst");
    
    phase.raise_objection(this);
    sequence_inst.start(env_inst.active_agent_inst.sequencer_inst);
    phase.drop_objection(this);
    
  endtask: run_phase
  
endclass: test_class
