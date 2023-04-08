class reference_model_class extends uvm_component;
  
  `uvm_component_utils(reference_model_class)
  
  function new (string name = "reference_model_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
  
  // Instantiation
  uvm_analysis_imp#(input_transaction_class, reference_model_class) analysis_imp_inst;
  uvm_blocking_put_imp#(reset_transaction_class, reference_model_class) put_imp_inst;
  uvm_nonblocking_get_imp#(output_transaction_class, reference_model_class) get_imp_inst;
  output_transaction_class output_transaction_inst;
  event process_instruction;
  input_transaction_class tx_transfer;
  t_data regfile [`REG_AMT-1:0];
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_imp_inst = new("analysis_imp_inst", this);
    get_imp_inst = new("get_imp_inst", this);
    put_imp_inst = new("put_imp_inst", this);
    output_transaction_inst = output_transaction_class::type_id::create("output_transaction_inst");
    tx_transfer = input_transaction_class::type_id::create("tx_transfer");
  endfunction: build_phase

  // Run phase
  virtual task run_phase(uvm_phase phase);

    fork
      forever begin
        @process_instruction;
        if (tx_transfer.reset == 1'b1) begin
          `uvm_info(get_name(), "Reset has been detected. Disabling fork.", UVM_NONE) // FIXME - nkizner - 2022-12-31 - Delete after debug
          disable fork;
          output_transaction_inst.stalled = 1'b0;
        end
        else begin
          fork begin

            // Declarations
            t_data calc_res;

            // Clone transaction
            input_transaction_class tx = input_transaction_class::type_id::create("tx");
            tx.copy(tx_transfer);

            if (!output_transaction_inst.stalled && tx.instv && tx.is_legal()) begin
              `uvm_info(get_name(), "Sequence item accepted. Starting processing:", UVM_NONE) // FIXME - nkizner - 2022-12-31 - Delete after debug
              tx.print(); // FIXME - nkizner - 2022-12-31 - Delete after debug
              calc_res = alu_calculate(tx.opcode, tx.src1, tx.src2, tx.imm);
              pipeline_wait(.is_stall(tx.opcode != OUT));
              // Write to register file
              if (tx.opcode != OUT) begin
                `uvm_info(get_name(), $sformatf("%0d = %0d %0s %0d", calc_res, get_reg(tx.src1, tx.imm), tx.opcode.name(), get_reg(tx.src2, tx.imm)), UVM_NONE) // FIXME - nkizner - 2022-12-31 - Delete after debug
                write_regfile(calc_res, tx.dst);
                print_regfile(); // FIXME - nkizner - 2022-12-31 - Delete after debug
              end // if OUT // FIXME - nkizner - 2023-02-04 - Use else?
              output_transaction_inst.dataout = calc_res;
              output_transaction_inst.dataoutv = tx.opcode==OUT;
            end // if stalled instv
          end join_none
        end // else
      end // forever
    join

  endtask: run_phase
  
  virtual function void write(input_transaction_class t);
    tx_transfer.copy(t);
    -> process_instruction;
  endfunction: write
  
  virtual task put (input reset_transaction_class t);
    if (t.reset === 1'b1) begin
      tx_transfer.reset = 1'b1;
      -> process_instruction;
    end
  endtask: put

  function t_data get_reg (t_reg_name source, t_data imm);
    case(source)
      R0: return regfile[0];
      R1: return regfile[1];
      R2: return regfile[2];
      R3: return regfile[3];
      IMM: return imm;
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

  task pipeline_wait(input bit is_stall);

    integer id = $random%100;
    `uvm_info("Write delay", $sformatf("Start %0d", id), UVM_NONE)

    output_transaction_inst.stalled = is_stall;
    #(`STALL_DELAY + `HALF_CYCLE_TIME);
    output_transaction_inst.stalled = 1'b0;
    #`CYCLE_TIME;

    `uvm_info("Write delay", $sformatf("Finish %0d", id), UVM_NONE)

  endtask: pipeline_wait
  
  function t_data alu_calculate (t_opcode opcode, t_reg_name src1, t_reg_name src2, t_data imm);
    case(opcode)
      LD: return imm;
      OUT: return get_reg(src1, imm);// FIXME - nkizner - 2022-12-02 - check src1!=IMM      
      ADD: return get_reg(src1, imm) + get_reg(src2, imm);
      SUB: return get_reg(src1, imm) - get_reg(src2, imm);
      NAND: return ~(get_reg(src1, imm) & get_reg(src2, imm));
      NOR: return ~(get_reg(src1, imm) | get_reg(src2, imm));
      XOR: return get_reg(src1, imm) ^ get_reg(src2, imm);
      SHFL: return get_reg(src1, imm) << lsb_idx(get_reg(src2, imm));
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
    $display("%0d %0d %0d %0d", regfile[0], regfile[1], regfile[2], regfile[3]);
  endfunction

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

