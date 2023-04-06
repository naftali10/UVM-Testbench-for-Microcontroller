class coverage_analyzer extends uvm_component;

	`uvm_component_utils(coverage_analyzer)

    input_transaction_class input_txn;
    coverage_transaction coverage;
    uvm_blocking_put_port#(coverage_transaction) put_port_inst;
    uvm_analysis_imp#(input_transaction_class, coverage_analyzer) analysis_imp_inst;
    event send_to_covergroup;

    extern function new(string name = "coverage_analyzer", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void write(input_transaction_class t);

	extern function void analyze_txn_for_coverage();
	extern function void track_non_initiated_regs_used_as_src();
	extern function void track_illegal_instructions();

endclass : coverage_analyzer


function coverage_analyzer::new(string name = "coverage_analyzer", uvm_component parent = null);

    super.new(name, parent);

endfunction : new


function void coverage_analyzer::build_phase(uvm_phase phase);

    super.build_phase(phase);
    input_txn = new();
    coverage = coverage_transaction::type_id::create("coverage");
    put_port_inst = new("put_port_inst", this);
    analysis_imp_inst = new("analysis_imp_inst", this);

endfunction : build_phase


function void coverage_analyzer::write(input_transaction_class t);

    input_txn.copy(t);
    analyze_txn_for_coverage();
    -> send_to_covergroup;

endfunction : write


task coverage_analyzer::run_phase(uvm_phase phase);

    super.run_phase(phase);
    forever begin
        @ send_to_covergroup;
        put_port_inst.put(coverage);
    end

endtask : run_phase


function void coverage_analyzer::analyze_txn_for_coverage();

    track_non_initiated_regs_used_as_src();
    track_illegal_instructions();

endfunction : analyze_txn_for_coverage


function void coverage_analyzer::track_non_initiated_regs_used_as_src();

    if (reference_model_class::is_instruction_legal(input_txn) && input_txn.instv == 1'b1 && input_txn.reset == 1'b0) begin
        
        if (!coverage.was_reg_used_as_dst(input_txn.src1))
            coverage.mark_reg_used_as_src_before_initiated(input_txn.src1);
        if (!coverage.was_reg_used_as_dst(input_txn.src2))
            coverage.mark_reg_used_as_src_before_initiated(input_txn.src2);

        coverage.mark_reg_used_as_dst(input_txn.src1);
        coverage.mark_reg_used_as_dst(input_txn.src2);

    end

endfunction : track_non_initiated_regs_used_as_src


function void coverage_analyzer::track_illegal_instructions();

    if (!(reference_model_class::is_instruction_legal(input_txn)) && input_txn.instv)
        coverage.mark_opcode_as_used_in_illegal_instruction(input_txn.opcode);

endfunction : track_illegal_instructions
