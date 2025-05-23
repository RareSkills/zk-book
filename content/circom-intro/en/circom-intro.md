# Introduction to ZK Circuits with Circom

Circom is a programming language for creating Rank 1 Constraint Systems (R1CS) and populating the witness vector of the R1CS.

The R1CS format is of interest because of the utility of that format for constructing SNARKs, particularly [Groth16](https://www.rareskills.io/post/groth16). With SNARKs, we enable verifiable computation, allowing us to prove the correctness of a computation. When verifying, the interested party expends less computational effort to confirm the correctness than they would need to perform the computation themselves. It is also possible to generate the proof without revealing the underlying data, and in this case, we refer to it as zkSNARKs.

The first part of our ZK book focused on proving a witness's validity for a given R1CS. This resource focuses on how to programmatically generate an R1CS and how to design them to model realistic algorithms such as a virtual machine or cryptographic hash functions.

## Prerequisites

We expect the reader to already be familiar with the following chapters from our ZK Book:

- [https://rareskills.io/post/p-vs-np](https://rareskills.io/post/p-vs-np)
- [https://rareskills.io/post/arithmetic-circuit](https://rareskills.io/post/arithmetic-circuit)
- [https://rareskills.io/post/finite-fields](https://rareskills.io/post/finite-fields)
- [https://rareskills.io/post/rank-1-constraint-system](https://rareskills.io/post/rank-1-constraint-system)

We are going to assume the reader knows what an R1CS is and what it represents. This is fully explained in the four chapters above.

It is not necessary to fully understand the math behind ZK to use Circom, but there are some principles that must be fully grasped, or Circom will not make sense.

Nonetheless, if the reader is serious about having a career in ZK, learning the foundations of ZK is essential. For that, we highly recommend reading through the first two sections of the [ZK book](rareskills.io/zk-book) and building the Groth16 proof system from scratch to enforce learning.

However, if the reader’s objective is to quickly understand ZK applications, then we recommend reading the four chapters listed above and then using this resource.

## Why Circom Exists

Circom was created to address two major issues in developing constraint systems for SNARKs.

1. Manually designing constraint systems is tedious and error-prone, especially when dealing with large-scale or repetitive constraints.
2. Populating the witness is equally challenging and requires manual computation of intermediary values that could otherwise be derived programmatically.

Thus, Circom 1) simplifies constraint design and 2) automates witness population.

### 1. Designing the constraint system is tedious

The tasks of manually designing a set of (correct) constraints and then translating them into R1CS are tedious and error-prone. Circom was created to make this task less challenging and tedious by programmatically generating the constraints.

For example, to say the value `x` can only have the values $\set{1,2,3}$, we can express that with the constraint

$$
0 === (x - 1) (x - 2) (x - 3)
$$

However, a R1CS can only have one non-constant multiplication per constraint, so we must break up the above constraint into two constraints:

$$
\begin{align*}
s &=== (x - 1)(x - 2) &&= x * x - 3 * x + 2\\
0 &=== s(x - 3) &&= x * s - 3 * s
\end{align*}
$$

For small systems, this manual translation is manageable. However, it would be extremely annoying to do it by hand if we needed to create this constraint for 100 or even 1000 variables. If we have thousands of very similar constraints, it would be preferable to create a "template" for the constraints and generate the constraints in a for loop. Circom allows us to create these constraints programmatically. 

For example, suppose we wanted to constrain 1,000 variables to have the values $\set{0,1}$. Circom can generate these values in a loop as follows:

```solidity
template Constrain1000Example() {
  signal input in[1000];
  
  for (var i = 0; i < 1000; i++) {
    0 === in[i] * (in[i] - 1);
  }
}

component main = Constrain1000Example();
```

We will explain the syntax further in later chapters, but the core idea is that we defined a constraint `0 === in[i] * (in[i] - 1)` and repeated it 1000 times.

### 2. Populating the witness is tedious

The witness in the context of ZK is an assignment to the variables that satisfies all the constraints in an arithmetic circuit.

As we saw in the article on [arithmetic circuits](https://www.rareskills.io/post/arithmetic-circuit), proving one number is less than another number requires converting both of the numbers to binary, as “greater than” is not meaningful in a finite field since the numbers wrap around.

Expressing the number $x$ in binary, assuming it fits in four bits, requires $x$ to satisfy the following constraints:

$$
\begin{align*}
x&===b_0+2b_1+4b_2+8b_3\\
0&===b_0(b_0 - 1)\\
0&===b_1(b_1 - 1)\\
0&===b_2(b_2 - 1)\\
0&===b_3(b_3 - 1)
\end{align*}
$$

Here, $b_0$ is the least significant bit, and $b_3$ is the most significant bit. The prover must supply $b_0, b_1, b_2, b_3$, which are the binary bits of $x$, along with $x$ itself. 

In this case, proving that $x$ is a four-bit number has become five times more tedious because, in addition to $x$, we also have to provide the binary values of  $x$, even though they can be derived deterministically and straightforwardly. Circom automates this process and allows us to write code to populate variables in the witness based on other variables. For example, to populate the binary variables, we could write the following Circom code (the following code lacks some necessary safety features — please do not copy it blindly):

```jsx
b_0 <-- x & 1;        // get the first bit of x via bitmask
b_1 <-- (x >> 1) & 1; // get the second bit of x
b_2 <-- (x >> 2) & 1; // get the third bit of x
b_3 <-- (x >> 3) & 1; // get the fourth bit of x
```

The code above *generates* the witness but does not create the constraints in our formula:

$$
\begin{align*}
x&===b_0+2b_1+4b_2+8b_3\\
0&===b_0(b_0 - 1)\\
0&===b_1(b_1 - 1)\\
0&===b_2(b_2 - 1)\\
0&===b_3(b_3 - 1)
\end{align*}
$$

The above circuit translated to Circom would be (the syntax will be explained more later):

```jsx
template BinaryConstraint() {

  // assign the values to b_0,...,b_3
  x === b_0 + 2*b_1 + 4*b_2 + 8*b_3;
  0 === b_0*(b_0 - 1);
  0 === b_1*(b_1 - 1);
  0 === b_2*(b_2 - 1);
  0 === b_3*(b_3 - 1);
}
```

One major convenience of Circom is that its code resembles mathematics in arithmetic circuits, so it is easy to translate a system of equations to Circom.

The idea is instead of supplying $(x,b_0,b_1,b_2,b_3)$ to the circuit, we only supply $x$. Circom will compute the binary values for us and then fill out the constraints with the computed values.

In addition to automating constraint generation, Circom improves the process of populating the witness through its  "assign and constrain" operator, `<==`.

## The advantage of `<==` assign and constrain in Circom

Circom further simplifies the witness population through its "assign and constrain" operator `<==`. Suppose we have the constraint:

```bash
z === x * y
```

If we supply the values for `x` and `y`, it would be a bit annoying to also have to supply the value for `z` because `z` only has one possible solution.
With Circom, we use `<==` as follows:

```bash
z <== x * y
```

With this, the variable `z` no longer needs to be provided as an input as Circom populates it for us, and its value will be locked into $x\cdot y$ for the rest of the circuit.

Hence, Circom saves a user from the hassle of explicitly providing a value for every element in the witness, which is a major selling point for Circom’s convenience.

## Circom is both a DSL and a programming language

The biggest source of confusion when programming in Circom is that it is both a programming language (similar to Javascript) and a DSL that compiles to an R1CS. In that sense, it is a bit like Solidity. Solidity can affect the underlying blockchain state by transferring Ether, but it can also behave like a regular programming language. The “programming language” portion of Circom is to aid with automatic witness population as described earlier. However, to the newcomer, it is not always clear which parts of Circom affect the underlying R1CS.

For example, the following is a valid Circom code that computes the power of a number:

```jsx
function power(base, exp) {
  return base ** exp;
}

template Power() {
  signal input base;
  signal input exp;
  signal output out;

  out <-- power(base, exp);
}

component main = Power();

/* INPUT = {
  "base": "3",
  "exp": "2"
} */
```

However, the code above does not generate any constraints (so it wouldn't be useful for proving anything). As we will learn later, the `<--` operator has the sole purpose of generating the witness, not generating the constraints.

## Why Learn Circom

As one of the oldest Domain-Specific Languages (DSLs) for ZK, Circom has the most available **libraries** and **projects** that you can learn from and is **battle-tested**.

We think that learning the more modern ZK DSLs, such as [Halo2](https://github.com/privacy-scaling-explorations/halo2) and [Plonky3](https://github.com/Plonky3/Plonky3) will be much easier if we teach Circom first, so we're doing that.

To see why, here is the code for computing the [Fibonacci sequence in Halo2](https://github.com/Divide-By-0/halo2-examples/blob/master/src/fibonacci/example1.rs) and the code for computing [Fibonacci in Plonky3](https://github.com/BrianSeong99/Plonky3_Fibonacci/blob/master/src/main.rs). A cursory look at the examples should convince the reader that those DSLs might not be the best place to start for a beginner. Here is the Circom code to prove that `out` is the correct n-th Fibonnaci number. It is much easier to understand by comparison:

```jsx
pragma circom 2.1.6;

// proves `out` is the nth
// fibonnaci number
template Fibonacci(n) {
  var offset = n + 1;
  assert(n > 2);
  
  signal fib[offset];
  signal output out;
  
  fib[0] <== 0;
  fib[1] <== 1;
  
  for (var i = 2; i < offset; i++) {
    fib[i] <== fib[i-1] + fib[i - 2];
  }
  
  out <== fib[n];
}

// 5th fibonnaci number is 5
// 0 1 1 2 3 5
component main = Fibonacci(5);
```

In contrast, Circom has a relatively simple learning curve for beginners diving into ZK development.

## Don’t Noir, Cairo, and Leo abstract away the need to learn constraint writing?

You can write smart contracts on ZK blockchains or layer 2s using Rust-like languages, such as Noir, Cairo, and Leo, that are designed to “hide” the constraint generation from the programmer. If your goal is simply to write applications for these blockchains,  learning how ZK constraints work under the hood is not strictly necessary.

However, consider that every serious Solidity programmer has a decent grasp of how the Ethereum Virtual Machine (EVM) works and can write basic assembly. Knowing what is happening behind the scenes will help you write more efficient code, and this resource accomplishes that goal.

Additionally, there are many bugs that rise up in these execution environments due to the underlying ZK execution model. Understanding what is actually private, what limitations may exist on control flow, common errors when using fields, or gaining the ability to safely use unconstrained functions in Noir or custom constraints in [o1js](https://docs.minaprotocol.com/zkapps/o1js) all require a low-level understanding.

### The goal of this series

Nonetheless, high-level ZK languages do not make constraint writing obsolete — in fact — they increase the demand for experts who truly understand how they work. The purpose of this resource is to onboard more advanced developers and security auditors to be able to develop and secure the underlying blockchain, virtual machine, and compiler environments that these high-level ZK languages use.

## How this resource is structured

This resource is divided into two main parts:

1) The first part teaches the syntax of Circom. Specifically, we teach how to write constraints and program Circom to populate most of the witness values for us.

2) The second part of this resource teaches how to design constraints for ZK applications in general. We'll use Circom for the examples, but the content applies to other ZK DSLs, such as Halo2 or Plonky3.

We will also touch on security issues in ZK applications throughout the content.

## Learning comes not only with study but with practice

Many of the chapters include explicit exercises or some unfinished code that is “left as an exercise for the reader”. **Your learning journey will be far more effective if you solve those problems**. We designed those problems to serve as a review of what you just read to enforce the learning. They do not require any special “insight” or “cleverness” to solve if you correctly understand the written resource. Our hope is that the exercises at the end will feel somewhat “obvious” after reading the material (if not, please raise an issue or open a pull request in the exercises’ repository!)

## Installing Circom

The instructions for installing Circom are here: [https://docs.circom.io/getting-started/installation/#installing-dependencies](https://docs.circom.io/getting-started/installation/#installing-dependencies)

There is also an online IDE for Circom here: [https://zkrepl.dev/](https://zkrepl.dev/)

## Addendum: Plonk vs Groth16 for Circom

For readers familiar with the Plonk proving system, it’s worth noting that we write the same circuit for both Plonk prover systems and the Groth16 prover system.

Groth16 allows an unlimited number of addition operations per constraint but only one non-constant multiplication (consider that a Rank 1 Constraint System has one multiplication per row). In contrast, Plonk only allows one multiplication or one addition per constraint, and not both. The one-multiplication-per-constraint limitation will become apparent as we explore Circom.

However, Circom circuits that are compatible with Groth16 will also work with Plonk. The snarkjs library that uses Rank 1 Constraints Systems as an input translates it to a Plonk constraint system if the developer so wishes.

Circom is, therefore, agnostic to whether the intended underlying proof system is Groth16 or Plonk. As long as the circuit is compatible with Groth16, it can also be compatible with Plonk with no additional changes from the developer.

## Authorship and Credits

Calnix wrote the first part of this book and significantly influenced its overall structure. Please [follow Calnix on X](https://x.com/cal_nix) and maybe drop a thank you.

We are grateful to [Veridise](https://veridise.com), [Privacy Scaling Explorations](https://pse.dev/en), Marco Besier from [zkSecurity](https://www.zksecurity.xyz), and [Chainlight](https://chainlight.io) for their helpful reviews of this work.