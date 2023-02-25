class subscriber_class extends uvm_subscriber#(input_transaction_class);
  
	`uvm_component_utils(subscriber_class)
  
	bit [`REG_AMT-1:0] regs_used_as_dsts = 0;
	bit [`REG_AMT-1:0] regs_used_before_inited = 0;
	bit [3-1:0] illegal_instructions = 0;

    input_transaction_class latest_txn;
	string cov_samp_report = "\nList of coverage samples:\n";

	covergroup covgrp;

		non_init_dst: coverpoint regs_used_as_dsts {
			wildcard bins r0 = {4'b0???};
			wildcard bins r1 = {4'b?0??};
			wildcard bins r2 = {4'b??0?};
			wildcard bins r3 = {4'b???0};
        }
        coverpoint regs_used_before_inited {
            wildcard bins r0 = {4'b1???};
            wildcard bins r1 = {4'b?1??};
            wildcard bins r2 = {4'b??1?};
            wildcard bins r3 = {4'b???1};
        }
		reset_seq: coverpoint latest_txn.reset{
			bins after1 = (1'b0 [*1] => 1'b1);
			bins after2 = (1'b0 [*2] => 1'b1);
			bins after3 = (1'b0 [*3] => 1'b1);
			bins on_then_off = (1'b1 => 1'b0);
		}
		val_seq: coverpoint latest_txn.instv{
			bins two = (1'b1 [*2]);
			bins three = (1'b1 [*3]);
			bins four = (1'b1 [*4]);
		}
		validity: coverpoint latest_txn.instv {
			bins val = {1'b1};
			bins inv = {1'b0};
		}
		reset: coverpoint latest_txn.reset {
			bins one = {1'b1};
			bins zero = {1'b0};
		}
		opcode: coverpoint latest_txn.opcode;
		ops: coverpoint latest_txn.opcode {
			bins all [] = {LD, OUT, ADD, SUB, NAND, NOR, XOR, SHFL};
		}
		start_with_op: coverpoint latest_txn.opcode {
			wildcard bins _ld = (LD => 'b?);
			wildcard bins _out = (OUT => 'b?);
			wildcard bins _add = (ADD => 'b?);
			wildcard bins _sub = (SUB => 'b?);
			wildcard bins _nand = (NAND => 'b?);
			wildcard bins _nor = (NOR => 'b?);
			wildcard bins _xor = (XOR => 'b?);
			wildcard bins _shfl = (SHFL => 'b?);
		}
		end_with_op: coverpoint latest_txn.opcode {
			wildcard bins _ld = ('b? => LD);
			wildcard bins _out = ('b? => OUT);
			wildcard bins _add = ('b? => ADD);
			wildcard bins _sub = ('b? => SUB);
			wildcard bins _nand = ('b? => NAND);
			wildcard bins _nor = ('b? => NOR);
			wildcard bins _xor = ('b? => XOR);
			wildcard bins _shfl = ('b? => SHFL);
		}
		coverpoint latest_txn.imm;
		src1 : coverpoint latest_txn.src1 {
			bins r0 = {R0};
			bins r1 = {R1};
			bins r2 = {R2};
			bins r3 = {R3};
			bins imm = {IMM};
		}
		src2 : coverpoint latest_txn.src2 {
			bins r0 = {R0};
			bins r1 = {R1};
			bins r2 = {R2};
			bins r3 = {R3};
			bins imm = {IMM};
		}
		dst : coverpoint latest_txn.dst {
			bins legal = {[R0:R3]};
			bins illegal = {IMM};
		}
		val_ops: cross latest_txn.opcode, validity {
			ignore_bins inv = binsof (validity.inv);
		}
		inv_ops: cross latest_txn.opcode, validity {
			ignore_bins val = binsof (validity.val);
		}
		illegal_instr : coverpoint illegal_instructions {
            wildcard bins ld      = {3'b1??};
            wildcard bins out     = {3'b?1?};
            wildcard bins imm_dst = {3'b??1};
		}
		legal_instr: cross ops, validity, reset, src1, dst{
			ignore_bins illegal_ld = binsof (ops) intersect {LD} && !binsof (src1) intersect {IMM} && binsof (reset) intersect {1'b0} && binsof (validity.val);
			ignore_bins illegal_out = binsof (ops) intersect {OUT} && binsof (src1) intersect {IMM} && binsof (reset) intersect {1'b0} && binsof (validity.val);
			ignore_bins illegal_dst = binsof (dst.illegal) && binsof (reset) intersect {1'b0} && binsof (validity.val);
			bins all = binsof (ops.all);
		}
		in_flight_reset: cross val_seq, reset_seq, legal_instr {
			bins reset_after_1 = binsof (reset_seq.after1) && binsof (val_seq.two);
			bins reset_after_2 = binsof (reset_seq.after2) && binsof (val_seq.three);
			bins reset_after_3 = binsof (reset_seq.after3) && binsof (val_seq.four);
			ignore_bins not_synced_1 = binsof (reset_seq.after1) && !binsof (val_seq.two);
			ignore_bins not_synced_2 = binsof (reset_seq.after2) && !binsof (val_seq.three);
			ignore_bins not_synced_3 = binsof (reset_seq.after3) && !binsof (val_seq.four);
			ignore_bins reset_on_then_off = binsof (reset_seq.on_then_off);
		}
		reset_right_after_ops: cross val_seq, reset_seq, legal_instr, start_with_op {
			ignore_bins reset_on_then_off = binsof (reset_seq.on_then_off);
			ignore_bins reset_after_2 = binsof (reset_seq.after2);
			ignore_bins reset_after_3 = binsof (reset_seq.after3);
			ignore_bins three_valid_ops = binsof (val_seq.three);
			ignore_bins four_valid_ops = binsof (val_seq.four);
		}
		ops_right_after_reset: cross val_seq, reset_seq, legal_instr, end_with_op {
			ignore_bins three_valid_ops = binsof (val_seq.three);
			ignore_bins four_valid_ops = binsof (val_seq.four);
			ignore_bins reset_after_1 = binsof (reset_seq.after1);
			ignore_bins reset_after_2 = binsof (reset_seq.after2);
			ignore_bins reset_after_3 = binsof (reset_seq.after3);
		}

	endgroup: covgrp

  
	function new (string name = "subscriber_class", uvm_component parent = null);

		super.new(name, parent);
		covgrp = new();
        latest_txn = new();

	endfunction: new
    

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);

    endfunction: build_phase

  
	virtual function void report_phase(uvm_phase phase);

		super.report_phase(phase);
		print_cov_rep();

	endfunction
  

	extern function void write(input_transaction_class t);

	extern function void parse_txn_for_coverage();
	extern function void track_regs_used_as_dst();
	extern function void print_cov_rep();
	extern function void track_non_init_regs_used_as_src();
	extern function void track_illegal_instructions();

	extern function void add_txn_to_report();

endclass: subscriber_class


function void subscriber_class::track_illegal_instructions();

    if (!(reference_model_class::is_instruction_legal(latest_txn)) && latest_txn.instv) begin
        case (latest_txn.opcode)
            LD:      illegal_instructions[0] = 1'b1;
            OUT:     illegal_instructions[1] = 1'b1;
            default: illegal_instructions[2] = 1'b1;
        endcase
    end

endfunction : track_illegal_instructions


function void subscriber_class::track_non_init_regs_used_as_src();

    if (reference_model_class::is_instruction_legal(latest_txn) && latest_txn.instv == 1'b1 && latest_txn.reset == 1'b0) begin
        if (regs_used_as_dsts[latest_txn.src1] == 1'b0)
            regs_used_before_inited[latest_txn.src1] = 1'b1;
        if (regs_used_as_dsts[latest_txn.src2] == 1'b0)
            regs_used_before_inited[latest_txn.src2] = 1'b1;
    end
    track_regs_used_as_dst();

endfunction : track_non_init_regs_used_as_src


function void subscriber_class::parse_txn_for_coverage();

    track_non_init_regs_used_as_src();
    track_illegal_instructions();

endfunction : parse_txn_for_coverage


function void subscriber_class::track_regs_used_as_dst();

	if (reference_model_class::is_instruction_legal(latest_txn) && latest_txn.instv == 1'b1 && latest_txn.reset == 1'b0)
		regs_used_as_dsts[latest_txn.dst] = 1'b1;

endfunction : track_regs_used_as_dst


function void subscriber_class::write(input_transaction_class t);

    latest_txn.copy(t);
    parse_txn_for_coverage();
    covgrp.sample();
    add_txn_to_report();

endfunction: write
  

function void subscriber_class::add_txn_to_report();

    cov_samp_report = {cov_samp_report, $sformatf("reset = %b \t instv = %b \t opcode = %s \t src1 = %s \t src2 = %s \t dst = %s \n",
        latest_txn.reset,
        latest_txn.instv,
        latest_txn.opcode,
        latest_txn.src1,
        latest_txn.src2,
        latest_txn.dst)
    };

endfunction : add_txn_to_report


function void subscriber_class::print_cov_rep();

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

endfunction : print_cov_rep
