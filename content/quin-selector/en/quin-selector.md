# Quin Selector

The Quin Selector is a design pattern that allows us to use a signal as an index for an array of signals.

As a prerequisite, we assume the reader has read the chapter on Conditional Statements in Circom.

The following code does not compile, but it illustrates what we are trying to accomplish:

```jsx
template ArraySelect(n) {

  signal input in[n];
  signal input index;
  
  signal output out;
  
  // won't compile -- non-quadratic constraints
  out <== in[index];
}
```

To express something conditional in Circom, we multiply the desired branch by one and the others by zero, then sum all the branches. The zeroed branches won’t have any effect on the sum. The Quin selector follows the same logic: we multiply the desired index by 1 and the rest by zero, then sum the result.

As an example, suppose our input array is `in = [5,9,14,20]`. Selecting the item at index 2 means we compute:

$$
5\cdot0+9\cdot0+\boxed{14\cdot1}+20\cdot0=14
$$

In other words, we do an inner product computation between `[5,9,14,20]` and `[0,0,1,0]`, which results in 14.

Each “switch” becomes 0 or 1 if `index` equals the desired index.

```jsx
include "./node_modules/circomlib/comparators.circom";

template ArraySelect(n) {

  signal input in[n];
  signal input index;
  signal output out;
  
  component eqs[n];
  
  // prod keeps a running product
  signal prod[n];
  
  // prod = 1 * in[i] if i == index else 0
  for (var i = 0; i < n; i++) {
    eqs[i] = IsEqual();
    eqs[i].in[0] <== i;
    eqs[i].in[1] <== index;
    
    prod[i] <== eqs[i].out * in[i];
  }
  
  // sum the result
  var sum;
  for (var i = 0; i < n; i++) {
    sum += prod[i];
  }
  
  out <== sum;
}
```

The code above does not constrain the index to be less than the size of the array. If the index is out of bounds, then the code will return 0 as the result. The [Quin Selector implementation in DarkForest](https://github.com/darkforest-eth/circuits/blob/master/perlin/QuinSelector.circom) includes a range check on `index`, so we refer the reader to that template, upon which the above examples were based:

```jsx
// out is the sum of in
template CalculateTotal(n) {
  signal input in[n];
  signal output out;

  signal sums[n];

  sums[0] <== in[0];

  for (var i = 1; i < n; i++) {
      sums[i] <== sums[i-1] + in[i];
  }

  out <== sums[n-1];
}

template QuinSelector(choices) {
  signal input in[choices];
  signal input index;
  signal output out;
  
  // Ensure that index < choices
  component lessThan = LessThan(252);
  lessThan.in[0] <== index;
  lessThan.in[1] <== choices;
  lessThan.out === 1;

  component calcTotal = CalculateTotal(choices);
  component eqs[choices];

  // For each item, check whether its index equals the input index.
  for (var i = 0; i < choices; i ++) {
    eqs[i] = IsEqual();
    eqs[i].in[0] <== i;
    eqs[i].in[1] <== index;

    // eqs[i].out is 1 if the index matches. As such, at most one input to
    // calcTotal is not 0.
    calcTotal.in[i] <== eqs[i].out * in[i];
  }

  // Returns 0 + 0 + 0 + item
  out <== calcTotal.out;
}
```

As an optimization, then step `component lessThan = LessThan(252);` doesn’t need 252 bits to ensure the `index` is less than `choices`. Depending on our application, we could use a much smaller number of bits to make the comparison and save on the number of constraints generated under the hood.

## Circomlib Implementation of Quin Selector

The [multiplexer](https://github.com/iden3/circomlib/blob/master/circuits/multiplexer.circom) in the Circomlib library accomplishes the same thing as Quin Selector. However, it indexes a 2-dimensional array and returns a 1-dimensional array. For example, given the array `in = [[5,5],[6,6],[7,7]]` and `index = 1`, it would return `[6, 6]`.

The component has the following inputs and outputs:

```jsx
template Multiplexer(wIn, nIn) {
  signal input inp[nIn][wIn];
  signal input sel;
  signal output out[wIn];

  // ...
}
```

Using the example `in = [[5,5],[6,6],[7,7]]`, `wIn` would be 2 and `nIn` would be 3. The signal `sel` is the index to pick; for example if `sel = 1` then `out = [6,6]`.

Instead of looping through the array and checking if the index `IsEqual` to the `sel` value, the Multiplexer generates a “mask” of all zeros with a 1 at the desired index and multiples that mask with the input. For example, if `sel = 1` it generates the mask `[0,1,0]` and multiplies the input by that mask.

Here is an example of using Circomlib’s multiplexer:

```jsx
include "circomlib/multiplexer.circom";

template MultiplexerExample(n) {
  signal input in[n];
  signal input k;
  signal output out;

  component mux = Multiplexer(1, n);

  for (var i = 0; i < n; i++) {
    mux.inp[i][0] <== in[i];
  }
  mux.sel <== k;

  out <== mux.out[0];
}

component main = MultiplexerExample(4);

/* INPUT = {
  "in": [3, 7, 9, 11],
  "k": "1"
} */
```

## Historical Note

This algorithm was referred to as “Linear Scan” in the [xjsnark paper](https://akosba.github.io/papers/xjsnark.pdf), which predates the eth Dark Forest implementation. Credit to [0xerhant](https://x.com/0xerhant/status/1873831895055950247) for pointing this out.