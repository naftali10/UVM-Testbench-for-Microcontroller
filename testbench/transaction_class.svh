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
  
  constraint no_write_to_imm {dst != IMM;}

  `uvm_object_utils_begin(input_transaction_class)
    `uvm_field_int (reset, UVM_ALL_ON)
    `uvm_field_int (instv, UVM_ALL_ON)
    `uvm_field_enum (t_opcode, opcode, UVM_ALL_ON)
    `uvm_field_int (imm, UVM_ALL_ON | UVM_DEC)
    `uvm_field_enum (t_reg_name, src1, UVM_ALL_ON)
    `uvm_field_enum (t_reg_name, src2, UVM_ALL_ON)
    `uvm_field_enum (t_reg_name, dst, UVM_ALL_ON)
  `uvm_object_utils_end

endclass: input_transaction_class

class output_transaction_class extends uvm_sequence_item;
  
  `uvm_object_utils(output_transaction_class)
  
  function new(string name = "");
    super.new(name);
  endfunction: new
  
  bit stalled;
  bit dataoutv;
  t_data dataout;
  
endclass: output_transaction_class
