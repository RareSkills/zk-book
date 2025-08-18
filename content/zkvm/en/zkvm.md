# How a ZKVM Works

A **Zero-Knowledge Virtual Machine** (ZKVM) is a virtual machine that can create a ZK-proof that verifies it executed a set of machine instructions correctly. This allows us to take a program (a set of opcodes), a virtual machine specification (how the virtual machine behaves, what opcodes it uses, etc), and prove that the output generated is correct. A verifier does not have to re-run the program, but only check the generated ZK proof — this allows verification to be succinct. Such succinctness is the basis of what makes ZK layer 2 blockchains scalable. It also enables someone to check that a machine learning algorithm ran as claimed without re-running the entire algorithm.

Contrary to the name, ZKVMs are rarely “zero knowledge” in the sense that they keep the computation private. Rather, they use ZK algorithms to produce a succinct proof that the program executed correctly on a certain input so that a verifier can double-check the computation with exponentially less work. Even though revealing the program input is optional, avoiding accidental data leaks and having multiple parties agree upon private state are very challenging engineering problems that still have unsolved challenges and scaling limitations.

A ZKVM “computes” each step in the opcode, then constrains that the opcode was executed correctly. The constraints must be designed in such a way that we can work with an arbitrary but valid opcode sequence.

We can think of a ZKVM as a series of “state” transitions. The  “state transition function” takes the previous state and the current opcode to be executed, an generates a new state. A ZKVM implements the “state transition function” and the circuit constraints that model its behavior. Note that “state” can include things like the “[program counter](https://en.wikipedia.org/wiki/Program_counter)” or other bookkeeping necessary for the VM to run properly.

This tutorial will build an extremely simple ZKVM that only supports basic arithmetic but is extensible for other opcodes. The VM presented here only has a stack and no memory or storage. We provide suggestions for further study of ZKVMs at the end of the article.

## Prerequisites

This tutorial assumes basic knowledge of how the EVM works (or some other stack-based architecture, such as the Java Virtual Machine). We build heavily off of the stack example from the previous chapter, so we assume knowledge of that.

## Simple stack-based ZKVM

We will build a simple stack-based ZKVM with one special-purpose signal that contains the result of the computation. The VM is fed a series of opcodes and numbers, then outputs the final result to a special signal we call `out`.

Our ZKVM only has the following opcodes:

- PUSH (pushes the first argument onto the stack)
- ADD (pops the top two items from the stack and pushes their sum)
- MUL (pops the top two items from the stack and pushes their product)
- NOP (no operation, don’t do anything)

For simplicity, all opcodes take a single argument, but only PUSH makes use of the argument. The rest of the instructions ignore the argument. The reason we supply arguments to opcodes that do not use them is so that we do not have to conditionally check if the argument is present or not, based on the opcode.

There is no STOP or RETURN opcode (the substitute is explained shortly). The VM takes a `steps` argument and returns whatever value is at the bottom of the stack after it executes `steps` many instructions.

The following animation gives a simple example of adding two numbers together in this architecture:

<video src="https://r2media.rareskills.io/ZKVM/zkvm.mp4" type="video/mp4" autoplay loop muted controls></video>

In Circom, loops cannot be of variable-length, they must always be executed for a fixed number of iterations, as the underlying Rank 1 Constraint System (R1CS) itself must be of fixed size. Similarly, programs cannot be of variable size. However, they must have the same number of opcodes regardless of the program run.

To run a program with fewer opcodes than the fixed number, we simply pad it with NOP until the program is of the maximum size. To know when to “stop executing,” the user must supply the above-mentioned `steps` argument to determine when the value at the bottom of the stack will be returned.

A couple of notes about our architecture:

- The VM is stack-based, like the EVM, Java Virtual Machine, or (for those who know) a [Reverse Polish Notation calculator](https://en.wikipedia.org/wiki/Reverse_Polish_notation).
- There are no jump instructions, so the program counter only increments.
- All opcodes take a single argument, but ADD, MUL, and NOP ignore the argument passed to them. That allows us to always increment the program counter by the same amount each time — we don’t have to update the program counter by 2 for a PUSH and 1 for an ADD and so on. We always move the counter up by 2.
- To read the argument of PUSH, we simply “look ahead” one index from the program counter.
- Addition and multiplication are done using modular arithmetic (the default in Circom). We use the order of Circom's default field as our “word size” — we don’t try to emulate VMs which have traditional word sizes like 64 bits or 256 bits. Emulating computation with bits of a fixed size is the subject of the following chapter.

## Updating Our Stack Code

We can make a few key changes to our stack code from the previous chapter to build a ZKVM that meets the spec described above.

- We removed the POP opcode since it is no longer needed.
- We add an ADD and MUL opcode.

Recall that the previous rules for copying the previous stack were:

- A. If the `sp` is 1 or greater, and column `j` is 1 index below `sp`, and the current instruction is PUSH or NOP, we should copy column `j`
- B. If the `sp` is 2 or greater, and column `j` is 2 indexes below `sp`, and the current instruction is POP, we should copy column `j`

Rule A remains unchanged, but B needs to be updated to the following:

- B. if the `sp` is 2 or greater, and column `j` is **3** indexes below `sp`, and the current instruction is ADD or MUL, we should copy column `j`

The reason for this change is that the previous POP instruction didn’t alter the second-to-top item on the stack, it only removed the top item. However, ADD effectively pops the stack twice and pushes the sum. Likewise, MUL pops the stack twice and pushes the product.

The previous stack implementation only wrote new values to the stack pointer. However, the new implementation can write the sum or product two indexes below the stack pointer. For example, the 12 in the stack below will become 15 after addition, and that location is two indexes below the stack pointer:

Before addition:

[12 , 3, sp] (sp = 3)

After addition:

[15, sp] (sp = 2)

Here, we have 12 as the bottom of the stack and `sp` pointing to the empty space above the stack.

Therefore, we need a signal to indicate that a particular column is two elements below the stack pointer.

The code below is heavily derived from the stack of the previous chapter, but it implements the updates described in this chapter. Specifically:

- We have replaced NOP, PUSH, and POP with NOP, PUSH, ADD, and MUL. ADD and MUL decrement the stack pointer by one, NOP keeps the stack pointer the same, and PUSH increases the stack pointer by one and copies its argument to the top of the stack.

```jsx
pragma circom 2.1.6;

include "circomlib/comparators.circom";
include "circomlib/gates.circom";

template AND3() {
  signal input in[3];
  signal output out;
  
  signal temp;
  temp <== in[0] * in[1];
  out <== temp * in[2];
}

// i is the column number
// bits is how many bits we need
// for the LessEqThan component
template ShouldCopy(i, bits) {
  signal input sp;
  signal input is_push;
  signal input is_nop;
  signal input is_add;
  signal input is_mul;
  
  // out = 1 if should copy
  signal output out;
  
  // sanity checks
  is_add + is_mul + is_push + is_nop === 1;
  is_nop * (1 - is_nop) === 0;
  is_push * (1 - is_push) === 0;
  is_add * (1 - is_add) === 0;
  is_mul * (1 - is_mul) === 0;
  
  // it's cheaper to compute ≠ 0 than > 0 to avoid
  // converting the number to binary
  signal spEqZero;
  signal spGteOne;
  spEqZero <== IsZero()(sp);
  spGteOne <== 1 - spEqZero;
  
  // it's cheaper to compute ≠ 0 and ≠ 1 than ≥ 2
  signal spEqOne;
  signal spGteTwo;
  spEqOne <== IsEqual()([sp, 1]);
  spGteTwo <== 1 - spEqOne * spEqZero;
  
  // the current column is 1 or more 
  // below the stack pointer
  signal oneBelowSp <== LessEqThan(bits)([i, sp - 1]);
  
  // the current column is 3 or more
  // below the stack pointer
  signal threeBelowSP <== LessEqThan(bits)([i, sp - 3]);
  
  // condition A
  component a3A = AND3();
  a3A.in[0] <== spGteOne;
  a3A.in[1] <== oneBelowSp;
  a3A.in[2] <== is_push + is_nop;
  
  // condition B
  component a3B = AND3();
  a3B.in[0] <== spGteTwo;
  a3B.in[1] <== threeBelowSP;
  a3B.in[2] <== is_add + is_mul;
  
  component or = OR();
  or.a <== a3A.out;
  or.b <== a3B.out;  
  out <== or.out;
}

template CopyStack(m) {
  var nBits = 4;
    signal output out[m];
    signal input sp;
    signal input is_add;
    signal input is_mul;
    signal input is_push;
    signal input is_nop;

    component ShouldCopys[m];
    signal copy[m];
    
    // loop over the columns
    for (var i = 0; i < m; i++) {
      ShouldCopys[i] = ShouldCopy(i, nBits);
      ShouldCopys[i].sp <== sp;
      ShouldCopys[i].is_add <== is_add;
      ShouldCopys[i].is_mul <== is_mul;
      ShouldCopys[i].is_push <== is_push;
      ShouldCopys[i].is_nop <== is_nop;
      out[i] <== ShouldCopys[i].out;
    }
}

// n is how many instructions we can handle
// since all the instructions might be push,
// our stack needs capacity of up to n
template ZKVM(n) {
  var NOP = 0;
  var PUSH = 1;
  var ADD = 2;
  var MUL = 3;

  signal input instr[2 * n];
  
  // we add one extra row for sp because
  // our algorithm always writes to the
  // next row and we don't want to conditionally
  // check for an array-out-of-bounds
  signal output sp[n + 1];

  signal output stack[n][n];

  var IS_NOP = 0;
  var IS_PUSH = 1;
  var IS_ADD = 2;
  var IS_MUL = 3;
  var ARG = 4;
  signal metaTable[n][5];

  // first instruction must be PUSH or NOP
  (instr[0] - PUSH) * (instr[0] - NOP) === 0;

  signal first_op_is_push;
  first_op_is_push <== IsEqual()([instr[0], PUSH]);

  // if the first op is NOP, we are forcing the first
  // value to be zero, but this is where the stack
  // pointer is, so it doesn't matter
  stack[0][0] <== first_op_is_push * instr[1];

  // initialize the rest of the first stack to be zero
  for (var i = 1; i < n; i++) {
    stack[0][i] <== 0;
  }

  // we fill out the 0th elements to avoid
  // uninitialzed signals
  sp[0] <== 0;
  sp[1] <== first_op_is_push;
  metaTable[0][IS_PUSH] <== first_op_is_push;
  metaTable[0][IS_NOP] <== 1 - first_op_is_push;
  metaTable[0][IS_ADD] <== 0;
  metaTable[0][IS_MUL] <== 0;
  metaTable[0][ARG] <== instr[1];

  // spBranch is what we add to the previous stack pointer
  // based on the opcode. Could be 1, 0, or -1 depending on the
  // opcode. Since the first opcode cannot be POP, -1 is not
  // an option here.
  var SAME = 0;
  var INC = 1;
  var DEC = 2;
  signal spBranch[n][3];
  spBranch[0][INC] <== first_op_is_push * 1;
  spBranch[0][SAME] <== (1 - first_op_is_push) * 0;
  spBranch[0][DEC] <== 0;

  // populate the metaTable and the stack pointer
  component EqPush[n];
  component EqNop[n];
  component EqAdd[n];
  component EqMul[n];

  component eqSP[n][n];
  signal eqSPAndIsPush[n][n];
  for (var i = 0; i < n; i++) {
    eqSPAndIsPush[0][i] <== 0;
  }

  // signals and components for copying
  component CopyStack[n];
  signal previousCellIfShouldCopy[n][n];
  for (var i = 0; i < n; i++) {
    previousCellIfShouldCopy[0][i] <== 0;
  }

  component eqSPMinus2[n][n];
  signal eqSPMinus2AndIsAdd[n][n];
  signal eqSPMinus2AndIsMul[n][n];
  for (var i = 0; i < n; i++) {
    eqSPMinus2AndIsAdd[0][i] <== 0;
    eqSPMinus2AndIsMul[0][i] <== 0;
  }

  // (the current column = sp - 2 and is_add) * sum
  signal eqSPMinus2AndIsAddWithValue[n][n];
  signal eqSPMinus2AndIsMulWithValue[n][n];

  signal sum_result[n][n];
  signal mul_result[n][n];
  for (var i = 0; i < n; i++) {
    eqSPMinus2AndIsAddWithValue[0][i] <== 0;
    eqSPMinus2AndIsMulWithValue[0][i] <== 0;
    sum_result[0][i] <== 0;
    mul_result[0][i] <== 0; 
  }

  for (var i = 1; i < n; i++) {
    // check which opcode we are executing
    EqPush[i] = IsEqual();
    EqPush[i].in[0] <== instr[2 * i];
    EqPush[i].in[1] <== PUSH;
    metaTable[i][IS_PUSH] <== EqPush[i].out;

    EqNop[i] = IsEqual();
    EqNop[i].in[0] <== instr[2 * i];
    EqNop[i].in[1] <== NOP;
    metaTable[i][IS_NOP] <== EqNop[i].out;

    EqAdd[i] = IsEqual();
    EqAdd[i].in[0] <== instr[2 * i];
    EqAdd[i].in[1] <== ADD;
    metaTable[i][IS_ADD] <== EqAdd[i].out;

    EqMul[i] = IsEqual();
    EqMul[i].in[0] <== instr[2 * i];
    EqMul[i].in[1] <== MUL;
    metaTable[i][IS_MUL] <== EqMul[i].out;

    // carry out the sums and muls
    for (var j = 0; j < n - 1; j++) {
      sum_result[i][j] <== stack[i - 1][j] + stack[i - 1][j + 1];
      mul_result[i][j] <== stack[i - 1][j] * stack[i - 1][j + 1];
    }

    // these values cannot be used in practice because
    // the stack doesn't go that high.
    // However, we still need to initialize
    // them because every column checks
    // if it is sp - 1, even the last 2
    for (var j = n - 1; j < n; j++) {
      sum_result[i][j] <== 0;
      mul_result[i][j] <== 0;
    }

    // get the instruction argument
    metaTable[i][ARG] <== instr[2 * i + 1];

    // if it is a push, write to the stack
    // if it is a copy, write to the stack
    CopyStack[i] = CopyStack(n);
    CopyStack[i].sp <== sp[i];
    CopyStack[i].is_push <== metaTable[i][IS_PUSH];
    CopyStack[i].is_nop <== metaTable[i][IS_NOP];
    CopyStack[i].is_add <== metaTable[i][IS_ADD];
    CopyStack[i].is_mul <== metaTable[i][IS_MUL];
    for (var j = 0; j < n; j++) {
      previousCellIfShouldCopy[i][j] <== CopyStack[i].out[j] * stack[i - 1][j];

      eqSP[i][j] = IsEqual();
      eqSP[i][j].in[0] <== j;
      eqSP[i][j].in[1] <== sp[i];
      eqSPAndIsPush[i][j] <== eqSP[i][j].out * metaTable[i][IS_PUSH];

      // check if the column is two less
      // than the stack pointer
      // if so, we prepare to write the sum or
      // product here
      // if the current instruction is add or mul
      eqSPMinus2[i][j] = IsEqual();
      eqSPMinus2[i][j].in[0] <== j;
      eqSPMinus2[i][j].in[1] <== sp[i] - 2; // underflow doesn't matter

      eqSPMinus2AndIsAdd[i][j] <== eqSPMinus2[i][j].out * metaTable[i][IS_ADD];
      eqSPMinus2AndIsMul[i][j] <== eqSPMinus2[i][j].out * metaTable[i][IS_MUL];

      eqSPMinus2AndIsAddWithValue[i][j] <== eqSPMinus2AndIsAdd[i][j] * sum_result[i][j];
      eqSPMinus2AndIsMulWithValue[i][j] <== eqSPMinus2AndIsMul[i][j] * mul_result[i][j];
      // we will either
      // - PUSH 
      // - COPY or implicilty assign 0
      // - ADD
      // - MUL
      stack[i][j] <== eqSPAndIsPush[i][j] * metaTable[i][ARG] + previousCellIfShouldCopy[i][j] + eqSPMinus2AndIsAddWithValue[i][j] + eqSPMinus2AndIsMulWithValue[i][j];
    }

    // write to the next row's stack pointer
    spBranch[i][INC] <== metaTable[i][IS_PUSH] * (sp[i] + 1);
    spBranch[i][SAME] <== metaTable[i][IS_NOP] * (sp[i]);
    spBranch[i][DEC] <== (metaTable[i][IS_ADD] + metaTable[i][IS_MUL]) * (sp[i] - 1);
    sp[i + 1] <== spBranch[i][INC] + spBranch[i][SAME] + spBranch[i][DEC];
  }
}

component main = ZKVM(5);

/* INPUT = {
    "instr": [1,3,1,6,1,2,3,0,3,0]
} */
```

## Isn’t it inefficient to have a constraint for every opcode if we only use one?

In our ZKVM, we conduct an addition and multiplication for every element in the stack, even though we actually use only one of them. This is not consequential for a very light operation like addition or multiplication. However, if we had an opcode for a heavy operation like hashing, this would generate significantly more constraints; we would have to populate a circuit for hashing for each item in the stack, even though only the top of the stack needs to be hashed. All this will result in unnecessary computations and high computational overhead.

We can improve the efficiency by using a Quin selector (or two) to determine which items on the stack will be inputs to the opcode, but this still means each iteration of the stack needs constraints for a hash even if it doesn’t use them.

*We leave it as an exercise for the reader to implement two Quin selectors to only add or multiply the top two items on the stack instead of the entire stack.*

This inefficiency of unnecessarily repeating unused constraints is a serious drawback of the vanilla R1CS, which does not allow for conditional use of constraints.

## Solutions to Improve Efficiency

Two modern approaches for dramatically improving the efficiency are constraints based on lookup tables and recursive proofs.

- A lookup table is an arithmetization scheme where only the constraints that are actually used are part of a table, and then the ZK proof proves that it used the correct entry from the table on each instruction.
- A recursive proof creates a separate ZK proof for each instruction and then combines the proof with another ZK proof that verifies that the input proofs are valid. (Consider that the verification algorithm in ZK can itself be modeled with an arithmetic circuit).

These improvements are the subject of later parts of the ZK book. However, the thought process behind modeling what a valid state transition looks like in a VM generalizes to modern day VMs.

## Learn more about about ZKVMs

The first proposal for a ZKVM was TinyRAM, proposed in a paper [Snarks for C: verifying Program Executions Succinctly and in Zero Knowledge](https://eprint.iacr.org/2013/507.pdf). The authors created, in their words “a minimalistic [RISC](https://en.wikipedia.org/wiki/Reduced_instruction_set_computer) random-access machine with a [Harvard architecture](https://en.wikipedia.org/wiki/Harvard_architecture) and word-addressable random-access memory.” The [TinyRAM specification](https://www.scipr-lab.org/doc/TinyRAM-spec-2.000.pdf) requires only 29 opcodes.

Since this paper spawned the research into ZKVMs, it is a high-impact paper worth understanding.

Most modern ZKVMs are based in the RISC-V architecture, but MIPS architecture ZKVMs exist also. ZK layer 2 blockchains often use their own custom architecture.

Ye Zhang’s [video](https://www.youtube.com/watch?v=vuQGdbpDWcs) on how Scroll created a ZKEVM is also fairly approachable for a high-level understanding.
