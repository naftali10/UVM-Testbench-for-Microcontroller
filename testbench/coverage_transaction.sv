class coverage_transaction extends input_transaction_class;

    `uvm_object_utils(coverage_transaction)
    
	bit [`REG_AMT-1:0] regs_used_as_dsts;
	bit [`REG_AMT-1:0] regs_used_as_src_before_initiated;
	bit [3-1:0] illegal_instructions;

    function new(string name = "");
        super.new(name);
        init_values();
    endfunction: new

    extern function void init_values ();
    extern function bit was_reg_used_as_dst (t_reg_name reg_name);
    extern function void mark_reg_used_as_dst (t_reg_name reg_name);
    extern function void mark_reg_used_as_src_before_initiated (t_reg_name reg_name);
    extern function void mark_opcode_as_used_in_illegal_instruction (t_opcode opcode);

endclass: coverage_transaction


function void coverage_transaction::init_values();

	regs_used_as_dsts = 0;
	regs_used_as_src_before_initiated = 0;
	illegal_instructions = 0;

endfunction : init_values


function bit coverage_transaction::was_reg_used_as_dst (t_reg_name reg_name);

    return (regs_used_as_dsts[reg_name] == 1'b1);

endfunction : was_reg_used_as_dst


function void coverage_transaction::mark_reg_used_as_dst (t_reg_name reg_name);

    regs_used_as_dsts[reg_name] = 1'b1;

endfunction : mark_reg_used_as_dst


function void coverage_transaction::mark_reg_used_as_src_before_initiated (t_reg_name reg_name);

    regs_used_as_src_before_initiated[reg_name] = 1'b1;

endfunction : mark_reg_used_as_src_before_initiated


function void coverage_transaction::mark_opcode_as_used_in_illegal_instruction (t_opcode opcode);

    case (opcode)
        LD:      illegal_instructions[0] = 1'b1;
        OUT:     illegal_instructions[1] = 1'b1;
        default: illegal_instructions[2] = 1'b1;
    endcase

endfunction : mark_opcode_as_used_in_illegal_instruction
