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
5/15/2025 

##  Steps to Build Diagram 

1. **Fetch Stage** 
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
      **Progress- 5/19/2025**
         - What Was Buildt Today
            - PC (32-bit residters)
            - Adder for PC + 4
            - MUX for next PC value (PC + 4 or Branch Target)
            - Shift Left 2 logic for Branch Targe
            - Second adder for branch target adder
            - PCrs wired to MUX select
         - What Next
            - Add 32-bit pin input for fake branch offset
            - Connect offset input to shift left block 
            - Test PC updates with clock inputs
            - Simulate BEQ behavior by flipping PCrs
      
2. **Instuction Decode + Register Files**
   - Extract rs, rt, rd, and immediate fields from the instruction (manually label or use splitters)
   -  Creat a register files -> 32-registers, 32-bit wide
   - connect Readport to the input for the ALU

3. **ALU and Execute Stage**
   - Add ALU block -> input A = rs, input B = Result of Mux
   - Add Mux For ALUrc -> selects between register data or immediate
   - ALU output gose to memory or wirte back

4. **Data Memory**
   - Use a RAM block to simulate Data Memory
   - Inputs: Adress = ALU Output, data = rt
   - Enable Memread/ Memwrite With control signals

5. **Write Backstage**
   - Use a Mux for MemtoReg to select ALU Result or Memory Output
   - Send to Register Files WriteData input

6. **Branching Logic** 
   - Add a comparator to Check if rs == rt
   - use Mux for PCrc -> decides next PC: PC + 4 or branch target
   - connect branch logic to Control Unit inputs