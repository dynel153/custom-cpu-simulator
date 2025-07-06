
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
