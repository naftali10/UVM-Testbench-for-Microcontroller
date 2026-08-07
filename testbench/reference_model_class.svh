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


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    make_tlm();
    make_output_templates();
    make_regfile();

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
    outputs_fifo_tlm            = new("outputs_fifo_tlm"                 );
    DUT_inputs_fifo             = new("DUT_inputs_fifo"                  );
    reset_fifo                  = new("reset_fifo"                       );
    speculated_outputs_fifo_tlm = new("speculated_outputs_fifo_tlm"      );

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

    for (integer global_time = 0; global_time < simulation_length; global_time++) begin
      predict_by_inputs_FIFO(global_time);
      // predict_by_reset_FIFO(global_time+1);
      // predict_from_speculated_WB(global_time);
      global_time += 2;
    end

  endfunction: predict_outputs


  function integer get_simulation_length();

    return reset_fifo.used() * 2;

  endfunction: get_simulation_length


  function void predict_by_inputs_FIFO(integer global_time);

    input_transaction_class inputs_tx = input_transaction_class::type_id::create("inputs_tx");

    inputs_tx = DUT_inputs_fifo.get_transaction();
    inputs_tx.verify_time(global_time);

    if (inputs_tx.will_reset()) begin
      delete_speculated_outputs();
      delete_speculated_WB();
      outputs_fifo_tlm.add_prediction(not_stalled_not_valid);
    end else

    if (inputs_tx.will_writeback()) begin
      if (outputs_fifo_tlm.is_last_stalled()) begin
          predict_from_speculated_outputs();
      end else begin
        if (speculated_outputs_fifo_tlm.is_empty()) begin
          outputs_fifo_tlm.           add_prediction(yes_stalled_not_valid);
          speculated_outputs_fifo_tlm.add_prediction(yes_stalled_not_valid);
          speculated_outputs_fifo_tlm.add_prediction(yes_stalled_not_valid);
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_not_valid);
        end else begin
          add_stall_to_first_3_speculated_outputs();
          predict_from_speculated_outputs();
        end        
        // add_speculated_WB(inputs_tx, global_time);   //  <-- Stopped here
      end
    end else

    if (inputs_tx.will_output()) begin
      if (outputs_fifo_tlm.is_last_stalled()) begin
        predict_from_speculated_outputs();
      end else begin
        if (speculated_outputs_fifo_tlm.is_empty()) begin
          outputs_fifo_tlm.           add_prediction(not_stalled_not_valid);
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_not_valid);
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_not_valid);
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_yes_valid);
        end else begin  // No stall, and there are spculations ==> OUT was latest instruction
          predict_from_speculated_outputs();
          speculated_outputs_fifo_tlm.add_prediction(not_stalled_yes_valid);
        end
      end
    end

  endfunction: predict_by_inputs_FIFO


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


  function void add_stall_to_first_3_speculated_outputs();

    speculated_outputs_fifo_tlm.add_stalls(3);

  endfunction: add_stall_to_first_3_speculated_outputs


  virtual function print_outputs_fifo();

    int fifo_size = outputs_fifo_tlm.used();
    output_transaction_class item = output_transaction_class::type_id::create("item");
    `uvm_info(get_name(), $sformatf("Printing FIFO contents. Size: %0d", fifo_size), UVM_NONE);
    for (int i = 0; i < fifo_size; i++) begin
      if (outputs_fifo_tlm.try_get(item)) begin
        `uvm_info(get_name(), $sformatf("FIFO Item %0d: stalled=%0h, dataoutv=%0h, dataout=%0h", i, item.stalled, item.dataoutv, item.dataout), UVM_NONE);
        outputs_fifo_tlm.try_put(item);
      end
    end

  endfunction: print_outputs_fifo

endclass: reference_model_class








void function predict_by_reset_FIFO(int global_time);

  get_reset_tx_from_FIFO();
  verify_reset_tx_time();

  if (reset_tx.will_reset()) begin
    delete_speculated_outputs();
    delete_speculated_WB();
  end

endfunction


void function predict_from_speculated_WB(int global_time);

  if (speculated_WB_FIFO.is_empty()) begin
  end else begin
    if (global_time == speculated_WB_FIFO.get_first().create_time) begin
      apply_speculated_WB();
    end
  end

endfunction