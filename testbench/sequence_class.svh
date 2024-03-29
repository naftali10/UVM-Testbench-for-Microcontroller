class sequence_class extends uvm_sequence#(input_transaction_class);
  
  `uvm_object_utils(sequence_class)
  
  function new (string name = "");
    super.new(name);
  endfunction : new
  
  input_transaction_class input_transaction_inst;
  
  task body();
    
    repeat (1) begin
      `uvm_do_with(input_transaction_inst, {reset==1'b1; instv==1'b1;})
      repeat (1) begin
        `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD; src1==IMM; dst==R0;})
        `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode!=LD; src1==R1;  dst!=IMM;})
      end
    end
    // Illegal instructions
    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD; src1!=IMM;  dst!=IMM;})
    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==OUT; src1==IMM; dst!=IMM;})
    // Legal and immediate reset
    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD; src1==IMM; dst==R0;})
    `uvm_do_with(input_transaction_inst, {reset==1'b1; instv==1'b1;})
    #`CYCLE_TIME;
    #`CYCLE_TIME;
    #`CYCLE_TIME;

  endtask : body
  
endclass
