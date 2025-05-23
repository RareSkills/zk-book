# Symbolic Variables in Circom

A symbolic variable in Circom is a variable that has been assigned values from a signal.

When a signal is assigned to a variable (thereby turning it into a symbolic variable), the variable becomes a container for that signal and for any arithmetic operations applied to it. A symbolic variable is declared using the `var` keyword, just like other variables.

For example, the following two circuits are equivalent, i.e. they produce the same underlying R1CS:

```jsx
template ExampleA() {
	signal input a;
	signal input b;
	signal input c;
	
	a * b === c;
}

template ExampleB() {
	signal input a;
	signal input b;
	signal input c;
	
	// symbolic variable v "contains" a * b
	var v = a * b;
	
	// a * b === c under the hood
	v === c;
}
```

In `ExampleB`, the symbolic variable `v` is simply a placeholder for the expression `a * b`. Both `ExampleA` and `ExampleB` are compiled using the exact same R1CS, and there is zero functional difference between them.

## Use cases of symbolic variables

### Checking That $\sum\texttt{in}[i]=\texttt{sum}$

Symbolic variables are extremely handy if we want to sum up an array of signals in a loop. In fact, summing signals in a loop is their most common use case:

```jsx
// assert sum of in === sum
template Sum(n) {
	signal input in[n];
	signal input sum;
	
	var accumulator;
	for (var i = 0; i < n; i++) {
		accumulator += in[i];
	}
	
	// in[0] + in[1] + in[2] + ... + in[n - 1] === sum
	accumulator === sum;
}
```

### Checking That `in` Is a Valid Binary Representation of `k`

A more interesting example is proving that `in[n]` is the binary representation of `k` for a templated value of `n`. In the circuit below, we check that:

$$
\texttt{in[0]}+2\cdot\texttt{in[1]}+4\cdot\texttt{in[2]} +\dots2^{n-1}\cdot\texttt{in[n-1]} == k
$$

If all the signals in `in` are constrained to be $\set{0,1}$, then that implies `in[]` is the binary representation of `k`:

```jsx
template IsBinaryRepresentation(n) {

	signal input in[n];
	signal input k;
	
	// in is binary only
	for (var i = 0; i < n; i++) {
		in[i] * (in[i] - 1) === 0;
	}
	
	// in is the binary representation of k
	var acc; // symbolic variable
	var powersOf2 = 1; // regular variable
	for (var i = 0; i < n; i++) {
		acc += powersOf2 * in[i];
		powersOf2 *= 2;
	}
	
	acc === k;
}
```

### Why symbolic variables are helpful

Consider the earlier example of proving that $\sum\texttt{in}[i]=\texttt{sum}$. Without symbolic variables, it’s very clumsy to express

```jsx
sum === in[0] + in[1] + in[2] + ... + in[n-1];
```

if we don’t know what `n` is in advance. Even if `n` was fixed, say at 32, actually typing out 32 variables by hand would be annoying. Thus, symbolic variables enable us to incrementally construct `in[0] + in[1] + in[2] + ...` without explicitly writing out the signals.

## Non quadratic Constraints With Symbolic Variables

Because symbolic variables can “contain” a multiplication between two signals, they can lead to embedding two multiplications into one constraint if we aren’t careful. Consider the following example, that will not compile:

```jsx
template QViolation() {
	signal input a;
	signal input b;
	signal input c;
	signal input d;
	
	// v "contains" a * b
	var v = a * b;
	
	// error: there are two
	// multiplications
	// in this constraint
	v === c * d;
}
```

In the code above, the symbolic variable `v` has one multiplication in it and we declared `v == a*b`.  So the constraint `v === c * d;` is equivalent to `a * b = c * d;`. Hence, the above code will not compile. 

## Arbitrary operators are allowed with non-symbolic variables

Doing operations like computing the modulo or bitshifting are allowed with (non-symbolic) variables. However, this means that the variable can no longer be used as part of a constraint: 

```jsx
// this has no constraints
// but it will compile
template Ok() {
	signal input a;
	signal input b;
	
	var v = a % b;
}
```

The above example will compile because `v` is not used in a constraint. However, if we use `v` in a constraint, the code will not compile. An example of this is shown below:

```jsx
template NotOk() {
	signal input a;
	signal input b;
	signal input c;
	
	var v = a % b;
	
	// non-quadratic constraint
	c === v;
}
```

### Symbolic variables cannot be used to determine the boundary of a loop or the condition

Similarly, only regular variables can be used to determine the boundary of a loop or the condition of an if statement. If a symbolic variable is used, then the code will not compile:

```jsx
template NotOk() {
	signal input a;
	signal input b;
	signal input c;
	
	var v = a * b;
	
	// v is a symbolic variable
	// used in an if statement
	if (v == 0) {
		c === 0;
	} else {
		c === 1;
	}
}
```

## Summary

Symbolic variables are variables that were assigned a value from a signal. They are most frequently used for adding a parameterizable number of signals together, as the sum can be accumulated in a for loop. They are effectively a “container” or “bucket” that holds either a single signal or a collection of signals that are added or multiplied together. If a variable is never assigned a value from a signal, then it is not a symbolic variable.

Since symbolic variables contain signals, care must be taken to avoid quadratic constraint violations when using them.
