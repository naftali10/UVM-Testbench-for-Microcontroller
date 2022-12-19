class driver_class extends uvm_driver#(transaction_class);

  `uvm_component_utils(driver_class)

  function new (string name = "driver_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Instantiations
  virtual ifc_inputs dut_vifc_in;
  virtual ifc_outputs dut_vifc_out;
  transaction_class transaction_inst;

  // Build phase
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    if(!uvm_config_db#(virtual ifc_inputs)::get(this, "", "dut_vifc_in", dut_vifc_in)) begin
      `uvm_fatal(get_type_name(), "Didn't get handle to virtual interface dut_vifc_in")
    end
    if(!uvm_config_db#(virtual ifc_outputs)::get(this, "", "dut_vifc_out", dut_vifc_out)) begin
      `uvm_fatal(get_type_name(), "Didn't get handle to virtual interface dut_vifc_out")
    end

  endfunction

  // Run phase
  virtual task run_phase(uvm_phase phase);
    
    forever begin

      seq_item_port.get_next_item(transaction_inst);
      `uvm_info(get_name(), "New sequence item is driven:", UVM_NONE)
      transaction_inst.print();
      // Pin wiggles
      dut_vifc_in.cb.reset <= transaction_inst.reset;
      dut_vifc_in.cb.instv <= transaction_inst.instv;
      dut_vifc_in.cb.opcode <= transaction_inst.opcode;
      dut_vifc_in.cb.imm <= transaction_inst.imm;
      dut_vifc_in.cb.src1 <= transaction_inst.src1;
      dut_vifc_in.cb.src2 <= transaction_inst.src2;
      dut_vifc_in.cb.dst <= transaction_inst.dst;

      wait_for_no_stall();

      seq_item_port.item_done();

    end
    
  endtask

  virtual task wait_for_no_stall();

      #`CYCLE_TIME //  Wait for IFC feeding in negedge and DUT output update in posedge
      #`HALF_CYCLE_TIME // Wait for stall signal to stabilize
      wait(dut_vifc_out.stalledx3 === 1'b0);

  endtask

endclass : driver_class
