class comparator_class extends uvm_component;
  
  `uvm_component_utils(comparator_class);
  
  function new (string name = "comparator_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  

  uvm_nonblocking_get_port#(output_transaction_class) DUT_outputs_tlm;
  uvm_nonblocking_get_port#(output_transaction_class) refmod_outputs_tlm;
  output_transaction_class temp_DUT_fifo[$], temp_REF_fifo[$];

  

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    DUT_outputs_tlm    = new("DUT_outputs_tlm",    this);
    refmod_outputs_tlm = new("refmod_outputs_tlm", this);

  endfunction: build_phase


  virtual function void check_phase(uvm_phase phase);

    output_transaction_class DUT_out_tx, refmod_out_tx;
    int min_size;
    string min_name;
    bit all_ok = 1;

    super.check_phase(phase);

    DUT_out_tx    = output_transaction_class::type_id::create("DUT_out_tx");
    refmod_out_tx = output_transaction_class::type_id::create("refmod_out_tx");

    while (DUT_outputs_tlm.can_get()) begin
      DUT_outputs_tlm.try_get(DUT_out_tx);
      temp_DUT_fifo.push_back(DUT_out_tx);
    end

    while (refmod_outputs_tlm.can_get()) begin
      refmod_outputs_tlm.try_get(refmod_out_tx);
      temp_REF_fifo.push_back(refmod_out_tx);
    end

    min_size = (temp_DUT_fifo.size() < temp_REF_fifo.size()) ? temp_DUT_fifo.size() : temp_REF_fifo.size();
    
    for (int i = 0; i < min_size; i++) begin
      all_ok &= are_output_transactions_same(temp_REF_fifo[i], temp_DUT_fifo[i], i);
    end

    if (!all_ok) begin
      `uvm_error(get_name(), "Output comparison failed. See errors above for details.")
      print_fifos();
    end else begin
      `uvm_info(get_name(), "All output transactions match between DUT and Reference Model.", UVM_NONE)
    end

    check_extra_outputs("DUT", "Reference Model", temp_DUT_fifo.size(), temp_REF_fifo.size());

  endfunction: check_phase


  function void check_extra_outputs(string fifo1_name, string fifo2_name, int fifo1_size, int fifo2_size);

    if (fifo1_size > fifo2_size)
      `uvm_warning(get_name(), $sformatf("%s has %0d extra output transactions that were not compared", fifo1_name, fifo1_size-fifo2_size))

    if (fifo2_size > fifo1_size)
      `uvm_warning(get_name(), $sformatf("%s has %0d extra output transactions that were not compared", fifo2_name, fifo2_size-fifo1_size))

  endfunction: check_extra_outputs


  function void print_fifos();

    `uvm_info(get_name(), "Printing contents of DUT and REF model output FIFOs:", UVM_NONE)

    for (int i = 0; i < temp_DUT_fifo.size(); i++) begin
      `uvm_info(get_name(), $sformatf("DUT FIFO %2d: stalled=%0h, dataoutv=%0h, dataout=%0h", i, temp_DUT_fifo[i].stalled, temp_DUT_fifo[i].dataoutv, temp_DUT_fifo[i].dataout), UVM_NONE)
    end
    for (int j = 0; j < temp_REF_fifo.size(); j++) begin
      `uvm_info(get_name(), $sformatf("REFMOD FIFO %2d: stalled=%0h, dataoutv=%0h, dataout=%0h", j, temp_REF_fifo[j].stalled, temp_REF_fifo[j].dataoutv, temp_REF_fifo[j].dataout), UVM_NONE)
    end

  endfunction: print_fifos


  function bit are_output_transactions_same(output_transaction_class refmod_out_tx, output_transaction_class dut_out_tx, int index);

    bit ok = 1;

    ok &= is_stalled_same(refmod_out_tx, dut_out_tx, index);
    ok &= is_dataoutv_same(refmod_out_tx, dut_out_tx, index);
    ok &= is_dataout_same(refmod_out_tx, dut_out_tx, index);
    
    return ok;

  endfunction: are_output_transactions_same


  function bit is_stalled_same(output_transaction_class refmod_out_tx, output_transaction_class dut_out_tx, int i);

    if (refmod_out_tx.stalled != dut_out_tx.stalled) begin
      `uvm_error(get_name(), $sformatf("Mismatch in 'stall' signal. DUT[%0d]: %b, REF[%0d]: %b", i, dut_out_tx.stalled, i, refmod_out_tx.stalled))
      return 0;
    end else begin
      `uvm_info(get_name(), $sformatf("'stalled' signal matches. DUT[%0d]: %b, REF[%0d]: %b", i, dut_out_tx.stalled, i, refmod_out_tx.stalled), UVM_DEBUG)
      return 1;
    end

  endfunction: is_stalled_same


  function bit is_dataoutv_same(output_transaction_class refmod_out_tx, output_transaction_class dut_out_tx, int i);

    if (refmod_out_tx.dataoutv != dut_out_tx.dataoutv) begin
      `uvm_error(get_name(), $sformatf("Mismatch in 'dataoutv' signal. DUT[%0d]: %b, REF[%0d]: %b", i, dut_out_tx.dataoutv, i, refmod_out_tx.dataoutv))
      return 0;
    end else begin
      `uvm_info(get_name(), $sformatf("'dataoutv' signal matches. DUT[%0d]: %b, REF[%0d]: %b", i, dut_out_tx.dataoutv, i, refmod_out_tx.dataoutv), UVM_DEBUG)
      return 1;
    end
    
  endfunction: is_dataoutv_same


  function bit is_dataout_same(output_transaction_class refmod_out_tx, output_transaction_class dut_out_tx, int i);

    if (refmod_out_tx.dataout&refmod_out_tx.dataoutv != dut_out_tx.dataout&dut_out_tx.dataoutv) begin
      `uvm_error(get_name(), $sformatf("Mismatch in 'dataout' signal. DUT[%0d]: %h, REF[%0d]: %h", i, dut_out_tx.dataout, i, refmod_out_tx.dataout))
      return 0;
    end else begin
      `uvm_info(get_name(), $sformatf("'dataout' signal matches. DUT[%0d]: %h, REF[%0d]: %h", i, dut_out_tx.dataout, i, refmod_out_tx.dataout), UVM_DEBUG)
      return 1;
    end

  endfunction: is_dataout_same
  
endclass: comparator_class
