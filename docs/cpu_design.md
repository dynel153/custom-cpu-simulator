# CPU – What is it and What Does it Do?

A CPU (Central Processing Unit) is the brain of the computer. It:

- Fetches instructions from memory
- Decodes them so they can be executed
- Executes instructions (math operations, memory access, jumps)
- Updates registers and/or memory based on the instruction

I'm creating a brain! 

---

##  Parts of the CPU

- **Program Counter (PC)** – Keeps track of which instruction is currently being executed
- **Instruction Memory** – Stores the program instructions
- **Instruction Decoder** – Breaks the binary instruction into opcode and operand fields
- **Register File** – Stores and outputs data from general-purpose registers
- **ALU (Arithmetic Logic Unit)** – Performs math and logical operations
- **Control Unit** – Sends signals to coordinate ALU, memory access, and register writes
- **Data Memory** – Stores or loads data during `LOAD` and `STORE` instructions
- **Clock & Reset** – Controls timing and resets the CPU state

---

##  CPU Execution Cycle

1. **Instruction Fetch (IF)**  
   PC → fetch instruction from Instruction Memory

2. **Instruction Decode (ID)**  
   Decode instruction, read source registers

3. **Execute (EX)**  
   Perform ALU operation or compute memory address

4. **Memory Access (MEM)** *(only if `LOAD` or `STORE`)*  
   Read or write from Data Memory

5. **Write Back (WB)**  
   Write result back to Register File
---
##  Branching Logic Planning

- Decided to include branching support from the start (no delays later)
- Need to support instructions like: `BEQ`, `JMP`
- Will require:
  - Comparator module (e.g., check if `R1 == R2`)
  - MUX to select next PC (normal or branch target)
  - Immediate field or jump address logic
  - Control signal: `Branch`, `Jump`, `PCSrc`
- Block diagram will include branching paths in PC logic

---


##  Steps to Build Diagram 

1. ## Fetch Stage 
   - Add a Program Counter(PC) -> 32-bit registers that holds the adress of the current instuction
   - Connect PC to Instuction Mem to fetch Instuction -> use ROM Block
   - Add an Adder to compute PC + 4 ( for next sequential instuction adress)
   - Add a second Adder to compute the branch target adress by adding the shifted immediate offest to PC + 4
      - Input 0 = PC + 4 
      - Input 1 = Branch target adress (From Adder)
      - Select = PCSrs (output from Comparator)
   - Output of MUX Feeds into Program Counter

    **Backgroup Concept**
      - Why Instuction are 4 byte apart (PC+4)
         - In MIPS and similar archetectures each instuction is 4 bytes (32 bits)
         - Memory is byte-adressable (1 adress = 1 bytes)
         - To move to the next instuction, the PC increase by 4
          - Ex. If the current instruction is at 0x00000000, the next is at 0x00000004
      - Why shift the branch offset by left by 2 bits
         - The offset feild in branch instuction like BEQ represents the number of instuction, not bytes
         - Since each instuction in 4 bytes, the actual jump distance in memeory is: offset X 4
         - Shifting left by 2 bits is equivalent to multiplyng the offset by 4
         - This give the real byte distance the cpu need to jump and ensure real line alignments in memory 
      - Why add a Second Adder
         - For Branch instuciton like BEQ,the cpu can't jump to the label direcly
         - It compute the branch target by:
            - Sign extending the 16 bit immeadiate
            - Shifting it left by 2 ( word- aligned) 
            - Adding it to PC + 4 with the second adder
         - This give the true adress to jump when the branch is taken 
         
      ## CPU Project Progress Log

### 5/19/2025

#### What Was Built Today
- [x] Program Counter (PC) — 32-bit register with clock input
- [x] Adder for `PC + 4`
- [x] MUX for selecting next PC value (`PC + 4` vs. branch target)
- [x] Shift Left 2 logic for branch target offset
- [x] Second Adder to compute `PC + BranchOffset`
- [x] PCrs (fake register to simulate branching condition) wired to MUX select for BEQ simulation


#### Fix Made:
- Originally used a 32-bit pin directly for the offset, which caused a width mismatch
- Replaced the 32-bit pin with a 16-bit input followed by a sign-extender to 32 bits before shifting

---

### 5/25/2025

#### Additions and Fixes
- [x] Added 16-bit input pin to simulate branch offset (as in MIPS)
- [x] Inserted a Bit Extender to sign-extend 16-bit input to 32 bits
- [x] Connected extended output to the Shift Left 2 block
- [x] Configured Shift Left block:
  - Input and Output: 32-bit
  - Shift Amount: constant `2`
- [x] Connected shifter output to Branch Target Adder
- [x] Confirmed all bit widths matched across connections to resolve `Incompatible widths` error

#### Key Insight:
- The shift block requires a 32-bit input, so a direct 16-bit pin causes a mismatch
- Fix: Use a Bit Extender between the 16-bit pin and the shifter
- Also added a constant (value = 2) as the shift amount, with a bit width of 3–5 bits

---

### Branch Simulation
- [x] Connected Branch Target output to MUX input `1`
- [x] Tested:
  - PCSrc = 0 → PC increments by 4
  - PCSrc = 1 → PC jumps by offset (2 << 2 = +8)
- [x] Verified logic by tracking tick-by-tick PC values using manual clock

---

### Correction Completed
- [x] Identified logic bug: Branch Target Adder was using `PC + 4`
- [x] Rewired it to use direct PC output from register
- [x] Now correctly computes:  
  `BranchTarget = PC + (SignExtendedOffset << 2)`

Branch logic is now MIPS-compliant and ready for simulation.

---

### Register Control Pins: PC Register — `R` and `WE`

#### WE (Write Enable)
- Controls when the PC is allowed to update
- When `WE = 1`, the PC updates its value from the input `D` on the next clock tick
- When `WE = 0`, the PC holds its current value, even if the clock ticks

#### R (Reset)
- Forces the PC to reset to 0
- When `R = 1`, the PC ignores other inputs and sets output `Q = 0`
- When `R = 0`, the PC behaves normally and responds to clock and `WE`

#### Summary Table:

| Clock Tick | R   | WE  | PC Behavior         |
|------------|-----|-----|---------------------|
| Tick       | 0   | 1   | Update from `D`     |
| Tick       | 0   | 0   | Hold current value  |
| Tick       | 1   | X   | Reset to 0          |

#### In This Design:
- R is set to constant 0 to disable reset during normal operation
- WE is set to constant 1 to allow the PC to update every clock tick

---

### Clock and Simulation Timing
- Slowed down simulation via `Simulate → Tick Frequency` to 0.5 Hz
- Verified:
  - PC increments by 4 when `PCSrc = 0`
  - PC jumps by `(offset << 2)` when `PCSrc = 1`
- Restarted simulation to validate behavior consistency:
  - PC transitioned correctly between sequential and branch targets
- Confirmed stability and correct propagation with auto-ticking clock

---

FETCH STAGE COMPLETED  
## Final Fetch Stage Integration: Instruction Memory (5/25/2025)

### Purpose:
To complete the Fetch Stage, the system must not only update the Program Counter (PC) but also retrieve the corresponding instruction from memory. Since instructions are word-aligned (each instruction is 4 bytes), the memory is indexed using PC[7:2], which represents the middle bits of the 32-bit PC.

### Problem Faced:
While the PC is 32 bits wide, the Logisim ROM component cannot accept a 32-bit address input due to hardware simulation limitations. The ROM was configured to use a 6-bit address input (64 possible instructions). The challenge was extracting bits PC[7:2] and merging them into a single 6-bit address input that could feed into the ROM.

Key issues encountered:
- Bits 2 through 7 of the PC were split across two grouped outputs of the original splitter
- A splitter cannot merge multiple separate inputs
- Logisim does not offer a direct "bus combiner" component, requiring a workaround

### Solution Implemented:

Step 1: ROM Configuration
- Configured the ROM to store 64 instructions, each 32 bits wide
- Address width set to 6 bits to reflect PC[7:2] word alignment

Step 2: Bit Extraction
- Used a 32-to-32 splitter to break out individual PC bits
- Extracted:
  - Bits 2 through 5 from group 5–0
  - Bits 6 and 7 from group 11–6

Step 3: Bit Merging
- Created a second splitter configured as a merger:
  - Bit Width In: 6
  - Fan Out: 6
  - Connected extracted bits in order:
    - Bit 0: PC[2]
    - Bit 1: PC[3]
    - Bit 2: PC[4]
    - Bit 3: PC[5]
    - Bit 4: PC[6]
    - Bit 5: PC[7]
- Merged output was used as a single 6-bit bus and connected directly to the ROM address input

### Final Outcome:
- On each clock tick, the PC value is updated
- PC[7:2] is extracted, merged, and used to index the ROM
- The ROM outputs a 32-bit instruction corresponding to that address
- This instruction output is now available to be sent to the Decode stage

### Design Rationale:
- This mirrors real CPU behavior where the PC is wide but only a portion is used to access memory or cache
- Instruction memory is intentionally smaller than the full PC space
- Modular signal extraction and reconstruction ensures readable, scalable CPU design

### Fetch Stage Summary:

| Component               | Description                                        |
|-------------------------|----------------------------------------------------|
| PC (32-bit)             | Tracks current instruction address                 |
| PC + 4 Adder            | Computes the next sequential instruction address   |
| Branch Adder            | Calculates PC + (offset << 2)                      |
| MUX (PCSrc)             | Chooses between sequential and branch addresses    |
| ROM (64 × 32)           | Stores instructions                                |
| PC[7:2] Extract + Merge | Extracted using splitters and combined for ROM     |
| ROM Output              | 32-bit instruction fed to Decode stage             |

Instruction fetch logic is now complete and fully functional. Ready to proceed to Decode Stage.

#### PC Addressing Example (Word-Aligned Access)

| PC Decimal | PC (32-bit Binary)                    | `pc[7:2]` (Index) | What It Does                |
| ---------- | ------------------------------------- | ----------------- | --------------------------- |
| `0`        | `00000000_00000000_00000000_00000000` | `000000`          | Instruction 0               |
| `4`        | `00000000_00000000_00000000_00000100` | `000001`          | Instruction 1               |
| `8`        | `00000000_00000000_00000000_00001000` | `000010`          | Instruction 2               |
| `12`       | `00000000_00000000_00000000_00001100` | `000011`          | Instruction 3               |
| `16`       | `00000000_00000000_00000000_00010000` | `000100`          | Instruction 4               |
| `20`       | `00000000_00000000_00000000_00010100` | `000101`          | Instruction 5               |
| ...        | ...                                   | ...               | ...                         |
| `252`      | `00000000_00000000_00000000_11111100` | `111111`          | Instruction 63 (last entry) |


      
## 2. **Instruction Decode + Pseudo Register File Integration**
- Wire Instruction Memory output to **two splitters**:
  - First splitter (R-type): Breaks into `op`, `rs`, `rt`, `rd`, `shamt`, `funct` → format: `6,5,5,5,5,6`
  - Second splitter (I-type): Breaks into `op`, `rs`, `rt`, `imm` → format: `6,5,5,16`
- Connect `imm` field from I-type splitter to **Sign Extender** (16 → 32 bits)
- Instead of using Logisim's built-in Register File block, built a **custom 4-register pseudo file** to simulate real register behavior:
  - **Inputs**:
    - `rd_input` (2-bit destination register address)
    - `rs_input` (2-bit read address for source register 1)
    - `rt_input` (2-bit read address for source register 2)
    - `WriteData` ← From ALU (labeled `ALU WriteData Input`)
    - `RegWrite` ← From Control Unit (labeled `control unit input`)
    - `Clock` ← From Fetch stage
  - **Outputs**:
    - `ReadData1` ← Output from MUX 1 (selected by `rs`)
    - `ReadData2` ← Output from MUX 2 (selected by `rt`)
- Internal Logic:
  - `rd_input` goes to a 2-to-4 **decoder**
  - Each decoder output line is ANDed with `RegWrite` to enable exactly one register’s write port
  - All registers share the same `WriteData` and `Clock` lines
  - Two 4-input **MUXes** select `ReadData1` and `ReadData2` from register outputs based on `rs_input` and `rt_input`
- **All inputs and outputs clearly labeled** for easy integration into the Decode stage and future Execution stage

---

### CPU Project Progress Log

## 6/10/2025

##### What Was Built Today
- [x] Finished building and labeling the pseudo-register file
- [x] Integrated inputs for `rd`, `rs`, `rt`, `RegWrite`, `Clock`, and `WriteData`
- [x] Verified MUXes correctly handle read selection
- [x] Confirmed one-hot decoder output drives safe write-enable logic
- [x] Paused on 32-register version with intent to revisit after decode stage is complete

##### Realization & Design Decisions
- Reading from registers only requires MUX selection; no decoder needed
- Writing requires controlled enable logic using decoder + RegWrite signal
- This 4-register model simulates core register file behavior of a real CPU
- Logisim did not include a built-in register file component suitable for this use
- Decided to build a pseudo register file manually to fully understand the logic
- Chose 4-register simulation instead of 32-register version to save time and maintain clarity; design is fully scalable later

---
## 6/14/2025 

### What Was Built Today

- Replaced `rs_input` with `rd_input` in the pseudo register file for proper write-back targeting in R-type instructions.
- Added 2-bit input pin `rd_input` to the `pseudo_register_file` subcircuit.
- Connected `rd_input` to the decoder, which determines the destination register to write to.
- Decoder outputs go to 4 AND gates, each tied to a different register's write enable (R0–R3).
- RegWrite signal (`CNTRL_Unit_Input`) is routed into each AND gate → ensures only one register writes when enabled.
- All registers share:
  - `ALU_WriteData` input (for value being written)
  - `CLK_input` (from Fetch stage or system clock)
- All inputs/outputs clearly labeled for future use:
  - `rd_input`, `rs_input`, `rt_input`
  - `ALU_WriteData`, `CNTRL_Unit_Input`, `CLK_input`

---

### Sign Extender Added

- Input: 16-bit `imm` field (from I-type instructions)
- Output: 32-bit sign-extended value
- Purpose: Properly extends immediate values with sign bit preserved (for operations like `addi`, `lw`, `sw`)
- Will connect to ALU input B later through MUX

---

### RegDst MUX (rd_input Selection Logic)

- Built a 2-to-1 MUX to decide between using `rt` or `rd` as the destination register
  - Input 0: `rt` (I-type instruction)
  - Input 1: `rd` (R-type instruction)
  - Output: Connects to `rd_input` of `pseudo_register_file`
  - Select Line: Will use `RegDst` signal from Control Unit
- Outcome: `rd_input` is now fully dynamic and instruction-type aware

---

### Decoded `shamt` and `funct` Fields

- Confirmed R-type splitter format: `6,5,5,5,5,6`
- Added labeled outputs:
  - `shamt_output` (bits 10–6): used for shift operations (e.g. `sll`, `srl`)
  - `funct_output` (bits 5–0): ALU Control uses this + `ALUOp` to decide actual ALU function
- These signals will be routed directly to the ALU stage or ALU control

---

### Final Decode Stage Output Pins

| Output Pin      | Purpose                                              |
|------------------|------------------------------------------------------|
| `opcode_output`  | Sent to Control Unit to determine instruction type   |
| `Read_data_1`    | Sent to ALU input A                                  |
| `Read_data_2`    | Sent to ALU input B (or Memory write data)           |
| `imm_value`      | From Sign Extender; feeds ALU via MUX                |
| `shamt_output`   | Shift amount for ALU (if applicable)                 |
| `funct_output`   | Function code for ALU control                        |

---

### Instruction Field Reference

#### R-type Instruction (Format: `6,5,5,5,5,6`)
| Field    | Bits     | Description                      |
|----------|----------|----------------------------------|
| `opcode` | 31–26     | Always `000000` for R-type       |
| `rs`     | 25–21     | Source register 1                |
| `rt`     | 20–16     | Source register 2                |
| `rd`     | 15–11     | Destination register             |
| `shamt`  | 10–6      | Shift amount                     |
| `funct`  | 5–0       | Function code (e.g. `add`, `sub`)|

#### I-type Instruction (Format: `6,5,5,16`)
| Field    | Bits     | Description                      |
|----------|----------|----------------------------------|
| `opcode` | 31–26     | Instruction type                 |
| `rs`     | 25–21     | Source register                  |
| `rt`     | 20–16     | Destination register             |
| `imm`    | 15–0      | Immediate (sign-extended)        |

### Decode Stage Summary
| Component              | Description                                                             |
|------------------------|-------------------------------------------------------------------------|
| Splitters (R & I)      | Separate fields from 32-bit instruction into fields for both formats    |
| Sign Extender          | Extends 16-bit `imm` field to 32 bits for I-type instructions           |
| Pseudo Register File   | Custom 4-register setup using decoder for write and MUX for read logic  |
| MUX (RegDst)           | Chooses `rd` (R-type) or `rt` (I-type) for destination register          |
| Control Signals Prep   | Connected `RegWrite`; planning for `RegDst`, `ALUSrc`, `ALUOp` soon     |
| Output Labeling        | Labeled all output pins: `opcode`, `shamt`, `funct`, `ReadData1`, etc.  |
| Instruction Awareness  | Fully decodes `shamt`, `funct`, and supports both R-type and I-type     |
| Stage Connectivity     | Ready to forward outputs to ALU and Control Unit in Execution stage      |

Instruction decode logic is now complete and fully functional. Ready to proceed to Execution Stage.

--
## 3.  ALU and Execute Stage
  - ALU receives:
  - `Input A` ← From `ReadData1` (Register file output)
  - `Input B` ← From ALUSrc MUX output
  - `ALUOp` ← 4-bit control signal from Control Unit
  - **Outputs**:
    - `alu_result` ← Sent to MEM or Writeback stage
    - `Zero` flag ← Used for branching (e.g., `beq`)

- ALUSrc MUX:
  - Selects between `ReadData2` (register value) and `imm_value` (from Sign Extender)
  - Controlled by `ALUSrc` signal from Control Unit

- ALUOp determines operation type (see table below)

- ALU inputs (`A` and `B`) are sent **in parallel** to 10 separate operation blocks:
  - AND, OR, ADD, XOR, NOR, SUB, SLT, SLL, SRL, SRA
  - Each block computes its result simultaneously

- A 16-to-1 MUX is used to select the correct operation output
  - MUX select line = `ALUOp[3:0]`
  - Unused MUX inputs are tied to 0 or left unwired for now

- Zero flag output is connected to SUB block result == 0

---

### CPU Project Progress Log

#### 6/17/2025

##### What Was Built Today
- [x] Created `ALU` subcircuit and added to main CPU diagram
- [x] ALUSrc MUX created and tested
- [x] Routed inputs from Decode stage: `ReadData1`, `ReadData2`, `imm_value`
- [x] Built output lines: `alu_result`, `Zero`
- [x] Started 10 logic operation blocks: AND, OR, ADD, XOR, NOR, SUB, SLT, SLL, SRL, SRA
- [x] Wired all logic block outputs into a 16-to-1 MUX
- [x] MUX controlled by `ALUOp` signal

##### Realization & Design Decisions
- Inputs can be broadcast to all logic blocks simultaneously
- ALUOp MUX allows centralized output selection
- Chose 10 realistic MIPS-style ALU operations for future CPU simulation
- Zero flag only needs to monitor SUB output for equality comparisons

---

#### 6/18/2025

##### What Was Built Today
- [x] Built the full ALU subcircuit as a dedicated component
- [x] Implemented all 10 core ALU operations in parallel:
  - AND, OR, ADD, XOR, NOR, SUB, SLT, SLL, SRL, SRA
- [x] Connected `Read_Data` and `ALU_MUX_RSLT` to all operation blocks as shared inputs
- [x] Connected `Shamt_input` as a third input to shift operation blocks
- [x] Added SLT logic with `<` comparator and 1-to-32-bit sign extender
- [x] Created a 16-to-1 MUX to select the final `alu_result` based on `ALU_op`
- [x] Verified the correct routing of inputs and operations into the MUX

##### Realization & Design Decisions
- ALU is now fully encapsulated in its own subcircuit (`ALU`) to simplify CPU integration
- All operation blocks receive inputs in parallel and compute simultaneously
- The `shamt_input` wire is necessary for SLL, SRL, and SRA instructions, and comes from the Decode stage
- The MUX cannot be labeled directly in Logisim, so internal documentation is used to track input assignment
- Zero flag logic will be handled later using the SUB result and a zero comparator
- Wiring is clean, modular, and mirrors real CPU ALU behavior

---

#### 6/23/2025

##### What Was Built Today
- [x] Implemented `Zero_flag` logic for branch comparison
- [x] Tapped the SUB block output directly (before the ALU result MUX)
- [x] Connected SUB output to a 32-bit equality comparator
- [x] Connected a 32-bit constant `0x00000000` to the other comparator input
- [x] Routed the comparator's 1-bit output to a labeled `Zero_flag` pin
- [x] Designed ROM block that maps instruction Opcode and Funct values to ALU control outputs in Control Unit subcircuit
- [x] Edited ROM contents using hex editor to reflect instruction-to-control logic mappings
- [x] Added `Opcode` and `Funct` input splitters in Control Unit to isolate 6-bit fields
- [x] Merged `Opcode` and `Funct` via 12-bit Merger as ROM address
- [x] Connected 6-bit ROM output to a Splitter (fanout = 3): `ALUOp` (4 bits), `ALUSrc` (1 bit), `Branch` (1 bit)
- [x] Labeled outputs clearly with color-coded wires in Logisim
- [x] Routed `ALUSrc` control signal from Control Unit to ALU input MUX
- [x] Connected `Branch` and `Zero_flag` outputs to an AND gate to generate `PCSrc`
- [x] Created output pin for `PCSrc` to eventually control PC update logic

##### Realization & Design Decisions
- Zero flag logic should not be routed through the ALU result MUX
- The `Zero_flag` is meaningful only for branching instructions like `beq`, so a constant comparator on the SUB result is the cleanest solution
- All 10 ALU ops run in parallel, so the SUB output is always valid — allowing the `Zero_flag` to be checked at any time
- Avoided creating a second ALU result by keeping `Zero_flag` separate from `alu_result`
- ROM-based Control Unit is a deliberate decision to replicate real CPU decoding logic, where input address formed by concatenating Opcode and Funct leads to the correct control signals
- Control Unit now includes:
  - Splitters to isolate `Opcode` and `Funct`
  - Merger to form ROM address
  - ROM block to map control signals
  - Splitter with fan-out = 3 to extract `ALUOp`, `ALUSrc`, and `Branch`
  - `ALUSrc` routes to MUX before ALU
  - `Zero_flag` and `Branch` routed to AND gate for `PCSrc`
- Design reflects practical constraints in Logisim and clean modularity for future testing

---
#### 6/28/2025

##### Execution Stage Diagram Update
- Implemented new control signals: `MemRead`, `MemWrite`, and `MemToReg`
- Connected these signals from the Control Unit to appropriate datapath components
- `MemRead` and `MemWrite` routed to future RAM control block
- `MemToReg` routed to be used as the select line for the final Writeback MUX
- `Read_data_2` is now directly forwarded to the MEM stage via a labeled output

##### Today's Design Focus and Breakthroughs
- Clarified the functional roles of `MemRead`, `MemWrite`, and `MemToReg`
- Decided that `MemToReg` can be derived directly from `MemRead` in current instruction set
- Recognized the need for distinct control signals:
  - `MemRead` for enabling RAM reads in MEM stage
  - `MemWrite` for enabling RAM writes in MEM stage
  - `MemToReg` for controlling the Writeback MUX
- Plan to extend ROM control output width from 6 bits to 9 bits to incorporate these memory-related signals
- Identified that `lw` is the only instruction requiring `MemToReg = 1`, making it safe (for now) to let `MemToReg = MemRead`
- Future-proofed design by documenting intent to refactor `MemToReg` as an independent signal if new instructions are added
- Added **missing `RegWrite` signal** as the 10th control output from the Control Unit
  - Recognized necessity of `RegWrite` in decoding stage to enable the correct register file to write
  - Updated Instruction Mapping and ROM table accordingly


#### Control Unit Design Reference

##### Inputs
| Input Name | Bit-width | Source           | Purpose                                                                 |
|------------|-----------|------------------|-------------------------------------------------------------------------|
| `Opcode`   | 6 bits    | From instruction | Identifies the instruction type (e.g., R-type, addi, lw, beq)           |
| `Funct`    | 6 bits    | From instruction | Used only if Opcode = 000000 (R-type) to specify the ALU operation      |

##### Outputs
| Output Name | Bit-width | Destination           | Purpose                                                                 |
|-------------|-----------|------------------------|-------------------------------------------------------------------------|
| `ALUOp`     | 4 bits    | ALU                   | Tells ALU what operation to perform (ADD, SUB, AND, etc.)               |
| `ALUSrc`    | 1 bit     | ALU input MUX         | Selects between register value or immediate                            |
| `Branch`    | 1 bit     | Branch logic          | Tells CPU that current instruction is a branch                          |
| `MemRead`   | 1 bit     | RAM read control      | Enables memory read access                                              |
| `MemWrite`  | 1 bit     | RAM write control     | Enables memory write access                                             |
| `MemToReg`  | 1 bit     | Writeback MUX select  | Chooses between ALU result and memory data                              |
| `RegWrite`  | 1 bit     | Register file         | Enables destination register to be written during WB stage              |

##### Instruction Mapping Table
| Instruction | Opcode   | Funct   | ALUOp | ALUSrc | Branch | MemRead | MemWrite | MemToReg | RegWrite |
|-------------|----------|---------|--------|--------|--------|----------|-----------|-----------|-----------|
| `add`       | 000000   | 100000  | 0010   | 0      | 0      | 0        | 0         | 0         | 1         |
| `sub`       | 000000   | 100010  | 0110   | 0      | 0      | 0        | 0         | 0         | 1         |
| `and`       | 000000   | 100100  | 0000   | 0      | 0      | 0        | 0         | 0         | 1         |
| `or`        | 000000   | 100101  | 0001   | 0      | 0      | 0        | 0         | 0         | 1         |
| `slt`       | 000000   | 101010  | 0111   | 0      | 0      | 0        | 0         | 0         | 1         |
| `addi`      | 001000   | 000000  | 0010   | 1      | 0      | 0        | 0         | 0         | 1         |
| `lw`        | 100011   | 000000  | 0010   | 1      | 0      | 1        | 0         | 1         | 1         |
| `sw`        | 101011   | 000000  | 0010   | 1      | 0      | 0        | 1         | 0         | 0         |
| `beq`       | 000100   | 000000  | 0110   | 0      | 1      | 0        | 0         | 0         | 0         |

##### ROM Address Map (Padded 12-bit Format for Readability)
| Instruction | Opcode | Funct  | Address (Hex) | 10-bit Output | 12-bit Padded (Grouped) | Output (Hex) |
|-------------|--------|--------|----------------|----------------|--------------------------|----------------|
| `add`       | 000000 | 100000 | `@020`         | `0010000001`   | `0000 1000 0001`         | `0x081`        |
| `sub`       | 000000 | 100010 | `@022`         | `0110000001`   | `0001 1000 0001`         | `0x181`        |
| `and`       | 000000 | 100100 | `@024`         | `0000000001`   | `0000 0000 0001`         | `0x001`        |
| `or`        | 000000 | 100101 | `@025`         | `0001000001`   | `0000 0100 0001`         | `0x041`        |
| `slt`       | 000000 | 101010 | `@02A`         | `0111000001`   | `0001 1100 0001`         | `0x1C1`        |
| `addi`      | 001000 | 000000 | `@200`         | `0010100001`   | `0000 1010 0001`         | `0x0A1`        |
| `lw`        | 100011 | 000000 | `@8C0`         | `0010101011`   | `0000 1010 1011`         | `0x0AB`        |
| `sw`        | 101011 | 000000 | `@AC0`         | `0010100100`   | `0000 1010 0100`         | `0x0A4`        |
| `beq`       | 000100 | 000000 | `@100`         | `0110010000`   | `0001 1001 0000`         | `0x190`        |

##### Realization & Design Notes
- The Control Unit is not affected by the `Zero` flag directly. Instead, it outputs `Branch = 1` when the instruction is `beq`, and the separate branch logic checks if `Zero = 1` to decide whether to jump.
- Control Unit outputs only determine the ALU behavior and route setup — the actual condition check (e.g., `A == B`) is handled by branch decision logic.
- For `R-type` instructions, both `Opcode` and `Funct` must be decoded to determine the correct `ALUOp`.
- For `I-type` instructions, only the `Opcode` is used.

---
- ALU will use 16-to-1 MUX to allow future operation expansion
- ALU design aligns with MIPS-style control logic and instruction set
- Operation result selected using `ALUOp` code from Control Unit
- Planning to simulate each operation in Logisim before connecting MEM stage

### ALU Operation Mapping

| ALUOp Code | Operation        | Description                     | Instruction Types       |
|------------|------------------|----------------------------------|--------------------------|
| 0000       | AND              | A & B                           | and, andi                |
| 0001       | OR               | A ∨ B                           | or, ori                  |
| 0010       | ADD              | A + B                           | add, addi, lw, sw        |
| 0011       | XOR              | A ⊕ B                           | xor, xori                |
| 0100       | NOR              | ~(A ∨ B)                        | nor                      |
| 0110       | SUB              | A - B                           | sub, beq                 |
| 0111       | SLT              | A < B → 1                       | slt, slti                |
| 1000       | SLL              | A << shamt                     | sll                      |
| 1001       | SRL              | A >> shamt (logical)           | srl                      |
| 1010       | SRA              | A >>> shamt (arithmetic)       | sra                      |

---

### ALU Control Logic
- ALUOp serves as the select line for the operation MUX
- All operations computed in parallel; output chosen by MUX
- Zero flag implemented using comparator on SUB output == 0

---

### Output Pins from Execute Stage

| Output Pin      | Purpose                                               |
|------------------|-------------------------------------------------------|
| `alu_result`     | Output of ALU; sent to Memory or WB stage            |
| `Zero`           | Indicates if A == B; used for branching              |
| `ALUOp`          | Sent from Control Unit to determine ALU operation    |
| `ALUSrc`         | Selects between register or immediate operand        |

---

### Planned Execution Logic Reference

| Component           | Description                                                       |
|---------------------|-------------------------------------------------------------------|
| ALUSrc MUX          | Chooses between `ReadData2` and `imm_value`                       |
| ALU                 | Performs arithmetic/logical operation based on `ALUOp`            |
| Operation Blocks    | 10 logic circuits for each ALU operation                          |
| Operation Selector  | 16-to-1 MUX driven by `ALUOp`                                     |
| Zero Flag Output    | Used to determine branch conditions for instructions like `beq`   |
| Control Signals     | `ALUOp` and `ALUSrc` routed from Control Unit                      |
| Instruction Awareness | Will eventually integrate with `funct` for R-type decoding       |

Execution stage is now structured with realistic logic blocks. Ready to test operation outputs and continue integration with MEM stage.


## 4. **Data Memory Stage**
- Use a **RAM block** to simulate data memory behavior
- Connect **ALU Output** as the Address input
- Connect **Register rt** as the Data input (for stores)
- Control access using:
  - `MemRead` signal to enable reading
  - `MemWrite` signal to enable writing
- This stage handles memory access for `lw` and `sw` instructions

### Functional Details
- For **load (`lw`)** instructions:
  - ALU computes the memory address
  - RAM block uses `MemRead = 1` to retrieve data
  - Output is forwarded to the **Write Back stage** to be saved in the destination register

- For **store (`sw`)** instructions:
  - ALU computes the memory address
  - `rt` value (from **Read Data 2**) is the data to store
  - RAM block uses `MemWrite = 1` to write data to the specified address
  - This data is not forwarded — it ends here

### Architectural Insight
- **Read Data 2** from the Register File (value of `rt`) is always forwarded to the MEM stage
- Even if it's not used (e.g., in `lw` or R-type instructions), it's harmless and simply ignored

### Required Update to EX Stage
- Currently, `Read Data 2` is only connected to the **MUX** before the ALU
- To support `sw`, it must be **split and routed forward** to the MEM stage

### CPU Project Progress Log

## 6/25/2025

**Update to EX Stage Outputs:**
- Add a separate output wire from **Read Data 2** that goes directly to the MEM stage
- This allows the value of `rt` to be available for writing to RAM
- ALU MUX should continue to choose between `Read Data 2` and the Sign-Extended Immediate, depending on instruction type

## 6/28/2025

**MEM Stage ImplementationS**
- Built full **MEM stage** for handling load and store instructions
- Connected the following signals:
  - `ALU_result[7:0]` as RAM address input (truncating 32-bit ALU result)
  - `Read2` (Register File `rt`) as data input for `sw`
  - `MemWrite` → RAM write enable
  - `MemRead` → RAM output enable
  - `Clk_Signal` → RAM clock input
- Added 2-to-1 **MUX** for WB stage:
  - Input 0: ALU result (for R-type)
  - Input 1: RAM output (for `lw`)
  - Select: `MemToReg`
  - Output labeled `ALU_WB` → forwarded to register file

**Reasoning:**
- RAM blocks in Logisim have limited address widths; slicing ALU address avoids width mismatch
- Write data (`Read2`) must be preserved beyond EX stage for `sw` to function
- Using `MemToReg = MemRead` simplifies writeback control logic since only `lw` uses memory result
- This MEM stage structure cleanly separates logic between control (ID), computation (EX), and memory access (MEM) 
**Clarified Signal Responsibilities Across Stages:**
-  `MemRead`: Enables **RAM read** — comes from Control Unit, used in **MEM** stage
-  `MemWrite`: Enables **RAM write** — comes from Control Unit, used in **MEM** stage
-  `MemToReg`: Selects between **ALU result** and **RAM output** for writing to the register file — used in **WB** stage

**Insight:** `MemToReg` can be set equal to `MemRead` in this version since only `lw` requires it. This simplifies MUX design in Writeback stage without adding an extra control signal — for now.

**Design Update:**
- The final MUX in the Writeback stage selects between ALU output and RAM output
- Its select line is driven by `MemRead` (or optionally a dedicated `MemToReg` signal if added later)
- This logic ensures correct data is written back to the Register File depending on instruction type

### Summary
- `Read Data 2` = value of `rt`
- Sent forward from ID → EX → MEM
- Used as write data for `sw` (if `MemWrite = 1`)
- ALU result = address (not the data itself)
- MEM stage activates only one path depending on control signals

## 5. **Write Backstage**
   - Use a Mux for MemtoReg to select ALU Result or Memory Output
   - Send to Register Files WriteData input

### CPU Project Progress Log

#### 6/28/2025
- The Write Back stage has already been partially built into the circuits for the other four stages during their construction.
- Today's work will focus on testing and modifying the existing logic to ensure proper data flow through the Write Back stage.
- Simulated the instruction memory using a ROM.
- Extracted PC bits [2–7] using a splitter to form a 6-bit ROM address range (64-entry instruction space).
- Merged those bits using a second splitter configured as a merger, wiring them in order from PC[2] to PC[7].
- Saved all instruction encodings as a hex file: `instruction_rom_test.hex`.
- This file will be used with `$readmemh` in Verilog to preload the ROM for simulation.
- The instruction sequence was carefully designed to test R-type, I-type, and branching instructions in a clean, sequential order.
- Verified that the **fetch stage is working correctly** — initial output from the ROM matched the first instruction (`addi $1, $0, 10`), confirming that ROM loading and PC-to-ROM addressing is functional.
- Created a dedicated **offset pin** from the decoding stage that will later be used by the fetch stage for branch operations. This pin represents the immediate offset for `beq` instructions.
- Due to time and design constraints, only **4 registers** are available in the register file.
- As a result, the simulation will run only the first **3 clock cycles**, which include:
  - `addi $1, $0, 10`
  - `addi $2, $0, 5`
  - `add  $3, $1, $2`
- This limited run allows verification of instruction decode, ROM access, ALU execution, and register file writes.
- During register file integration, it was discovered that the **RegWrite signal** was missing from the control unit's output.
- This signal is essential to control whether a register write occurs for instructions like `add`, `addi`, and `lw`.
- Plan: **update the control unit** to expand the control word from 9 bits to 10 bits, adding a dedicated `RegWrite` control signal.
- `RegWrite` will be high for register-writing instructions and low for operations like `sw` and `beq` that should not trigger a register update.

### Edits
- Finalized the logic behind the creation of the **PC Write Enable (PC_WE)** signal.
- PC_WE should be **0** during memory operations (`lw` or `sw`) and **1** otherwise.
- This is determined by checking the `MemRead` and `MemWrite` control signals from the control unit.
- Since `MemRead` is 1 for `lw`, and `MemWrite` is 1 for `sw`, they are **never both active at the same time**.
- Therefore, we use a **NOR gate** to implement:
  `PC_WE = ~(MemRead | MemWrite)`

#### 6/29/2025
- While wiring the control signals from the control unit to the rest of the CPU, a simulation issue was discovered.
- The `RegWrite` and `PCSrc` signals were connected using gates (e.g., NOR), but some of these inputs were **floating (undefined)** due to missing data from previous stages.
- As a result, wires appeared **red in Logisim**, indicating **undefined behavior**.
- These undefined control signals blocked correct flow of data, particularly from the **fetch** stage, halting progress in simulation.
- Plan: ensure **all control lines are grounded or defaulted** if unused temporarily, or fully integrated with defined upstream logic.
- Simulation will be paused until all signal paths are fully resolved and functional.

### Logic Breakdown for NOR Gate:
| MemRead | MemWrite | MemRead \| MemWrite | PC_WE = ~(...) |
|---------|----------|----------------------|------------------|
| 0       | 0        | 0                    | 1  (Update PC)  |
| 1       | 0        | 1                    | 0  (Pause PC)   |
| 0       | 1        | 1                    | 0  (Pause PC)   |
| 1       | 1        | 1                    | 0  (Theoretically won't happen) |

- This cleanly expresses the intent: only allow PC to update when **neither memory control signal is active**.
- The NOR gate ensures simplicity, robustness, and accuracy even if the design evolves later.

#### Diagram Phase Completion Summary (6/29/2025)
- The full CPU diagram is now complete.
- All five stages — Fetch, Decode, Execute, Memory, and Write Back — have been connected and structurally verified.
- Despite Logisim's simulation limitations (e.g., red wires due to undefined gate inputs), the **core logic and dataflow design are structurally sound**.
- The ROM correctly loads instruction data, and control signals propagate as intended.
- Simulation halted due to Logisim’s inability to simulate undefined or floating values from partial circuits.
- Rather than over-engineering within Logisim, I will now shift to **Verilog implementation** where timing, clock edges, and memory behavior can be precisely simulated.
- **Purpose of diagram was to act as a reference** — and that mission is now complete.
- Next step: begin modular Verilog design using the diagram as a verified blueprint.

### Test Instruction ROM (6/28/2025)
| ROM Addr (dec) | ROM Addr (hex) | Instruction     | Binary                                | Hex       |
|----------------|----------------|------------------|----------------------------------------|-----------|
| 0              | @000           | addi $1, $0, 10  | 00100000000000010000000000001010      | 2001000A  |
| 1              | @001           | addi $2, $0, 5   | 00100000000000100000000000000101      | 20020005  |
| 2              | @002           | add $3, $1, $2   | 00000000001000100001100000100000      | 00221820  |
| 3              | @003           | sub $4, $1, $2   | 00000000001000100010000000100010      | 00222022  |
| 4              | @004           | and $5, $1, $2   | 00000000001000100010100000100100      | 00222824  |
| 5              | @005           | or $6, $1, $2    | 00000000001000100011000000100101      | 00223025  |
| 6              | @006           | slt $7, $2, $1   | 00000000010000010011100000101010      | 0041382A  |
| 7              | @007           | sw $3, 0($0)     | 10101100000000110000000000000000      | AC030000  |
| 8              | @008           | lw $8, 0($0)     | 10001100000010000000000000000000      | 8C080000  |
| 9              | @009           | beq $1, $2, 2    | 00010000001000100000000000000010      | 11220002  |
| 10             | @00A           | addi $9, $0, 99  | 00100000000010010000000001100011      | 20096063  |
| 11             | @00B           | addi $10, $0, 88 | 00100000000010100000000001011000      | 200A0058  |
