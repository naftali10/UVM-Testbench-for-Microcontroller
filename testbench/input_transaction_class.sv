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
  rand integer create_time;
  
  `uvm_object_utils_begin(input_transaction_class)
    `uvm_field_int  (reset,               UVM_ALL_ON)
    `uvm_field_int  (instv,               UVM_ALL_ON)
    `uvm_field_enum (t_opcode,    opcode, UVM_ALL_ON)
    `uvm_field_int  (imm,                 UVM_ALL_ON | UVM_DEC)
    `uvm_field_enum (t_reg_name,  src1,   UVM_ALL_ON)
    `uvm_field_enum (t_reg_name,  src2,   UVM_ALL_ON)
    `uvm_field_enum (t_reg_name,  dst,    UVM_ALL_ON)
    `uvm_field_int  (create_time,         UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end


    function bit is_legal();

        if (this.reset  == 1'b1) return 1'b1;
        if (this.opcode == LD  && this.src1 != IMM) return 1'b0;
        if (this.opcode == OUT && this.src1 == IMM) return 1'b0;
        if (this.dst    == IMM) return 1'b0;
        if ((^this.reset  === 1'bx) ||
            (^this.instv  === 1'bx) ||
            (^this.opcode === 1'bx) ||
            (^this.imm    === 1'bx) ||
            (^this.src1   === 1'bx) ||
            (^this.src2   === 1'bx) ||
            (^this.dst    === 1'bx)
        ) return 1'b0;
        return 1'b1;

    endfunction: is_legal


    function bit is_valid();

        return this.instv == 1'b1;

    endfunction : is_valid


    function bit will_writeback();

        return this.is_legal() && this.instv == 1'b1 && this.reset == 1'b0 && this.opcode != OUT;

    endfunction : will_writeback


    function bit will_output();

        return this.is_legal() && this.instv == 1'b1 && this.reset == 1'b0 && this.opcode == OUT;

    endfunction : will_output


    function bit will_reset();

        return this.reset == 1'b1;

    endfunction : will_reset


    function bit uses_src2();

        return this.opcode != LD && this.opcode != OUT;

    endfunction : uses_src2


    function void verify_time(integer t);

        if (create_time == t) begin
            `uvm_info(get_name(), $sformatf("Transaction is at expected time %0d", t), UVM_DEBUG);
        end else begin
            `uvm_error(get_name(), $sformatf("Transaction is at time %0d, and not at expected time %0d", create_time, t));
        end

    endfunction

endclass: input_transaction_class
