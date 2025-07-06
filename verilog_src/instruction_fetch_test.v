
module IF_test;

reg clk;
reg PC_WE;
reg PC_reset;
reg PC_Src;
reg [15:0] offset;
wire [31:0] instruction; 

IF my_if (
  .clk(clk),
  .PC_WE(PC_WE),
  .PC_reset(PC_reset),
  .PC_Src(PC_Src),
  .offset(offset),
  .instruction(instruction)
);

// Clock toggles every 5 time units (10 total period)
always #5 clk = ~clk;

// Test sequence: run just enough to confirm basic functionality
initial begin
  clk = 0;
  PC_WE = 0;
  PC_reset = 1;
  PC_Src = 0;
  offset = 0;

  #10; // simulate two clock cycles (5 time units high, 5 low)
  PC_reset = 0;
  PC_WE = 1;
// offset = 16'h0000 means a 16-bit value (hexadecimal) set to 0
// Equivalent to 16'd0 (decimal) or 16'b0000000000000000 (binary)
  offset = 16'h0000;

  #20;
  $finish;
end

endmodule
