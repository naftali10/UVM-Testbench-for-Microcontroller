class comparator_class extends uvm_component;
  
  `uvm_component_utils(comparator_class);
  
  function new (string name = "comparator_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  

  uvm_nonblocking_put_imp# (output_transaction_class, comparator_class) DUT_outputs_tlm;
  uvm_nonblocking_get_port#(output_transaction_class)                   refmod_outputs_tlm;
  output_transaction_class monitor_output_transaction_inst, refmod_output_transaction_inst;
  event output_tx_arrived;
  

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    DUT_outputs_tlm    = new("DUT_outputs_tlm", this);
    refmod_outputs_tlm = new("refmod_outputs_tlm", this);
    monitor_output_transaction_inst = output_transaction_class::type_id::create("monitor_output_transaction_inst");
    refmod_output_transaction_inst = output_transaction_class::type_id::create("monitor_output_transaction_inst");

  endfunction: build_phase


  task run_phase(uvm_phase phase);

    forever begin
      @ output_tx_arrived;
      fork begin
        output_transaction_class mon_out_tx = output_transaction_class::type_id::create("mon_out_tx");
        output_transaction_class refmod_out_tx = output_transaction_class::type_id::create("refmod_out_tx");
        mon_out_tx.copy(monitor_output_transaction_inst);
        sync_DUT_to_refmod();
        if (!refmod_outputs_tlm.try_get(refmod_output_transaction_inst))
          `uvm_fatal(get_name(), "Reference model failed sending transaction to Comparator")
        refmod_out_tx.copy(refmod_output_transaction_inst);
        if(mon_out_tx.dataoutv == 1'b1 || refmod_out_tx.dataoutv == 1'b1)
          if(!mon_out_tx.compare(refmod_out_tx)) begin
            `uvm_error(get_name(), "Outputs of DUT and reference model are not identical:")
            mon_out_tx.print();
            refmod_out_tx.print();
        end
      end
      join_none
    end

  endtask: run_phase


  virtual function bit try_put(output_transaction_class monitor_output_transaction_inst_);

    monitor_output_transaction_inst.copy(monitor_output_transaction_inst_);
    -> output_tx_arrived;
    return 1;

  endfunction: try_put

  virtual function bit can_put();
  endfunction: can_put

  task sync_DUT_to_refmod();
    #`SAMPLE_DELAY;
  endtask: sync_DUT_to_refmod
  
endclass: comparator_class
