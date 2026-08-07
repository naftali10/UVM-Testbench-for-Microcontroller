class reference_model_class extends uvm_component;
  
  `uvm_component_utils(reference_model_class)
  
  function new (string name = "reference_model_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Instantiation
  uvm_analysis_imp#       (input_transaction_class,  reference_model_class)    DUT_inputs_tlm;
  uvm_blocking_put_imp#   (reset_transaction_class,  reference_model_class)    reset_tlm;
  tlm_fifo_class#         (input_transaction_class) DUT_inputs_fifo;
  tlm_fifo_class#         (reset_transaction_class) reset_fifo;
  output_tlm_fifo_class   outputs_fifo_tlm, speculated_outputs_fifo_tlm;

  regfile_transaction_class regfile, speculated_regfile;
  output_transaction_class not_stalled_not_valid, yes_stalled_not_valid, not_stalled_yes_valid;

  bit reset_flag;


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    make_tlm();
    make_output_templates();
    make_regfile();
    reset_flag = 0;

  endfunction: build_phase


  virtual function void write(input_transaction_class t);

    input_transaction_class tx_transfer = input_transaction_class::type_id::create("tx_transfer");
    tx_transfer.copy(t);
    DUT_inputs_fifo.try_put(tx_transfer);

  endfunction: write

  
  virtual task put(input reset_transaction_class t);

    reset_transaction_class tx_transfer = reset_transaction_class::type_id::create("tx_transfer");
    tx_transfer.copy(t);
    reset_fifo.try_put(tx_transfer);

  endtask: put


  function void make_tlm();

    DUT_inputs_tlm              = new("DUT_inputs_tlm",              this);
    reset_tlm                   = new("reset_tlm",                   this);
    DUT_inputs_fifo             = new("DUT_inputs_fifo",             this, 0);
    reset_fifo                  = new("reset_fifo",                  this, 0);
    outputs_fifo_tlm            = new("outputs_fifo_tlm",            this, 0);
    speculated_outputs_fifo_tlm = new("speculated_outputs_fifo_tlm", this, 0);

  endfunction: make_tlm


  function void make_output_templates();

    not_stalled_not_valid = output_transaction_class::type_id::create("not_stalled_not_valid");
    not_stalled_yes_valid = output_transaction_class::type_id::create("not_stalled_yes_valid");
    yes_stalled_not_valid = output_transaction_class::type_id::create("yes_stalled_not_valid");

    not_stalled_not_valid.stalled  = 1'b0;
    not_stalled_not_valid.dataoutv = 1'b0;

    not_stalled_yes_valid.stalled  = 1'b0;
    not_stalled_yes_valid.dataoutv = 1'b1;

    yes_stalled_not_valid.stalled  = 1'b1;
    yes_stalled_not_valid.dataoutv = 1'b0;

  endfunction: make_output_templates


  function void make_regfile();

    regfile = regfile_transaction_class::type_id::create("regfile");
    speculated_regfile = regfile_transaction_class::type_id::create("speculated_regfile");
    regfile.reset();
    speculated_regfile.reset();

  endfunction: make_regfile


  virtual function void extract_phase(uvm_phase phase);

    super.extract_phase(phase);
    predict_outputs();

  endfunction: extract_phase


  function void predict_outputs();

    integer simulation_length = get_simulation_length();

    for (integer sim_time = 1; sim_time < simulation_length; sim_time += 2) begin
      `uvm_info(get_name(), $sformatf("Simulation time is %0d of %0d", sim_time, simulation_length), UVM_NONE);
      predict_by_inputs_FIFO(sim_time);
      predict_by_reset_FIFO(sim_time+1);
      predict_from_speculated_WB(sim_time);
      print_outputs_fifo();
    end

  endfunction: predict_outputs


  function integer get_simulation_length();

    return reset_fifo.used() * 2;

  endfunction: get_simulation_length


  function void predict_by_inputs_FIFO(integer sim_time);

    input_transaction_class inputs_tx = input_transaction_class::type_id::create("inputs_tx");

    inputs_tx = DUT_inputs_fifo.get_transaction();
    inputs_tx.verify_time(sim_time);
    `uvm_info(get_name(), "Processing inputs transaction:", UVM_NONE) inputs_tx.print();

    if (inputs_tx.will_reset()  || reset_flag) begin
      if (speculated_outputs_fifo_tlm.is_empty()) begin
        `uvm_info(get_name(), $sformatf("instruction will reset. predicting 1 step backwards."), UVM_NONE);
        outputs_fifo_tlm.add_prediction(not_stalled_not_valid, sim_time-1);
      end else begin
          `uvm_info(get_name(), $sformatf("instruction will reset. predicting from speculation, then deleting it."), UVM_NONE);
          predict_from_speculated_outputs();
      end
      delete_speculated_outputs();
      delete_speculated_WB();
      reset_flag = 0;
    end else

    if (inputs_tx.will_writeback()) begin
      if (outputs_fifo_tlm.is_last_stalled()) begin
          `uvm_info(get_name(), $sformatf("instruction does nothing. predicting from speculated outputs"), UVM_NONE);
          predict_from_speculated_outputs();
      end else begin
        if (speculated_outputs_fifo_tlm.is_empty()) begin
          `uvm_info(get_name(), $sformatf("instruction will writeback. predicting 3 steps ahead"), UVM_NONE);
          outputs_fifo_tlm.           add_prediction(yes_stalled_not_valid, sim_time-1);
          speculated_outputs_fifo_tlm.add_prediction(yes_stalled_not_valid, sim_time+1);
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_not_valid, sim_time+3);
        end else begin
          `uvm_info(get_name(), $sformatf("instruction will writeback. stalling 2 steps ahead, and predicting from speculation."), UVM_NONE);
          add_stall_to_first_2_speculated_outputs();
          predict_from_speculated_outputs();
        end        
        // add_speculated_WB(inputs_tx, sim_time);   //  <-- Stopped here
      end
    end else

    if (inputs_tx.will_output()) begin
      if (outputs_fifo_tlm.is_last_stalled()) begin
        `uvm_info(get_name(), $sformatf("instruction does nothing. predicting from speculated outputs"), UVM_NONE);
        predict_from_speculated_outputs();
      end else begin
        if (speculated_outputs_fifo_tlm.is_empty()) begin
          `uvm_info(get_name(), $sformatf("instruction will output. predicting 4 steps ahead"), UVM_NONE);
          outputs_fifo_tlm.           add_prediction(not_stalled_not_valid, sim_time-1);
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_not_valid, sim_time+1);
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_not_valid, sim_time+3);
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_yes_valid, sim_time+5);
        end else begin  // No stall, and there are spculations ==> OUT was latest instruction
          `uvm_info(get_name(), $sformatf("instruction will output after output. predicting from specultaion and adding 1 speculation"), UVM_NONE);
          predict_from_speculated_outputs();
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_yes_valid, sim_time+5);
        end
      end
    end

  endfunction: predict_by_inputs_FIFO


  function void predict_by_reset_FIFO(int sim_time);

    reset_transaction_class reset_tx = reset_transaction_class::type_id::create("reset_tx");

    reset_tx = reset_fifo.get_transaction();
    reset_tx.verify_time(sim_time);
    
    `uvm_info(get_name(), "Processing reset transaction:", UVM_NONE) reset_tx.print();

    if (reset_tx.will_reset()) begin
      `uvm_info(get_name(), $sformatf("instruction will reset. raising reset flag."), UVM_NONE);
      reset_flag = 1;
    end
  
  endfunction: predict_by_reset_FIFO


  function void delete_speculated_outputs();

    speculated_outputs_fifo_tlm.flush();

  endfunction: delete_speculated_outputs

  
  function void delete_speculated_WB();

    speculated_regfile.reset();

  endfunction: delete_speculated_WB


  function void predict_from_speculated_outputs();

    output_transaction_class tx = output_transaction_class::type_id::create("tx");
    tx = speculated_outputs_fifo_tlm.pop_prediction();
    outputs_fifo_tlm.add_prediction(tx);

  endfunction: predict_from_speculated_outputs


  function void add_stall_to_first_2_speculated_outputs();

    speculated_outputs_fifo_tlm.add_stalls(2);

  endfunction: add_stall_to_first_2_speculated_outputs


  function void predict_from_speculated_WB(int sim_time);

    if (speculated_regfile.create_time == sim_time)
        regfile.copy(speculated_regfile);

  endfunction: predict_from_speculated_WB


  virtual function print_outputs_fifo();

    int fifo_size = outputs_fifo_tlm.used();
    output_transaction_class item = output_transaction_class::type_id::create("item");
    `uvm_info(get_name(), $sformatf("Printing outputs FIFO contents. Size: %0d", fifo_size), UVM_NONE);
    for (int i = 0; i < fifo_size; i++) begin
      if (outputs_fifo_tlm.try_get(item)) begin
        `uvm_info(get_name(), $sformatf("FIFO Item %0d: time=%0d, stalled=%0h, dataoutv=%0h, dataout=%0h", i, item.create_time, item.stalled, item.dataoutv, item.dataout), UVM_NONE);
        outputs_fifo_tlm.try_put(item);
      end
    end

    fifo_size = speculated_outputs_fifo_tlm.used();
    `uvm_info(get_name(), $sformatf("Printing speculated outputs FIFO contents. Size: %0d", fifo_size), UVM_NONE);
    for (int i = 0; i < fifo_size; i++) begin
      if (speculated_outputs_fifo_tlm.try_get(item)) begin
        `uvm_info(get_name(), $sformatf("FIFO Item %0d: time=%0d, stalled=%0h, dataoutv=%0h, dataout=%0h", i, item.create_time, item.stalled, item.dataoutv, item.dataout), UVM_NONE);
        speculated_outputs_fifo_tlm.try_put(item);
      end
    end

  endfunction: print_outputs_fifo

endclass: reference_model_class