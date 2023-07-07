class subscriber_class extends uvm_subscriber#(input_transaction_class);
  
	`uvm_component_utils(subscriber_class)
  

    input_transaction_class latest_txn;
    covergroup_container covergroup_container_inst;
    coverage_analyzer coverage_analyzer_inst;
    uvm_analysis_export#(input_transaction_class) analysis_export_inst;
	string coverage_sampeling_report = "\nList of coverage samples:\n";

	extern function new (string name = "subscriber_class", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase (uvm_phase phase);
    extern function void report_phase(uvm_phase phase);

    extern function void write(input_transaction_class t);
	extern function void add_txn_to_report(input_transaction_class input_txn);
	extern function void print_coverage_report();

endclass: subscriber_class


function subscriber_class::new (string name = "subscriber_class", uvm_component parent = null);

    super.new(name, parent);
    covergroup_container_inst = covergroup_container::type_id::create("covergroup_container_inst", this);
    coverage_analyzer_inst = coverage_analyzer::type_id::create("coverage_analyzer_inst", this);
    latest_txn = new();

endfunction: new


function void subscriber_class::build_phase(uvm_phase phase);

    super.build_phase(phase);
    analysis_export_inst = new("analysis_export_inst", this);

endfunction: build_phase


function void subscriber_class::connect_phase (uvm_phase phase);

    coverage_analyzer_inst.put_port_inst.connect(covergroup_container_inst.put_imp_inst);
    analysis_export_inst.connect(this.analysis_export);
    analysis_export_inst.connect(coverage_analyzer_inst.analysis_imp_inst);
    
endfunction : connect_phase


function void subscriber_class::report_phase(uvm_phase phase);

    super.report_phase(phase);
    print_coverage_report();

endfunction


function void subscriber_class::write(input_transaction_class t);

    add_txn_to_report(t);

endfunction : write


function void subscriber_class::add_txn_to_report(input_transaction_class input_txn);

    coverage_sampeling_report = {coverage_sampeling_report, $sformatf("reset = %b \t instv = %b \t opcode = %s \t src1 = %s \t src2 = %s \t dst = %s \n",
        input_txn.reset,
        input_txn.instv,
        input_txn.opcode,
        input_txn.src1,
        input_txn.src2,
        input_txn.dst)
    };

endfunction : add_txn_to_report


function void subscriber_class::print_coverage_report();

    `uvm_info(get_name(), $sformatf(
        {
        "\nCoverage Statistics:\n",
        "All operations = %0.2f %%\n",
        "Valid operations = %0.2f %%\n",
        "Invalid operations = %0.2f %%\n",
        "Illegal instructions = %0.2f %%\n",
        "opcodes cancelled after 1 cycle = %0.2f %%\n"
        },
        covergroup_container_inst.covgrp.opcode.get_coverage(),
        covergroup_container_inst.covgrp.val_ops.get_coverage(),
        covergroup_container_inst.covgrp.inv_ops.get_coverage(),
        covergroup_container_inst.covgrp.illegal_instructions.get_coverage(),
        covergroup_container_inst.covgrp.opcodes_cancelled_after_1_cycle.get_coverage()
        ),
        UVM_NONE);
    `uvm_info(get_name(), coverage_sampeling_report, UVM_NONE)

endfunction : print_coverage_report
