module control_unit(
    input [5:0] op_code,       // 6-bit operation code
    input [5:0] func_code,     // 6-bit function code (used for R-type instructions)
    output Branch,             // Branch control signal
    output CNTRL_RS,           // Register file write enable
    output MEM_WS,             // Memory write signal
    output MEM_RS,             // Memory read signal
    output MEM_TR,             // Select between memory or ALU output for write-back
    output ALU_Src,            // ALU source select (register or immediate)
    output PC_WE,              // Program counter write enable
    output [3:0] ALU_OP        // ALU operation code
);

// Combine opcode and function code into a single 12-bit address
wire [11:0] full_code;
assign full_code = {op_code,func_code};

// Control unit ROM: 4096 entries of 10-bit control signals
reg [9:0] control_uo [0:4095];

// Load control signal definitions from external file at simulation start
initial begin 
  $readmemh ("control_unit.hex", control_uo);
  $display ("CONTROL UNIT INITIALIZED");
end

// Assign individual control signals based on bits from control_uo
assign ALU_OP    = control_uo[full_code][9:6];  // ALU operation
assign ALU_Src   = control_uo[full_code][5];    // ALU input source (register/immediate)
assign Branch    = control_uo[full_code][4];    // Branch signal
assign MEM_RS    = control_uo[full_code][3];    // Memory read
assign MEM_WS    = control_uo[full_code][2];    // Memory write
assign MEM_TR    = control_uo[full_code][1];    // Memory to register select
assign CNTRL_RS  = control_uo[full_code][0];    // Register write enable

// PC write enable is high only when no memory read/write is happening
assign PC_WE = ~|{MEM_RS, MEM_WS};

// Debug output for control signal status
always @ (*) begin
  $display ("OUTPUT FROM THE CONTROL UNIT: %h", control_uo[full_code]);
  $display ("ALU OP CODE         : %b", ALU_OP);
  $display ("ALU MUX INPUT       : %b", ALU_Src);
  $display ("Branch Signal       : %b", Branch);

  if (MEM_RS)
      $display("Reading             : YES");
  else 
      $display("Reading             : NO");

  if (MEM_WS)
      $display("Writing             : YES");
  else 
      $display("Writing             : NO");

  if (MEM_TR)
      $display("DATA SOURCE         : MEM");
  else 
      $display("DATA SOURCE         : WB");

  if (CNTRL_RS)
      $display("WRITEBACK           : ENABLE");
  else 
      $display("WRITEBACK           : DISABLE");

  if (PC_WE)
      $display("PC UPDATE           : ENABLE");
  else 
      $display("PC UPDATE           : DISABLE");
end

endmodule
