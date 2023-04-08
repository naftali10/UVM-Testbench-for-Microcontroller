class coverage_transaction_class extends input_transaction_class;

    `uvm_object_utils(coverage_transaction_class)
    
	bit [`REG_AMT-1:0] regs_used_as_dsts;
	bit [`REG_AMT-1:0] regs_used_as_src_before_initiated;
	bit [2:0] illegal_instructions;

	bit [7:0] opcodes_used_as_valid;
	bit [7:0] opcodes_used_as_invalid;
    bit [7:0] opcodes_used_as_valid_and_invalid;

    function new(string name = "");
        super.new(name);
        init_values();
    endfunction: new

    extern function void init_values ();
    extern function void copy_input_txn (input_transaction_class input_txn);
    extern function bit was_reg_used_as_dst (t_reg_name reg_name);
    extern function void mark_opcode_used_as_valid (t_opcode opcode);
    extern function void mark_opcode_used_as_invalid (t_opcode opcode);
    extern function bit was_opcode_used_as_valid (t_opcode opcode);
    extern function bit was_opcode_used_as_invalid (t_opcode opcode);
    extern function void mark_opcode_used_as_valid_and_invalid (t_opcode opcode);
    extern function void mark_reg_used_as_dst (t_reg_name reg_name);
    extern function void mark_reg_used_as_src_before_initiated (t_reg_name reg_name);
    extern function void mark_opcode_as_used_in_illegal_instruction (t_opcode opcode);

endclass: coverage_transaction_class


function void coverage_transaction_class::init_values();

	regs_used_as_dsts = 0;
	regs_used_as_src_before_initiated = 0;
	illegal_instructions = 0;
    opcodes_used_as_valid = 0;
    opcodes_used_as_invalid = 0;
    opcodes_used_as_valid_and_invalid = 0;

endfunction : init_values


function void coverage_transaction_class::copy_input_txn (input_transaction_class input_txn);

  this.reset = input_txn.reset;
  this.instv = input_txn.instv;
  this.opcode = input_txn.opcode;
  this.imm = input_txn.imm;
  this.src1 = input_txn.src1;
  this.src2 = input_txn.src2;
  this.dst = input_txn.dst;

endfunction : copy_input_txn


function bit coverage_transaction_class::was_reg_used_as_dst (t_reg_name reg_name);

    return (regs_used_as_dsts[reg_name] == 1'b1);

endfunction : was_reg_used_as_dst


function void coverage_transaction_class::mark_reg_used_as_dst (t_reg_name reg_name);

    regs_used_as_dsts[reg_name] = 1'b1;

endfunction : mark_reg_used_as_dst


function void coverage_transaction_class::mark_reg_used_as_src_before_initiated (t_reg_name reg_name);

    regs_used_as_src_before_initiated[reg_name] = 1'b1;

endfunction : mark_reg_used_as_src_before_initiated


function void coverage_transaction_class::mark_opcode_as_used_in_illegal_instruction (t_opcode opcode);

    case (opcode)
        LD:      illegal_instructions[0] = 1'b1;
        OUT:     illegal_instructions[1] = 1'b1;
        default: illegal_instructions[2] = 1'b1;
    endcase

endfunction : mark_opcode_as_used_in_illegal_instruction


function void coverage_transaction_class::mark_opcode_used_as_valid(t_opcode opcode);

    opcodes_used_as_valid[opcode] = 1'b1;

endfunction : mark_opcode_used_as_valid


function void coverage_transaction_class::mark_opcode_used_as_invalid(t_opcode opcode);

    opcodes_used_as_invalid[opcode] = 1'b1;

endfunction : mark_opcode_used_as_invalid


function bit coverage_transaction_class::was_opcode_used_as_valid(t_opcode opcode);

    return opcodes_used_as_valid[opcode];

endfunction : was_opcode_used_as_valid


function bit coverage_transaction_class::was_opcode_used_as_invalid(t_opcode opcode);

    return opcodes_used_as_invalid[opcode];

endfunction : was_opcode_used_as_invalid


function void coverage_transaction_class::mark_opcode_used_as_valid_and_invalid(t_opcode opcode);

    opcodes_used_as_valid_and_invalid[opcode] = 1'b1;

endfunction : mark_opcode_used_as_valid_and_invalid
