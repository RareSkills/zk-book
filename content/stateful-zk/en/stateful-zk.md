# Introduction to Stateful Computations in ZK

When carrying out iterative computations such as powers, factorials, or computing the Fibonacci sequence, we need to “stop the computation” after a certain point. 

For example, if we are computing $x^7$,  we would multiply $x$ by itself seven times. However, conditional stopping is not possible in an arithmetic circuit. Since circuits are of a fixed size (the underlying R1CS has a fixed number of rows and you can’t change it), they must be large enough to account for every exponent we would care to compute.

Therefore, the solution is to compute every possible value up to some limit greater than what we expect to compute in practice. Then we use a Quin selector to pick the desired value.

This chapter shows an example of doing this with the factorial, Fibonacci sequence, and leaves computing the power as an exercise.

We can think of each of these computations as a state machine that goes through a fixed state-transition a certain number of times (where the number of iterations is determined at proving time and not baked into the circuit).

These sequences only have one possible computation at each step (e.g. add the previous two states or multiply the previous state by some number). However, if we add conditional branching at each state, then we have all the components necessary for stateful computation.

In this chapter we will only show examples where there is only one possible state-change and the number of state changes is variable. In the upcoming chapters we will show how to make the state transition itself be conditional, i.e. have multiple possible state transitions.

## Factorial Example

We now show how to write a circuit that proves we correctly computed

$$
y =x!\pmod p
$$

where $!$ is the factorial and $p$ is the default field modulus.

To compute a factorial in a traditional programming language, such as Python, the code would be as follows:

```python
def factorial_mod_p(x, p):
  if x == 0:
    return 1
    
  acc = 1
  for i in range(1, x+1):
    acc = (acc * i) % p
  
  return acc
```

However, the code above will have a few issues if directly translated to Circom:

- Circom does not support if statements, so the `if x == 0: return 0` line will not compile.
- Circom does not support loops of an unknown number of iterations. Since `x` determines the value of the loop, this also won’t compile. Circom compiles to an R1CS under the hood, and the underlying R1CS needs to have a fixed size and can’t change size based on the value of the inputs.

To make the code compatible with an arithmetization representation like R1CS, we need to compute the factorial from zero up to some upper bound that we intend to support.

For example, if we know we will never need to compute more than 99 factorial, then we must compute every factorial from 0 to 99 inclusive. If we want to create a proof for 80 factorial, we still need to compute the factorials from 0 to 99, but we use a Quin selector to return the result for 80.

Here is a Python example that has no if-statements and a fixed-length loop:

```python
def factorial_mod_p(x, p):

  assert x < 100
  # allocate the array
  ans = [0] * 100
  ans[0] = 1 # 0! = 1
  
  for i in range(1, 100):
      ans[i] = (ans[i-1] * i) % p
  
  return ans[x]
```

In a sense, we are creating an array of length 100 and populating the values with the factorial of that index. We will then “select” the factorial we care about using the Quin Selector.

The translation to Circom is straightforward:

```jsx
include "./node_modules/circomlib/circuits/multiplexer.circom";
include "./node_modules/circomlib/circuits/comparators.circom";

template factorial(n) {
  signal input in;
  signal output out;

  // precompute factorials from 0 to n
  signal factorials[n+1];

  // compute the factorials
  factorials[0] <== 1;
  for (var i = 1; i <= n; i++) {
    factorials[i] <== factorials[i - 1] * i;
  }

  // ensure that in < n
  signal inLTn;
  inLTn <== LessThan(252)([in, n]);
  inLTn === 1;
  
  // select the factorial of interest
  component mux = Multiplexer(1, n);
  mux.sel <== in;

  // assign factorials into the multiplexer
  for (var i = 0; i < n; i++) {
    mux.inp[i][0] <== factorials[i];
  }

  out <== mux.out[0];
}

component main = factorial(100);

/*
  INPUT = { "in": "3" }
*/
```

### An insecure implementation

Many engineers new to Circom often use an “intuitive” solution that avoids any issues with quadratic constraints and produces code such as the following:

```jsx
pragma circom 2.1.8;

include "./node_modules/circomlib/circuits/comparators.circom";

template factorial(n) {
  signal input in;
  signal output out;

  signal factorials[n + 1];

  // compute the factorials
  var acc = 1;
  for (var i = 1; i < n; i++) {
    acc = acc * i;
  }
  
  out <-- acc;
}

component main = factorial(100);
```

Although `out` will have the correct answer, the total absence of `<==` or `===` operators means the circuit has no constraints.

**In the code above, the programmer has produced code to correctly compute the factorial, but not to constrain it.**

## Fibonacci Modulo p Example

In the factorial example, we had to “hardcode” the 0th entry of `factorials` to be 1, since 0! = 1. In the Fibonacci sequence, the first two numbers are 1, and everything after that is the sum of the previous two numbers in the sequence. Therefore, for the Fibonacci code, we hardcode the first two values and then compute the rest.

The circuit below computes the Fibonacci sequence up to the nth number modulo p, then outputs the “in” Fibonacci number of interest.

```jsx

include "./node_modules/circomlib/circuits/multiplexer.circom";
include "./node_modules/circomlib/circuits/comparators.circom";

template Fibonacci(n) {
  assert(n >= 2); // so we don't break the hardcoding

  signal input in; // compute the kth Fibonacci number
  signal output out;

  // precompute Fibonacci sequence from
  // 0 to n
  signal fib[n + 1];

  // compute the factorials
  fib[0] <== 1;
  fib[1] <== 1;
  
  for (var i = 2; i < n; i++) {
    fib[i] <== fib[i - 1] + fib[i - 2];
  }

  // ensure that in < n
  signal inLTn;
  inLTn <== LessThan(252)([in, n]);
  inLTn === 1;

  // select the fibonacci number 
  // of interest
  component mux = Multiplexer(1, n);
  mux.sel <== in;

  // assign Fibonacci into
  // the Quin Selector
  for (var i = 0; i < n; i++) {
    mux.inp[i][0] <== fib[i];
  }

  out <== mux.out[0];
}

component main = Fibonacci(99);

/*
  INPUT = {"in": 5}
*/
```

As usual, it is important to explicitly constrain each update of the Fibonacci sequence, and not simply compute the result in an unconstrained loop.

### Exercise:

Complete the [pow exercise](https://github.com/RareSkills/zero-knowledge-puzzles/blob/main/Power/pow.circom) in Circom Puzzles.