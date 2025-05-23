# Quadratic Constraints

## Circom Constraints

A Rank 1 Constraint System has at most one multiplication between signals per constraint. This is called a "quadratic" constraint. Any constraint containing an operation other than addition or multiplication will be rejected by Circom with the “Non quadratic constraints are not allowed” error.

The following two examples will not compile because they have more than one multiplication of signals per constraint.

## Non quadratic constraint example 1

Compiling the following will result in the following `error: [T3001]: Non quadratic constraints are not allowe`

```jsx
template QuadraticViolation1() {
  signal input a;
  signal input b;
  signal input c;
  signal input d;
  
  // two multiplications per constraint
  // is not allowed
  a * b === c * d;
}
```

## Non quadratic constraint example 2

Similar to the previous example, the following constraint has two multiplications between signals.

```jsx
template QuadraticViolation2() {
  signal input a;
  signal input b;
  signal input c;
  signal input d;
  
  // two multiplications per constraint
  // is not allowed
  a * b * c === d;
}
```

## Constant multiplications do not count

Therefore, the following examples will compile, even though there is more than one multiplication.

```jsx
a * b === c;

2*a * 3*b === 4*c; // integer coefficients allowed

a * b + c === d; // addition and one multiplication allowed

a + b + c === d; // multiplication is optional

a * b + c === d + e + f; // no restrictions on number of additions
```

## Quadratic Form and R1CS

Recall that in [arithmetization](https://www.rareskills.io/post/arithmetic-circuit), we flatten our verification program into a series of intermediate steps, where each intermediate step only contains a single multiplication between unknown variables.

**Consider the following verification example:**

```python
def someProblem(x, y, out):
  res = y^2 + 4*(x^2)*y -2 
  assert out == res, "incorrect inputs";
```

**Conversion to an R1CS would yield us:**

```jsx
v1  === y * y
v2  === x * x 
out === v1 + (4v2 * y) - 2
```

- The R1CS format requires us to restructure the problem into intermediate steps that only have 1 multiplication operation between signals to adhere the quadratic constraint limitation.
- This creates our system of constraints.

**Consequently, the R1CS representation would be:**

```jsx
//     Cw = Aw * Bw
       v1  = y * y
       v2  = x * x 
out -v1 +2 = (4v2 * y)
```

Since we previously ensured that there was only 1 multiplication per constraint, we are able to express the system of constraints in vector form, which is an R1CS.

## Examples of Non-multiplicative Operators Causing a Non quadratic Constraint

If an illegal operation (not addition or multiplication) is used in a constraint, the Circom compiler will report the “Non quadratic constraints are not allowed!” error.

Here, we provide some examples.

### Example 1: Signals Cannot Be Used to Index Signal Arrays

The following operation will result in a quadratic constraints violation. There is no direct translation from array indexing to addition and multiplication. The following code results in the error `Non-quadratic constraint was detected statically, using unknown index will cause the constraint to be non-quadratic`:

```jsx
template KMustEqual5(n) {

  signal input in[n];
  signal input k;
  
  // not allowed
  in[k] === 5;
}
```

It is still technically possible to accomplish array indexing, but this requires a more complex solution we will show in a later chapter.

### Example 2: Signals Cannot Use Operations Such as % and <<

The following constraints will create a “Non quadratic constraints are not allowed!” violation:

```jsx
template Example() {
  signal input a;
  signal input b;
  
  // not allowed
  a === b % 5;
  
  // not allowed
  a === b << 2;
}
```

## How Circom handles division

Somewhat subtly, Circom will allow “division” by a constant, because it can simply be replaced by multiplication by that number's multiplicative inverse. As such, the following code is valid:

```jsx
template Example() {
  signal input a;
  signal input b;
  
  a === b / 2;
}

component main = Example();
```

However, dividing signals is not allowed because that means we computed the signal’s multiplicative inverse, which does not have a direct translation to only addition and multiplication. Computing the multiplicative inverse is usually done with the [extended euclidean algorithm](https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm), which requires loops and conditional statements — operations that cannot be natively expressed with addition and multiplication.

```jsx
template Example() {
  signal input a;
  signal input b;
  signal input c;
  
  // not allowed
  a === b / c;
}

component main = Example();
```

In contrast, subtraction of signals is allowed because it directly translates to multiplication by the constant `-1`:

```jsx
template Example() {
  signal input a;
  signal input b;
  
  // allowed
  a === b - a;
  
  // equivalent
  a === b + -1*a
}

component main = Example();
```

Integer division, as opposed to multiplication by the modular inverse is represented by the `\` and it is not allowed to be applied to signals:

```jsx
template Example() {
  signal input a;
  signal input b;
  
  // can only use \ with variables
  // not signals
  a === b \ 2;
}

component main = Example();
```

For variables, you have both integer division and “normal” division (i.e., multiplication with the multiplicative inverse of the divisor).

For signals, on the other hand, only “normal” division (in the above sense) is allowed.

## Summary

A constraint can only have one multiplication between signals, but there is no limit on the number of additions.

It might seem that this restriction makes it impossible to express any interesting computation beyond simple arithmetic, but we will see later in this tutorial series that there exist numerous clever design patterns to work around this limitation.

Once we understand the design patterns, we can compose them to model much more complex algorithms.
