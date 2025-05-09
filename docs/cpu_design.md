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
