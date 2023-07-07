class input_transaction_class extends uvm_sequence_item;
  
  // `uvm_object_utils(input_transaction_class) // commented because of registartion below
  
  function new (string name = "");
    super.new(name);
  endfunction: new
  
  rand logic reset;
  rand logic instv;
  rand t_opcode opcode;
  rand t_data imm;
  rand t_reg_name src1, src2;
  rand t_reg_name dst;
  
  `uvm_object_utils_begin(input_transaction_class)
    `uvm_field_int (reset, UVM_ALL_ON)
    `uvm_field_int (instv, UVM_ALL_ON)
    `uvm_field_enum (t_opcode, opcode, UVM_ALL_ON)
    `uvm_field_int (imm, UVM_ALL_ON | UVM_DEC)
    `uvm_field_enum (t_reg_name, src1, UVM_ALL_ON)
    `uvm_field_enum (t_reg_name, src2, UVM_ALL_ON)
    `uvm_field_enum (t_reg_name, dst, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function bit is_legal();
  extern function bit is_valid();
  extern function bit will_output();
  extern function bit will_writeback();
  extern function bit will_reset();

endclass: input_transaction_class


function bit input_transaction_class::is_legal();

  if (this.reset == 1'b1) return 1'b1;
  if (this.opcode == LD && this.src1 != IMM) return 1'b0;
  if (this.opcode == OUT && this.src1 == IMM) return 1'b0;
  if (this.dst == IMM) return 1'b0;
  return 1'b1;

endfunction: is_legal


function bit input_transaction_class::is_valid();

    return this.instv == 1'b1;

endfunction : is_valid


function bit input_transaction_class::will_writeback();

    return this.is_legal() && this.instv == 1'b1 && this.reset == 1'b0 && this.opcode != OUT;

endfunction : will_writeback


function bit input_transaction_class::will_output();

    return this.is_legal() && this.instv == 1'b1 && this.reset == 1'b0 && this.opcode == OUT;

endfunction : will_output


function bit input_transaction_class::will_reset();

    return this.reset == 1'b1 && this.is_valid();

endfunction : will_reset
