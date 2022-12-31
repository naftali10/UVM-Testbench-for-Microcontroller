// Interface name: Global Inputs
// Duty: Connecting the machine to its inputs

interface ifc_inputs (input bit clock);
  logic reset, instv;
  t_opcode opcode;
  t_data imm;
  t_reg_name src1, src2;
  t_reg_name dst;

  modport receiver (input clock,
                    input reset,
                    input instv,
                    input opcode,
                    input imm,
                    input src1,
                    input src2,
                    input dst);
endinterface
