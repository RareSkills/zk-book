# Public and Private Inputs

A public input in Circom is a signal in the witness that will be revealed to the verifier.

For example, suppose we want to create a ZK proof that states: “we know the input to a hash that produced 0x492c…9254.” To make this claim meaningful, the value 0x492c…9254 (the target hash output) must be public. Otherwise, we are semantically claiming that “we hashed something,” which isn’t as useful.

The following circuit claims, “I multiplied two numbers together and got a third:”

```jsx
template Main() {
  signal input a;
  signal input b;
  signal input c;
  
  a * b === c;
}

component main = Main();
```

This next circuit makes a similar claim, but with the change that the result is public “I multiplied two numbers together and got a third whose value is publicly known:”

```jsx
template Main() {
  signal input a;
  signal input b;
  signal input c;
  
  a * b === c;
}

component main {public [c]} = Main();
```

- All input signals are private by default unless they are made explicitly public using the `component main {public [c]}` syntax. The main component is the only place where we can define which inputs are public.
- The list `[c]` is a list of signals to make public. It could have contained more signals, such as `[a,c]`, if we wanted to make `a` public also.
- Only input signals can be specified as public, intermediate signals cannot.

The template above compiles to a Rank-1 Constraint System (R1CS) identical to the following, where we introduce the `output` keyword in the main component:

```jsx
template Main() {
  signal input a;
  signal input b;
  signal output c;
  
  a * b ==> c;
}

component main = Main();
```

In the two templates above, `c` is public and constrained to be the product of `a` and `b`. Therefore, the underlying R1CS is the same. However, the second version is more “convenient” since we don’t have to explicitly supply `c`. In the first circuit that uses `component main {public [c]}`, if we supply `c` that does not obey the constraints, the witness will not be generated. However, in the second circuit using `c` as an output, the witness generator automatically computes the correct value for `c`, eliminating manual input.

Since `c` is wholly determined by `a` and `b`, there is no reason to explicitly provide a value for `c`, so the `output` notation is to be preferred.

Note that outputs are public.

    

In the case of inputs, if we want to make some public, then that means we have a signal whose value is *not* wholly determined by other signal values. In such cases,  we must use the `public` modifier method. For example, if we claim “I multiplied `a`, `b`, and `c` together to get `d`, with `a` and `d` public, but `b` and `c` private, we would structure that circuit as:

```jsx
template Main() {
  signal input a; // explicitly public
  signal input b;
  signal input c;
  signal output d; // implicitly public
  
  signal s <== a * b; // intermediate signal
  d <== c * s;
}

component main{public [a]} = Main();
```

Here is how to understand `output` signals:

- For a sub-component, an `output` is a signal that will be assigned a value from the other inputs and potentially be used later by the component that instantiates the sub-component.
- For the main component, an `output` is a public signal in the witness whose value should be wholly determined by other input signals. *Declaring an output signal and not assigning a value to it can create a vulnerability because a prover can assign any value they want. We’ll show the mechanism of this exploit in an upcoming chapter.*

Despite the name “output”, **there is no mechanism to get the “output” from the main component — Circom cannot return anything. There is no way for some other codebase to read the value of “output.”**

**It only generates an R1CS, helps compute the witness for the R1CS. Snarkjs then uses the Circom code to generate a ZK proof that the witness satisfies the R1CS.**

Circom isn’t being “executed”, which is why it doesn’t “return” anything. You aren’t “running” Circom, you are merely describing an abstract circuit that is being turned into two parts: R1CS and a witness generator, which are used separately.

An output signal in the main component can be thought of as an intermediate signal that is public to the verifier.

## Witness layout with public signals

Circom arranges the witness vector as follows:

```
[constant, public signals, private signals]
```

Let’s use “I multiplied hidden values `a`, `b`, with a public value `c` together to get a public value of `d`” as an example:

```jsx
// assert that a*b === c*d
template Example() {
  signal input a;
  signal input b;
  signal input c;
  signal input d;
  
  signal s;
  
  s <== a * b;
  d === s * c;
}

component main {public [c, d]} = Example();
```

Note that we could save some code by making `d` an output, but we don’t do that here to make the upcoming demonstration more clear.

To see how the witness is structured:

1. Save the file above as `Example.circom`
2. Compile it with `circom Example.circom --sym --r1cs --wasm`
3. Create the `input.json`: `echo '{"a": "3", "b": "4", "c":"2", "d":"24"}' > input.json`
4. `cd example_js`
5. Compute the witness: `node generate_witness.js example.wasm ../input.json witness.wtns`
6. Convert the witness to json and cat it: `snarkjs wej witness.wtns && cat witness.json`

We should get the following result. Note that this matches the values we supplied for `input.json`:

```jsx
[
 "1", // constant
 "2", // c (public signal)
 "24", // d (public signal)
 "3", // a
 "4", // b
 "12" // s
]
```

Thus, we can see the witness layout is always:

- The constant entry in the witness (which is always 1)
- The public signals (`c`, `d`)
- The input signals (`a`, `b`)
- The intermediate signals (`s`).

## Summary

- Inputs are private by default
- We can make inputs public by using the `component main {public [in1, in2]} = Main();` syntax
- Outputs are public signals
- Outputs are signals that are computed for the user based on other inputs