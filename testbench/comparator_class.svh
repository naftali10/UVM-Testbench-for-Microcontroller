class comparator_class extends uvm_component;
  
  `uvm_component_utils(comparator_class);
  
  function new (string name = "comparator_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  

  uvm_nonblocking_get_port#(output_transaction_class) DUT_outputs_tlm;
  uvm_nonblocking_get_port#(output_transaction_class) refmod_outputs_tlm;
  

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    DUT_outputs_tlm    = new("DUT_outputs_tlm",    this);
    refmod_outputs_tlm = new("refmod_outputs_tlm", this);

  endfunction: build_phase


  virtual function void check_phase(uvm_phase phase);

    output_transaction_class DUT_out_tx, refmod_out_tx;

    super.check_phase(phase);

    // print_fifos();

    DUT_out_tx    = output_transaction_class::type_id::create("DUT_out_tx");
    refmod_out_tx = output_transaction_class::type_id::create("refmod_out_tx");

    while (DUT_outputs_tlm.can_get() && refmod_outputs_tlm.can_get()) begin
      DUT_outputs_tlm.   try_get(DUT_out_tx);
      refmod_outputs_tlm.try_get(refmod_out_tx);
      compare_output_transactions(DUT_out_tx, refmod_out_tx);
    end

    if(refmod_outputs_tlm.can_get())
      `uvm_warning(get_name(), "Reference model has extra output transactions that were not compared with DUT output transactions")
    if(DUT_outputs_tlm.can_get())
      `uvm_warning(get_name(), "DUT has extra output transactions that were not compared with reference model output transactions")

  endfunction: check_phase


  function void print_fifos();

    output_transaction_class DUT_out_tx, refmod_out_tx;
    int idx = 0;

    while (DUT_outputs_tlm.can_get()) begin
      DUT_outputs_tlm.try_get(DUT_out_tx);
      `uvm_info(get_name(), $sformatf("DUT FIFO %2d: stalled=%0h, dataoutv=%0h, dataout=%0h", idx, DUT_out_tx.stalled, DUT_out_tx.dataoutv, DUT_out_tx.dataout), UVM_NONE)
      idx = idx + 1;
    end

    idx = 0;

    while (refmod_outputs_tlm.can_get()) begin
      refmod_outputs_tlm.try_get(refmod_out_tx);
      `uvm_info(get_name(), $sformatf("REFMOD FIFO %2d: stalled=%0h, dataoutv=%0h, dataout=%0h", idx, refmod_out_tx.stalled, refmod_out_tx.dataoutv, refmod_out_tx.dataout), UVM_NONE)
      idx = idx + 1;
    end

  endfunction: print_fifos


  function void compare_output_transactions(output_transaction_class refmod_out_tx, output_transaction_class mon_out_tx);

    compare_stalled(refmod_out_tx, mon_out_tx);
    compare_dataoutv(refmod_out_tx, mon_out_tx);
    compare_dataout(refmod_out_tx, mon_out_tx);

  endfunction: compare_output_transactions


  function void compare_stalled(output_transaction_class refmod_out_tx, output_transaction_class mon_out_tx);

    if (refmod_out_tx.stalled != mon_out_tx.stalled) begin
      `uvm_error(get_name(), $sformatf("Mismatch in 'stall' signal. DUT: %b, REF: %b", mon_out_tx.stalled, refmod_out_tx.stalled))
    end else begin
      `uvm_info(get_name(), $sformatf("'stalled' signal matches. DUT: %b, REF: %b", mon_out_tx.stalled, refmod_out_tx.stalled), UVM_DEBUG)
    end

  endfunction: compare_stalled


  function void compare_dataoutv(output_transaction_class refmod_out_tx, output_transaction_class mon_out_tx);

    if (refmod_out_tx.dataoutv != mon_out_tx.dataoutv) begin
      `uvm_error(get_name(), $sformatf("Mismatch in 'dataoutv' signal. DUT: %b, REF: %b", mon_out_tx.dataoutv, refmod_out_tx.dataoutv))
    end else begin
      `uvm_info(get_name(), $sformatf("'dataoutv' signal matches. DUT: %b, REF: %b", mon_out_tx.dataoutv, refmod_out_tx.dataoutv), UVM_DEBUG)
    end
    
  endfunction: compare_dataoutv


  function void compare_dataout(output_transaction_class refmod_out_tx, output_transaction_class mon_out_tx);

    if (refmod_out_tx.dataout&refmod_out_tx.dataoutv != mon_out_tx.dataout&mon_out_tx.dataoutv) begin
      `uvm_error(get_name(), $sformatf("Mismatch in 'dataout' signal. DUT: %h, REF: %h", mon_out_tx.dataout, refmod_out_tx.dataout))
    end else begin
      `uvm_info(get_name(), $sformatf("'dataout' signal matches. DUT: %h, REF: %h", mon_out_tx.dataout, refmod_out_tx.dataout), UVM_DEBUG)
    end

  endfunction: compare_dataout
  
endclass: comparator_class
