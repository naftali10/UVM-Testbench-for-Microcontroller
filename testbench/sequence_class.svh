class sequence_class extends uvm_sequence#(input_transaction_class);
  
  `uvm_object_utils(sequence_class)
  
  function new (string name = "");
    super.new(name);
  endfunction: new
  
  input_transaction_class input_transaction_inst;
  
  task body();
    

    `uvm_do_with(input_transaction_inst, {reset==1'b1;})  // reset


    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD; src1==IMM; dst==R0;})  // Load IMM to GPR R0
    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD; src1==IMM; dst==R1;})  // Load IMM to GPR R1
    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD; src1==IMM; dst==R2;})  // Load IMM to GPR R2
    `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==LD; src1==IMM; dst==R3;})  // Load IMM to GPR R3

    repeat (4)
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==OUT; src1!=IMM;  dst!=IMM;})  // Output GPR

    `uvm_do_with(input_transaction_inst, {reset==1'b1;})  // reset

    repeat (4)
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; !(opcode inside {LD, OUT}); dst!=IMM;})  // WB to GPR

    `uvm_do_with(input_transaction_inst, {reset==1'b1; opcode==OUT;})  // reset

    repeat (4) begin
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b0; opcode==OUT; src1!=IMM;  dst!=IMM;})  // invalid OUT
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==OUT; src1!=IMM;  dst!=IMM;})  // Output GPR
    end

    repeat (4) begin
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b0; opcode==OUT; src1!=IMM;  dst!=IMM;})  // invalid OUT
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; !(opcode inside {LD, OUT}); dst!=IMM;})  // WB to GPR
    end

    repeat (6)
      `uvm_do_with(input_transaction_inst, {reset==1'b0; instv==1'b1; opcode==OUT; src1!=IMM;  dst!=IMM;})  // Output GPR


  endtask: body
  
endclass: sequence_class
