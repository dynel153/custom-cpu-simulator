

module register_file (
  input clk,                      // Clock signal
  input CNTRL_RS,                // Control signal indicating whether to write
  input [4:0] rs,                // Address of first register to read; stands for register source  
  input [4:0] rt,                // Address of second register to read; stand for register target
  input [4:0] rd,                // Address of register to write; stand for register destination 
  input [31:0] ALU_WB,           // Value to write back into register destination
  output [31:0] Read_Data,       // Data read from rs
  output [31:0] Read_Data2       // Data read from rt
);


  // Define 32 general-purpose registers, 32 bits each
  reg [31:0] registers [0:31];

  // Initialize all registers to start at zero using for loop
  initial begin
    integer i;
    for ( i = 0; i < 32; i = i + 1) begin
      registers[i] = 32'h0000000;
    end
  end

  // Read data from the register file
  assign Read_Data = registers[ rs];
  assign Read_Data2 = registers[ rt];

  // On each clock cycle, handle write-back logic and display log
  always @(posedge clk) begin
    // Display current read values before write occurs
    $display("[INIT] Registers %0d have Value %0d",rs, Read_Data);
    $display("[INIT] Registers %0d have Value %0d",rt, Read_Data2);

    // If control signal is high, and writing to register 0, the output will be 0; else it will be ALU_WB
    if (CNTRL_RS) begin
      if (rd == 5'b00000) begin
        registers[rd] <= 32'h00000000;
        $display ("[UPDATE] Registers %0d have Value %0d",rd, registers[rd]); 
       end else begin
         registers[rd] <= ALU_WB;
        $display("[UPDATE] Registers %0d have Value %0d",rd, ALU_WB);
      end
    end else begin
      $display("NO WRITE BACK OCCUR");
    end
  end

endmodule
