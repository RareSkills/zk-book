# Intermediate Signals and Sub-Component

Circom’s primary purpose is to compile down to a Rank 1 Constraint System (R1CS), but its secondary purpose is to populate the witness.

For most circuits, the value of a few signals determines what the rest of the signals will be.

For example, it may seem a bit redundant to supply `c` as an input to the following template because its value is completely dependent on `a` and `b`:

```jsx
template Mul() {
  signal input a;
  signal input b;
  signal input c;
  
  c === a * b;
}
```

A more motivating example follows next.

## Breaking up a non-quadratic constraint

Suppose we want to create an R1CS for `a * b * c === d`. Since R1CS allows one multiplication per constraint, we have to create another signal `s` and an additional constraint to break up the multiplication:

```jsx
template Mul3() {
  signal input a;
  signal input b;
  signal input c;
  signal input d;
  
  signal input s;
  
  s === a * b;
  d === s * c;
}
```

It would be extremely tedious to supply another input every time we do more than one multiplication, especially in larger circuits with numerous multiplications. Furthermore, the value for `s` in the example above is deterministically dependent on `a` and `b`.

## Intermediate signals and assignment

To avoid the hassle of supplying `s`, Circom offers the `==>` and `<==` operators that assigns the value of `s` to be calculated by Circom (remember that part of Circom's functionality is to generate the witness). Thus, the value of `s` will not need to be supplied as an input. The `==>` and `<==` operators (precisely) means “assign and constrain:”

```jsx
template Mul3() {
  signal input a;
  signal input b;
  signal input c;
  signal input d;
  
  // no longer an input
  signal s;
  
  a * b ==> s;
  s * c === d;
}
```

Circom is flexible on the direction of the arrow, `a * b ==> s` means the same as `s <== a * b`.

In the code above, `s` is called an *intermediate signal*. An intermediate signal is a signal defined as `signal` keyword without the `input` keyword. Therefore, `signal s` is an intermediate signal, but `signal input a` is not.

**The underlying R1CS is identical between the two templates above. The `==>` simply saves us the hassle of supplying the value for `s` as part of the input.**

Assuming the witness vector $\mathbf{w}$ is represented as `[1, a, b, c, d, s]`, the underlying R1CS would be as follows:

$$
\begin{bmatrix}
0 & 1 & 0 & 0 & 0 & 0\\
0 & 0 & 0 & 0 & 0 & 1
\end{bmatrix}\mathbf{w}
\circ
\begin{bmatrix}
0 & 0 & 1 & 0 & 0 & 0\\
0 & 0 & 0 & 1 & 0 & 0
\end{bmatrix}\mathbf{w}=
\begin{bmatrix}
0 & 0 & 0 & 0 & 0 & 1\\
0 & 0 & 0 & 0 & 1 & 0
\end{bmatrix}\mathbf{w}
$$

This can be thought of as passing Circom the witness `[1, a, b, c, d, _]` and Circom computing the full witness `[1, a, b, c, d, s]` based on the input.

**Assignment to `s` happens outside the R1CS. The R1CS only checks that a matrix equation is satisfied by the witness vector $\mathbf{w}$. The R1CS expects the witness to be provided and does not compute any of its values. This approach simplifies circuit design and reduces the manual effort while keeping the R1CS structure unchanged.**

## Signal Values Cannot Be Re-Assigned With `<==`

A signal represents a concrete entry in the witness vector. Thus, it cannot change the value once it is set. As such, the following code will not compile:

```jsx
template CannotReassign() {
  signal input a;
  signal input b;
  
  signal c;
  
  c <== a * b;
  
  // not allowed
  // c already set
  c <== a * a;
}
```

## Real Example: Checking the Product of an Array

The more multiplications we have in our circuit, the more handy the `==>` operator becomes because it saves on having to supply additional input signals.

Suppose we wanted to enforce that the input signal `k` is the result of the product of all the signals in the array `in[n]`. In other words, we are checking:

$$
\prod_{i=0}^{n - 1}\texttt{in}[i]===k
$$

This would introduce a significant amount of intermediate signals. To keep the code clean, we can have all the intermediate signals be assigned to a separate array as follows:

```jsx
template KProd(n) {
  signal input in[n];
  signal input k;
  
  // intermediate signal array
  signal s[n];
  
  s[0] <== in[0];
  for (var i = 1; i < n; i++) {
    s[i] <== s[i - 1] * in[i];
  }
  
  k === s[n - 1];
}
```

Based on the code above, `s[n - 1]` holds the value

$$
\prod_{i=0}^{n - 1}\texttt{in}[i]
$$

which we can then constrain to be equal to `k`.

## Breaking Circom Into Templates

Now that we understand the `<==` operator, we can understand how Circom uses templates to make code more modular.

Similar to our example `Mul3`, suppose we have a circuit that takes 3 inputs and enforces that their product is a 4th (here is the code reproduced):

```jsx
template Mul3() {
  signal input a;
  signal input b;
  signal input c;
  signal input d; // d === a * b * c
  
  // no longer an input
  signal s;
  
  a * b ==> s;
  s * c === d;
}
```

But suppose we had to do this twice with eight inputs. In this case, it might be tempting to copy and paste the code twice for the inputs (a,b,c,d), and (x,y,z,u), which would be ugly.

```jsx
template Mul3x2() {
  signal input a;
  signal input b;
  signal input c;
  signal input d; // d === a * b * c
  
  signal input x;
  signal input y;
  signal input z;
  signal input u; // u === x * y * z
  
  // ugly code here
}
```

Instead, we can put `Mul3` as a separate template as follows:

```jsx
// separate template
template Mul3() {
  signal input a;
  signal input b;
  signal input c;
  signal input d; // d === a * b * c
  
  // no longer an input
  signal s;
  
  a * b ==> s;
  s * c === d;
}

// main component
template Mul3x2() {
  signal input a;
  signal input b;
  signal input c;
  signal input d; // d === a * b * c
  
  signal input x;
  signal input y;
  signal input z;
  signal input u; // u === x * y * z
  
  component m3_1 = Mul3();
  m3_1.a <== a;
  m3_1.b <== b;
  m3_1.c <== c;
  m3_1.d <== d;
  
  component m3_2 = Mul3();
  m3_2.a <== x;
  m3_2.b <== y;
  m3_2.c <== z;
  m3_2.d <== u;
}
```

Of note:

- We declare components with the syntax `component m3_1 = Mul3();`. This is the same syntax we use to declare the main component.
- We “connect” the signals using the `<==` operator.
- The code above is entirely equivalent to copying and pasting the core logic of `Mul3` twice.

## Passing Results Back From Templates

It would be handy in some situations if a sub-component could “pass results back” to the component that created it.

For example, the following main component uses a sub-component `Square` to assign and constrain `out` to be the square of `in`.

```jsx
template Square() {
  signal input in;
  signal output out;
  
  out <== in * in;
}

template Main() {
  signal input a;
  signal input b;
  signal input sumOfSquares;
  
  component a2 = Square();
  component b2 = Square();
  
  a2.in <== a;
  b2.in <== b;
  
  // assert that a^2 + b^2 === sum of Squares
  a2.out + b2.out === sumOfSquares;
}

component main = Main();
```

**In the context of sub-components, an output signal is a signal that expects to be assigned a value via the `<==` operator and can be used to pass values back to the component that created it.**

In the context of the `main` component — an output signal means something entirely different — we will explain that in a later chapter.

## Example: Binary to Number

The [circomlib library](https://github.com/iden3/circomlib) is a library of Circom templates for various common operations. One such operation is to convert a binary array to a signal. We have seen previously that this can be accomplished with $b_0+2b_1+4b_2+...+2^{n-1}b_{n-1}=v$. Here is how we can do it in a separate component. The following template can be found in the [bitify.circom](https://github.com/iden3/circomlib/blob/master/circuits/bitify.circom) file of the Circom library:

```jsx
template Bits2Num(n) {
  signal input in[n];
  signal output out;
    
  // lc is short for "linear combination"
  // it serves as an accumulator variable
  var lc1=0;

  var e2 = 1;
  for (var i = 0; i<n; i++) {
    lc1 += in[i] * e2;
    e2 = e2 + e2; // could also be e2 *= 2;
  }

  lc1 ==> out;
}
```

We don’t need to copy and paste code from the library — it can be “included” similar to how other languages import other files:

```jsx
include "circomlib/bitify.circom";

template Main(n) {
  signal input in[n];
  signal input v;
  
  // instantiate the Bits2Num component
  component b2n = Bits2Num(n);
  
  // loop over each binary value
  // and assign and constrain it to the
  // b2n input array
  for (var i = 0; i < n; i++) {
    b2n.in[i] <== in[i];
  }
  
  b2n.out === v;
}

component main = Main(4);

/* INPUT = {"in": [1, 0, 0, 1], "v": 9} */
```

The above component can be tested in zkrepl, but if running locally, the import path needs to be set according to how the directory is configured. Typically, Circomlib is [installed](https://www.npmjs.com/package/circomlib) with yarn or npm.

## One line component example

Rather than assign the input signals to a component separately, it is possible to provide them as an argument. This is called an “[anonymous component](https://docs.circom.io/circom-language/anonymous-components-and-tuples/).” Consider the following example:

```jsx
template Mul() {
  signal input in[2];
  signal output out;

  out <== in[0] * in[1];
}

template Example() {

  signal input a;
  signal input b;

  signal output out;

  // one line instantiation
  out <== Mul()([a, b]);
}

component main = Example();
```

## Output signals should not be ignored

An output signal must be part of constraints in the component that instantiated it. If an output signal is left “floating” then in some circumstances, a malicious prover can assign any value to it. More on this will be covered in [hacking underconstrained circuits](https://www.rareskills.io/post/underconstrained-circom).

## Summary

- The `<==` and `==>` saves us the hassle of supplying the value of a signal explicitly in the input.json.
- We can use `<==` or `==>` whenever the value of one signal is directly determined by the value of another.
- `<==` is equivalent to `==>` . The arguments are simply reversed, but the effect is the same.
- Components can instantiate other sub-components and send values to their input signals using `<==` or `==>`.
- The `output` signals of a sub-component should be constrained to equal other signals in the component that instantiated it.
