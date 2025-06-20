# Indicate Then Constrain

If we want to say that “`x` can be equal to 5 or 6” we can simply use the following constraint:

```jsx
(x - 6) * (x - 5) === 0
```

However, suppose we want to say that “`x` is less than 5 or `x` is greater than 17.” In this case, we cannot just combine both conditions directly, because if `x` is less than 5, it will violate the constraint that `x` is greater than 17 and vice versa.

The solution is to create *indicator* signals of the different conditions (e.g., `x` being less than 5, or being greater than 17), then apply constraints to the indicators.

## Circomlib Comparator Library

The [Circomlib comparator library](https://github.com/iden3/circomlib/blob/master/circuits/comparators.circom) contains a component `LessThan` that returns 0 or 1 to indicate if `in[0]` is less than `in[1]`. How this component works is described in the [Arithmetic Circuit](https://www.rareskills.io/post/arithmetic-circuit) chapter. But as a summary, suppose `x` and `y` are at most 3 bits large. If we compute `z = 2^3 + (x - y)`, then if `x` is less than `y`,  `z` will be less than 2^3 and vice versa (2^3 = 8). Since `z` is a 4-bit number, we can efficiently check if `z` is less than 2^3 by looking only at the most significant bit. 2^3 in binary is `1000₂`. Every 4-bit number greater than or equal to 2^3 has the most significant bit equal to 1, and every 4-bit number less than 2^3 has the most significant bit equal to 0.

| Number | Binary Representation | Is greater or equal to 2^3 |
| --- | --- | --- |
| 15 | 1111 | Yes |
| 14 | 1110 | Yes |
| 13 | 1101 | Yes |
| … |  |  |
| 10 | 1010 | Yes |
| 9 | 1001 | Yes |
| 8 (2^3) | 1000 | Yes |
| 7 | 0111 | No |
| 6 | 0110 | No |
| … |  |  |
| 2 | 0010 | No |
| 1 | 0001 | No |
| 0 | 0000 | No |

For general n-bit numbers, we can check if `x` is greater than or equal to 2^n by checking if the most significant bit is set. Therefore, we can generalize that if `x` and `y` are `n-1` bit numbers, then we can detect if `x < y` by checking if the most significant bit of `2^(n-1) + (x - y)` is set or not.

Here is a minimal example of using the LessThan template:

```jsx
include "circomlib/comparators.circom";

template Example () {
  signal input a;
  signal input b;
  signal output out;
  
  // 252 will be explained in the next section
  out <== LessThan(252)([a, b]);
}

component main = Example();

/* INPUT = {
  "a": "9",
  "b": "10"
} */
```

## Where 252 comes from

Numbers in a [finite field](https://www.rareskills.io/post/finite-fields) (which is what Circom uses) cannot be compared to each other as “less than” or “greater” since the typical algebraic laws of inequalities do not hold.

For example, if $x > y$, then if $c$ is positive, it should always be true that $x+c>y+c$. However, this is not true in a finite field. We could pick $c$ such that it is the additive inverse of $x$, i.e. $x + c=0\mod p$. We will then end up with a nonsensical statement that 0 is greater than a non-zero number. For example, if $p = 7$ and $x=2$ and $y=1$ we have that $x>y$. However, if we add $5$ to both $x$ and $y$, then we have $0>1$.

The 252 specifies the number of bits in the `LessThan` component to limit how large `x` and `y` can be, so that a meaningful comparison can be made (the section above used 4 bits as an example).

Circom can hold numbers up to 253 bits large in the finite field. For security reasons discussed in the [Alias Check](https://www.rareskills.io/post/circom-aliascheck) chapter, we should not convert a field element to a binary representation that can encode numbers larger than the field. Therefore, Circom does not allow comparison templates to be instantiated with more than 252 bits ([source code](https://github.com/iden3/circomlib/blob/252f8130105a66c8ae8b4a23c7f5662e17458f3f/circuits/comparators.circom#L90)).

However, recall that for `LessThan(n)` we need to compute `z = 2^n + (x - y)`, and `2^n` needs to be one bit larger than `x` or `y`. Therefore, `x` and `y` need to be at most $2^{n-1}$ bits large. Since Circom supports numbers up to 253 bits large, `x` and `y` must be at most 252 bits large.

## x is less than 5 or x is greater than 17

Thankfully, the Circomlib library will do the bulk of the work for us. We will use the output signals of LessThan and GreaterThan components to *indicate* if x is less than 5 or greater than 17.

Then, we *constrain* that at least one of them is 1 by using the OR component (which is simply `out <== a + b - a * b` under the hood).

```jsx
pragma circom 2.1.6;

include "circomlib/comparators.circom";
include "circomlib/gates.circom";

template DisjointExample1() {
  signal input x;
  
  signal indicator1;
  signal indicator2;

  indicator1 <== LessThan(252)([x, 5]);
  indicator2 <== GreaterThan(252)([x, 17]);

  component or = OR();
  or.a <== indicator1;
  or.b <== indicator2;

  or.out === 1;
}

component main = DisjointExample1();

/* INPUT = {
  "x": "18"
} */
```

**It is very important to include the constraint `or.out === 1;`, otherwise the circuit would accept the signals `indicator1` and `indicator2` both being zero. We'll get back to this in greater detail towards the end of this chapter.**

### Simplifying the code

The code above can be simplified by using the indicator signals implicitly, as demonstrated next:

```jsx
pragma circom 2.1.6;

include "circomlib/comparators.circom";
include "circomlib/gates.circom";

template DisjointExample1() {
  signal input x;

  component or = OR();
  or.a <== LessThan(252)([x, 5]);
  or.b <== GreaterThan(252)([x, 17]);
  or.out === 1;   
}

component main = DisjointExample1();

/* INPUT = {
  "x": "18"
} */
```

## It is not the case that both x < 100 and y < 100

 To express the above case where both `x` < 100 and `y` < 100,” we can use a NAND gate. The NAND gate returns 1 for all combinations **except** when both inputs are 1, which has the following truth table:

| a | b | out |
| --- | --- | --- |
| 0 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

Therefore, we can create an indicator signal that `x` is less than 100 and an indicator signal that `y` is less than 100, and constrain a NAND relationship between them.

```jsx
pragma circom 2.1.6;

include "circomlib/comparators.circom";
include "circomlib/gates.circom";

template DisjointExample2() {
  signal input x;
  signal input y;

  component nand = NAND();
  nand.a <== LessThan(252)([x, 100]);
  nand.b <== LessThan(252)([y, 100]);
  nand.out === 1;   
}

component main = DisjointExample2();

/* INPUT = {
  "x": "18",
  "y": "100"
} */
```

## k is greater than at least 2 of x, y, or z

In this example, we are trying to express that `k` is greater than `x` and `y` or `k` is greater than `x` and `z`, or `k` is greater than `y` and `z`. `k` could be greater than `x`, `y`, and `z`, but that isn’t required.

Since it is verbose to express such a complicated logic expression above, it’s simpler to add up the number of signals `k` is greater than, and then check that this number is 2 or more.

```jsx
pragma circom 2.1.6;

include "circomlib/comparators.circom";
include "circomlib/gates.circom";

template DisjointExample3(n) {
  signal input k;
  signal input x;
  signal input y;
  signal input z;
  
  signal totalGreaterThan;
  
  signal greaterThanX;
  signal greaterThanY;
  signal greaterThanZ;
  
  greaterThanX <== GreaterThan(252)([k, x]);
  greaterThanY <== GreaterThan(252)([k, y]);
  greaterThanZ <== GreaterThan(252)([k, z]);
  
  totalGreaterThan = greaterThanX + greaterThanY + greaterThanZ;
  
  signal atLeastTwo;
  atLeastTwo <== GreaterEqThan(252)([totalGreaterThan, 2]);
  atLeastTwo === 1;
}

component main = DisjointExample3();

/* INPUT = {
  "k": 20
  "x": 18,
  "y": 100,
  "z": 10
} */
```

## Do not forget to constrain the outputs of components!

Sometimes, developers may forget to constrain the output of components, **which can lead to severe security vulnerabilities!** For example, the following code might seem like it enforces that `x` and `y` both be equal `1`, but this is not the case. `x` and `y` could be zero (or any other arbitrary value). The *output* of the AND gate will be zero if `x` and `y` are zero, but the output is not constrained to be anything.

```jsx
template MissingConstraint1() {
  signal input x;
  signal input y;

  component and = AND();
  and.a <== x;
  and.b <== y;
  
  // and.out is not constrained, so x and y can have any values!
}
```

Similarly, the following circuit does not force `x` to be less than 100. The output of LessThan is 1 if `x` is less than 100, but the code doesn’t constrain the output to ensure that this is indeed true.

```jsx
template MissingConstraint2() {
  signal input x;

  component lt = LessThan(252);
  lt.in[0] <== x;
  lt.in[1] <== 100;
  	
  // x could be ≥ 100 since lt.out is allowed to be 0 or any other arbitrary value
}
```
