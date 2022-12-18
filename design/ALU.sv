// Module name: ALU
// Duty: Executing for two input buses
//		 (A and B) the following operations (encoding in backets):
//		 (2) A+B, (3) A-B, (4) bitwise NAND, (5) bitwise NOR,
//		 (6) bitwise XOR, and (7) SHFL A by the index of the least 
//		 significant '1' on B (starting at index 1 on the right).
//		 Encodings (0) and (1) simply yield A.

module ALU (
  input t_data A,B,							// Data buses
  input t_opcode op,						// Encoded operation
  output t_data result						// Result of operation
  );
  t_data results [`ALU_OP_AMT-1:0];
  genvar i,j;
  //----- simple operations -----
  assign results [LD] = A;
  assign results [OUT] = A;
  assign results [ADD] = A+B;
  assign results [SUB] = A-B;
  assign results [NAND] = ~(A&B);
  assign results [NOR] = ~(A|B);
  assign results [XOR] = A^B;
  
  //----- shift left operation -----
  SHFL SHFL_inst(.A(A),
                 .B(B),
                 .result(results [SHFL]));
  
  //----- output muxes -----
  generate for (i=0; i<`DATA_WIDTH; i++) begin : for_every_bit
    logic [`ALU_OP_AMT-1:0] mux_inputs;
    for (j=0; j<`ALU_OP_AMT; j++) begin: for_every_operation
	  	assign mux_inputs[j] = results[j][i]; // All results, single bit
    end: for_every_operation
    mux #(.size(`ALU_OP_AMT)) output_mux (.data(mux_inputs),
                                          .sel(op),
  	                                      .out(result[i]));
  end: for_every_bit
  endgenerate
endmodule
