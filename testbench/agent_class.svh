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
  uvm_analysis_port#(input_transaction_class) DUT_inputs_tlm;
  uvm_blocking_put_port#(reset_transaction_class) reset_tlm;
  uvm_blocking_get_port#(output_transaction_class) DUT_outputs_tlm;

  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (get_is_active()) begin
        driver_inst = driver_class::type_id::create("driver_inst",this);
        input_monitor_inst = input_monitor_class::type_id::create("input_monitor_inst",this);
        sequencer_inst = sequencer_class::type_id::create("sequencer_inst",this);
        DUT_inputs_tlm = new("DUT_inputs_tlm", this);
        reset_tlm = new("reset_tlm", this);
    end else begin
        output_monitor_inst = output_monitor_class::type_id::create("output_monitor_inst",this);
        DUT_outputs_tlm = new("DUT_outputs_tlm", this);
    end
  endfunction

  // Connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active()) begin
        driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
        input_monitor_inst.DUT_inputs_tlm.connect(DUT_inputs_tlm);
        input_monitor_inst.reset_tlm.connect(reset_tlm);
    end else begin
        output_monitor_inst.DUT_outputs_fifo_tlm.get_export.connect(DUT_outputs_tlm);
    end
  endfunction

endclass : agent_class
