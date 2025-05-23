# Conditional Statements in Circom

Circom is very strict with the usage of if-statements. The following rules must be followed:

- Signals cannot be used to alter the behavior of an if-statement.
- A signal cannot be assigned a value inside an if-statement.

The example circuit below demonstrates both violations:

```jsx
template Foo() {

  signal input in;
  signal input cond;
  
  signal output out;
  
  // if-statements cannot depend on 
  // values not known at compile time
  if (in == 3) {
    // assigning a value inside an if-statement
    // whose value is unknown at compile time
    // is not allowed
    out <== 4;
  }
}
```

If-statements are acceptable if they are not affected by any signals, and do not affect any signals. 

Effectively, they are not part of the underlying Rank 1 Constraint system (R1CS).

For example, if we wanted to compute the maximum value in a list (without generating constraints), we can use the following typical solution, which Circom accepts since no signals are involved:

```jsx
var max;
for (var i = 0; i < n; i++) {
  if (arr[i] > max) {
    max = arr[i];
  }
}
```

This computation creates no constraints, it is simply for convenience.

## Branching in Circom

It might seem that Circom is incapable of conditional branching, but this is not the case. To create conditional branches in Circom, all branches of a statement must be executed, with the 'unwanted' branches multiplied by zero and the 'correct' branch multiplied by one.

## Example of a computation with branches

Suppose we are modeling the following computation:

```python
def foo(x):

  if x == 5:
    out = 14
  elif x == 9:
    out = 22
  elif x == 10:
    out = 23
  else
    out = 45
    
  return out
```

With no clear mathematical link between `x` and `out`, it's best to model this conditional as directly as possible. Here is how we describe the conditional statement mathematically:

$$
\texttt{out} = \texttt{x\_eq\_5}\cdot14+\texttt{x\_eq\_9}\cdot22+\texttt{x\_eq\_10}\cdot23+\texttt{otherwise}\cdot45\\
$$

- `x_eq_5` equals 1 if `x` equals 5, and zero otherwise, which can be accomplished with `IsEqual()([x, 5])`
- `x_eq_9` equals 1 when `x` equals 9, zero otherwise
- `x_eq_10` equals 1 when `x` equals 10, zero otherwise
- `otherwise` equals 1 when all of the above (`x_eq_5`, `x_eq_9`, `x_eq_10`) are 0.

We can assign the values to the signals `x_eq_5`, `x_eq_9`, `x_eq_10`, and `otherwise` using the `IsEqual()` template from Circomlib — this will also enforce that they are 0 or 1. To ensure that exactly one signal is 1 and the rest are zeros, we use the following constraint:

$$
\begin{align*}
1===\texttt{x\_eq\_5}+\texttt{x\_eq\_9}+\texttt{x\_eq\_10}+\texttt{otherwise}

\end{align*}
$$

In general, we create “binary switches” that are 1 when a particular branch is active and 0 otherwise. Then, we add up the evaluation of all the branches, each multiplied by their switch.  

Since only one branch of $\texttt{out = }...$ will be active, the rest of the evaluations are multiplied by 0 and hence don’t matter.

Here is the complete circuit:

```jsx
include "./node_modules/circomlib/circuits/comparators.circom";

template MultiBranchConditional() {
  signal input x;
  
  signal output out;
  
  signal x_eq_5;
  signal x_eq_9;
  signal x_eq_10;
  signal otherwise;
  
  x_eq_5 <== IsEqual()([x, 5]);
  x_eq_9 <== IsEqual()([x, 9]);
  x_eq_10 <== IsEqual()([x, 10]);
  otherwise <== IsZero()(x_eq_5 + x_eq_9 + x_eq_10);
  
  signal branches_5_9;
  signal branches_10_otherwise;
  
  branches_5_9 <== x_eq_5 * 14 + x_eq_9 * 22;
  branches_10_otherwise <== x_eq_10 * 23 + otherwise * 45;
  
  out <== branches_5_9 + branches_10_otherwise;
}

component main = MultiBranchConditional();
```

To make our code cleaner, it would be better to put the four-way branch as a separate component — that way, we can re-use the branching template.

```jsx
include "./node_modules/circomlib/circuits/comparators.circom";

template Branch4(cond1, cond2, cond3, branch1, branch2, branch3, branch4) {
  signal input x;
  signal output out;
  
  signal switch1;
  signal switch2;
  signal switch3;
  signal otherwise;
  
  switch1 <== IsEqual()([x, cond1]);
  switch2 <== IsEqual()([x, cond2]);
  switch3 <== IsEqual()([x, cond3]);
  otherwise <== IsZero()(switch1 + switch2 + switch3);
  
  signal branches_1_2 <== switch1 * branch1 + switch2 * branch2;
  signal branches_3_4 <== switch3 * branch3 + otherwise * branch4;
  
  out <== branches_1_2 + branches_3_4;
}

template MultiBranchConditional() {
  signal input x;
  
  signal output out;
  
  component branch4 = Branch4(5,9,10,14,22,23,45);
  
  branch4.x <== x;
  branch4.out ==> out; // same as out <== branch4.out
}

component main = MultiBranchConditional();
```

## Code when many branches are involved

In the code above, we had to explicitly write `switch1`, `switch2`,..., `otherwise`, which could be very tedious if the code has a lot of branches.

Instead, we could think of our computation as the inner product (generalized dot product) of the switches and the branches:

$$
\begin{align*}
\text{out}&===\langle[\text{switch}_1, \text{switch}_2,...,\text{switch}_n],[\text{branch}_1, \text{branch}_2,...,\text{branch}_n]\rangle\\
&=\text{switch}_1\cdot\text{branch}_1+\text{switch}_2\cdot\text{branch}_2+\dots+\text{switch}_n\cdot\text{branch}_n\\
1&===\text{switch}_1+\text{switch}_2+...+\text{switch}_n\\
0&===\text{switch}_i*(\text{switch}_i-1),\text{i = 1...n}
\end{align*}
$$

This above formulation ensures that precisely one switch is active (equal to 1), while all others are 0, making the corresponding branch the output. 

To implement this efficiently in Circom, we use the  `EscalarProduct` template from [multiplexer.circom](https://github.com/iden3/circomlib/blob/master/circuits/multiplexer.circom) . This template takes two vectors of length n, multiplies them element-wise, and sums the result. In the following code block, we use `EscalarProduct` to multiply each switch by each branch. Note that the final switch and branch are handled slightly differently because the final condition is a “catch-all” else statement.

```jsx
include "./node_modules/circomlib/circuits/comparators.circom";
include "./node_modules/circomlib/circuits/multiplexer.circom";

template BranchN(n) {
  assert(n > 1); // too small

  signal input x;

  // conds n - 1 is otherwise
  signal input conds[n - 1];
  
  // branch n - 1 is the otherwise branch
  signal input branches[n];
  signal output out;
  
  signal switches[n];
  
  component EqualityChecks[n - 1];
  
  // only compute IsEqual up to the second-to-last switch
  for (var i = 0; i < n - 1; i++) {
    EqualityChecks[i] = IsEqual();
    
    EqualityChecks[i].in[0] <== x;
    EqualityChecks[i].in[1] <== conds[i];
    switches[i] <== EqualityChecks[i].out;
  }
  
  // check the last condition
  var total = 0;
  for (var i = 0; i < n - 1; i++) {
    total += switches[i];
  }
  
  // if none of the first n - 1 switches
  // are active, then `otherwise` must be 1
  switches[n - 1] <== IsZero()(total);
  
  component InnerProduct = EscalarProduct(n);
  for (var i = 0; i < n; i++) {
    InnerProduct.in1[i] <== switches[i];
    InnerProduct.in2[i] <== branches[i];
  }
  
  out <== InnerProduct.out;
}

template MultiBranchConditional() {
	signal input x;
	
	signal output out;
	
	component branchn = BranchN(4);

  var conds[3] = [5, 9, 10];
  var branches[4] = [14, 22, 23, 45];
  for (var i = 0; i < 4; i++) {
    if (i < 3) {
        branchn.conds[i] <== conds[i];
    }
    
    branchn.branches[i] <== branches[i];
  }

  branchn.x <== x;
  branchn.out ==> out; // same as out <== branch4.out
}

component main = MultiBranchConditional();
```

## When is it okay to use if-statements?

Suppose we wanted to create a template that returns a completely different circuit depending on the circuit parameter. For example, if we are creating a `Max` component that takes an array `in[n]` and returns the max, it would be more efficient to simply return the 0th item in the index if `n` is equal to 1.

Below, we show an example of a valid use of the if-statement when used with defining constraints. Here, the if-statement is executed at compile time, so the template will produce a well-defined circuit:

```jsx
include "./node_modules/circomlib/circuits/comparators.circom";

template Max(n) {
  signal input in[n];
  signal output out;
  
  assert(n > 0);

  if (n == 1) {
    out <== in[0];
  }
  
  // it is okay to declare signals inside
  // the if-statement because the evaluation
  // of the if-statement is known at compile time
  else if (n == 2) {
    signal zeroGtOne;
    signal branch0;
    signal branch1;

    zeroGtOne <== GreaterThan(252)([in[0], in[1]]);
    branch0 <== zeroGtOne * in[0];
    branch1 <== (1 - zeroGtOne) * in[1];
    
    out <== branch0 + branch1;
  }
  else {
    // case for n > 2
  }
}

component main = Max(2);
```

## Conditional statements are not zk-friendly

A key design implication is that each condition in a Circom circuit doubles its size since branches can't be "short-circuited." Unlike traditional programming, all branches are computed.

When using ZK to prove a computation, we want to optimize for

1. Having as few branches as possible, as each branch increases the work of the prover.
2. Having the total computational cost across all branches be minimized, not just the expected computation based on the probability of a branch.
3. Avoiding conditional statements where possible.