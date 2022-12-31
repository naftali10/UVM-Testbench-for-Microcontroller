class agent_class extends uvm_agent;
    
  `uvm_component_utils(agent_class)

  function new (string name = "agent_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Components instantiation
  driver_class driver_inst;
  input_monitor_class input_monitor_inst;
  output_monitor_class output_monitor_inst;
  sequencer_class sequencer_inst;
  uvm_analysis_port#(input_transaction_class) input_analysis_port_inst;
  uvm_blocking_put_port#(reset_transaction_class) reset_put_port_inst;
  uvm_nonblocking_put_port#(output_transaction_class) output_put_port_inst;

  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (get_is_active()) begin
        driver_inst = driver_class::type_id::create("driver_inst",this);
        input_monitor_inst = input_monitor_class::type_id::create("input_monitor_inst",this);
        sequencer_inst = sequencer_class::type_id::create("sequencer_inst",this);
        input_analysis_port_inst = new("input_analysis_port_inst", this);
        reset_put_port_inst = new("reset_put_port_inst", this);
    end else begin
        output_monitor_inst = output_monitor_class::type_id::create("output_monitor_inst",this);
        output_put_port_inst = new("output_put_port_inst", this);
    end
  endfunction

  // Connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active()) begin
        driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
        input_monitor_inst.analysis_port_inst.connect(input_analysis_port_inst);
        input_monitor_inst.put_port_inst.connect(reset_put_port_inst);
    end else begin
        output_monitor_inst.put_port_inst.connect(output_put_port_inst);
    end
  endfunction

endclass : agent_class
