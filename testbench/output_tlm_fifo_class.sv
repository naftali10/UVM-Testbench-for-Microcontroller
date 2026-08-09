class output_tlm_fifo_class extends tlm_fifo_class#(output_transaction_class);

    `uvm_object_utils(output_tlm_fifo_class)

    uvm_tlm_fifo#(output_transaction_class) temp_fifo;


    function new (string name = "", uvm_component parent = null, int size_ = 0);
        super.new(name, parent, size_);
        temp_fifo = new("temp_fifo", this, 0);
    endfunction: new


    function void move_items_to_temp_fifo(int count);
        
        output_transaction_class tx;

        for (int i = 0; i < count; i++) begin
            tx = output_transaction_class::type_id::create("tx");
            this.try_get(tx);
            temp_fifo.try_put(tx);
        end

    endfunction: move_items_to_temp_fifo


    function void move_items_from_temp_fifo(int count);
        
        output_transaction_class tx;

        for (int i = 0; i < count; i++) begin
            tx = output_transaction_class::type_id::create("tx");
            temp_fifo.try_get(tx);
            this.try_put(tx);
        end

    endfunction: move_items_from_temp_fifo


    function output_transaction_class peek_last();

        output_transaction_class tx = output_transaction_class::type_id::create("tx");
        output_transaction_class result = output_transaction_class::type_id::create("result");
        
        move_items_to_temp_fifo(this.used());
        move_items_from_temp_fifo(temp_fifo.used()-1);

        temp_fifo.try_get(tx);
        result.copy(tx);
        this.try_put(tx);
        return result;

    endfunction: peek_last


    function bit is_last_stalled();

        output_transaction_class tx = output_transaction_class::type_id::create("tx");
        tx = peek_last();
        return tx.is_stalled();

    endfunction: is_last_stalled


    function void add_prediction(output_transaction_class tx, integer sim_time = 'x, t_data dataout = 'x);

        output_transaction_class t = output_transaction_class::type_id::create("t");
        t.copy(tx);
        if (sim_time!=='x)
            t.create_time = sim_time;
        if (dataout!=='x)
            t.dataout = dataout;

        if(this.try_put(t)) begin
            `uvm_info(get_name(), $sformatf("Successfully put output transaction into FIFO"), UVM_DEBUG);
        end else begin
            `uvm_error(get_name(), $sformatf("Failed to put output transaction into FIFO"));
        end

    endfunction: add_prediction


    function output_transaction_class pop_prediction();

        output_transaction_class tx = output_transaction_class::type_id::create("tx");
        tx = this.get_transaction();
        return tx;

    endfunction: pop_prediction


    function void add_stalls(int count);

        output_transaction_class tx;

        if (this.used() < count)
            `uvm_error(get_name(), $sformatf("Cant stall %0d item(s) because There are only %0d item(s) in FIFO", count, this.used()));

        for (int i = 0; i < count; i++) begin
            tx = output_transaction_class::type_id::create("tx");
            this.try_get(tx);
            tx.stalled = 1;
            temp_fifo.try_put(tx);
        end
        move_items_to_temp_fifo(this.used());
        move_items_from_temp_fifo(temp_fifo.used());

    endfunction: add_stalls


endclass: output_tlm_fifo_class