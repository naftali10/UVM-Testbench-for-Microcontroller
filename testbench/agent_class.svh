class agent_class extends uvm_agent;
    
  `uvm_component_utils(agent_class)

  function new (string name = "agent_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Components instantiation
  driver_class driver_inst;
  monitor_class monitor_inst;
  sequencer_class sequencer_inst;
  uvm_analysis_port#(transaction_class) analysis_port_inst;

  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver_inst = driver_class::type_id::create("driver_inst",this);
    monitor_inst = monitor_class::type_id::create("monitor_inst",this);
    sequencer_inst = sequencer_class::type_id::create("sequencer_inst",this);
    analysis_port_inst = new("analysis_port_inst", this);
  endfunction

  // Connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
    monitor_inst.analysis_port_inst.connect(analysis_port_inst);
  endfunction

endclass : agent_class
