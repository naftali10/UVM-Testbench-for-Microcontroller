class reset_transaction_class extends uvm_sequence_item;

  // `uvm_object_utils(reset_transaction_class)  // commented because of registartion below
  
  function new(string name = "");
    super.new(name);
  endfunction: new

  logic reset;
  integer create_time;

  `uvm_object_utils_begin(reset_transaction_class)
    `uvm_field_int  (reset,               UVM_ALL_ON)
    `uvm_field_int  (create_time,         UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end


  function bit will_reset();

    return this.reset == 1'b1;

  endfunction : will_reset


  function void verify_time(integer t);

    if (create_time == t) begin
        `uvm_info(get_name(), $sformatf("Transaction is at expected time %0d", t), UVM_DEBUG);
    end else begin
        `uvm_error(get_name(), $sformatf("Transaction is at time %0d, and not at expected time %0d", create_time, t));
    end

  endfunction

endclass: reset_transaction_class
