// Module name: SHFL
// Duty: Shift left input bus A by the index of the least 
//		 significant '1' on input bus B 
//		 (starting at index 1 on the right).

module SHFL (
  input  t_data A,        // bus to be shifted
  input  t_data B,        // shift amount bus
  output t_data result    // data output
  );

  logic flag;
  logic [$clog2(`DATA_WIDTH):0] shift_amt;

  always_comb begin
    flag = 1;
    for (int i = 0; i < `DATA_WIDTH; i++) begin
      if (B[i] && flag)
        shift_amt = i + 1;
        flag = 0;
    end
    result = A << shift_amt;
  end

endmodule
