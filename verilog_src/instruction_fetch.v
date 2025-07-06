

module IF (
  input clk,
  input PC_WE,
  input PC_reset,
  input PC_Src,
  input [15:0] offset,
  output [31:0] instruction
);

  // pc stores the current value of the Program Counter
  reg [31:0] pc;

  // ext_offset is the offset extended to 32 bits and multiplied by 4
  // Q: I don't understand this {{16{offset[15]}}, offset};
  // A: This is sign-extension. We take the sign bit (offset[15]) and repeat it 16 times to extend to 32 bits. 
  // This allows negative jumps. Then we multiply by 4 because instructions are word-aligned (4 bytes apart).
  wire [31:0] ext_offset = {{16{offset[15]}}, offset} * 4;

  // PC_NV means PC Next Value — this is the normal case where PC just increments by 4 to fetch the next instruction
  wire [31:0] PC_NV = pc + 4;

  // PC_BV means PC Branch Value — the branch target address using the offset (used for jump or branch instructions)
  wire [31:0] PC_BV = pc + ext_offset;

  // PC_MR is the MUX Result that chooses between PC_NV and PC_BV
  // (Q: So you're checking to see if the select bit is 0, but what does the rest mean?
  // A: This is a ternary operator. If PC_Src == 0, use the next instruction (PC_NV). 
  // Otherwise, use the branch target address (PC_BV). It acts like a 2-to-1 multiplexer.)
  wire [31:0] PC_MR;
  assign PC_MR = (PC_Src == 0) ? PC_NV : PC_BV;

  // instruction_mem is a block of 64 words (32-bit each) to store the program instructions
  // (Q: reg [31:0] instruction_mem [0:63] — your creating something to store the value for the 64 address mem?)
  // A: Yes. This is the actual memory array used to store the instructions. Each address stores a 32-bit instruction.
  reg [31:0] instruction_mem[0:63];

  // Initialize instruction memory from an external hex file at the start of simulation
  initial begin
    $readmemh("instruction_rom_test.hex", instruction_mem);
    // $display is a built-in Verilog system task that prints formatted output to the simulator console.
    // $display("string %format", vars...) outputs the formatted string at runtime.
    // Common specifiers: %0d (decimal), %h (hex), %b (binary), %s (string)
    // This log confirms the hex file was loaded
    $display("[INIT] Instruction memory loaded from instruction_rom_test.hex");
  end

  // (Q: If (PC_reset) pc <= 0 — why?)
  // A: PC_reset is a control signal. When high, it resets the PC to 0 on the rising clock edge.
  // This is typically done to restart the program from the beginning.
  always @(posedge clk) begin
    if (PC_reset) begin
      pc <= 0;
      $display("[RESET] PC reset to 0");
    end else if (PC_WE) begin
      pc <= PC_MR; // update PC with either next or branch address
      $display("[UPDATE] PC updated to %0d", PC_MR);
    end
    $display("[FETCH] PC = %0d, Instruction = %h", pc, instruction);
  end

  // (Q: So pc is 32-bit, but we're only using bits [7:2] — why?)
  // A: Because instructions are word-aligned, the last 2 bits are always 00. Dropping them gives you the word index (0–63).
  wire [5:0] address = pc [7:2];

  // Fetch instruction from instruction memory using the calculated index
  assign instruction = instruction_mem[address];

endmodule



