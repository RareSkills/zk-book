# Compute Then Constrain

"Compute then constrain" is a design pattern in ZK circuits where an algorithm's correct output is first computed without constraints. The correctness of the solution is then verified by enforcing invariants related to the algorithm.

## Motivation for compute then constrain

If one were limited to only using add, multiply, and assign-then-constrain (`==>`), then many calculations would be extremely challenging to model and require an extremely large number of additions and multiplications.

For example, computing the square root of a number requires several iterative estimates. This would make the circuit size considerably larger.

Therefore, it is often more practical to run the computation outside the circuit — i.e., do not generate any constraints while computing the answer — then configure constraints which are satisfied if and only if the computed answer is correct.

We will show a lot of examples from the [Bitify](https://github.com/iden3/circomlib/blob/master/circuits/bitify.circom) and [Comparator](https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom) libraries in Circomlib, which use this pattern heavily.

## The “thin arrow” `<--` operator in Circom and how it differs from `<==`

The `<==` operator assigns a value to a signal and creates a constraint. Because constraints must be quadratic, we cannot carry out operations such as the following:

```jsx
template InputEqualsZero() {
  signal input in;
  signal output out;
  
  // out = 1 if in == 0
  out <== in == 0 ? 1 : 0;
}

component main = InputEqualsZero();
```

Compiling the above circuit will result in a non-quadratic constraints error, since the ternary operator cannot be directly expressed as a single multiplication between signals. In fact, Circom directly rejects any operation on signals that is not multiplication or addition.

At first, it may seem that Circom cannot compute `out` for us and requires it to be provided as public input instead. However, this would be very inconvenient if a lot of signals were involved.

We need a mechanism to tell Circom “compute and assign the value for this signal as a function of other signals, but do not create a constraint.” The syntax for that operation is the `<--` operator:

```jsx
template InputEqualsZero() {
  signal input in;
  signal output out;
  
  // out = 1 if in == 0
  out <-- in == 0 ? 1 : 0;
}

component main = InputEqualsZero();
```

The operation `in == 0 ? 1 : 0;` is sometimes called an “out-of-circuit computations” or a “hint.”

The code above will compile, **but `out` and `in` have no constraints applied to them**.

The `<--` operator is very convenient because it allows us to compute values without generating constraints that eliminates the need to manually supply certain signal values. However, it has also been a source of security bugs.

**Circom does not enforce that developers create the appropriate constraints after using `<--` and this has been a common source of critical and high vulnerabilities in Circom. Even if the developer adds no constraints, thus creating very dangerous code, the compiler will not even give a warning or a notice. Unconstrained signals can take any value, thus allowing the circuit to produce ZK proofs for nonsensical statements.**

We will teach in a later tutorial, [exploiting underconstrained circuits](https://www.rareskills.io/post/underconstrained-circom), how to exploit Circom code that misuses the `<--` operator. For now, think of it as an operation that saves us the trouble of supplying a certain signal value ourselves while still requiring us to constrain that signal later.

Computing and the constraining is best understood by examples, which the rest of this chapter provides.

## Example 1: Modular Square Root

A modular square root of a number $q$ is a number $r$ such that $r^2=q\pmod p$. However, not all field elements have a modular square root. The constraint that models the correct computation of a square root is straightforward (although computing the square root is not).

Consider the following code, which proves that `out` is the modular square root of `in`:

```jsx
function sqrt(n) {
  // do some magic (see the next code block)
  return r;
}

template ValidSqrt() {
  signal input in;
  signal output out; // sqrt(in)
  
  out <-- sqrt(in);
  out * out === in; // ensure sqrt was correct
  // the `*` is implicity done modulo p
}
```

Here, `out <-- sqrt(in)` assigns the square root to `out` without adding constraints.

The [pointbits](https://github.com/iden3/circomlib/blob/master/circuits/pointbits.circom) file in Circomlib provides the function for computing the modular square root. Note that functions must be declared outside of a Circom template. A “function” in Circom is simply a convenience for putting related code into a contained block.

```jsx
function sqrt(n) {

    if (n == 0) {
        return 0;
    }

    // Test that have solution
    var res = n ** ((-1) >> 1);
//        if (res!=1) assert(false, "SQRT does not exists");
    if (res!=1) return 0;

    var m = 28;
    var c = 19103219067921713944291392827692070036145651957329286315305642004821462161904;
    var t = n ** 81540058820840996586704275553141814055101440848469862132140264610111;
    var r = n ** ((81540058820840996586704275553141814055101440848469862132140264610111+1)>>1);
    var sq;
    var i;
    var b;
    var j;

    while ((r != 0)&&(t != 1)) {
        sq = t*t;
        i = 1;
        while (sq!=1) {
            i++;
            sq = sq*sq;
        }

        // b = c ^ m-i-1
        b = c;
        for (j=0; j< m-i-1; j ++) b = b*b;

        m = i;
        c = b*b;
        t = t*c;
        r = r*b;
    }

    if (r < 0 ) {
        r = -r;
    }

    return r;
}
```

Modular square roots have two solutions: the square root itself and its additive inverse. Thus, we can generate both solutions as follows:

```jsx
template ValidSqrt() {
  signal input in;
  signal output out1; // sqrt(in)
  signal output out2; // -sqrt(in)
  
  out1 <-- sqrt(in);
  out2 <-- out1 * -1; // Computation Step (Unconstrained)
  out1 * out1 === in; // Verification Step (Constraint-Based):
  out2 * out2 === in; // Verification Step
}
```

**WARNING:** The code presented here is hardcoded to the default field size of Circom. If you configure Circom to use some other field, it may produce the wrong answer!

The example above demonstrates that computing the square root is much simpler when constraints are not a concern — if we tried to compute the square root using only multiplication and addition, the circuit would be unreasonably large. The correctness of the result can then be enforced through constraints afterward.

This illustrates how Circom can be both a traditional programming language and also a constraint generation DSL. The function `sqrt(n)` portion of the code is traditional programming, but the constraint `in === out * out` generates the constraint.

## Example 2: Sudoku

If a computation is too difficult or computationally expensive to model through constraints—that is, if it requires many gates and intermediate signals—one can simply provide it as an input and assume the prover obtained the answer by other means.

To actually solve a Sudoku puzzle, one must run a search algorithm for possible solutions, likely using depth-first search. However, we do not need to prove we ran a search algorithm directly — producing a valid solution is sufficient to prove that we ran the search algorithm. Because there are numerous [Sudoku tutorials](https://github.com/nalinbhardwaj/snarky-sudoku/blob/main/circuits/sudoku.circom) for Circom on the internet already, we do not produce an example here.

## Example 3: Modular Inverse

Suppose we want to compute the multiplicative inverse of signal `in`, i.e., find a signal `out` such that `out * in === 1`.

One way to compute multiplicative inverses is to use Fermat’s Little Theorem:

$$
x^{-1}=x^{p-2}\pmod p
$$

However, using such a large exponent (Circom's default is $p\approx2^{254}$) will result in a lot of multiplications and a very large circuit. Instead, it would be better to compute the multiplicative inverse *outside* of the circuit and then prove we have the correct multiplicative inverse. For example:

```jsx
template MulInv() {
  signal input in;
  signal output out;
  
  // Fermat's little theorem
  // compute:
  // note that -2 = p - 2 mod p
  var inv = in ** (-2);
  out <-- inv;
  
  // then constrain
  out * in === 1;
}

component main = MulInv();
```

Here, we only have one constraint: `out * in === 1`, so this is very efficient.

### Modular division in Circom

Circom interprets the `/` operator as modular division, so the inverse of a value `n` can be computed as:

```jsx
inv <-- 1 / n;
```

The template above could be written a little more cleanly as:

```solidity
template MulInv() {
  signal input in;
  signal output out;
  
  // compute
  out <-- 1 / in;
  
  // then constrain
  out * in === 1;
}

component main = MulInv();
```

Modular division is a non-quadratic operation, so it must be used only with variables or with the thin arrow assignment — i.e. it needs to be computed out-of-circuit.

## Example 4: IsZero

### Motivation

The IsZero circuit is very handy for composing into larger computations. Suppose for example that we wanted to prove that `x` is less than 16 or `x` equals 42.

The following set of constraints won’t work:

```jsx
// equal 42
x === 42

// less than 16
x === b_0 + 2*b_1 + 4*b_2 + 8*b_3
0 === b_0 * (b_0 - 1)
0 === b_1 * (b_1 - 1)
0 === b_2 * (b_2 - 1)
0 === b_3 * (b_3 - 1)
```

If `x` is 42, it will violate the bottom constraints and if it is less than 16 it will violate `x === 42`.

Thus, we really want subcircuits to *indicate* that a certain condition holds (i.e., `x` equaling 42 or being less than 16) without *enforcing* that a certain condition holds. We can then place constraints on these *indicators*. For example, suppose we had the indicators `x_eq_42` and `x_lt_16`. We can constrain that at least one of them is true with the following:

```jsx
// at least one of the two signals is not zero
x_eq_42 * x_lt_16 === 1;
```

To create an *indicator* that `x` equals 42, we want to know if the value `x - 42` is precisely zero or not.

### Designing a circuit to indicate a value is zero

Here, we design a circuit that returns `1` if the input is `0` and `0` otherwise (For the curious, the name of this function is the [Kronecker Delta function](https://en.wikipedia.org/wiki/Kronecker_delta)).

If we wrote such a function purely using addition and multiplication, our function would be a polynomial, which is limited in how many places it can be 0. In other words, if we wanted our function to be zero *everywhere* in our finite field, then our polynomial would have a degree nearly as large as the finite field order, which is impractical.

Instead, we design a set of constraints where `in` and `out` have the following properties:

| in | out | constraint |
| --- | --- | --- |
| 0 | 0 | violated |
| 0 | 1 | accepted |
| not 0 | 0 | accepted |
| not 0 | 1 | violated |

We need a set of constraints that require `out` to be 1 if `in` is 0, and `out` to be 0 if `in` is non-zero. Another way of thinking about this relationship is “at least one of `in` or `out` must be non-zero, but they cannot both be zero or both be non-zero.”

Saying that at least one of `in` and `out` must be zero can be modeled with the constraint `in * out === 0`.

In the table below, we can see that `in * out === 0` accepts the situation "exactly one of `in` and `out` are zero," and it correctly rejects the situation where both `in` and `out` are non-zero:

| in | out | constraint | in * out === 0 |
| --- | --- | --- | --- |
| 0 | 0 | violated | accept |
| 0 | 1 | accepted | accept |
| not 0 | 0 | accept | accept |
| not 0 | 1 | violated | violate |

The issue with the constraint `in * out === 0` is that it does not prevent the case where `in` and `out` are both 0 (as marked as red in the table above).

The missing property that we are trying to capture is that `in` and `out` cannot be zero simultaneously.

Naively, we could accomplish this with `in + out === 1`. This would mean that if `in` is 1 then `out` must be 0 and vice versa. However, the specifications say that `in` could be any non-zero value, for example, 100, and `100 + out` cannot be 1.

However, if we can “turn the 100 into a 1” then we can make the constraint work. This can be accomplished by computing the multiplicative inverse of `in` outside the circuit and subsequently applying the constraint `in * inv + out === 1`. If `in` is zero, then we make `inv` zero because zero does not have a multiplicative inverse. We now have the following constraints:

```jsx
in * inv + out === 1;
in * out === 0;
```

Note that `inv` is not itself constrained, but this is not consequential in this case.

The first constraint, `in * inv + out === 1;` only serves the purpose of disallowing both `in` and `out` to be zero. If both `in` and `out` are zero, then the constraint will be violated regardless of the value of `inv`.

To summarize the computations done outside the circuit:

- Whether `in` is zero or not.
- The multiplicative inverse of `in`.

The [IsZero](https://github.com/iden3/circomlib/blob/0a045aec50d51396fcd86a568981a5a0afb99e95/circuits/comparators.circom#L24) component in Circomlib accomplishes the constraints outlined in this section:

```jsx
template IsZero() {
  signal input in;
  signal output out;

  signal inv;

  inv <-- in!=0 ? 1/in : 0;

  out <== -in*inv +1;
  in*out === 0;
}
```

It first computes `inv` outside the circuit, then constraints `out` to be 1 if `in` is zero and 0 to `out` otherwise.

### Non-deterministic inputs

Values computed outside the circuit that enable us to use more concise constraints are called “advice inputs” or “non-deterministic inputs.” The `inv` signal in the circuit above is an example of an advice input, or non-deterministic input.

## Example 5: IsEqual

The [IsEqual](https://github.com/iden3/circomlib/blob/0a045aec50d51396fcd86a568981a5a0afb99e95/circuits/comparators.circom#L37) component in Circomlib is closely related to `IsZero` — it checks if the difference between the inputs is zero (if so, then they must be equal to each other):

```solidity
template IsEqual() {
  signal input in[2];
  signal output out;

  component isz = IsZero();

  in[1] - in[0] ==> isz.in;

  isz.out ==> out;
}
```

## Example 6: Num2Bits

The [Num2Bits](https://github.com/iden3/circomlib/blob/252f8130105a66c8ae8b4a23c7f5662e17458f3f/circuits/bitify.circom#L25) template in Circomlib decomposes a signal into `n` bits as specified by the template parameter:

```jsx
template Num2Bits(n) {
  signal input in; // number
  signal output out[n]; // binary output
  var lc1=0;

  var e2=1;
  for (var i = 0; i<n; i++) {
    out[i] <-- (in >> i) & 1;
    out[i] * (out[i] -1 ) === 0;
    lc1 += out[i] * e2;
    e2 = e2+e2;
  }

  lc1 === in;
}
```

*Please note that for `n` in the code above, if $2^n$ is larger than the finite field, we may have an [alias bug](https://www.rareskills.io/post/circom-aliascheck). This is explained further in that chapter.*

Essentially, the code loops through each bit in the binary representation, starting from the least significant bit. On each iteration of the loop, we store the value `[1,2,4,8,…,2^i]` in a variable `e2`, which is the value that bit represents. If that bit is 1 (`out[i] <-- (in >> i) & 1;`),  we add that value to the accumulator `lc1`. At each iteration in the loop, we constrain that the bit read is actually 0 or 1 (with `out[i] * (out[i] -1 ) === 0;`). In the end, we constrain that the computed binary value matches the original value (`lc1 === in;`).

The way it computes the binary array is best shown with an animation, which we show here:

<video src="https://r2media.rareskills.io/ComputeThenConstrain/Num2Bits.mp4" type="video/mp4" autoplay loop muted controls></video>

Comparable to the earlier examples, computing the binary value is done outside the circuit, but then we constrain afterwards to ensure that the binary array is correct.

The `Num2Bits` template is a core component in the template `LessThan` and other templates for comparing the relative value of signals.

Field elements (numbers in a finite field) cannot be directly compared to each other — they need to be converted to binary numbers first.

To understand how to efficiently compare the size of binary numbers in a circuit, please review the relevant section in our chapter on [Arithmetic Circuits](https://www.rareskills.io/post/arithmetic-circuit#:~:text=%F0%9D%91%A0-,Compute%20%E2%89%A5%20in%20binary,-If%20we%20are) then compare the discussion there to the [LessThan template in Circomlib](https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom#L89).

## Example 7: IsMax

To prove that an item is the maximum in a list, we must show that it is 1) greater than or equal to every element and 2) that it is also present in the list. To understand the second requirement, consider that 100 is not the max of the list [4,5,6] even though 100 is greater than or equal to every item in the list.

The circuit below computes the maximum outside the circuit using a traditional for loop, then uses the `GreaterEqThan` component to ensure that `out` is greater than or equal to every other item in the list.

To ensure that `out` equals at least one of the items in the list, it sums up an `IsEqual` comparison to every other signal. If the sum is zero, then we know that `out` is not in the list. Therefore, we constrain that sum to not be zero:

```jsx

template IsMax() {
  signal input in[3];
  signal output out;
  
  // compute the max as usual
  var maxx = in[0];
  for (var i = 1; i < 3; i++) {
    if (in[i] > maxx) {
      maxx = in[i];
    }
  }
  
  // propose the max, but do not constrained it yet
  out <-- maxx;
  
  // max must be ≥ every other element
  signal gte0;
  signal gte1;
  signal gte2;
  
  // gte0 <== GreaterEqThan(252)([out, in[0]]);
  // is shorthand for
  // component gte0 = GreaterEqThan(252);
  // gte0[0] <== out;
  // gte0[1] <== in[0];
  // 252 is to ensure we don't have enough
  // bits to encode numbers larger than what
  // fits in the default finite field, which
  // would lead to aliasing issues
  gte0 <== GreaterEqThan(252)([out, in[0]]);
  gte1 <== GreaterEqThan(252)([out, in[1]]);
  gte2 <== GreaterEqThan(252)([out, in[2]]);
  gte0 === 1;
  gte1 === 1;
  gte2 === 1;
  
  // max must be equal to at least one element
  signal eq0;
  signal eq1;
  signal eq2;
  eq0 <== IsEqual()([out, in[0]]);
  eq1 <== IsEqual()([out, in[1]]);
  eq2 <== IsEqual()([out, in[2]]);
  
  signal iz;
  iz <== IsZero()(eq0 + eq1 + eq2);
  // if IsZero is 1, we have a violation
  iz === 0;
}
```

In its current form, our circuit is hardcoded to only support an array of length 3. However, it would be nice to be able to have a template for an arbitrary length input. This is the subject of an upcoming chapter.

## Practice Problems

Write a Circom function that finds the root of a degree 2 polynomial using the quadratic formula. Remember, everything is done over a finite field, so you need to use the modular square root from the first example.

Then, write constraints that the two roots (if they exist) satisfy the polynomial. Pass in the polynomial to the Circom template as an array of three coefficients.
