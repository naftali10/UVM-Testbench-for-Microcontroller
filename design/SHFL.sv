// Module name: SHFL
// Duty: Shift left input bus A by the index of the least 
//		 significant '1' on input bus B 
//		 (starting at index 1 on the right).

module SHFL (
  input t_data A,		// bus to be shifted
  input t_data B,		// shift amount bus
  output t_data result	// data output
  );
  
  int shamt=0;
  
  always @* begin
    while (B[shamt]==0)
  	  shamt++;
    if (B==0)
      result = A;
  	else
      result = A<<(shamt+1);
  end
  
endmodule
