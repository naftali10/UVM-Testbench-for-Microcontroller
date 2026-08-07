class regfile_transaction_class extends uvm_sequence_item;

    `uvm_object_utils(regfile_transaction_class)

    function new (string name = "");
        super.new(name);
    endfunction: new

    rand t_data regfile [`REG_AMT-1:0];
    rand integer create_time;


    function void reset();

        create_time = 0;
        regfile[0] = 'x;
        regfile[1] = 'x;
        regfile[2] = 'x;
        regfile[3] = 'x;

    endfunction: reset


    function t_data get_reg (t_reg_name source, t_data imm);

        case(source)
            R0: return regfile[0];
            R1: return regfile[1];
            R2: return regfile[2];
            R3: return regfile[3];
            IMM: return imm;
            default: `uvm_error(get_name(), $sformatf("Invalid register name %0d", source))
        endcase

    endfunction: get_reg


    function int lsb_idx(t_data num);

        int i=0;
        num = (num & (num-1)) ^ num;
        while(num) begin
            num = num >> 1;
            i++;
        end
        return i;

    endfunction: lsb_idx


    function t_data alu_calculate (t_opcode opcode, t_reg_name src1, t_reg_name src2, t_data imm);

        case(opcode)
            LD:   return imm;
            OUT:  return get_reg(src1, imm);  // FIXME - nkizner - 2022-12-02 - check src1!=IMM
            ADD:  return get_reg(src1, imm) + get_reg(src2, imm);
            SUB:  return get_reg(src1, imm) - get_reg(src2, imm);
            NAND: return ~(get_reg(src1, imm) & get_reg(src2, imm));
            NOR:  return ~(get_reg(src1, imm) | get_reg(src2, imm));
            XOR:  return get_reg(src1, imm) ^ get_reg(src2, imm);
            SHFL: return get_reg(src1, imm) << lsb_idx(get_reg(src2, imm));
            default: `uvm_error(get_name(), $sformatf("Invalid opcode %0h", opcode))
        endcase

    endfunction: alu_calculate


    function void write_regfile(t_data value, t_reg_name destination);

        case (destination)
            R0: regfile[0] = value;
            R1: regfile[1] = value;
            R2: regfile[2] = value;
            R3: regfile[3] = value;
        endcase

    endfunction: write_regfile


    function void print_regfile();

        $display("%0h %0h %0h %0h", regfile[0], regfile[1], regfile[2], regfile[3]);

    endfunction: print_regfile

endclass: regfile_transaction_class