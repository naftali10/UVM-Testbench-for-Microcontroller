class tlm_fifo_class#(type T = uvm_transaction) extends uvm_tlm_fifo#(T);

    `uvm_object_utils(tlm_fifo_class#(T))

    function new (string name = "");
        super.new(name);
    endfunction: new


    function T get_transaction();

        T tx = T::type_id::create("tx");
        if(this.try_get(tx)) begin
            return tx;
        end else begin
            `uvm_error(get_name(), $sformatf("Failed to get transaction"));
        end

    endfunction: get_transaction


endclass: tlm_fifo_class
