
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

=======================

## Progress Log — July 17, 2025
Began implementation of the control unit and successfully created a ROM-based design to generate control signals:
 - Created a 12-bit instruction ID from opcode and function code to use as an address for control signal lookup
 - Defined a 4,096-entry ROM (`reg [9:0] control_uo [0:4095]`) to map each instruction ID to a 10-bit control word
 - Loaded control signals into the ROM using `$readmemh("control_unit.hex", control_uo);`
 - Used `assign` statements to slice each control signal cleanly from the ROM entry
 - Implemented logic to suppress program counter updates during memory access using `PC_WE = ~|{MEM_RS, MEM_WS};`
 - Used an `always @(*)` block with `$display` to print active control signals in simulation for debugging
 - Carefully structured code to separate `initial`, `assign`, and `always` blocks to avoid simulation errors

Learned today:
 - `assign` statements cannot go inside `initial` or `always` blocks; they must be in the main body of the module
 - `$display` can only be used inside procedural blocks like `always` or `initial`, not in the global scope
 - Attempting to display a whole array like `control_uo` will cause errors — instead, index it properly (e.g., `control_uo[full_code]`)
 - ROMs are commonly used in multi-cycle CPU control units to simplify instruction decoding
 - Control signal gating (like pausing PC updates during memory ops) is essential for correct instruction timing
 - The 12-bit instruction ID allows for 0x000 to 0xFFF address range, giving 4,096 possible control mappings

## Progress Log — July 21, 2025
Today, the control unit hex memory was finalized and formatted properly for Verilog simulation compatibility:
 - Converted old memory dump into a flat `$readmemh`-compatible format
 - Ensured each line number corresponds to a memory address (0–4095), and every line contains one 4-digit control word
 - Populated specific instruction addresses with correct 10-bit control words
 - Padded all unused lines with `0000` to prevent undefined behavior
 - Renamed file to `control_unit_test.hex` and loaded it into the design folder
 - Updated the control unit code to use `localparam CNTRL_WIDTH = 10;` for scalable signal width
 - Rewrote all signal slicing logic to reference `CNTRL_WIDTH`, ensuring flexible indexing for future expansion
 - Added fallback logic to assign a default NOP control word (`10'b0000000000`) if an uninitialized instruction address is accessed

Learned today:
 - `$readmemh` in Verilog requires one value per line; the line number equals the address
 - Padding unused addresses with NOP (`0000`) prevents errors during simulation
 - Each control word must be exactly the correct width (10 bits) and properly aligned
 - Memory-mapped control units offer clean, modular decoding for each instruction
 - Parameterizing the control width makes the design scalable and avoids hardcoding signal lengths
 - Referencing signals like `control_word[CNTRL_WIDTH-5]` instead of raw indexes improves maintainability

### Control Word Bit Mapping (from MSB to LSB):
```
[9:6]  ALU_OP     // ALU operation type
[5]    ALU_Src    // ALU source select: 0 = reg, 1 = imm
[4]    Branch     // Branch enable
[3]    MEM_RS     // Memory read enable
[2]    MEM_WS     // Memory write enable
[1]    MEM_TR     // Memory-to-register select
[0]    CNTRL_RS   // Register file write enable
```

This mapping is used to generate each hex value stored in the control ROM.
Each instruction is uniquely mapped to a 12-bit address (`full_code`) and drives these 10 control signals.
The use of `localparam CNTRL_WIDTH` makes it easy to expand the control word format in future versions of the CPU.

=======================

## Progress Log — July 28, 2025
Today, the testbench for the control unit was successfully written and reviewed:
 - Created a new testbench module `CU_TEST` to simulate control unit behavior
 - Declared input `reg` values and output `wire` signals to match the `control_unit` interface
 - Instantiated the `control_unit` with all connections correctly mapped
 - Wrote an `initial begin` block to simulate a series of instruction tests (ADD, SUB, OR, LW, etc.)
 - Used `#10;` time delays between each input to allow control logic to settle and display
 - Relied on the main module’s `$display` debugging logic to view internal control signal values
 - Added `$finish;` to the end of the testbench to terminate the simulation cleanly

Learned today:
 - Testbenches use `reg` for inputs because they are assigned inside procedural blocks
 - `wire` is used for outputs because those are driven by the DUT (design under test)
 - Verilog requires semicolons and proper quote matching — small syntax issues can break simulation
 - `$finish;` is essential to automatically end the simulation once test cases are complete
 - Simulation only runs as far as the time control and active instructions go; adding delay ensures outputs are visible before advancing

This testbench is now ready for simulation and functional verification of control unit ROM behavior.

