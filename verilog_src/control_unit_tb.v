module CU_TEST;

  // Declare input signals for the control unit
  reg [5:0] op_code;     // Operation code input
  reg [5:0] func_code;   // Function code input (used for R-type instructions)

  // Declare output wires to capture the control signals from the control unit
  wire [3:0] ALU_OP;     // ALU operation signal
  wire Branch;           // Branch control signal
  wire CNTRL_RS;         // Register file write enable
  wire MEM_WS;           // Memory write signal
  wire MEM_RS;           // Memory read signal
  wire MEM_TR;           // Memory to register signal
  wire PC_WE;            // Program counter write enable

  // Instantiate the control unit and connect inputs/outputs
  control_unit my_test (
    .op_code(op_code),
    .func_code(func_code),
    .ALU_OP(ALU_OP),
    .Branch(Branch),
    .CNTRL_RS(CNTRL_RS),
    .MEM_WS(MEM_WS),
    .MEM_RS(MEM_RS),
    .MEM_TR(MEM_TR),
    .PC_WE(PC_WE)
  );

  // Begin the test sequence using an initial block
  initial begin 
      // Test ADD instruction (opcode=000000, funct=100000)
      op_code = 6'b000000;
      func_code = 6'b100000;
      $display("INSTRUCTION CODE (ADDR): %h", full_code);
      #10;

      // Test SUB instruction (opcode=000000, funct=100010)
      op_code = 6'b000000;
      func_code = 6'b100010;
      $display("Testing SUB instruction");
      #10;

      // Test AND instruction (opcode=000000, funct=100100)
      op_code = 6'b000000;
      func_code = 6'b100100;
      $display("Testing AND instruction");
      #10;

      // Test OR instruction (opcode=000000, funct=100101)
      op_code = 6'b000000;
      func_code = 6'b100101;
      $display("Testing OR instruction");
      #10;

      // Test SLT instruction (opcode=000000, funct=101010)
      op_code = 6'b000000;
      func_code = 6'b101010;
      $display("Testing SLT instruction");
      #10;

      // Test ADDI instruction (opcode=001000, immediate operation)
      op_code = 6'b001000;
      func_code = 6'b000000;
      $display("Testing ADDI instruction");
      #10;

      // Test LW instruction (opcode=100011)
      op_code = 6'b100011;
      func_code = 6'b000000;
      $display("Testing LW instruction");
      #10;

      // Test SW instruction (opcode=101011)
      op_code = 6'b101011;
      func_code = 6'b000000;
      $display("Testing SW instruction");
      #10;

      // Test BEQ instruction (opcode=000100)
      op_code = 6'b000100;
      func_code = 6'b000000;
      $display("Testing BEQ instruction");
      #10;

      // Finish the simulation cleanly
      $finish;
  end

endmodule
