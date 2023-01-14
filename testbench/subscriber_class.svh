class subscriber_class extends uvm_subscriber#(input_transaction_class);
  
  `uvm_component_utils(subscriber_class)
  
  // Declarations
  logic reset, instv;
  t_opcode opcode;
  t_data imm;
  t_reg_name src1, src2;
  t_reg_name dst;
  
  // Coverage
  covergroup covgrp;
    coverpoint reset;
    validity: coverpoint instv {
        bins val = {1'b1};
        bins inv = {1'b0};}
    ops: coverpoint opcode {
        bins all [] = {LD, OUT, ADD, SUB, NAND, NOR, XOR, SHFL};}
        // bins in_out = {LD, OUT};
        // bins calc = {ADD, SUB, NAND, NOR, XOR, SHFL};}
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
    illegal_ops: cross ops, validity, reset, src1, src2, dst{
        ignore_bins reset = binsof (reset) intersect {1'b1};
        ignore_bins inv = binsof (validity.inv);
        ignore_bins legal_calc = binsof (ops) intersect {ADD, SUB, NAND, NOR, XOR, SHFL} && binsof (dst.legal);
        ignore_bins legal_ld = binsof (ops) intersect {LD} && binsof (src1) intersect {IMM};
        ignore_bins legal_out = binsof (ops) intersect {OUT} && !binsof (src1) intersect {IMM};
        bins illegal_ld = binsof (ops) intersect {LD} && !binsof (src1) intersect {IMM};
        bins illegal_out = binsof (ops) intersect {OUT} && binsof (src1) intersect {IMM};
        bins illegal_dst = binsof (dst) intersect {IMM};
        }
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
                                    covgrp.illegal_ops.get_coverage()
                                    ),
                                    UVM_NONE);
  endfunction
  
endclass
