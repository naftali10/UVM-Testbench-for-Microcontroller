class env_class extends uvm_env;

  `uvm_component_utils(env_class)

  function new (string name = "env_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  // Components instantiation
  agent_class active_agent_inst, passive_agent_inst;
  subscriber_class subscriber_inst;
  scoreboard_class scoreboard_inst;

  // Build phase
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    active_agent_inst = agent_class::type_id::create("active_agent_inst", this);
    passive_agent_inst = agent_class::type_id::create("passive_agent_inst", this);
    uvm_config_db#(int)::set(this, "active_agent_inst", "is_active", UVM_ACTIVE);
    uvm_config_db#(int)::set(this, "passive_agent_inst", "is_active", UVM_PASSIVE);
    subscriber_inst = subscriber_class::type_id::create("subscriber_inst", this);
    scoreboard_inst = scoreboard_class::type_id::create("scoreboard_inst", this);
  endfunction: build_phase

  // Connect phase
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    active_agent_inst.input_analysis_port_inst.connect(subscriber_inst.analysis_export);
    active_agent_inst.input_analysis_port_inst.connect(scoreboard_inst.input_analysis_port_inst);
    passive_agent_inst.output_put_port_inst.connect(scoreboard_inst.output_put_port_inst);
  endfunction: connect_phase
  
endclass : env_class
