# Arithmetic Circuits for ZK Take 6

One key point from our article on [P vs NP](https://www.rareskills.io/post/p-vs-np) was that any solution to a problem in P or NP can be verified by modeling the problem as a Boolean circuit. Then, we convert our solution for the original problem to a set of values for the Boolean variables (called the witness) that results in the Boolean circuit returning true.

This article continues the one linked above, so please read that first.

## Arithmetic circuits as an alternative to Boolean circuits

One disadvantage of using a Boolean circuit to represent a solution to a problem is that it can be verbose when representing arithmetic operations such as addition or multiplication.

For example, if we want to express "a + b = c where a = 16, b = 8, c = 24," we must transform a, b, and c into binary numbers. Each bit in the binary number will correspond to a distinct Boolean variable. In this example, let's assume we need 4 bits to encode a, b, and c, where a₀ represents the Least Significant Bit (LSB), and a₃ represents the Most Significant Bit (MSB) of number a, as shown below:  

- `a₃, a₂, a₁, a₀`
- a = 1000
- `b₃, b₂, b₁, b₀`
- b = 0100
- `c₃, c₂, c₁, c₀`
- c = 1100

(The method to convert a number to binary is explained later in this article). Once we have a, b, c written in binary, we can write a Boolean circuit whose inputs are all the binary digits (a₀, a₁, …, c₂, c₃). Our goal is to write such a Boolean circuit, such that the circuit outputs true if and only if a + b = c. This turns out to be more complicated than we might expect, as you can see in the large circuit below, which models a + b = c in binary. For the sake of brevity, we do not show the derivation. We only show the formula to illustrate how verbose such a circuit can be:

```rust
((a₄ ∧ b₄ ∧ c₄) ∨ (¬a₄ ∧ ¬b₄ ∧ c₄) ∨ (¬a₄ ∧ b₄ ∧ ¬c₄) ∨ (a₄ ∧ ¬b₄ ∧ ¬c₄)) ∧

((a₃ ∧ b₃ ∧ ((a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) ∨ 
 (¬a₃ ∧ ¬b₃ ∧ ((a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) ∨ 
 (¬a₃ ∧ b₃ ∧ ¬((a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) ∨
 (a₃ ∧ ¬b₃ ∧ ¬((a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀))))) ∧

((a₂ ∧ b₂ ∧ ((a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀))) ∨ 
 (¬a₂ ∧ ¬b₂ ∧ ((a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀))) ∨ 
 (¬a₂ ∧ b₂ ∧ ¬((a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) ∨
 (a₂ ∧ ¬b₂ ∧ ¬((a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀))))) ∧

((a₁ ∧ b₁ ∧ c₀) ∨ (¬a₁ ∧ ¬b₁ ∧ c₀) ∨ (¬a₁ ∧ b₁ ∧ ¬c₀) ∨ (a₁ ∧ ¬b₁ ∧ ¬c₀)) ∧

((a₀ ∧ b₀ ∧ c₀) ∨ (¬a₀ ∧ ¬b₀ ∧ c₀) ∨ (¬a₀ ∧ b₀ ∧ ¬c₀) ∨ (a₀ ∧ ¬b₀ ∧ ¬c₀)) ∧

¬ ((a₄ ∧ b₄) ∨ 
     (b₄ ∧ (a₃ ∧ b₃) ∨ (b₃ ∧ (a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀))) ∨ 
     (a₃ ∧ (a₂ ∧ b₂) ∨ (b₂ ∧ (a₁ ∧ b₁) ∨ (b₁ ∧ c₀) ∨ (a₁ ∧ c₀)))) 
```

The point is, if we are restricted to Boolean inputs and basic Boolean operations (AND, OR, NOT), constructing circuits can quickly become complicated and tedious for basic problems, especially when those problems involve arithmetic.

In contrast, it would be simpler to directly represent numbers inside a circuit. Instead of modeling addition with a Boolean formula, we directly use addition and multiplication on those numbers.

This article demonstrates that it is also possible to model any problem in P or NP with an *arithmetic circuit*.

## Arithmetic Circuits

An arithmetic circuit is a system of equations using only addition, multiplication, and equality. Like a Boolean circuit, it checks that a proposed set of inputs is valid, but doesn’t compute a solution.

The following is our first example of an arithmetic circuit:

```solidity
6 = x₁ + x₂
9 = x₁x₂
```

We say a Boolean circuit is *satisfied* if we have an assignment to the input variables that results in an output of true. Similarly, an arithmetic circuit is satisfied if there is an assignment to the variables such that all the equations hold true. For example, the circuit above is satisfied by `x₁ = 3, x₂ = 3` because both equations of the circuit hold true, and the circuit is *not* satisfied by `x₁ = 1, x₂ = 6` because the equation `9 = x₁x₂` fails to be true

So, we can think of an arithmetic circuit interchangeably with the set of equations in the circuit. A set of inputs “satisfies the circuit” if and only if those inputs make *all* the equations true.

## Notation and Terminology

Variables in an arithmetic circuit are referred to as **signals**. We will call variables signals because [Zero Knowledge (ZK) Programming Languages](https://www.rareskills.io/post/zero-knowledge-programming-language) refer to them as such.

When we write equality, we will use the `===` operator. We use this notation because [Circom](https://docs.circom.io) (the programming language we will use to write ZK Proofs) uses it to state two signals hold equal value, so we may as well get accustomed to seeing it.

We emphasize that the `===` is asserting the left-hand side and right-hand side are equal. For example, in the following circuit:

`c === a + b`

**we are not adding `a` to `b` and assigning it to `c`**. **We assume that the values `a`, `b`, and `c` are provided as inputs, and we are asserting a relationship between them holds. This has the effect of *constraining* the sum of `a` and `b` to be `c`.**

Think of the `c === a + b` as being completely equivalent to `assertEq(c, a + b)`. Similarly, the expression `a + b === c * d` is completely equivalent to `assertEq(a + b, c * d)`. In essence, verifying these equations in a circuit involves checking if certain conditions (constraints) are satisfied. The agent proving the validity of their witness can assign any values to signals. However, their proof (witness) will only be considered valid if all the constraints are met.

If an agent wishes to prove:

```solidity
a === b + c + 3
a * u === x * y
```

they must supply `(a, b, c, u, x, y)` from *outside the circuit* and assign them to the signals in the circuit.

Remember, the code above is equivalent to:

```solidity
assertEq(a, b + c + 3)
assertEq(a * u, x * y)
```

A useful mental model for the arithmetic circuit is that all signals are treated as inputs without outputs.

To drive the point home, we supply a visualization in the following video. All of the signals are inputs, and `===` is used to check instead of assign.

[ArithmeticCircuit.mp4](Arithmetic%20Circuits%20for%20ZK%20Take%206%20f95263458ad34576acc6595d6aa156a4/ArithmeticCircuit.mp4)

The circuit in the video could have been written as:

```solidity
z + y === x
x + y === u
```

with no change in meaning.

The arithmetic circuit `x === x + 1` does not mean increment x. It is an arithmetic circuit with no solution because x cannot be equal to x + 1. Thus, it is impossible to satisfy the constraint.

### Interpreting Arithmetic Circuits

Consider the following circuit:

```solidity
x₁(x₁ - 1) === 0
x₁x₂ === x₁
```

The first constraint `x₁(x₁ - 1) === 0` restricts the possible values x₁ to only 0 or 1. Any other value for x₁ would not satisfy this constraint.

In the second constraint `x₁x₂ === x₁` we have two possible scenarios:

- If `x₁ = 1`, then `x₂` must also be 1, or the second constraint cannot be satisfied. If `x₁ = 1` and `x₂ ≠ 1`, then the second equation becomes `1 * x₂ === 1` which can only be satisfied by `x₂ = 1`.
- If `x₁ = 0`, then `x₂` can have any value because `0x₂ === 0` is trivial to satisfy.

The following assignments to (x₁, x₂) are all valid witnesses:

- (x₁, x₂) = (1, 1)
- (x₁, x₂) = (0, 2)
- (x₁, x₂) = (0, 1337)
- (x₁, x₂) = (0, 404)

Remember, a system of equation can have many solutions. Similarly, an arithmetic circuit can also have many solutions. Usually though, we’re only interested in verifying a given solution. We don’t need to find all solutions for an arithmetic circuit.

### Boolean vs Arithmetic Circuit

The table below shows how Boolean circuits and arithmetic circuits differ, but keep in mind they serve the same purpose of validating a witness:

| Boolean Circuit | Arithmetic Circuit |
| --- | --- |
| Variables are 0, 1 | Signals hold numbers |
| Only operations are AND, OR, NOT | Only operations are addition and multiplication |
| Satisfied when the output is true | Satisfied when the left hand side equals the right hand side for all equations (there is no output) |
| Witness is an assignment to the Boolean variables that satisfies the Boolean circuit | Witness is an assignment to the signals that satisfies all the equality constraints |

Aside from the convenience of using fewer variables in some circumstances, arithmetic circuits and Boolean circuits are tools that accomplish the same job — proving you have a witness to a problem in NP.

### a + b = c

Let’s revisit our example above: writing a *Boolean* circuit to represent the equation `a + b = c`, where we’re given `c = 24`. For a Boolean circuit, we need to encode `a`, `b`, and `c` in binary, which requires 4 bits each. In total, we have 12 inputs to the circuit. By comparison, the arithmetic circuit only requires 3 inputs: `a`, `b`, and `c`. This reduction in the number of inputs, and also in the size of the circuit, is the reason we opt to use arithmetic circuits for ZK applications.

### Similarities between systems of equations and arithmetic circuits

Boolean circuits always have one expression that returns true or false if the witness is satisfied.

For example, if we have a set of signals x, y, and z, and we wish to constrain the sum of x and y to be 5, then we need a separate equation for that. Any way we wish to constrain z would have its own separate equation.

To demonstrate arithmetic circuits and Boolean circuits are equivalent, we will later show that any Boolean circuit can be transformed into an arithmetic circuit. This shows they can be used interchangeably for the purpose of demonstrating an agent has a witness to a problem in P or NP. 

### All P problems are a subset of NP problems

As discussed in the previous chapter, **all P problems are a subset of NP problems** in terms of the computation requirements for validating a witness, so we will only refer to NP problems going forward, with the understanding that this includes P.

Our conclusion is that if any solution to a problem in NP can be modeled with a Boolean circuit, then any solution to a problem in NP (or P) can be modeled with an arithmetic circuit.

But before we demonstrate their equivalence, we will provide examples of modeling the solutions to problems in NP so we get an intuition for how arithmetic circuits are used.

## Examples of Arithmetic circuits

In our first example, we redo our 3-coloring problem for Australia. In the second, we use an arithmetic circuit to prove a list is sorted.

### Example 1: Modeling 3-coloring with an Arithmetic Circuit

When we used a Boolean circuit to model a 3-coloring, each territory had 3 Boolean variables - one for each color - indicating whether the country had been assigned that color. We then added constraints to force each territory to have exactly one color (color constraints) and constraints to enforce that adjacent territories did not get the same color (boundary constraints).

It’s easier to model this problem using arithmetic circuits because we can assign a single signal to each territory with the possible values {1, 2, 3} to model their colors, instead of three Boolean variables. We can arbitrarily assign colors to the numbers, such as blue = 1, red = 2, and green = 3.

For each territory, we write the single color constraint as:

```rust
0 === (1 - x) * (2 - x) * (3 - x)
```

to enforce that each territory has exactly one color. The constraint above can only be satisfied if x is 1, 2, or 3.

**3-Coloring Australia**

![580px-Australia_map,_States.svg.jpg](Arithmetic%20Circuits%20for%20ZK%20Take%206%20f95263458ad34576acc6595d6aa156a4/580px-Australia_map_States.svg.jpg)

Recall that Australia has six territories:

- `WA` = West Australia
- `SA` = South Australia
- `NT` = Northern Territory
- `Q` = Queensland
- `NSW` = New South Wales
- `V` = Victoria

Saying `WA = 1` is equivalent to saying “Color West Australia Blue.” Similarly, `WA = 2` means “red” was assigned to West Australia, and `WA = 3` means “green” was assigned.

Our color constraint (constraining each territory to be blue, red or green) for each territory becomes:

```jsx
1) 0 === (1 - WA) * (2 - WA) * (3 - WA)
2) 0 === (1 - SA) * (2 - SA) * (3 - SA)
3) 0 === (1 - NT) * (2 - NT) * (3 - NT)
4) 0 === (1 - Q) * (2 - Q) * (3 - Q)
5) 0 === (1 - NSW) * (2 - NSW) * (3 - NSW)
6) 0 === (1 - V) * (2 - V) * (3 - V)
```

We now want to enforce that neighboring territories do not have the same color. One way to accomplish this is to multiply the signals of the neighboring territory and ensure that the product is an “acceptable” one. Consider the following table for neighboring territories `x` and `y`:

| x | y | product |
| --- | --- | --- |
| 1 | 1 | 1 |
| 1 | 2 | 2 |
| 1 | 3 | 3 |
| 2 | 1 | 2 |
| 2 | 2 | 4 |
| 2 | 3 | 6 |
| 3 | 1 | 3 |
| 3 | 2 | 6 |
| 3 | 3 | 9 |

If two signals (neighboring territories) have the same number (color), then their product will be one of {1, 4, 9}, the orange numbers above. If `x` and `y` are constrained to be 1, 2, or 3, and `x` and `y` are not equal to each other, then the product `xy` will be one of {2, 3, 6}. Therefore, if `xy = 2` or `xy = 3` or `xy = 6`, we accept the assignment because it means the two neighbors have different colors.

For each neighboring territory `x` and `y`, we can use the following constraint to enforce that they are not equal to each other:

```
0 === (2 - xy) * (3 - xy) * (6 - xy)
```

The above equation is satisfied if and only if the product `xy` is equal to 2, 3, or 6.

The boundary constraints are created by iterating through the borders and applying the boundary constraints between each pair of neigboring territories as the video below illustrates:

[AustraliaNP (2).mp4](Arithmetic%20Circuits%20for%20ZK%20Take%206%20f95263458ad34576acc6595d6aa156a4/AustraliaNP_(2).mp4)

We now show the boundary constraints:

```rust
Western Australia and South Australia:
7) 0 === (2 - WA * SA) * (3 - WA * SA) * (6 - WA * SA)

Western Australia and Northern Territory
8) 0 === (2 - WA * NT) * (3 - WA * NT) * (6 - WA * NT)

Northern Territory and South Australia
9) 0 === (2 - NT * SA) * (3 - NT * SA) * (6 - NT * SA)

Northern Territory and Queensland
10) 0 === (2 - NT * Q) * (3 - NT * Q) * (6 - NT * Q)

South Australia and Queensland
11) 0 === (2 - SA * Q) * (3 - SA * Q) * (6 - SA * Q)

South Australia and New South Wales
12) 0 === (2 - SA * NSW) * (3 - SA * NSW) * (6 - SA * NSW)

South Australia and Victoria
13) 0 === (2 - SA * V) * (3 - SA * V) * (6 - SA * V)

Queensland and New South Wales
14) 0 === (2 - Q * NSW) * (3 - Q * NSW) * (6 - Q * NSW)

New South Wales and Victoria
15) 0 === (2 - NSW * V) * (3 - NSW * V) * (6 - NSW * V)
```

By combining the two, we see the complete arithmetic circuit for proving we have a valid 3-coloring for Australia:

```rust
// color constraints
0 === (1 - WA) * (2 - WA) * (3 - WA)
0 === (1 - SA) * (2 - SA) * (3 - SA)
0 === (1 - NT) * (2 - NT) * (3 - NT)
0 === (1 - Q) * (2 - Q) * (3 - Q)
0 === (1 - NSW) * (2 - NSW) * (3 - NSW)
0 === (1 - V) * (2 - V) * (3 - V)

// boundary constraints
0 === (2 - WA * SA) * (3 - WA * SA) * (6 - WA * SA)
0 === (2 - WA * NT) * (3 - WA * NT) * (6 - WA * NT)
0 === (2 - NT * SA) * (3 - NT * SA) * (6 - NT * SA)
0 === (2 - NT * Q) * (3 - NT * Q) * (6 - NT * Q)
0 === (2 - SA * Q) * (3 - SA * Q) * (6 - SA * Q)
0 === (2 - SA * NSW) * (3 - SA * NSW) * (6 - SA * NSW)
0 === (2 - SA * V) * (3 - SA * V) * (6 - SA * V)
0 === (2 - Q * NSW) * (3 - Q * NSW) * (6 - Q * NSW)
0 === (2 - NSW * V) * (3 - NSW * V) * (6 - NSW * V)
```

We have 15 constraints just like the Boolean circuit, **but 1/3rd as many variables (signals).** Instead of 3 Boolean variables for each territory, we have one signal for each territory. For larger circuits, this reduction in complexity and space can be substantial.

### Example 2 Proving a List is Sorted

Given a list of numbers `[a₁, a₂, ..., aₙ]`, we say the list is “sorted” if `aₙ ≥ aₙ₋₁ ≥ … a₃ ≥ a₂ ≥ a₁`. In other words, going from the end to the beginning, the numbers are non-increasing.

Our goal is to write an arithmetic circuit that verifies the list is sorted.

To do this, we need an arithmetic circuit that expresses `a ≥ b` for two signals. This turns out to be more complicated than it would seem at first glance because arithmetic circuits only allow for equality, addition, and multiplication, not comparison.

But let’s say we had such a “greater than or equal to” circuit - call it `GTE(a,b)`. Then we would construct the circuits for comparing each pair of consecutive list elements: `GTE(aₙ, aₙ₋₁), ...,  GTE(a₃, a₂), GTE(a₂, a₁)`, and if all of them are satisfied, then the list is sorted.

To compare two decimal numbers without the ≥ operator, we first need an arithmetic circuit that validates a proposed binary representation for the number, so we first go on a small detour about binary numbers.

### Prerequisite: Binary encoding

We write binary numbers with the subscript 2. For example, 11₂ is 3 and 101₂ is 5. Each of the 1s and 0s is called a bit. We say the left-most bit is the most significant bit (MSB) and the right-most bit is the least significant bit (LSB).

As we will show shortly, during conversion to decimal, the most significant bit is multiplied by the largest coefficient and the least significant bit is multiplied by the smallest coefficient. So if we write a four bit binary number as `b₃b₂b₁b₀`, `b₃` ****is the MSB and `b₀` is the LSB.

The video below illustrate the conversion of 1101₂ to 13:

[BinaryToDecimal (1).mov](Arithmetic%20Circuits%20for%20ZK%20Take%206%20f95263458ad34576acc6595d6aa156a4/BinaryToDecimal_(1).mov)

As shown in the video, a four bit binary number can be converted to a decimal number `v` with the following formula:

`v = 8b₃ + 4b₂ + 2b₁ + b₀`

This could also be written as:

`v = 2³b₃ + 2²b₂ + 2¹b₁ + 2⁰b₀`

For example, 1001₂ = 9, 1010₂ = 10, and so forth. For a general `n` bit binary number, the conversion is:

`v = 2ⁿ⁻¹b₃ + ... + 2¹b₁ + 2⁰b₀`

We omit a discussion of how to convert a decimal number to binary. For now, if the reader wishes to convert to binary, they can use the built-in `bin` function from Python:

```python
>>> bin(3)
'0b11'
>>> bin(9)
'0b1001'
>>> bin(10)
'0b1010'
>>> bin(1337)
'0b10100111001'
>>> bin(404)
'0b110010100'
```

We can create an arithmetic circuit that asserts “`v` is a decimal number with a four bit binary representation `b₃`, `b₂`, `b₁`, `b₀`” by using the following circuit:

```solidity
8b₃ + 4b₂ + 2b₁ + b₀ === v

// force the "bits" to be zero or one
b₀(b₀ - 1) === 0
b₁(b₁ - 1) === 0
b₂(b₂ - 1) === 0
b₃(b₃ - 1) === 0
```

The signals `b₃, b₂, b₁, b₀` are constrained to be the binary representation of `v`. If `b₃, b₂, b₁, b₀` aren’t binary, or aren’t the binary representation of `v`, then the circuit cannot be satisfied.

Observe that **there is no satisfying assignment to the signals `(v, b₃, b₂, b₁, b₀)`** where `v > 15`. That is, if we set `b₃, b₂, b₁, b₀` to all 1, the highest the constraints allow, then the sum will be 15. It is not possible to add to anything higher. In ZK, this is sometimes called a *range check* on `v`. Not only does the circuit above demonstrate the binary representation of `v`, it also forces `v < 16`.

We can generalize this to the following circuit which constrains `v < 2ⁿ` and also gives us the binary representation of `v`:

```solidity
2ⁿ⁻¹bₙ₋₁ +...+ 2²b₂ + 2¹b₁ + b₀ === v
b₀(b₀ - 1) === 0
b₁(b₁ - 1) === 0
//...
bₙ₋₁(bₙ₋₁ - 1) === 0
```

**Saying a number `v` is encoded with at most `n` bits is equivalent to saying `v < 2ⁿ`.**

To get a sense for how `2ⁿ` changes as a function of n, consider the following table:

| n bits | max value (binary) | max value (decimal) | 2ⁿ (decimal) | 2ⁿ (binary) |
| --- | --- | --- | --- | --- |
| 2 | 11₂ | 3 | 4 | 100 |
| 3 | 111₂ | 7 | 8 | 1000 |
| 4 | 1111₂ | 15 | 16 | 10000 |
| 5 | 11111₂ | 31 | 32 | 100000 |

Note that the number `2ⁿ` in binary requires 1 more bit to store than the value `2ⁿ - 1`. By constraining the number of bits a number is encoded with to `n` bits, it forces that number to be less than `2ⁿ`.

It’s helpful to remember the relationship between powers of 2 and the number of bits required to store them.

- 2ⁿ requires n + 1 bits to store. For example, 2⁰=1₂, 2¹ = 10₂, 2²=100₂, 2³=1000₂ and so forth.
- 2ⁿ⁻¹ is half of 2ⁿ and requires n bits to store
- 2ⁿ − 1 requires n bits to store. It is the maximum value we can store with n bits, when all the bits are set to 1.

If we take a number *n* and compute 2ⁿ, we get an n + 1 bit number with the most significant bit being 1, and the rest zero. `n = 3` in the examples below:

$$
2^n=\underbrace{1000}_{n+1\space bits}
$$

2ⁿ⁻¹ is the same as 2ⁿ / 2. Since it is written as 2 to some power, it still has the same “shape” of a binary number with an MSB of 1 and the rest zero, but it will require n bits to encode it instead of n + 1 bits.

$$
2^{n-1}=\underbrace{100}_{n\space bits}
$$

2ⁿ −1 is an n bit number with all the bits set to one. 

$$
2^n-1=\underbrace{111}_{n\space bits}
$$

### Compute ≥ in binary

If we are working with binary numbers of a fixed size, `n` bits, the number 2ⁿ⁻¹ is special because we can easily assert an `n` bit binary number is greater or equal to 2ⁿ⁻¹ — or less than it. We call 2ⁿ⁻¹ the “midpoint.” The video below illustrates how to compare the size of an `n` bit number to 2ⁿ⁻¹:

[Scene6.mp4](Arithmetic%20Circuits%20for%20ZK%20Take%206%20f95263458ad34576acc6595d6aa156a4/Scene6.mp4)

By checking the most significant bit of an `n` bit number, we can tell if that number is greater than or equal to 2ⁿ⁻¹ or less than 2ⁿ⁻¹.

If we compute `2ⁿ⁻¹ + Δ` and look at the most significant bit of that sum, we can quickly tell if `Δ` is positive or negative. If `Δ` is negative, then `2ⁿ⁻¹ + Δ` must be less than `2ⁿ⁻¹`.

[msb-delta.mp4](Arithmetic%20Circuits%20for%20ZK%20Take%206%20f95263458ad34576acc6595d6aa156a4/msb-delta.mp4)

### Detecting if u ≥ v

If we replace `Δ` with `u - v` then the most significant bit of `2ⁿ⁻¹ + (u - v)` tells us if u ≥ v or u < v.

[u-v.mp4](Arithmetic%20Circuits%20for%20ZK%20Take%206%20f95263458ad34576acc6595d6aa156a4/u-v.mp4)

**Preventing overflow in 2ⁿ⁻¹ + (u - v)**

In the scheme above to compare `u` to `v`, we must ensure that `|u - v| < 2ⁿ⁻¹`, otherwise there might be an arithmetic overflow or underflow when computing `2ⁿ⁻¹ + (u - v)`. *Overflow* happens when we add two numbers together and the sum exceeds what the bits can hold. *Underflow* happens when we subtract `a - b` and `b > a` causing the result to go below zero.

If we restrict `u` and `v` to be represented with at most `n - 1` bits, while `2ⁿ⁻¹` is represented with `n` bits, then underflow and overflow cannot occur. When both `u` and `v` are represented with at most `n - 1` bits, the maximum absolute value of `|u - v|` is a `n - 1` bit number.

We see that `2ⁿ⁻¹ + (u - v)` cannot underflow in this case, because `2ⁿ⁻¹` is at least 1 bit larger than `|u - v|`.

Now consider the overflow case. Without loss of generality, for n = 4 , i.e. four bit numbers, the midpoint is 2ⁿ⁻¹ =  2⁴⁻¹ = 8 or 1000₂. The maximum value `|u - v|` can hold in this case, as a 3 bit number, is 111₂. Adding 1000₂ + 111₂ results in 1111₂, which is not an overflow.

### Summary of the arithmetic circuit for u ≥ v, when u and v are n - 1 bit numbers

- We constrain `u` and `v` to be at most `n - 1` bit numbers.
- We create an arithmetic circuit that encodes the binary representation of `2ⁿ⁻¹ + (u - v)` using `n` bits.
- If the most significant bit of `2ⁿ⁻¹ + (u - v)` is 1, then u ≥ v and vice versa.

Final arithmetic circuit to check if u ≥ v is as follows. We fix `n = 4` which means `u` and `v` must be constrained to be 3-bit numbers. The interest reader can generalize this to other values of `n`:

```jsx
// u and v are represented with at most 3 bits:
2²a₂ + 2¹a₁ + a₀ === u
2²b₂ + 2¹b₁ + b₀ === v

// 0 1 constraints for aᵢ, bᵢ
a₀(a₀ - 1) === 0
a₁(a₁ - 1) === 0
a₂(a₂ - 1) === 0
b₀(b₀ - 1) === 0
b₁(b₁ - 1) === 0
b₂(b₂ - 1) === 0

// 2ⁿ⁻¹ + (u - v) binary representation
2³ + (u - v) === 8c₃ + 4c₂ + 2c₁ + c₀

// 0 1 constraints for cᵢ
c₀(c₀ - 1) === 0
c₁(c₁ - 1) === 0
c₂(c₂ − 1) === 0
c₃(c₃ − 1) === 0

// Check that the MSB is 1
c₃ === 1
```

### Asserting a list is sorted

Now that we have an arithmetic circuits to compare pairs of signals, we repeat this circuit for each sequential pair in the list and verify it is sorted.

## Summary of examples

We’ve shown how we can create an arithmetic circuit modeling the solution to the problems from the previous chapter.

We now generalize this to say we can model any problem in NP using an arithmetic circuit.

## How a Boolean circuit can be modeled with an arithmetic circuit

Every Boolean circuit can be modeled with an arithmetic circuit. By this, we mean we can define a process for converting a Boolean circuit B into an arithmetic circuit A such that a set of inputs that satisfies B can be mapped to a set of signals that satisfies A. Below, we explain the key pieces of this process, and then walk through an example of converting a specific Boolean circuit into an arithmetic circuit.

Suppose we have the following Boolean formula: `out = (x ∧ ¬ y) ∨ z`. This formula is true if (`x` is true AND `y` is false) OR `z` is true.

We encode `x`, `y`, and `z` as arithmetic circuit signals and constrain them to have values 0 or 1.

The following arithmetic circuit can only be satisfied if x, y, z are each 0 or 1.

```rust
x(x - 1) === 0
y(y - 1) === 0
z(z - 1) === 0
```

Now let’s show how to map Boolean circuit operators to arithmetic circuit operators, assuming that the input variables have been constrained to be 0 or 1.

### AND gate

We translate the Boolean AND `t = u ∧ v` into an arithmetic circuit as follows:

```solidity
u(u - 1) === 0
v(v - 1) === 0
t === uv
```

`t` will only be 1 if both `u` and `v` are 1, hence this arithmetic circuit models an AND gate. Because of the constraints `u(u - 1) = 0` and `v(v - 1) = 0`, `t` can only be 0 or 1.

### NOT gate

We translate the Boolean NOT `t = ¬u` into an arithmetic circuit as follows:

```rust
u(u - 1) === 0
t === 1 - u
```

`t` is 1 when `u` is 0 and vice versa. Because of the constraint `u(u - 1) === 0`, `t` can only be 0 or 1.

### OR gate

We translate the Boolean OR `t === u ∨ v` into an arithmetic circuit as follows:

```rust
u(u - 1) === 0
v(v - 1) === 0
t === u + v - uv
```

To see why it models the OR gate, consider the following table:

| u | v | u + v | uv | t (u + v - uv) |
| --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 2 | 1 | 1 |

If `u` or `v` are 1, then `t` will be at least 1. To prevent `t` from equaling 2 (which is an invalid output from a Boolean operator), we subtract `uv`, which will be 1 when both `u` and `v` are 1.

Observe that with all the gates above, we do not need to apply a constraint `t(t - 1) === 0`. The output `t` is implicitly constrained to be 0 or 1 because there is no assignment to the inputs that could result in a value for `t` being 2 or greater.

### Transforming `out = (x ∧ ¬ y) ∨ z` into an arithmetic circuit

Now that we’ve seen how to translate all the allowed operations of Boolean circuits into arithmetic circuits, let’s look at an example of converting a Boolean circuit into an arithmetic one.

### Create the 0 1 constraints

```rust
x(x - 1) === 0
y(y - 1) === 0
z(z - 1) === 0
```

### Replace `¬ y` with the the arithmetic circuit for NOT

out = (x ∧ ¬ y) ∨ z

out = (x ∧ (1 - y)) ∨ z

### Replace `∧` with the arithmetic circuit for AND

out = (x ∧ (1 - y)) ∨ z

out = (x(1 - y)) ∨ z

### Replace `∨` with the arithmetic circuit for OR

out = (x(1 - y)) ∨ z

out = (x(1 - y)) + z - (x(1 - y))z 

Our final arithmetic circuit for `out = (x ∧ ¬ y) ∨ z` is:

```jsx
x(x - 1) === 0
y(y - 1) === 0
z(z - 1) === 0
out === (x(1 - y)) + z - (x(1 - y))z
```

If desired, we could simpify the last equation:

```jsx
out === (x(1 - y)) + z - ((x(1 - y))z)
out === x - xy + z - ((x - xy)z)
out === x - xy + z - (xz - xyz)

out === x - xy + z - xz + xyz
```

We could also write the arithmetic circuit as follows with no change in meaning:

```jsx
x² === x
y² === y
z² === z
out === x - xy + z - xz + xyz
```

## Summary

**If the solution to every problem in NP can be modeled with a Boolean circuit and every Boolean circuit can be transformed into an equivalent arithmetic circuit, then it follows that the solution to every problem in NP can be modeled with an arithmetic circuit.**

In practice, ZK developers prefer to use arithmetic circuits over Boolean circuits because, as shown in the examples above, they generally require fewer variables to accomplish the same task.

There is no need to calculate a Boolean circuit and then transform it into an arithmetic circuit. We can model the solution to the NP problem with an arithmetic circuit directly.

## Next steps

We have glossed over two very important details in this article. Some other challenges exist that need to be addressed. For example:

- We didn’t discuss what datatype we used to store signals for the arithmetic circuit and how we handle overflow during addition or multiplication.
- We have no way of expressing the value 2/3 without losing precision. Any fixed point or floating point representation we chose will have rounding issues

To handle these problems, arithmetic circuits are calculated over *finite fields:* a branch of mathematics where all addition and multiplication is done modulo a prime number.

Finite field arithmetic has some surprising differences from regular arithmetic introduced by the modulo operator, so the next chapter will explore them in detail.

## Learn more with RareSkills

Learn more about [Zero Knowledge Proofs](https://www.rareskills.io/zk-book) in our free ZK Book. This tutorial is a chapter in that book.

## Practice Problems

1. Create an arithmetic circuit that takes signals `x₁`, `x₂`, ..., `xₙ` and is satisfied if *at least* one signal is 0.
2. Create an arithmetic circuit that takes signals `x₁`, `x₂`, ..., `xₙ` and is satsified if all are 1.
3. A bipartite graph is a graph that can be colored with two colors such that no two neighboring nodes share the same color. Devise an arithmetic circuit scheme to show you have a valid witness of a 2-coloring of a graph. Hint: the scheme in this tutorial needs to be adjusted before it will work with a 2-coloring.
4. Devise an arithmetic circuit that constrains `k` to be the maximum of `x`, `y`, or `z`. That is, `k` should be equal to `x` if `x` is the maximum value, and same for `y` and `z`.
5. Create an arithmetic circuit that takes signals `x₁`, `x₂`, ..., `xₙ`, constrains them to be binary, and outputs 1 if *at least* one of the signals is 1. Hint: this is tricker than it looks. Consider combining what you learned in the first two problems and using the NOT gate.
6. Devise an arithmetic circuit to determine if a signal `v` is a power of two (1, 2, 4, 8, etc). Hint: create an arithmetic circuit that constrains another set of signals to encode the binary representation of `v`, then place additional restrictions on those signals.
7. The covering set problem starts with a set S = {1, 2, …, 10} and several well-defined subsets of S, for example: {1, 2, 3}, {3, 5, 7, 9}, {8, 10}, {5, 6, 7, 8}, {2, 4, 6, 8}, and asks if we can take at most `k` subsets of S such that their union is S. In the example problem above, the answer for `k = 4` is true because we can use {1, 2, 3}, {3, 5, 7, 9}, {8, 10}, {2, 4, 6, 8}. Note that for each problems, the subsets we can work with are determined at the beginning. We cannot construct the subsets ourselves. If we had been given the subsets {1,2,3}, {4,5} {7,8,9,10} then there would be no solution because the number 6 is not in the subsets.

On the other hand, if we had been given S = {1,2,3,4,5} and the subsets {1}, {1,2}, {3, 4}, {1, 4, 5} and asked can it be covered with `k = 2` subsets, then there would be no solution. However, if `k = 3` then a valid solution would be {1, 2}, {3, 4}, {1, 4, 5}.

Our goal is to prove for a given set S and a defined list of subsets of S, if we can pick a set of subsets such that their union is S. Specifically, the question is if we can do it with `k` or fewer subsets. We wish to prove we know which `k` (or fewer) subsets to use by encoding the problem as an arithmetic circuit.