# Circom Template Parameters, Variables, Loops, If Statements, Assert

This chapter covers essential syntax, which you'll see in most Circom programs. With Circom, we're able to define a Rank 1 Constraint System (R1CS) using code instead of explicitly defining each constraint. We'll explore those tools in this chapter.

## **Template Parameters**

Previously, we looked at a circuit (`IsBinary`) that verified whether the supplied inputs were indeed binary. That circuit was hardcoded to accept only 2 inputs. 

```jsx
template IsBinary() {

  signal input in[2];

  in[0] * (in[0] - 1) === 0;
  in[1] * (in[1] - 1) === 0;
}

component main = IsBinary();
```

While the above code works for two inputs, modifying it to support large `n` inputs would require manually adding constraints, which is a bad developer experience.

Therefore, Circom allows us to constrain an arbitrary number of signals using the following pattern to automatically generate the constraints:

```jsx
template IsBinary(n) {

  // array of n inputs
  signal input in[n];
    
  // n loops: n constraints
  for (var i = 0; i < n; i++) {
    in[i] * (in[i] - 1) === 0;
  }
}

// instantiated w/ 4 inputs & 4 constraints
component main = IsBinary(4);
```

Notice that the template declaration has changed to include `n` in the parenthesis. 

- `n` here is known as a template parameter
- `n` is used within the circuit to specify the size of the array `in`
- on instantiating the template, we must specify the value of `n`

## Circuits and constraints in Circom must have a fixed, known structure

Although constraints can be generated programmatically, **the existence and configuration of constraints cannot conditionally depend on signals.**

While templates can use parameters, the circuit must be static and clearly defined. There is no support for "dynamic-length" circuits or constraints — everything must be fixed and well-defined from the start.

Imagine having an R1CS system of constraints whose structure was mutable based on input signal values. Neither the prover nor the verifier could operate as the number of constraints is not set in stone.

The value for `n` must be set at compile time.

## For loop and Variables: `for`, `var`

We now explain the `for` loop introduced above.

```jsx
template IsBinary(n) {

  // array of n inputs
  signal input in[n];
    
  // n loops: n constraints
  for (var i = 0; i < n; i++) {
    in[i] * (in[i] - 1) === 0;
  }
}

// instantiated with 4 inputs & 4 constraints
component main = IsBinary(4);
```

- both inputs and loop iterations are defined by `n`
- for each input, a constraint is defined with the purpose of verifying that the input is either `0` or `1`

We have introduced two new keywords into the circuit: `for` and `var`

- `for` works like you're used to.
- The `var` keyword  declares a **variable**; in this case, `i`, as seen in the loop definition.
- The equal symbol `=` assigns the value on the right to the variable on the left.

Here, the variable `i` is used to programmatically refer to different signals in the input array while creating constraints for them. Being able to programmatically generate constraints is extremely useful, as doing this by hand when hundreds or thousands of constraints are involved would be extremely error-prone.

### Variables

Variables hold non-signal data and are mutable. Here is an example of a variable declaration outside of a loop:

```jsx
template VariableExample(n) {
  var acc = 2;
  signal s;
}
```

- By default, variables are **not** part of the R1CS system of constraints.
    - We will shortly see that variables can be used as additive or multiplicative constants inside the R1CS.
- Variables are used to compute values outside the R1CS to help define the R1CS.
- When working with variables, Circom behaves like a normal programming language.
- Math operations are done modulo `p`. The full list of operators is provided in the [Circom documentation here](https://docs.circom.io/circom-language/basic-operators/#arithmetic-operators). These will feel familiar coming from a C-like language (e.g. `++`, `**`, `<=`, etc). However, keep in mind that `/` means multiplication with the multiplicative inverse, and `\` means integer division.
- However, the only valid operators for signals are `+`, `*`, `===`, `<--`, and `<==`. We will discuss `<--` and `<==` in a later article.

## If statements

Circom allows us to conditionally create constraints using `if` statements — but these conditions must be deterministic and known at compile time. An example is shown next:

### Example: Enforcing Equality on the Even Indexes

Suppose we have two arrays. We could use the following template to generate constraints which enforce that the items at even indices are equal (without checking the odds)

```jsx
template EqualOnEven(n) {
  signal input in1[n];
  signal input in2[n];
  
  for (var i = 0; i < n; i++) {
    if (i % 2 == 0) {
      in1[i] === in2[i];
    }
    // otherwise no constraint is generated
  }
}
```

Note that the variable `i` dictates which constraints get generated.

### Signals cannot be used for branching conditions in if statements or for loops

The following code is not allowed because signal `a` is used as the conditional for the `if` statement:

```jsx
template IfStatementViolation() {
  signal input a;
  signal input b;
  
  if (a == 2) {
    b === 3;
  }
  else {
    b === 4;
  }
}
```

In a Rank 1 Constraint System, there can only be addition and multiplication between signals. Circom is only a thin wrapper on top of a Rank 1 Constraint System. Therefore, it cannot “translate” an if statement to addition and multiplication.

It is still possible to do a conditional operation (if statement) based on signals in Circom — this is the subject of a later chapter. But for now, consider that there is no “direct” translation from an `if` statement to a single multiplication.

### Using Variables as Part of Constraints

Variables can be used as part of constraints. In the example below, we enforce that the input array `in[n]` is a Fibonacci sequence. Note that a variable array syntax is `var varName[size]`:

```jsx
template IsFib(n) {
  assert(n > 1);
  
  signal input in[n];
  
  // generate the Fibonacci sequence
  var correctFibo[n];
  correctFibo[0] = 0;
  correctFibo[1] = 1;

  for (var i = 2; i < n; i++) {
    correctFibo[i] = correctFibo[i - 1] + correctFibo[i - 2];
  }
  

  // assert that the input is a Fibonacci sequence
  for (var i = 0; i < n; i++) {
    in[i] === correctFibo[i];
  }
}
```

Of note:

- The `assert(n > 1)` does not generate any constraints. It prevents the template from getting instantiated if the condition for the template parameter is not met.
- We can enforce that a signal has a certain value by doing `signal === var`. This is the same as doing `signal === 5` or some other constant.

### Circom Does Not Have a Constant Keyword

Instead, we can use variables to assign a name to a magic number to improve readability. For example:

```jsx
template Equality() {
  signal input in[2];
  
  var left = 0;
  var right = 1;
  
  // require the inputs
  // to be equal
  in[left] === in[right];
}
```

## Variables Can Be Added to and Multiplied by Other Signals

In Circom, variables can be added to or multiplied by signals, just like constants. In the example below, we require that `in2[]` is `in1[]` multiplied by its index.

For example, if `in1[] = [3,5,6]` then it must be the case that `in2[] = [0,5,12]` because `[3,5,6]` gets element-wise multiplied by `[0,1,2]`.

```jsx
template IsIndexMultiplied(n) {
  signal input in1[n];
  signal input in2[n];
  
  for (var i = 0; i < n; i++) {
    in1[i] * i === in2[i];
  }
}

component main = IsIndexMultiplied(3);

/* INPUT = {"in1": [0,1,2], "in2": [0,1,4]} */

// accept
// in1[] = [0,1,2]
// in2[] = [0,1,4]

// reject
// in1[] = [0,1,2]
// in2[] = [0,0,2]
```

You can test the code [here](https://zkrepl.dev).

## Key Takeaways

- Behind the scenes, if variables are added or multiplied with a signal, the variable gets compiled to a constant in the R1CS.
- For signals, it is not allowed to do operations other than addition, subtraction, or multiplication because an R1CS can only have addition or multiplication with a constant. Subtraction behind the scenes is simply addition with the additive inverse.
- If a signal is divided by a constant (or a variable holding a constant), it will multiply that signal by the multiplicative inverse of the constant unless the constant is 0, in which case the code will not compile.

## Practice problems

Try out the following problems from ZK Puzzles. Run the tests to check your answer.

- [https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/AllBinary/AllBinary.circom](https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/AllBinary/AllBinary.circom)
- [https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/MultiANDNoOut/MultiANDNoOut.circom](https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/MultiANDNoOut/MultiANDNoOut.circom)
- [https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/IncreasingDistance/IncreasingDistance.circom](https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/IncreasingDistance/IncreasingDistance.circom)
