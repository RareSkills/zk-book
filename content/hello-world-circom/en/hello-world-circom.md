# Hello World Circom

## Introduction

This chapter shows the relationship between Circom code and the Rank 1 Constraint System (R1CS) it compiles to.

Understanding R1CSs is **critical** to understanding Circom, so be sure to brush up on [Rank 1 Constraint Systems](https://www.rareskills.io/post/rank-1-constraint-system) if you haven’t already.

To explain the workings of Circom, we will start with a few examples.

## **Example 1: Simple Multiplication**

Assume we are trying to create ZK proofs to assess if someone knows the product of two arbitrary numbers: `c = a * b`. 

 

Put another way, for some `a` and `b`, we are looking to **verify** that the user has computed the correct value for `c`. 

In pseudocode, the verification would be as follows (note, this is *not* Circom code):

```python
def someVerification(a, b, c):
  res = a * b 
  assert res == c, "invalid calculation"
```

Consequently, our R1CS would have just one constraint, namely the following:

```python
assert c == a * b
```

R1CS expresses such constraints in a structured matrix format. According to what we saw in the [chapter on R1CS](https://www.rareskills.io/post/rank-1-constraint-system), the witness vector $\mathbf{w}$ should be written as `[1, a, b, c]`, and the corresponding R1CS can be written as:

$$
\begin{bmatrix}
0&1&0&0\\
\end{bmatrix}\mathbf{w}
\circ
\begin{bmatrix}
0&0&1&0\\
\end{bmatrix}\mathbf{w}
=
\begin{bmatrix}
0&0&0&1\\
\end{bmatrix}\mathbf{w}
$$

If a = 3, b = 4, and c = 12, the operation above would be:

$$
\begin{bmatrix}
0&1&0&0\\
\end{bmatrix}
\begin{bmatrix}
1\\
3\\
4\\
12\\
\end{bmatrix}
\circ
\begin{bmatrix}
0&0&1&0\\
\end{bmatrix}\begin{bmatrix}
1\\
3\\
4\\
12\\
\end{bmatrix}
=
\begin{bmatrix}
0&0&0&1\\
\end{bmatrix}\begin{bmatrix}
1\\
3\\
4\\
12\\
\end{bmatrix}
$$

This is how we would write the above constraint in Circom:

```jsx
template SomeCircuit() {
  // inputs
  signal input a;
  signal input b;
  signal input c;
  
  // constraints 
  c === a * b;
}

component main = SomeCircuit();
```

- Given inputs `a`, `b`, `c`, the circuit verifies that `a * b` is indeed equal to `c`.
- The circuit serves to verify, **not** to compute. This is why `c` (the output of the calculation) is also one of the required inputs.
- The `===` operator defines the constraint as previously expressed in R1CS form. `===` behaves like an assertion, so the circuit will not be satisfied if invalid inputs are supplied. In the code above, `c === a * b` constrains `c` to have a value equal to the product of `a` and `b`.

## zkRepl, an online IDE for Circom

For quick experiments, [zkRepl](https://zkrepl.dev) is fantastic and convenient tool.

We can conveniently test the code above in zkRepl by supplying the inputs as a comment:

![zkRepl showing the Circom compiler output](https://r2media.rareskills.io/HelloWorldCircom/OneConstraint.png)

***Note:** The input is supplied as a JSON object in a comment when using zkrepl. To test if the code compiles an the input satisfies the circuit, use shift-enter.*

The “non-linear constraints” equals 1 (see the red box) because the underlying R1CS has one row constraint with a multiplication between two signals. This is to be expected since we have a single `===`.

### **`template` , `component` , `main`**

- **Templates** define a blueprint for circuits, like a class defines the structure for objects in OOP (Object Oriented Programming).
- A **component** is an instantiation of a template, similar to how an object is an instance of a class in Object Oriented Programming.

```jsx
// create template
template SomeCircuit() {
  // .... stuff
}

// instantiate template 
component main = SomeCircuit();
```

`component main = SomeCircuit()` is needed because Circom requires a single top-level component, `main`, to define the circuit structure that will be compiled.

### `signal input`

- Signal inputs are values that will be provided from outside the component. (Circom does not enforce a value is actually provided — it is up to the developer to ensure that the values are actually supplied. If they aren’t, this can lead to a security vulnerability — this will be explored in a later chapter.)
- Input signals are immutable and cannot be altered.
- Signals are exactly the variables in a Rank 1 Constraint System witness vector.

## The Finite Field of Circom

Circom performs arithmetic in a [finite field](https://www.rareskills.io/post/finite-fields) with an order of `21888242871839275222246405745257275088548364400416034343698204186575808495617`, which we will simply call $p$. It is a **254-bit number**, corresponding to the curve order of the bn128 elliptic curve. This curve is widely used, in particular it's the one made available via precompiles in the EVM. Since Circom was intended to be used for developing ZK-SNARK applications on Ethereum, it makes sense to make the field size match the curve order of the bn128 curve.

Circom allows the default order to be changed via command-line argument.

The following should be obvious to the reader:

- `p` under `mod p` is congruent to `0`;
- `p-1` is the largest integer in the [finite field](https://www.rareskills.io/post/finite-field) `mod p.`
- Passing values that are larger than `p-1` will result in overflow.

## Example 2: BinaryXY

Let’s look at a second example to conclude this section. 

Consider a circuit that verifies whether the values passed to it are binary, i.e., `0` or `1`.

If the input variables are `x` and `y`, the system of constraints would be:

```jsx
(1):  x * (x - 1) === 0
(2):  y * (y - 1) === 0
```

*Recall that, by definition, every constraint in an R1CS can have at most one multiplication between variables.*

***x*(x-1) === 0 checks if x is a binary digit***

- *There are only 2 roots for this polynomial expression.*
- *I.e., x = 0 or x = 1.*

**Expressed in Circom**

```jsx
template IsBinary() {
	
  signal input x;
  signal input y;
  
  x * (x - 1) === 0;
  y * (y - 1) === 0;
}

component main = IsBinary();
```

### **Alternative Expression: Using Arrays**

In Circom, we have the option to declare our inputs as separate signals or to declare an array which contains all the inputs. It is more conventional in Circom to group all the inputs into an ***array*** of signals called `in` instead of providing separate inputs `x` and `y`.

Following the convention, we will represent the earlier circuit as follows. Arrays are indexed starting at zero, as you would normally expect:

```jsx
template IsBinary() {

  // array of 2 input signals
  signal input in[2];
  
  in[0] * (in[0] - 1) === 0;
  in[1] * (in[1] - 1) === 0;
}

// instantiate template 
component main = IsBinary();
```

## Only witnesses that satisfy the constraints are accepted

Circom can only generate a proof for an input that actually satisfies the circuit. In the following circuit (copied from the code directly above), we supply `[0, 2]` as an input that only accepts {0,1} for any element of the array.

For 0, we have `0 * (0 - 1) === 0`, which is ok. However, for `2 * (2-1) === 2`, we have a constraint violation as indicated in the red box in the figure below.

![zkRepl showing the Circom constraints are not satisfied](https://r2media.rareskills.io/HelloWorldCircom/IsBinaryViolation.png)

# Circom in the command line

This section introduces common Circom commands. We assume the reader has already installed Circom and the required dependencies.

Create a new directory and add a file called `somecircuit.circom` inside with the following code:

```jsx
pragma circom 2.1.8;

template SomeCircuit() {
  // inputs
  signal input a;
  signal input b;
  signal input c;
  
  // constraints 
  c  === a * b;
}

component main = SomeCircuit();
```

## 1. Compiling Circuits

In the terminal, execute the following command to compile:

```bash
circom somecircuit.circom --r1cs --sym --wasm
```

- The `--r1cs` flag means to output an r1cs file, the `--sym` flag gives the variables a human-readable name (more info can be found in the [sym docs](https://docs.circom.io/circom-language/formats/sym/)), and `--wasm` is for generating wasm code to populate the witness of the R1CS, given an input JSON (shown in a later section).
- Interchange the name of the circuit `somecircuit.circom` to be compiled as needed.

This is the expected output:

![circom command line result](https://r2media.rareskills.io/HelloWorldCircom/CircomSomeCircuitCMDLine.png)

- Observe that non-linear constraints are listed as 1, indicative of `a * b === c`.
- Wires is the number of columns in the R1CS. In this example, we have a constant column and three signals `a`, `b`, `c`.

The compiler creates the following:

- `somecircuit.r1cs` file
- `somecircuit.sym` file
- `somecircuit_js` directory

### **.r1cs File**

- This file contains the circuit’s R1CS system of constraints in binary format.
- Can be used with different tool stacks to construct proving/verifying statements (e.g. snarkjs, libsnark).

Note that R1CS files are sort of like binary, in the sense that running `cat <file>` will give you gibberish. 

Running `snarkjs r1cs print somecircuit.r1cs`, we get the following human-readable output:

```
[INFO]  snarkJS: [ 21888242871839275222246405745257275088548364400416034343698204186575808495616main.a ] * [ main.b ] - [ 21888242871839275222246405745257275088548364400416034343698204186575808495616main.c ] = 0
```

In Circom, arithmetic operations are conducted within a finite field, so `21888242871839275222246405745257275088548364400416034343698204186575808495616` is actually representative of `-1`. In the R1CS file however, the constraint operator is `=` instead of `==` or `===`.

We can confirm this by checking `-1 mod p`, (in Python: `-1 % p`), where `p` is the order of Circom’s finite field. If we translate the large values that `snarkjs r1cs print somecircuit.r1cs` printed to negative numbers, we get:

```solidity
[-1 * main.a] * [main.b] - [-1 * main.c] = 0
```

We will now convert the expression above into the more familiar `a * b === c`. The algebra is shown next:

```
[-1 * main.a] * [main.b] - [-1 * main.c] = 0

    [-main.a] * [main.b] - [-main.c] = 0 // distribute -1
   
     [main.a] * [main.b] + [-main.c] = 0 // multiply both sides by -1
    
     [main.a] * [main.b] = [main.c] // move -main.c to the other side
```

Again, observe that this matches with the constraint (`a * b === c`) described in  `somecircuit.circom`. 

### .sym File

The `somecircuit.sym` file is a **symbols file** generated during compilation. This file is essential because:

- It maps human-readable variable names to their corresponding positions in the R1CS for debugging.
- It helps in printing the constraint system in a more understandable format, making it easier to verify and debug your circuit.

### somecircuit_js Directory

The `somecircuit_js`  directory contains artifacts for witness generation:

- `somecircuit.wasm`
- `generate_witness.js`
- `witness_calculator.js`

The `generate_witness.js` file is what we will use in the next section, the other two files are helpers for `generate_witness.js`.

By supplying input values for the circuit, these artifacts will calculate the necessary intermediate values and create a witness that can be used to generate a ZK proof.

## 2. Calculating the Witness

To generate the witness, we must supply the public input values for the circuit. We do this by creating an `inputs.json` file in the `somecircuit_js` directory.

Say we want to create a witness for input values `a=1`, `b=2`, `c=2`. The JSON file would be like so:

```json
{"a": "1","b": "2","c": "2"}
```

Circom expects strings instead of numbers because JavaScript does not work accurately with integers larger than $2^{53}$ ([source](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER)).

Run this command in the `somecircuit_js` directory: 

```bash
node generate_witness.js **somecircuit.wasm** inputs.json witness.wtns
```

The output is the computed witness as a `witness.wtns` file.

<aside>
💡

If we had passed values that did not honor the constraint, `a*b === c`, e.g. `a=1`, `b=2`, `c=3`, `witness_calculator.js` would throw an error. 

</aside>

### **Examine The Computed Witness: witness.wtns**

If you run `cat witness.wtns`, the output is gibberish.

![witness file cat to terminal](https://r2media.rareskills.io/HelloWorldCircom/BinaryFile.png)

This is because `witness.wtns` is a binary file in a format accepted by snarkjs.

To get the human-readable form, we export it to JSON via: `snarkjs wtns export json witness.wtns`. We then view the JSON using `cat witness.json`:

![witness json cat to terminal](https://r2media.rareskills.io/HelloWorldCircom/Witness.png)

- The first `1` is the constant portion of the witness, which is always `1`. We have that `a = 1`, `b = 2`, and `c = 2` since our input JSON was `{"a": "1","b": "2","c": "2"}`.
- snarkjs ingests the `witness.wtns` file to output `witness.json`.
- The computed witness adheres to the R1CS layout of the witness vector: `[1, a, b, c]` = `[1, 1, 2, 2]`

## Example: isbinary.circom

Let’s run through a less trivial example: `isbinary.circom`. The form of the constraints should be familiar to the reader (recall example 2).

```javascript
template IsBinary() {

  // array of 2 input signals
  signal input in[2];
  
  in[0] * (in[0] - 1) === 0;
  in[1] * (in[1] - 1) === 0;
}

// instantiate template 
component main = IsBinary();
```

### **Compile Circuit**

- **`circom isbinary.circom --r1cs --sym --wasm`**
- Sanity check on terminal output: `non-linear constraints: 2`

![checking the number of r1cs constraints in the terminal](https://r2media.rareskills.io/HelloWorldCircom/NonLinearConstraints.png)

This makes sense, as our circuit contains two assertions, each involving a multiplication of signals.

Next we examine the R1CS file:  The command `snarkjs r1cs print isbinary.r1cs` results in the following output:

```
[INFO]  snarkJS: [ 218882428718392752222464057452572750885483644004160343436982041865758084956161 +main.in[0] ] * [ main.in[0] ] - [  ] = 0
[INFO]  snarkJS: [ 218882428718392752222464057452572750885483644004160343436982041865758084956161 +main.in[1] ] * [ main.in[1] ] - [  ] = 0
```

Notice that this large number is slightly different from the **-1 mod p** coefficient highlighted earlier (I.e.:`21888242871839275222246405745257275088548364400416034343698204186575808495616`)

Observe the additional digit, `1`, at the end:

- `21888242871839275222246405745257275088548364400416034343698204186575808495616`
- `21888242871839275222246405745257275088548364400416034343698204186575808495616(1)`

**The reason there is a `1` at the end is due to a flaw in how snarkjs formats the output. It is “trying” to say -1 * 1 but has no space between them.**

We will now algebraically transform the output of snarkjs to the original constraints of:

```bash
(in[0] - 1) * in[0] === 0
(in[1] - 1) * in[0] === 0
```

The derivation is as follows:

```
// original circom output
[ 218882428718392752222464057452572750885483644004160343436982041865758084956161 +main.in[0] ] * [ main.in[0] ] - [  ] = 0
[ 218882428718392752222464057452572750885483644004160343436982041865758084956161 +main.in[1] ] * [ main.in[1] ] - [  ] = 0

// remove empty terms
[ (21888242871839275222246405745257275088548364400416034343698204186575808495616)1 +main.in[0] ] * [ main.in[0] ] = 0
[ (21888242871839275222246405745257275088548364400416034343698204186575808495616)1 +main.in[1] ] * [ main.in[1] ] = 0

// rewrite p - 1 as -1
[ (-1)1 +main.in[0] ] * [ main.in[0] ] = 0
[ (-1)1 +main.in[1] ] * [ main.in[1] ] = 0

// simplify
[ main.in[0] - 1] * [ main.in[0] ] = 0
[ main.in[1] - 1] * [ main.in[1] ] = 0
```

### **Generating The Witness**

- Create an `inputs.json` file in the `./isbinary_js` directory.
- We will opt to pass values `in[0] = 1`, `in[1] = 0`.
- We will use the following for `inputs.json`.

```javascript
{"in": ["1","0"]}
```

- Generate `witness.wtns`: `node generate_witness.js isbinary.wasm inputs.json witness.wtns` (in the `isbinary_js` directory)
- Now that `witness.wtns` has been created, export it to JSON, so we can examine it:
`snarkjs wtns export json witness.wtns`
- We would get the following output on executing `cat witness.json`:

```javascript
[
 "1",  // 1
 "1",  // in[0] 
 "0"   // in[1] 
]
```

- The computed signal matches the R1CS layout of the witness vector, `[1, in[0], in[1]]`, as do their respective values.

## Generating a ZK Proof

Once the R1CS has been created, the reader can follow the steps in the [Circom documentation to generate the ZK Proof](https://docs.circom.io/getting-started/proving-circuits/) and an accompanying smart contract verifier.

## Practice Problems

Test your understanding/learning from this chapter by solving these puzzles from our ZK Puzzles repo. Each puzzle requires you to fill in the missing logic. You can check your answers simply by running the unit tests.

- [https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/BinaryXY/BinaryXY.circom](https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/BinaryXY/BinaryXY.circom)
- [https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/MultiplyNoOut/MultiplyNoOut.circom](https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/MultiplyNoOut/MultiplyNoOut.circom)
- [https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/FourBitBinary/FourBitBinary.circom](https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/FourBitBinary/FourBitBinary.circom)
