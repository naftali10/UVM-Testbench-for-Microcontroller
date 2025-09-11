class reference_model_class extends uvm_component;
  
  `uvm_component_utils(reference_model_class)
  
  function new (string name = "reference_model_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Instantiation
  uvm_analysis_imp#       (input_transaction_class,  reference_model_class) analysis_imp_inst;
  uvm_blocking_put_imp#   (reset_transaction_class,  reference_model_class) put_imp_inst;
  uvm_nonblocking_get_imp#(output_transaction_class, reference_model_class) get_imp_inst;
  output_transaction_class output_transaction_inst;
  event start_processing;
  input_transaction_class tx_transfer;
  t_data regfile [`REG_AMT-1:0];
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_imp_inst = new("analysis_imp_inst", this);
    get_imp_inst =      new("get_imp_inst",      this);
    put_imp_inst =      new("put_imp_inst",      this);
    output_transaction_inst = output_transaction_class::type_id::create("output_transaction_inst");
    tx_transfer = input_transaction_class::type_id::create("tx_transfer");
  endfunction: build_phase

  // Run phase
  virtual task run_phase(uvm_phase phase);

    fork
      forever begin
        @start_processing;
        if (tx_transfer.reset == 1'b1) begin
          `uvm_info(get_name(), "Reset has been detected. Disabling fork.", UVM_DEBUG) // FIXME - nkizner - 2022-12-31 - Delete after debug
          disable fork;
          output_transaction_inst.stalled = 1'b0;
        end
        else begin
          fork begin

            // Clone transaction
            input_transaction_class tx = input_transaction_class::type_id::create("tx");
            tx.copy(tx_transfer);

            case ({output_transaction_inst.stalled, tx.instv, tx.is_legal()}) inside
              3'b?0?:
                `uvm_info(get_name(), "Sequence item is not valid. Skipping.", UVM_DEBUG)
              3'b??0:
                `uvm_info(get_name(), "Sequence item is not legal. Skipping.", UVM_DEBUG)
              3'b1??:
                `uvm_info(get_name(), "Sequence item is stalled. Skipping.", UVM_DEBUG)
              3'b011:begin
                // `uvm_info(get_name(), "Sequence item accepted. Starting processing:", UVM_NONE) tx.print(); // FIXME - nkizner - 2022-12-31 - Delete after debug
                process_instruction(tx);
                end
              default:
                `uvm_error(get_name(), $sformatf("Unexpected case in fork. %b", {output_transaction_inst.stalled, tx.instv, tx.is_legal()}))
            endcase
          end join_none
        end // else
      end // forever
    join

  endtask: run_phase


  task process_instruction(input input_transaction_class tx);

    t_data calc_res;
    integer id = $random%100;

    id_and_wait(id);
    exe_and_wait(.is_stall(tx.opcode != OUT), .calc_res(calc_res), .tx(tx), .id(id));
    wait_and_wb (.is_stall(tx.opcode != OUT), .calc_res(calc_res), .tx(tx), .id(id));
    update_output(.dataout(calc_res), .dataoutv(tx.opcode == OUT));

  endtask: process_instruction


  task id_and_wait(input integer id);
    
    ;
    #`CYCLE_TIME;

  endtask: id_and_wait


  task exe_and_wait(input bit is_stall, input input_transaction_class tx, input integer id, output t_data calc_res);
    
    output_transaction_inst.stalled = is_stall;
    calc_res = alu_calculate(tx.opcode, tx.src1, tx.src2, tx.imm);

    #`CYCLE_TIME;

  endtask: exe_and_wait


  task wait_and_wb(input bit is_stall, input t_data calc_res, input input_transaction_class tx, input integer id);
    
    output_transaction_inst.stalled = is_stall;
    #`CYCLE_TIME;
    output_transaction_inst.stalled = 1'b0;

    if (tx.opcode != OUT) begin
      write_regfile(calc_res, tx.dst);
      // `uvm_info(get_name(), $sformatf("regfile written. Status:"), UVM_NONE); print_regfile(); // FIXME - nkizner - 2022-12-31 - Delete after debug
    end

  endtask: wait_and_wb


  function void update_output(input t_data dataout, input bit dataoutv);

    output_transaction_inst.dataout = dataout;
    output_transaction_inst.dataoutv = dataoutv;

  endfunction: update_output

  
  virtual function void write(input_transaction_class t);

    tx_transfer.copy(t);
    -> start_processing;

  endfunction: write

  
  virtual task put (input reset_transaction_class t);

    if (t.reset === 1'b1) begin
      tx_transfer.reset = 1'b1;
      -> start_processing;
    end

  endtask: put


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


  virtual function bit try_get(output output_transaction_class t);

    t = new();
    t.stalled = output_transaction_inst.stalled;
    t.dataoutv = output_transaction_inst.dataoutv;
    t.dataout = output_transaction_inst.dataout;
    return 1;

  endfunction: try_get


  virtual function bit can_get();
  endfunction: can_get

endclass: reference_model_class

