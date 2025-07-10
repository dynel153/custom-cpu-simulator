module test_stub;
  reg [31:0] registers [0:31];
  integer i;

  initial begin 
    for (i = 0; i < 32; i = i + 1) begin
      registers[i] = 32'd0;
    end
  end
endmodule
