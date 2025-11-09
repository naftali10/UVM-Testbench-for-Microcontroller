class reference_model_class extends uvm_component;
  
  `uvm_component_utils(reference_model_class)
  
  function new (string name = "reference_model_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Instantiation
  uvm_analysis_imp#       (input_transaction_class,  reference_model_class)    DUT_inputs_tlm;
  uvm_blocking_put_imp#   (reset_transaction_class,  reference_model_class)    reset_tlm;
  uvm_tlm_fifo#           (output_transaction_class) outputs_fifo_tlm;

  int stall_counter = 0;
  bit last_in_fifo_tlm_is_valid_out = 0;
  t_data regfile [`REG_AMT-1:0];
  output_transaction_class not_stalled_not_valid;
  output_transaction_class stalled_not_valid;
  output_transaction_class not_stalled_valid;


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    DUT_inputs_tlm   = new("DUT_inputs_tlm",   this);
    reset_tlm        = new("reset_tlm",        this);
    outputs_fifo_tlm = new("outputs_fifo_tlm", this, 0);

    make_output_templates();

  endfunction: build_phase


  virtual function void write(input_transaction_class t);

    input_transaction_class tx_transfer = input_transaction_class::type_id::create("tx_transfer");
    tx_transfer.copy(t);
    if (should_predict(tx_transfer))
      predict_outputs(tx_transfer);

  endfunction: write

  
  virtual task put (input reset_transaction_class t);

    input_transaction_class tx_transfer = input_transaction_class::type_id::create("tx_transfer");
    tx_transfer.copy(t);
    if (tx_transfer.reset == 1'b1) begin
      tx_transfer.reset = 1'b1;
    end
    stall_counter = stall_counter-1;

  endtask: put


  function bit should_predict(input_transaction_class tx);

    case ({0<stall_counter, tx.instv, tx.is_legal()}) inside
      3'b?0?: begin`uvm_info(get_name(), "Sequence item is not valid. Skipping.", UVM_DEBUG)  return 0; end
      3'b??0: begin `uvm_info(get_name(), "Sequence item is not legal. Skipping.", UVM_DEBUG) return 0; end
      3'b1??: begin `uvm_info(get_name(), "Sequence item is stalled. Skipping.",   UVM_DEBUG) return 0; end
      3'b011: begin /*`uvm_info(get_name(), "Sequence item accepted for prediction:", UVM_NONE) tx.print();*/ return 1; end
      default: begin
        `uvm_error(get_name(), $sformatf("Unexpected case. %b", {0<stall_counter, tx.instv, tx.is_legal()}))
        return 0;
      end
    endcase

  endfunction: should_predict


  function void make_output_templates();

    not_stalled_not_valid = output_transaction_class::type_id::create("not_stalled_not_valid");
    stalled_not_valid     = output_transaction_class::type_id::create("stalled_not_valid");
    not_stalled_valid     = output_transaction_class::type_id::create("not_stalled_valid");

    not_stalled_not_valid.stalled  = 1'b0;
    not_stalled_not_valid.dataoutv = 1'b0;

    stalled_not_valid.stalled  = 1'b1;
    stalled_not_valid.dataoutv = 1'b0;

    not_stalled_valid.stalled  = 1'b0;
    not_stalled_valid.dataoutv = 1'b1;

  endfunction: make_output_templates


  function void predict_outputs(input_transaction_class tx);

    if (tx.will_reset()) begin
      predict_reset();
      stall_counter = 0;
    end
    else if (tx.will_output()) begin
      predict_out(tx);
      stall_counter = 0;
    end
    else if (tx.will_writeback()) begin
      predict_writeback(tx);
      stall_counter = 3;
    end
    else begin
      `uvm_error(get_name(), "Instruction is neither reset, output, nor writeback. This should never happen.")
    end

  endfunction: predict_outputs


  function void predict_reset();

    outputs_fifo_tlm.flush();
    outputs_fifo_tlm.try_put(not_stalled_not_valid);
    last_in_fifo_tlm_is_valid_out = 0;

  endfunction: predict_reset


  function void predict_out(input_transaction_class tx);

    output_transaction_class valid_out = output_transaction_class::type_id::create("valid_out");
    valid_out.copy(not_stalled_valid);
    valid_out.dataout = alu_calculate(tx.opcode, tx.src1, tx.src2, tx.imm);
    
    if (last_in_fifo_tlm_is_valid_out)
      outputs_fifo_tlm.try_put(valid_out);
    else begin
      outputs_fifo_tlm.try_put(not_stalled_not_valid);
      outputs_fifo_tlm.try_put(not_stalled_not_valid);
      outputs_fifo_tlm.try_put(not_stalled_not_valid);
      outputs_fifo_tlm.try_put(valid_out);
    end
    last_in_fifo_tlm_is_valid_out = 1;

  endfunction: predict_out


  function void predict_writeback(input_transaction_class tx);

    t_data result = alu_calculate(tx.opcode, tx.src1, tx.src2, tx.imm);
    write_regfile(result, tx.dst);
    `uvm_info(get_name(), $sformatf("Writing back %0h to R%0d", result, tx.dst), UVM_NONE)
    outputs_fifo_tlm.try_put(stalled_not_valid);
    outputs_fifo_tlm.try_put(stalled_not_valid);
    outputs_fifo_tlm.try_put(not_stalled_not_valid);
    last_in_fifo_tlm_is_valid_out = 0;

  endfunction: predict_writeback


  function t_data get_reg (t_reg_name source, t_data imm);

    case(source)
      R0: return regfile[0];
      R1: return regfile[1];
      R2: return regfile[2];
      R3: return regfile[3];
      IMM: return imm;
      default: `uvm_error(get_name(), $sformatf("Invalid register name %0d", source))
    endcase

  endfunction: get_reg


  function int lsb_idx(t_data num);

    int i=0;
    num = (num & (num-1)) ^ num;
    while(num) begin
      num = num >> 1;
      i++;
    end
    return i;

  endfunction: lsb_idx

  
  function t_data alu_calculate (t_opcode opcode, t_reg_name src1, t_reg_name src2, t_data imm);

    case(opcode)
      LD: return imm;
      OUT: return get_reg(src1, imm);  // FIXME - nkizner - 2022-12-02 - check src1!=IMM
      ADD: return get_reg(src1, imm) + get_reg(src2, imm);
      SUB: return get_reg(src1, imm) - get_reg(src2, imm);
      NAND: return ~(get_reg(src1, imm) & get_reg(src2, imm));
      NOR: return ~(get_reg(src1, imm) | get_reg(src2, imm));
      XOR: return get_reg(src1, imm) ^ get_reg(src2, imm);
      SHFL: return get_reg(src1, imm) << lsb_idx(get_reg(src2, imm));
      default: `uvm_error(get_name(), $sformatf("Invalid opcode %0h", opcode))
    endcase

  endfunction: alu_calculate


  function void write_regfile(t_data value, t_reg_name destination);

    case (destination)
      R0: regfile[0] = value;
      R1: regfile[1] = value;
      R2: regfile[2] = value;
      R3: regfile[3] = value;
    endcase

  endfunction: write_regfile


  function void print_regfile();

    $display("%0h %0h %0h %0h", regfile[0], regfile[1], regfile[2], regfile[3]);

  endfunction: print_regfile


  virtual function print_fifo();

    int fifo_size = outputs_fifo_tlm.used();
    output_transaction_class item = output_transaction_class::type_id::create("item");
    `uvm_info(get_name(), $sformatf("Printing FIFO contents. Size: %0d", fifo_size), UVM_NONE);
    for (int i = 0; i < fifo_size; i++) begin
      if (outputs_fifo_tlm.try_get(item)) begin
        `uvm_info(get_name(), $sformatf("FIFO Item %0d: stalled=%0h, dataoutv=%0h, dataout=%0h", i, item.stalled, item.dataoutv, item.dataout), UVM_NONE);
        outputs_fifo_tlm.try_put(item);
      end
    end
  endfunction: print_fifo

endclass: reference_model_class
