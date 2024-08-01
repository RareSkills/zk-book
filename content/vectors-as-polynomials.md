# Vectors as Polynomials

Nearly all ZK-Proof algorithms rely on the Schwartz-Zippel Lemma to achieve succintness.

The Schwartz-Zippel Lemma states that if we are given two polynomials $p(x)$ and $q(x)$ with degree $d_p$ and $d_q$ respectively, then if $p(x) \neq q(x)$, the number of points where $p(x)$ and $q(x)$ intersect is less than or equal to $\mathsf{max}(d_p, d_q)$.

Let's consider a few examples.

## Example polynomials and the Schwartz-Zippel Lemma
### A straight line crossing a parabola

Consider the polynomial $p(x) = x$ and $q(x) = x^2$. They intersect at $x = 0$ and $x = 1$.

### A degree three polynomial and a degree one polynomial

Consider the polynomials $p(x) = x^3$ and $q(x) = x$. The polynomials intersect at $x = -1$, $x = 0$, and $x = 1$ and nowhere else. The number of intersections is bounded by the maximum degree of the polynomials, which in this case is 3.

## Polynomials in finite fields and the Schwartz-Zippel Lemma
The Schwartz-Zippel Lemma holds for polynomials in [finite fields](https://www.rareskills.io/post/finite-fields) (i.e. all computations are done modulo a prime $p$).

## Polynomial equality testing
We can test that two polynomials are equal by checking if all their coefficients are equal, but this takes $\mathcal{O}(d)$ time.

If instead we could evaluate the polynomials at a random point $u$ we could compare them in $\mathcal{O}(1)$ time.

That is, in a finite field $\mathbb{F}_{p}$, we pick a random value $u$ from $[0,p)$. Then we evaluate $y_f=f(u)$ and $y_g=g(u)$. If $y_f = y_g$, then one of two things msut be true:

1. $f(x) = g(x)$
2. $f(x) \neq g(x)$ and we picked one of the $d$ points where they intersect where $d = \mathsf{max}(\deg(f), \deg(g))$

If $d << p$, then situation 2 is unlikely to the point of being negligible.

For example, if the field $\mathbb{F}_{p}$ has $p \approx 2^{254}$ (a little smaller than a [uint256](https://www.rareskills.io/post/uint-max-value-solidity)), and if the polynomials are not more than one million degree large, then the probability of picking a point where they intersect is

$$
\frac{1\times 10^6}{2^{254}} \approx \frac{2^{20}}{2^{254}} \approx \frac{1}{2^{234}} \approx \frac{1}{10^{70}}
$$

To put a sense of scale on that, the number of atoms in the universe is about $10^{78}$ to $10^{82}$, so it is extremely unlikely that we will pick a point where the polynomials intersect, if the polynomials are not equal.

## Using the Schwartz-Zippel Lemma to test if two vectors are equal

### Interpolating a vector as a polynomial
Consider that if we have two points, they can be interpolated with a line. For example, given $(1, 1)$ and $(2, 2)$, we can draw a line that intersects both points, it would be a degree 1 polynomial $y = x$.

Now consider that if we have one point, we can draw a line through that point with a degree 0 polynomial. For example, if the point is $(10, 5)$ we can draw a line through it $y = 5$ (which is a degree 0 polynomial).

The pattern that we can "draw a polynomial through" $n$ points with a (at most) degree $n - 1$ polynomial holds for any number of points. For example, the points $(0, 0), (1, 1), (2, 4)$ can be interpolated with $y = x^2$. If those points happened to be a straight line, e.g. $(0, 0), (1, 1), (2, 2)$, then we could draw a line through $(1, 1)$ and $(2, 2)$ with a degree 1 polynomial $y = x$, but in general, three points won't be collinear, so we'll need a degree 2 polynomial to cross all the points.

It isn't important to understand how to compute this polynomial, as there are math libraries that will do it for us. The most common algorithm is *Lagrange interpolation* and we show how to do that in Python.

#### Float example
We can compute a polynomial $p(x)$ that crosses through the points $(1,4), (2,8), (3,2), (4,1)$ using Lagrange interpolation.

```python
from scipy.interpolate import lagrange
x_values = [1, 2, 3, 4]
y_values = [4, 8, 2, 1]

print(lagrange(x_values, y_values))
#      3      2
# 2.5 x - 20 x + 46.5 x - 25
```

#### Finite field example
Let's use the same polynomial as before, but this time we'll use a finite field $\mathbb{F}_{17}$ instead of floating point numbers.

```python
import galois
import numpy as np
GF17 = galois.GF(17)

xs = GF17(np.array([1,2,3,4]))
ys = GF17(np.array([4,8,2,1]))

p = galois.lagrange_poly(xs, ys)

assert p(1) == GF17(4)
assert p(2) == GF17(8)
assert p(3) == GF17(2)
assert p(4) == GF17(1)
```