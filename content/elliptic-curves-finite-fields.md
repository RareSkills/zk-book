# Elliptic Curves over Finite Fields

What do elliptic curves in finite fields look like?

It’s easy to visualize smooth elliptic curves, but what do elliptic curves over a finite field look like?

The following is a plot of $y² = x³ + 3 \pmod 23$

![Plot of y² = x³ + 3 \pmod 23](https://static.wixstatic.com/media/935a00_9b8594bdeb9b4eb580847f1d5ffcd6c0~mv2.png/v1/fill/w_614,h_678,al_c,lg_1,q_90,enc_auto/935a00_9b8594bdeb9b4eb580847f1d5ffcd6c0~mv2.png)

Because we only allow integer inputs (more specifically, [finite field](https://www.rareskills.io/post/finite-fields) elements), we are not going to obtain a smooth plot.

Not every $x$ value will result in an integer for the $y$ value when we solve the equation, so no point will be present at that value for $x$. You can see such gaps in the plot above.

Code to generate this plot will be provided later.

### The prime number changes the plot dramatically
Here are some plots of $y² = x³ + 3$ done over modulo 11, 23, 31, and 41 respectively. The higher the modulus, the more points it holds, and the more complex the plot appears to be.

![Plot of elliptic curves modulo 11, 23](https://static.wixstatic.com/media/935a00_e592040ff7174e81a1f32ed7ed70a150~mv2.png/v1/fill/w_1053,h_565,al_c,q_90,enc_auto/935a00_e592040ff7174e81a1f32ed7ed70a150~mv2.png)

![Plot of elliptic curves modulo 23, 31](https://static.wixstatic.com/media/935a00_382bd8455deb45efba13fdb7d77517b4~mv2.png/v1/fill/w_1053,h_565,al_c,q_90,enc_auto/935a00_382bd8455deb45efba13fdb7d77517b4~mv2.png)

We established in the previous article that elliptic curve points with the "connect and flip" operation are a group. When we do this over a finite field, it remains a group, but it becomes a cyclic group, which is tremendously useful for our application. Why it is cyclic unfortunately will require some very involved math, so you’ll just have to accept that for now. But this should not be too surprising. We have a finite number of points, so generating each point by carrying out $(x + 1)G, (x + 2)G, … (x + order - 1)G$ should at least seem plausible.

In the application of cryptography, $p$ needs to be large. In practice, it is over 200 bits. We will revisit this in a later section.

## Background
### Field element
We’re going to say "field element" a lot in this article, and hopefully from our previous tutorials you are comfortable with that term already. But if not, it is a positive integer that is inside a modulo operation.

That is, if we do addition modulo 11, then the finite field elements from that set is [0,1,…,9,10]. It isn’t correct to say "integers" even though that’s the data type we will use in our Python examples. You cannot have a negative field element (although integers can be negative) when doing addition modulo a prime number. A "negative" number in a finite field is simply the inverse of another number, that is, a number that when summed together results in zero. For example, in a finite field of modulo 11, 4 can be considered "-7" because 7 + 4 (mod 11) is 0, in a comparative sense to how 7 + (-7) is zero for regular numbers.

Over the field of rational numbers, multiplication has the identity element of 1, and the inverse of a number is simply the numerator and the denominator flipped. For example, 500/303 is the inverse of 303/500 because if you multiply them, you get 1.

In a finite field, the inverse of an element is the number you multiply it with to get the finite field element 1. For example, in modulo 23, 6 is the inverse of 4 because when you multiply them together modulo 23, you get 1. When the order of the field is prime, every number except zero has an inverse.

### Cyclic Groups
A cyclic [group](https://www.rareskills.io/group-theory-and-coding) is a group such that every element can be computed by starting with a generator element and repeatedly applying the group’s binary operator.

A very simple example is integers modulo 11 under addition. If your generator is 1, and you keep adding the generator to itself, you can generate every element in the group from 0 to 10.

Saying a elliptic curve points form a cyclic group (under elliptic curve addition) means we can represent every number in a finite field as an elliptic curve point and add them together just like we would regular integers in a finite field.

That is,

5 + 7 (mod p) is homomorphic to 5G + 7G

Where G is the generator of the elliptic curve cyclic group. We’ll show what point corresponds to G later.

This is only true of elliptic curves over finite fields that have a prime number of points, which are the kinds of curves we use in practice. This is something we'll revisit later.

## bn128 formula
The bn128 curve, which is used by the Ethereum precompiles to verify ZK proofs, is specified as follows:

$$
p = 21888242871839275222246405745257275088696311157297823662689037894645226208583
$$

$$
y² = x³ + 3 \pmod p
$$

The field_modulus should not be confused with the curve order, which is the number of points on the curve.

For the bn128 curve, the curve order is as follows:

```python
from py_ecc.bn128 import curve_order
# 21888242871839275222246405745257275088548364400416034343698204186575808495617
print(curve_order)
```

The field modulus is very large, which makes experimenting with it unwieldy. In the next section, we’ll build up an intuition for elliptic curve points in finite fields using the same formula, but with a smaller modulus.

## Generating elliptic curve cyclic group y² = x³ + 3 (mod 11)
To solve the equation above, and determine which $(x, y)$ points are on the curve, we’ll need to compute $\mathsf{sqrt}(x³ + 3) \pmod {11}$.

### Modular square roots
We use the [Tonelli Shanks Algorithm](https://en.wikipedia.org/wiki/Tonelli%E2%80%93Shanks_algorithm) to compute modular square roots. You can read up on how the algorithm works if you are curious, but for now you can treat it as a black box that computes the mathematical square root of a field element over a modulus, or lets you know if the square root does not exist.

For example, the square root of 5 modulo 11 is 4 (4 x 4 mod 11 = 5), but there is no square root of 6 modulo 11. (The reader is encourage to discover this is true via brute force).

Square roots often have two solutions, a positive and a negative one. Although we don’t have numbers with a negative sign in a finite field, we still have a notion of "negative numbers" in the sense of having an inverse.

You can find code online to implement the algorithm described above, but to avoid putting large chunks of code in this tutorial, we will install a python library instead.

For example, the square root of 5 modulo 11 is 4 (4 × 4 mod 11 = 5), but there is no square root of 6 modulo 11. (The reader is encourage to discover this is true via brute force).

Square roots have two solutions, a positive and a negative one. Although we don’t have numbers with a negative sign in a finite field, we still have a notion of “negative numbers” in the sense of having an inverse.

You can find code online to implement the algorithm described above, but to avoid putting large chunks of code in this tutorial, we will install a Python library instead.

```bash
python3 -m pip install libnum
```

After installing [libnum](https://pypi.org/project/libnum/), we can run the following code to demonstrate its use.

```python
from libnum import has_sqrtmod_prime_power, has_sqrtmod_prime_power

# the functions take arguments# has_sqrtmod_prime_power(n, field_mod, k), where n**k,
# but we aren't interested in powers in modular fields, so we set k = 1
# check if sqrt(8) mod 11 exists
print(has_sqrtmod_prime_power(8, 11, 1))
# False

# check if sqrt(5) mod 11 exists
print(has_sqrtmod_prime_power(5, 11, 1))
# True

# compute sqrt(5) mod 11
print(list(libnum.sqrtmod_prime_power(5, 11, 1)))
# [4, 7]

assert (4 ** 2) % 11 == 5
assert (7 ** 2) % 11 == 5

# we expect 4 and 7 to be inverses of each other, because in "regular" math, the two solutions to a square root are sqrt and -sqrt
assert (4 + 7) % 11 == 0
```
Now that we know how to compute modular square roots, we can iterate through values of $x$ and compute $y$ from the formula $y² = x³ + b$. Solving for $y$ is just a matter of taking the modular square root of both sides (if it exists) and saving the resulting $(x, y)$ pairs so we can plot them later.

Let’s create a simple plot of an elliptic curve

$$y² = x³ + 3 (mod 11)$$

```python
import libnum
import matplotlib.pyplot as plt

def generate_points(mod):
    xs = []
    ys = []
    def y_squared(x):
        return (x**3 + 3) % mod

    for x in range(0, mod):
        if libnum.has_sqrtmod_prime_power(y_squared(x), mod, 1):
            square_roots = libnum.sqrtmod_prime_power(y_squared(x), mod, 1)

            # we might have two solutions
            for sr in square_roots:
                ys.append(sr)
                xs.append(x)
    return xs, ys


xs, ys = generate_points(11)
fig, (ax1) = plt.subplots(1, 1);
fig.suptitle('y^2 = x^3 + 3 (mod p)');
fig.set_size_inches(6, 6);
ax1.set_xticks(range(0,11));
ax1.set_yticks(range(0,11));
plt.grid()
plt.scatter(xs, ys)
plt.plot();
```