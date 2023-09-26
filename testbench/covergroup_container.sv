class covergroup_container extends uvm_component;

	`uvm_component_utils(covergroup_container)

    uvm_blocking_put_imp#(coverage_transaction_class, covergroup_container) put_imp_inst;

    extern function new(string name = "covergroup_container", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task put (input coverage_transaction_class t);

    covergroup covgrp with function sample (coverage_transaction_class coverage);

        opcode : coverpoint coverage.opcode;
        opcodes_used_as_both_valid_and_invalid : coverpoint coverage.opcodes_used_as_both_valid_and_invalid{
            wildcard bins _ld   = {8'b_????_???1};
            wildcard bins _out  = {8'b_????_??1?};
            wildcard bins _add  = {8'b_????_?1??};
            wildcard bins _sub  = {8'b_????_1???};
            wildcard bins _nand = {8'b_???1_????};
            wildcard bins _nor  = {8'b_??1?_????};
            wildcard bins _xor  = {8'b_?1??_????};
            wildcard bins _shfl = {8'b_1???_????};
        }
        illegal_instructions : coverpoint coverage.illegal_instructions {
            wildcard bins ld      = {3'b1??};
            wildcard bins out     = {3'b?1?};
            wildcard bins imm_dst = {3'b??1};
        }
        ops: coverpoint coverage.opcode {
            bins all [] = {LD, OUT, ADD, SUB, NAND, NOR, XOR, SHFL};
        }
        regs_used_as_src_before_initiated: coverpoint coverage.regs_used_as_src_before_initiated {
            wildcard bins r0 = {4'b???1};
            wildcard bins r1 = {4'b??1?};
            wildcard bins r2 = {4'b?1??};
            wildcard bins r3 = {4'b1???};
        }
        regs_used_for_output: coverpoint coverage.regs_used_for_output {
            wildcard bins r0 = {4'b???1};
            wildcard bins r1 = {4'b??1?};
            wildcard bins r2 = {4'b?1??};
            wildcard bins r3 = {4'b1???};
        }
        opcodes_cancelled_after_1_cycle : coverpoint coverage.opcodes_cancelled_after_1_cycle {
            wildcard bins _ld   = {8'b_????_???1};
            wildcard bins _out  = {8'b_????_??1?};
            wildcard bins _add  = {8'b_????_?1??};
            wildcard bins _sub  = {8'b_????_1???};
            wildcard bins _nand = {8'b_???1_????};
            wildcard bins _nor  = {8'b_??1?_????};
            wildcard bins _xor  = {8'b_?1??_????};
            wildcard bins _shfl = {8'b_1???_????};
        }
        opcodes_cancelled_after_2_cycles : coverpoint coverage.opcodes_cancelled_after_2_cycles {
            wildcard bins _ld   = {8'b_????_???1};
            wildcard bins _out  = {8'b_????_??1?};
            wildcard bins _add  = {8'b_????_?1??};
            wildcard bins _sub  = {8'b_????_1???};
            wildcard bins _nand = {8'b_???1_????};
            wildcard bins _nor  = {8'b_??1?_????};
            wildcard bins _xor  = {8'b_?1??_????};
            wildcard bins _shfl = {8'b_1???_????};
        }
        opcodes_right_after_reset : coverpoint coverage.opcodes_right_after_reset {
            wildcard bins _ld   = {8'b_????_???1};
            wildcard bins _out  = {8'b_????_??1?};
            wildcard bins _add  = {8'b_????_?1??};
            wildcard bins _sub  = {8'b_????_1???};
            wildcard bins _nand = {8'b_???1_????};
            wildcard bins _nor  = {8'b_??1?_????};
            wildcard bins _xor  = {8'b_?1??_????};
            wildcard bins _shfl = {8'b_1???_????};
        }
        imm_used_as_dst : coverpoint coverage.imm_used_as_dst {
            bins imm_used_as_dst = {1'b1};
        }
        validity: coverpoint coverage.instv {
            bins val = {1'b1};
            bins inv = {1'b0};
        }
        reset: coverpoint coverage.reset {
            bins one = {1'b1};
            bins zero = {1'b0};
        }
        start_with_op: coverpoint coverage.opcode {
            wildcard bins _ld = (LD => 'b?);
            wildcard bins _out = (OUT => 'b?);
            wildcard bins _add = (ADD => 'b?);
            wildcard bins _sub = (SUB => 'b?);
            wildcard bins _nand = (NAND => 'b?);
            wildcard bins _nor = (NOR => 'b?);
            wildcard bins _xor = (XOR => 'b?);
            wildcard bins _shfl = (SHFL => 'b?);
        }
        end_with_op: coverpoint coverage.opcode {
            wildcard bins _ld = ('b? => LD);
            wildcard bins _out = ('b? => OUT);
            wildcard bins _add = ('b? => ADD);
            wildcard bins _sub = ('b? => SUB);
            wildcard bins _nand = ('b? => NAND);
            wildcard bins _nor = ('b? => NOR);
            wildcard bins _xor = ('b? => XOR);
            wildcard bins _shfl = ('b? => SHFL);
        }
        coverpoint coverage.imm;
        src1 : coverpoint coverage.src1 {
            bins r0 = {R0};
            bins r1 = {R1};
            bins r2 = {R2};
            bins r3 = {R3};
            bins imm = {IMM};
        }
        src2 : coverpoint coverage.src2 {
            bins r0 = {R0};
            bins r1 = {R1};
            bins r2 = {R2};
            bins r3 = {R3};
            bins imm = {IMM};
        }
        dst : coverpoint coverage.dst {
            bins legal = {[R0:R3]};
            bins illegal = {IMM};
        }
        val_ops: cross coverage.opcode, validity {
            ignore_bins inv = binsof (validity.inv);
        }
        inv_ops: cross coverage.opcode, validity {
            ignore_bins val = binsof (validity.val);
        }
        legal_instr: cross ops, validity, reset, src1, dst{
            ignore_bins illegal_ld = binsof (ops) intersect {LD} && !binsof (src1) intersect {IMM} && binsof (reset) intersect {1'b0} && binsof (validity.val);
            ignore_bins illegal_out = binsof (ops) intersect {OUT} && binsof (src1) intersect {IMM} && binsof (reset) intersect {1'b0} && binsof (validity.val);
            ignore_bins illegal_dst = binsof (dst.illegal) && binsof (reset) intersect {1'b0} && binsof (validity.val);
            bins all = binsof (ops.all);
        }

    endgroup: covgrp

endclass : covergroup_container


function covergroup_container::new(string name = "covergroup_container", uvm_component parent = null);

    super.new(name, parent);
    covgrp = new();

endfunction : new


function void covergroup_container::build_phase(uvm_phase phase);

    super.build_phase(phase);
    put_imp_inst = new("put_imp_inst", this);

endfunction : build_phase


task covergroup_container::put (input coverage_transaction_class t);

    covgrp.sample(t);

endtask : put
