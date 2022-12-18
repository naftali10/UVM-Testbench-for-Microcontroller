// Module name: Flexible Multiplexer
// Duty: Selecting one bit out of multiple data bits.
//		 the flexibility of this mux is in its input data size.

module mux #(
  parameter size = 8					// Size of input data
  )(
  input logic [size-1:0] data,			// Data bits
  input logic [$clog2(size)-1:0] sel,	// Selector
  output logic out						// Selected Output bit
  );
  assign out = data[sel];
  always @(sel, size) begin
    assert(sel<size) else $fatal (0,"Mux's selector's value is too high.");
    assert(0<=sel) else $fatal (0,"Mux's selector's value is negative.");
  end
endmodule
