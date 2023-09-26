class coverage_analyzer extends uvm_component;

	`uvm_component_utils(coverage_analyzer)

    input_transaction_class input_txn;
    coverage_transaction_class coverage;
    uvm_blocking_put_port#(coverage_transaction_class) put_port_inst;
    uvm_analysis_imp#(input_transaction_class, coverage_analyzer) analysis_imp_inst;
    event send_to_covergroup;


    function new(string name = "coverage_analyzer", uvm_component parent = null);

        super.new(name, parent);

    endfunction : new


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        input_txn = new();
        coverage = coverage_transaction_class::type_id::create("coverage");
        put_port_inst = new("put_port_inst", this);
        analysis_imp_inst = new("analysis_imp_inst", this);

    endfunction : build_phase


    function void write(input_transaction_class t);

        input_txn.copy(t);
        analyze_txn_for_coverage();
        -> send_to_covergroup;

    endfunction : write


    task run_phase(uvm_phase phase);

        super.run_phase(phase);
        forever begin
            @ send_to_covergroup;
            put_port_inst.put(coverage);
        end

    endtask : run_phase


    function void analyze_txn_for_coverage();

        coverage.copy_input_txn(input_txn);
        track_opcode_validity();
        track_non_initiated_regs_used_as_src();
        track_illegal_instructions();
        track_legal_valid_instructions_cancel();
        track_legal_valid_instructions_after_reset();
        track_regs_used_for_output();
        track_imm_used_as_dst();

    endfunction : analyze_txn_for_coverage


    function void track_non_initiated_regs_used_as_src();

        if (input_txn.will_writeback() || input_txn.will_output()) begin
            
            if (!coverage.was_reg_used_as_dst(input_txn.src1))
                coverage.mark_reg_used_as_src_before_initiated(input_txn.src1);
            if (input_txn.uses_src2() && !coverage.was_reg_used_as_dst(input_txn.src2))
                coverage.mark_reg_used_as_src_before_initiated(input_txn.src2);

            coverage.mark_reg_used_as_dst(input_txn.dst);

        end

    endfunction : track_non_initiated_regs_used_as_src


    function void track_illegal_instructions();

        if (!input_txn.is_legal() && input_txn.is_valid())
            coverage.mark_opcode_as_used_in_illegal_instruction(input_txn.opcode);

    endfunction : track_illegal_instructions


    function void track_opcode_validity();

        if (input_txn.is_valid())
            coverage.mark_opcode_used_as_valid(input_txn.opcode);
        else
            coverage.mark_opcode_used_as_invalid(input_txn.opcode);

        if (coverage.was_opcode_used_as_valid(input_txn.opcode) && coverage.was_opcode_used_as_invalid(input_txn.opcode))
            coverage.mark_opcode_used_as_both_valid_and_invalid(input_txn.opcode);

    endfunction : track_opcode_validity


    function void track_legal_valid_instructions_cancel();

        if (coverage.is_waiting_for_cancel) begin
            coverage.cycles_since_last_legal_valid_instruction ++;
            if (input_txn.will_reset()) begin
                coverage.mark_instruction_cancel();
                coverage.is_waiting_for_cancel = 0;
            end
            else if (coverage.cycles_since_last_legal_valid_instruction >= 2) begin
                coverage.cycles_since_last_legal_valid_instruction = 0;
                coverage.is_waiting_for_cancel = 0;
            end
        end
        else begin
            if (input_txn.is_legal() && input_txn.is_valid() && !input_txn.will_reset()) begin
                coverage.opcode_of_last_legal_valid_instruction = input_txn.opcode;
                coverage.cycles_since_last_legal_valid_instruction = 0;
                coverage.is_waiting_for_cancel = 1;
            end
        end

    endfunction : track_legal_valid_instructions_cancel


    function void track_legal_valid_instructions_after_reset();

        if (input_txn.will_reset()) begin
            coverage.last_instruction_is_reset = 1;
        end
        else begin
            if (coverage.last_instruction_is_reset && input_txn.is_legal() && input_txn.is_valid())
                coverage.mark_legal_valid_instructions_after_reset(input_txn.opcode);
            coverage.last_instruction_is_reset = 0;
        end

    endfunction : track_legal_valid_instructions_after_reset


    function void track_regs_used_for_output();

        if (input_txn.will_output)
            coverage.mark_regs_used_for_output(input_txn.src1);

    endfunction : track_regs_used_for_output


    function void track_imm_used_as_dst();

        if (input_txn.dst == IMM && input_txn.is_valid() && !input_txn.will_reset())
            coverage.imm_used_as_dst = 1'b1;

    endfunction : track_imm_used_as_dst

endclass : coverage_analyzer
