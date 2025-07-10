
 # Vegilog Progress Log

  ========================================
## Progress Log — July 4, 2025
 Defined module IF with inputs and outputs
   Understood the purpose of each input:
    - clk for timing
    - PC_WE to enable write to PC
    - PC_reset to reset PC
    - PC_Src to select between sequential and branch
    - offset as a signed 16-bit branch input
      Declared internal wires and register:
     - pc to store current instruction address
    - ext_offset to hold sign-extended and shifted offset
    - PC_NV for PC + 4
    - PC_BV for PC + offset
     - PC_MR as MUX result
  Learned how to:
     - Sign-extend using {{16{offset[15]}}, offset}
     - Use ternary operator to simulate a MUX
     - Use non-blocking assignment (<=) for sequential logic
  Next step: implement instruction memory using pc

 =======================

## Progress Log — July 5, 2025
 Built out and finalized instruction memory for IF stage
  - Used reg [31:0] instruction_mem [0:63] to define 64-word memory
  - Loaded instruction_rom_test.hex into memory using $readmemh
  - Discussed how to calculate instruction memory address using PC[7:2]
  - Committed to using 64 addresses and understood PC max at 252

 Added debugging tools:
  - Used $display to log INIT, FETCH, RESET, UPDATE events
  - Used format specifiers %0d (decimal) and %h (hexadecimal)

 Wrote and structured testbench for IF stage:
  - Declared inputs/outputs and instantiated IF module
  - Configured clock using always #5 clk = ~clk
  - Initialized inputs and toggled control signals
  - Set simulation duration to 10 time units and called $finish

 Simulated successfully with Icarus Verilog:
  - Verified correct instruction fetching from hex file
  - Observed PC resetting to 0 and incrementing by 4
  - Output logs matched expected behavior, confirming success

 To rerun simulation in the future:
  - Run the following command in terminal from the folder with your Verilog files:
    ```bash
    iverilog -o sim.out -s IF_test instruction_fetch.v instruction_fetch_test.v
    vvp sim.out
    ```

 =======================
 
 ## Progress Log — July 7, 2025
Created the register file module for the decoding stage:
 - Defined a 32-register array, each 32-bits wide: reg [31:0] registers [0:31];
 - Used rs and rt inputs as read addresses and rd as the write address
 - Outputs Read_Data and Read_Data2 reflect the values of registers[rs] and registers[rt]
 - Used 'assign' statements for continuous output from the register array
 - Created an always @(posedge clk) block to handle conditional write-back
 - Ensured register 0 is hardwired to zero by initializing it in an initial block
 - Prevented writes to register 0 with a conditional guard (write_a != 5'b00000)
 - Used $display to log read values before write-back and updates after write

Learned today:
 - How to structure a register file in Verilog using modular design
 - Proper use of assign vs procedural assignment
 - That inputs cannot be reassigned inside a module
 - Correct usage of initial vs always blocks
 - Best practices for preventing register overwrites (like locking register 0)
 - Syntax rules for if/else, begin/end, and $display formatting
 - How to simulate hardware logic in a readable and traceable way

=======================

## Progress Log — July 8, 2025
Finalized the register file implementation and ensured simulation behavior matched expectations:
 - After reviewing yesterday’s version, I realized that any uninitialized register would output undefined values (xxxxxxxx) in simulation.
 - To fix this, I wrote a for loop inside an `initial` block to explicitly initialize all 32 registers to zero at the start of simulation.
 - I removed unnecessary assign aliases like `read_da` and `read_da2` to make the code cleaner and reduce confusion.
 - I also removed simulation-specific logic that could interfere with integration into a full system later, keeping only the essential outputs.
 - Corrected syntax issues in the initial block (fixed for-loop and used 32'h00000000)
 - Replaced undefined variable 'write_a' with properly scoped 'rd'
 - Used non-blocking assignment (<=) consistently inside the always block
 - Prevented writes to register 0 by checking (rd == 5'b00000) and forcing it to 0
 - Confirmed register 0 value was preserved during all operations
 - Made code simulation-friendly using an initial block to initialize all registers to zero

Learned today:
 - Initial blocks are for simulation only and are ignored in hardware (FPGAs)
 - Register 0 must be explicitly preserved and cannot rely on initial blocks for synthesis
 - Assigning too frequently or unnecessarily can slow down hardware due to extra logic
 - assign statements outside of always blocks run in parallel (order doesn’t matter), but order matters inside always blocks depending on blocking vs non-blocking usage
 - A reset signal is necessary for real hardware to safely initialize values
 - Simulation values like xxxxxxxx mean undefined and will appear if no initialization occurs
 
=======================

## Progress Log — July 9, 2025
Tested the register file module using a testbench and validated its behavior under simulated clock cycles:
 - Connected the register file into a testbench and simulated multiple read/write sequences
 - Wrote test cases to verify that register 0 remains unchanged even when write-enable is high and data is supplied
 - Confirmed that regular registers (e.g., register 2) accept and store written data correctly
 - Observed output logs using $display to confirm behavior on every clock cycle
 - Used test patterns with controlled timing delays to check when values settle and updates occur
 - Noticed repeated output lines were due to unchanged signals being sampled on each posedge of the clock
 - Planned to reduce clutter in future logs by aligning testbench delays (#5 instead of #10) with clock timing

Learned today:
 - The always block will trigger on every posedge of the clock, even if inputs haven't changed
 - Simulation logs can show repeated behavior unless timing is tightly controlled
 - Writing to register 0 is blocked correctly, and this protection holds across all test cases
 - Real hardware does not stop at the end of an initial block, so a $finish statement is needed in testbenches to cleanly exit
 - Icarus Verilog has quirks with variable declarations — integer loop counters must be declared outside unnamed blocks to avoid SystemVerilog-only errors
 - Understanding what each line of output means helps confirm the correctness of module design
