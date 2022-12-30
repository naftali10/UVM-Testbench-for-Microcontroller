class driver_class extends uvm_driver#(input_transaction_class);

  `uvm_component_utils(driver_class)

  function new (string name = "driver_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Instantiations
  virtual ifc_inputs dut_vifc_in;
  virtual ifc_outputs dut_vifc_out;
  input_transaction_class input_transaction_inst;

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
      
      @ (posedge dut_vifc_in.clock);
      seq_item_port.get_next_item(input_transaction_inst);
      `uvm_info(get_name(), "New sequence item is driven:", UVM_NONE)
      input_transaction_inst.print();
      // Pin wiggles
      dut_vifc_in.reset <= input_transaction_inst.reset;
      dut_vifc_in.instv <= input_transaction_inst.instv;
      dut_vifc_in.opcode <= input_transaction_inst.opcode;
      dut_vifc_in.imm <= input_transaction_inst.imm;
      dut_vifc_in.src1 <= input_transaction_inst.src1;
      dut_vifc_in.src2 <= input_transaction_inst.src2;
      dut_vifc_in.dst <= input_transaction_inst.dst;

      wait_for_no_stall();

      seq_item_port.item_done();

    end
    
  endtask

  virtual task wait_for_no_stall();
/*
      #`HALF_CYCLE_TIME // Wait for DUT input update in clock negedge
      #`HALF_CYCLE_TIME // Wait for DUT output update in clock posedge
      #`HALF_CYCLE_TIME // Wait for Stall signal to stabilize
*/
      #`CYCLE_TIME
      wait(dut_vifc_out.stalledx3 === 1'b0);

  endtask

endclass : driver_class
