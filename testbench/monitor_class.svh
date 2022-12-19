class monitor_class extends uvm_monitor;

  `uvm_component_utils(monitor_class)

  function new(string name = "monitor_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  // Instantiation
  virtual ifc_inputs dut_vifc_in;
  virtual ifc_outputs dut_vifc_out;
  uvm_analysis_port#(transaction_class) analysis_port_inst;
  
  // Build phase
  virtual function void build_phase (uvm_phase phase);
    
    super.build_phase(phase);
    analysis_port_inst = new("analysis_port_inst",this);
    if(!uvm_config_db#(virtual ifc_inputs)::get(this, "", "dut_vifc_in", dut_vifc_in))
      `uvm_fatal(get_type_name(), "Input DUT interface not found")
    if(!uvm_config_db#(virtual ifc_outputs)::get(this, "", "dut_vifc_out", dut_vifc_out))
      `uvm_fatal(get_type_name(), "Output DUT interface not found")
  endfunction: build_phase
  
  // Run phase
  task run_phase(uvm_phase phase);
    transaction_class transaction_inst = transaction_class::type_id::create("transaction_inst");

    forever begin

      @(posedge dut_vifc_in.clock);
      // Inputs
      transaction_inst.reset = dut_vifc_in.reset;
      transaction_inst.instv = dut_vifc_in.instv;
      transaction_inst.opcode = dut_vifc_in.opcode;
      transaction_inst.imm = dut_vifc_in.imm;
      transaction_inst.src1 = dut_vifc_in.src1;
      transaction_inst.src2 = dut_vifc_in.src2;
      transaction_inst.dst = dut_vifc_in.dst;
      
      // Outputs
      transaction_inst.stalledx3 = dut_vifc_out.stalledx3;
      transaction_inst.dataoutvx3 = dut_vifc_out.dataoutvx3;
      transaction_inst.dataoutx3 = dut_vifc_out.dataoutx3;
      
      `uvm_info(get_name(), "Sending to reference model.", UVM_NONE)
      analysis_port_inst.write(transaction_inst);

    end

  endtask: run_phase
  
endclass: monitor_class
