class output_transaction_class extends uvm_sequence_item;
  
  // `uvm_object_utils(output_transaction_class) // commented because of registartion below
  
  function new(string name = "");
    super.new(name);
  endfunction: new
  
  bit stalled;
  bit dataoutv;
  t_data dataout;
  integer create_time;

  `uvm_object_utils_begin(output_transaction_class)
    `uvm_field_int (stalled,     UVM_ALL_ON)
    `uvm_field_int (dataoutv,    UVM_ALL_ON)
    `uvm_field_int (dataout,     UVM_ALL_ON)
    `uvm_field_int (create_time, UVM_ALL_ON)
  `uvm_object_utils_end


  function bit is_stalled();

    return stalled;

  endfunction: is_stalled

  
endclass: output_transaction_class
