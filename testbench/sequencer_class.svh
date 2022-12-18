class sequencer_class extends uvm_sequencer#(transaction_class);

  `uvm_component_utils(sequencer_class)

  function new(string name = "sequencer_class", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : sequencer_class
