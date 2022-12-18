class sequence_class extends uvm_sequence#(transaction_class);
  
  `uvm_object_utils(sequence_class)
  
  function new (string name = "");
    super.new(name);
  endfunction : new
  
  transaction_class transaction_inst;
  
  // Run phase
  task body();
    
    `uvm_do_with(transaction_inst, {reset==1'b1;})
    repeat (10) begin
      `uvm_do_with(transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD; src1==IMM; dst!=IMM;})
    end
    repeat (10) begin
      `uvm_do_with(transaction_inst, {reset==1'b0; instv==1'b1;})
    end

  endtask
  
endclass
