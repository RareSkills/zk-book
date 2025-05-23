# Circom Components in a Loop

Circom does not allow for components to be directly instantiated in a loop. For example, compiling the following code results in the error below.

```jsx
include "./node_modules/circomlib/circuits/comparators.circom";

template IsSorted(n) {
  signal input in[n];
	
  for (var i = 0; i < n; i++) {
    component lt = LessEqThan(252); // error here
    lt.in[0] <== in[0];
    lt.in[1] <== in[1];
    lt.out === 1;
  }
}

component main = IsSorted(8);
```

```
Signal or component declaration inside While scope. Signal and component can only be defined in the initial scope or in If scopes with known condition
```

The workaround is to declare an array of the components but not specify the component type:

```jsx
pragma circom 2.1.8;
include "./node_modules/circomlib/circuits/comparators.circom";

template IsSorted(n) {

  signal input in[n];
  
  // declare array of components
  // but do not specify the component type
  component lessThan[n];

  for (var i = 0; i < n - 1; i++) {
    lessThan[i] = LessEqThan(252); // specify type in the loop
    lessThan[i].in[0] <== in[i];
    lessThan[i].in[1] <== in[i+1];
    lessThan[i].out === 1;
  }
}

component main = IsSorted(8);

```

When components are declared in this manner, it is not possible to do a “one-line assignment” to a signal like shown below:

```jsx
pragma circom 2.1.8;
include "./node_modules/circomlib/circuits/comparators.circom";

template IsSorted() {

  signal input in[4];
  signal leq1;  
  signal leq2;  
  signal leq3;  
  
  // one line assignment to the signal
  leq1 <== LessEqThan(252)([in[0], in[1]]);
  leq2 <== LessEqThan(252)([in[1], in[2]]);
  leq3 <== LessEqThan(252)([in[2], in[3]]);
  
  leq1 === 1;
  leq2 === 1;
  leq3 === 1;
}

component main = IsSorted();
```

Outside a loop, signals can be set on a single line. Inside a loop, however, we have to write out the assignment in more steps, like we did in `lessThan[i] = LessEqThan(252); // specify type in the loop`.

## Example 1: max of an array

To illustrate a useful example of declaring components in a loop, we show how to prove `k` is the maximum of an array. To do this, we need to constrain that `k` is greater than or equal to every other element and that it is equal to at least one of the elements. To see why the equality check is necessary, consider that 18 is greater than or equal to all the elements in [7, 8, 15], but it is not the maximum of the array.

The following Circom code computes the maximum value of the array without generating constraints. Then, it runs `n` [GreaterEqualThan](https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom#L131) components to constrain that the proposed `max` value is indeed the maximum value, and also checks that at least one of the elements is equal to `k` using an array of [IsEqual](https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom#L37) components.

```jsx
include "./node_modules/circomlib/circuits/comparators.circom";

template Max(n) {
  signal input in[n];
  signal output out;
  
  // no constraints here, just a computation    
  // to find the max    
  
  var max = 0;    
  for (var i = 0; i < n; i++) {        
    max = in[i] > max ? in[i] : max;   
  }    
  
  signal maxSignal;    
  maxSignal <-- max;
  
  // for each element in the array, assert that
  // max ≥ that element
  component GTE[n];
  component EQ[n];
  var acc;
  for (var i = 0; i < n; i++) {
  	GTE[i] = GreaterEqThan(252);
  	GTE[i].in[0] <== maxSignal;
  	GTE[i].in[1] <== in[i];
  	GTE[i].out === 1;
  	
  	// this is used in the
  	// next code block to ensure
  	// that maxSignal equals at
  	// least one of the inputs
  	EQ[i] = IsEqual();
  	EQ[i].in[0] <== maxSignal;
  	EQ[i].in[1] <== in[i];
  	
  	// acc is greater than zero
  	// (acc != 0) if EQ[i].out
  	// equals 1 at least one time
  	acc += EQ[i].out;
  }
  
  // assert that maxSignal is 
  // equal to at least one of the
  // inputs. if acc = 0 then
  // none of the inputs equals
  // maxSignal
  signal allZero;
  allZero <== IsEqual()([0, acc]);
  allZero === 0;
  out <== max;
}

component main = Max(8);
```

**Exercise:** Create a circuit that does the same as above, but for the `min`.

## Example 2: array Is sorted

We can assert that an array is sorted by checking that each element is less than or equal to the subsequent one. Unlike the previous example which needed `n` components, we need `n - 1` components since we are comparing neighboring values to each other. Since we have `n` elements, we are going to do `n - 1` comparisons.

Here is a template that constrains an input array `in[n]` to be sorted. Note that if an array only has one element, it is sorted by definition, and the circuit below is also compatible with that scenario:

```jsx
pragma circom 2.1.6;

include "circomlib/comparators.circom";

template IsSorted(n) {
  signal input in[n];

  component lt[n - 1];
  
  // loop goes up to n - 1, not n
  for (var i = 0; i < n - 1; i++) {
    lt[i] = LessThan(252);
    lt[i].in[0] <== in[i];
    lt[i].in[1] <== in[i+1];
    lt[i].out === 1;
  }
}

component main = IsSorted(3);
```

## Example 3: All items are unique

To check that all items in a list are unique, the most straightforward way is to use a hashmap — but hashmaps are not available in arithmetic circuits. The second most efficient way is to sort the list, but sorting inside a circuit is quite tricky, so we avoid that for now. This leaves us with the brute force solution of comparing every element to every other element. This requires a nested for-loop.

The computation we are doing can be illustrated as follows:

$$
\begin{array}{c|c|c|c|c|}
&a_1&a_2&a_3&a_4\\
\hline
a_1&&\neq&\neq&\neq\\
\hline
a_2&&&\neq&\neq\\
\hline
a_3&&&&\neq\\
\hline
a_4\\
\hline
\end{array}
$$

In general, there will be

$$
\frac{n(n-1)}{2}
$$

inequality checks, so we will need that many components.

We show how to accomplish this below:

```jsx
pragma circom 2.1.8;

include "./node_modules/circomlib/comparators.circom";

template ForceNotEqual() {
  signal input in[2];

  component iseq = IsEqual();
  iseq.in[0] <== in[0];
  iseq.in[1] <== in[1];
  iseq.out === 0;
}

template AllUnique (n) {
  signal input in[n];

  // the nested loop below will run
  // n * (n - 1) / 2 times
  component Fneq[n * (n-1)/2];

  // loop from 0 to n - 1
  var index = 0;
  for (var i = 0; i < n - 1; i++) {
    // loop from i + 1 to n
    for (var j = i + 1; j < n; j++) {
      Fneq[index] = ForceNotEqual();
      Fneq[index].in[0] <== in[i];
      Fneq[index].in[1] <== in[j];
      index++;
    }
  }
}

component main = AllUnique(5);
```

## Summary

To use Circom components inside a loop, we declare an array of components outside the loop without specifying the type.

Then inside the loop, we declare the components and constrain the inputs and outputs of the component.
