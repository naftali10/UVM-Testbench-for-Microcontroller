class sequence_class extends uvm_sequence#(input_transaction_class);
  
  `uvm_object_utils(sequence_class)
  
  function new (string name = "");
    super.new(name);
  endfunction: new
  
  input_transaction_class input_transaction_inst;
  
  task body();
    
    `uvm_do_with(input_transaction_inst, {reset==1'b1;})  // reset

    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD;  src1==IMM; dst==R0; })  // Load IMM to R0
    
    repeat (4)
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==OUT; src1==R0;  dst!=IMM;})  // Output R0


    `uvm_do_with(input_transaction_inst, {reset==1'b1;})  // reset
    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; !(opcode inside {LD, OUT}); src1==R0; src2==IMM; dst==R1;})  // WB to R1
    `uvm_do_with(input_transaction_inst, {reset==1'b1;})  // reset

    repeat (4)
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==OUT; src1==R1;  dst!=IMM;})  // Output R1


  endtask: body
  
endclass: sequence_class
