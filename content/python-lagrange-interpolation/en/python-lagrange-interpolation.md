# Langrange Interpolation with Python

Lagrange interpolation is a technique for computing a polynomial that passes through a set of $n$ points.

## Interpolating a vector as a polynomial
### Examples

#### A straight line through two points
Consider that if we have two points, they can be interpolated with a line. For example, given $(1, 1)$ and $(2, 2)$, we can draw a line that intersects both points, it would be a degree 1 polynomial $y = x$.

#### A single point
Now consider that if we have one point, we can draw a line through that point with a degree 0 polynomial. For example, if the point is $(3, 5)$ we can draw a line through it $y = 5$ (which is a degree 0 polynomial).

#### Three points and a parabola
The pattern that we can "draw a polynomial through" $n$ points with a (at most) degree $n - 1$ polynomial holds for any number of points. For example, the points $(0, 0), (1, 1), (2, 4)$ can be interpolated with $y = x^2$. If those points happened to be a straight line, e.g. $(0, 0), (1, 1), (2, 2)$, then we could draw a line through $(1, 1)$ and $(2, 2)$ with a degree 1 polynomial $y = x$, but in general, three points won't be collinear, so we'll need a degree 2 polynomial to cross all the points.

## Python code for Lagrange interpolation
For our purposes isn't important to understand how to compute this polynomial, as there are math libraries that will do it for us. The most common algorithm is *Lagrange interpolation* and we show how to do that in Python.

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

### Uniqueness of the interpolating polynomial
Going back to our example of the points $(1, 1), (2, 2)$, the lowest degree polynomial that interpolates, them, $y = x$. In general,

**For a set of $n$ points, there is a unique lowest-degree polynomial of at most degree $n - 1$ that interpolates them.**

The polynomial of lowest degree that interpolates the polynomials is sometimes called the *Lagrange polynomial*.

The consequence of this is that

**If we use the points $(1,2,...,n)$ as the $x$ values to convert a length $n$ vector to a polynomial via Lagrange interpolation, then the resulting polynomial is unique.**

In other words, given a consistent basis of x-values to interpolate a vector over, there is a unique polynomial that interpolates a given vector. Spoken another way, every length $n$ vector has a unique polynomial representation.

Informally, every $n$ degree vector has a unique $n - 1$ degree polynomial that "represents" it. The degree could be less if, for example, the points are collinear, but the vector will be unique.

The "lowest degree" part is important. Given two points, there are an extremely large number of polynomials that cross those two points -- but the lowest degree polynomial is unique.
