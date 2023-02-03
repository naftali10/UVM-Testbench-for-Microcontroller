class subscriber_class extends uvm_subscriber#(input_transaction_class);
  
  `uvm_component_utils(subscriber_class)
  
  // Declarations
  logic reset, instv;
  t_opcode opcode;
  t_data imm;
  t_reg_name src1, src2;
  t_reg_name dst;

  string cov_samp_report = "\nList of coverage samples:\n";
  
  // Coverage
  covergroup covgrp;
    reset_seq: coverpoint reset{
      bins after1 = (1'b0 [*1] => 1'b1);
      bins after2 = (1'b0 [*2] => 1'b1);
      bins after3 = (1'b0 [*3] => 1'b1);
      bins on_then_off = (1'b1 => 1'b0);}
    val_seq: coverpoint instv{
      bins two = (1'b1 [*2]);
      bins three = (1'b1 [*3]);
      bins four = (1'b1 [*4]);}
    validity: coverpoint instv {
      bins val = {1'b1};
      bins inv = {1'b0};}
    ops: coverpoint opcode {
      bins all [] = {LD, OUT, ADD, SUB, NAND, NOR, XOR, SHFL};}
      // bins in_out = {LD, OUT};
      // bins calc = {ADD, SUB, NAND, NOR, XOR, SHFL};}
    start_with_op: coverpoint opcode {
      wildcard bins _ld = (LD => 'b?);
      wildcard bins _out = (OUT => 'b?);
      wildcard bins _add = (ADD => 'b?);
      wildcard bins _sub = (SUB => 'b?);
      wildcard bins _nand = (NAND => 'b?);
      wildcard bins _nor = (NOR => 'b?);
      wildcard bins _xor = (XOR => 'b?);
      wildcard bins _shfl = (SHFL => 'b?);}
    end_with_op: coverpoint opcode {
      wildcard bins _ld = ('b? => LD);
      wildcard bins _out = ('b? => OUT);
      wildcard bins _add = ('b? => ADD);
      wildcard bins _sub = ('b? => SUB);
      wildcard bins _nand = ('b? => NAND);
      wildcard bins _nor = ('b? => NOR);
      wildcard bins _xor = ('b? => XOR);
      wildcard bins _shfl = ('b? => SHFL);}
    coverpoint imm;
    coverpoint src1;
    coverpoint src2;
    coverpoint dst {
      bins legal = {[R0:R3]};
      bins illegal = {IMM};}
    val_ops: cross opcode, validity {
      ignore_bins inv = binsof (validity.inv);}
    inv_ops: cross opcode, validity {
      ignore_bins val = binsof (validity.val);}
    illegal_instr: cross ops, validity, reset, src1, dst{
      ignore_bins reset = binsof (reset) intersect {1'b1};
      ignore_bins inv = binsof (validity.inv);
      ignore_bins legal_calc = binsof (ops) intersect {ADD, SUB, NAND, NOR, XOR, SHFL} && binsof (dst.legal);
      ignore_bins legal_ld = binsof (ops) intersect {LD} && binsof (src1) intersect {IMM};
      ignore_bins legal_out = binsof (ops) intersect {OUT} && !binsof (src1) intersect {IMM};
      bins illegal_ld = binsof (ops) intersect {LD} && !binsof (src1) intersect {IMM};
      bins illegal_out = binsof (ops) intersect {OUT} && binsof (src1) intersect {IMM};
      bins illegal_dst = binsof (dst.illegal);}
    legal_instr: cross ops, validity, reset, src1, dst{
      ignore_bins illegal_ld = binsof (ops) intersect {LD} && !binsof (src1) intersect {IMM} && binsof (reset) intersect {1'b0} && binsof (validity.val);
      ignore_bins illegal_out = binsof (ops) intersect {OUT} && binsof (src1) intersect {IMM} && binsof (reset) intersect {1'b0} && binsof (validity.val);
      ignore_bins illegal_dst = binsof (dst.illegal) && binsof (reset) intersect {1'b0} && binsof (validity.val);
      bins all = binsof (ops.all);}
    in_flight_reset: cross val_seq, reset_seq, legal_instr {
      bins reset_after_1 = binsof (reset_seq.after1) && binsof (val_seq.two);
      bins reset_after_2 = binsof (reset_seq.after2) && binsof (val_seq.three);
      bins reset_after_3 = binsof (reset_seq.after3) && binsof (val_seq.four);
      ignore_bins not_synced_1 = binsof (reset_seq.after1) && !binsof (val_seq.two);
      ignore_bins not_synced_2 = binsof (reset_seq.after2) && !binsof (val_seq.three);
      ignore_bins not_synced_3 = binsof (reset_seq.after3) && !binsof (val_seq.four);
      ignore_bins reset_on_then_off = binsof (reset_seq.on_then_off);}
    reset_right_after_ops: cross val_seq, reset_seq, legal_instr, start_with_op {
      ignore_bins reset_on_then_off = binsof (reset_seq.on_then_off);
      ignore_bins reset_after_2 = binsof (reset_seq.after2);
      ignore_bins reset_after_3 = binsof (reset_seq.after3);
      ignore_bins three_valid_ops = binsof (val_seq.three);
      ignore_bins four_valid_ops = binsof (val_seq.four);}
    ops_right_after_reset: cross val_seq, reset_seq, legal_instr, end_with_op {
      ignore_bins three_valid_ops = binsof (val_seq.three);
      ignore_bins four_valid_ops = binsof (val_seq.four);
      ignore_bins reset_after_1 = binsof (reset_seq.after1);
      ignore_bins reset_after_2 = binsof (reset_seq.after2);
      ignore_bins reset_after_3 = binsof (reset_seq.after3);}
  endgroup: covgrp
  
  function new (string name = "subscriber_class", uvm_component parent = null);
    super.new(name, parent);
    covgrp = new();
  endfunction: new
    
  // Write
  function void write (input_transaction_class t);
    reset= t.reset;
    instv = t.instv;
    opcode = t.opcode;
    imm = t.imm;
    src1 = t.src1;
    src2 = t.src2;
    dst = t.dst;
    covgrp.sample();

    cov_samp_report = {cov_samp_report, $sformatf("reset = %b \t instv = %b \t opcode = %s \t src1 = %s \t dst = %s \n", t.reset, t.instv, t.opcode, t.src1, t.dst)};

  endfunction: write
  
  // Report phase
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_name(), $sformatf({"\nCoverage Statistics:\n",
                                    "All operations = %0.2f %%\n",
                                    "Valid operations = %0.2f %%\n",
                                    "Invalid operations = %0.2f %%\n",
                                    "Illegal instructions = %0.2f %%\n"
                                    },
                                    covgrp.opcode.get_coverage(),
                                    covgrp.val_ops.get_coverage(),
                                    covgrp.inv_ops.get_coverage(),
                                    covgrp.illegal_instr.get_coverage()
                                    ),
                                    UVM_NONE);
    `uvm_info(get_name(), cov_samp_report, UVM_NONE)
  endfunction
  
endclass
