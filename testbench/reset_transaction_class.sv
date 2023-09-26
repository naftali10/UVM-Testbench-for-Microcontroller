class reset_transaction_class extends uvm_sequence_item;

  `uvm_object_utils(reset_transaction_class)
  
  function new(string name = "");
    super.new(name);
  endfunction: new

  logic reset;

endclass: reset_transaction_class
