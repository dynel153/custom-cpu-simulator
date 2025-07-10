module RF_T;
  
  reg clk;
  reg CNTRL_RS; // Control signal to enable writing to the register file
  reg [4:0] rs;   // Address of the first register to read
  reg [4:0] rt;   // Address of the second register to read
  reg [4:0] rd;   // Address of the register to write to
  reg [31:0] ALU_WB; // Data to write back into the register file
  wire [31:0] Read_Data;  // Output of the first read register
  wire [31:0] Read_Data2; // Output of the second read register

  // Instantiating the register_file module
  register_file my_test(
    .clk(clk),
    .CNTRL_RS(CNTRL_RS),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .ALU_WB(ALU_WB),
    .Read_Data(Read_Data),
    .Read_Data2(Read_Data2)
  );

  // Clock generator: toggles clk every 5 time units
  always #5 clk = ~clk;

  initial begin 
    // Initialize all inputs
    clk = 0;
    rs = 0;
    rd = 0;
    rt = 0;
    CNTRL_RS = 0;
    ALU_WB = 0;
  
    // First test: attempt to write to register 0 (should not succeed)
    #10;
    CNTRL_RS = 1;
    rs = 5'b00001;
    rt = 5'b00010;
    rd = 5'b00000; // Trying to write to reg 0 (should remain 0)
    ALU_WB = 32'h00000001;
  
    // Second test: write value 2 to register 2
    #20;
    CNTRL_RS = 1;
    rs = 5'b00001;
    rt = 5'b00010;
    rd = 5'b00010;
    ALU_WB = 32'h00000002;

    // Third test: observe values in rs and rt (expect reg2 to return 2)
    #30;
    CNTRL_RS = 1;
    rs = 5'b00010;
    rt = 5'b00011;
    rd = 5'b00000; // No write intended here

    // Wait 10 more time units to allow values to settle, then finish simulation
    #10;
    $finish;
  end
endmodule
