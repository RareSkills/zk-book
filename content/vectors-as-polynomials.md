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

### Uniqueness of the interpolating polynomial
Going back to our example of the points $(1, 1), (2, 2)$, the lowest degree polynomial that interpolates, them, $y = x$. In general,

**For a set of $n$ points, there is a unique lowest-degree polynomial of at most degree $n - 1$ that interpolates them.**

The consequence of this is that

**If we use the points $(1,2,...,n)$ as the $x$ values to convert a length $n$ vector to a polynomial via Lagrange interpolation, then the resulting polynomial is unique.**

Informally, every $n$ degree vector has a unique $n - 1$ degree polynomial that "represents" it. The degree could be less if, for example, the points are collinear, but the vector will be unique.

The "lowest degree" part is important. Given two points, there are an extremely large number of polynomials that cross those two points -- but the lowest degree polynomial is unique.

## The addition of vectors of vectors is homomorphic to the addition of polynomials
### Vector addition is homomorphic to polynomial addition

If we take two vectors, interpolate them with polynomials, then add the polynomials together, we get the same polynomial as if we added the vectors together and then interpolated the sum vector.

Spoken more mathematically, let $\mathcal{L}(\mathbf{v})$ be the polynomial resulting from Lagrange interpolation on the vector $\mathbf{v}$ using $(1, 2, ..., n)$ as the $x$ values, where $n$ is the length of $\mathbf{v}$. The following is true:

$$\mathcal{L}(\mathbf{v} + \mathbf{w}) = \mathcal{L}(\mathbf{v}) + \mathcal{L}(\mathbf{w})$$

In other words, the polynomials resulting from interpolating vectors $\mathbf{v}$ and $\mathbf{w}$ are the same as the polynomials resulting from interpolating the vectors $\mathbf{v} + \mathbf{w}$.

#### Worked example
Let $f_1(x) = x^2$ and $f_2(x) = x^3$ $f_1$ interpolates $(1, 1), (2, 4), (3, 9)$ or the vector $[1,4,9]$ and $f_2$ interpolates $[1,8,27]$.

The sum of the vectors is $[2,12,36]$ and it is clear that $x^3 + x^2$ interpolates that. Let $f_3(x) = f_1(x) + f_2(x) = x^3 + x^2$.

$$
\begin{align*}
f_3(1) &= 1 + 1 = 2\\
f_3(2) &= 8 + 4 = 12\\
f_3(3) &= 27 + 9 = 36
\end{align*}
$$

#### Testing the math in Python

Unit testing a proposed mathematical identity doesn't make it true, but it does illustrate what is happening. The reader is encouraged to try out a few different vectors to see that the identity holds.

```python
import galois
import numpy as np

p = 17
GF = galois.GF(p)

xs = GF(np.array([1,2,3]))

# two arbitrary vectors
v1 =  GF(np.array([4,8,2])) 
v2 =  GF(np.array([1,6,12]))

def L(v):
    return galois.lagrange_poly(xs, v)

assert L(v1 + v2) == L(v1) + L(v2)
```

Note that we do this in a finite field because floats will have issues with precision.

### Scalar multiplication 
Let $\lambda$ be a scalar (or field element in finite field). Then

$$\mathcal{L}(\lambda \mathbf{v}) = \lambda \mathcal{L}(\mathbf{v})$$

#### Worked example
Suppose our 3 points are $[3, 6, 11]$. The polynomial that interpolates that is $f(x) = x^2 + 2$. If we multiply the vector by 3 we get $[9, 18, 33]$. The polynomial that interpolates that is

```python
from scipy.interpolate import lagrange

x_values = [1, 2, 3]
y_values = [9, 18, 33]

print(lagrange(x_values ,y_values))

#    2
# 3 x + 6
```

or $3x^2 + 6$.

#### Worked example in code
```python
import galois
import numpy as np

p = 17
GF = galois.GF(p)

xs = GF(np.array([1,2,3]))

# arbitrary vector
v =  GF(np.array([4,8,2]))

# arbitrary constant
lambda_ =  GF(15)

def L(v):
    return galois.lagrange_poly(xs, v)

assert L(lambda_ * v) == lambda_ * L(v)
```

### Scalar multiplication is really vector addition
When we say "multiply a vector by 3" we are really saying "add the vector to itself three times".

Since we are only working in finite field, we don't concern ourselves with the interpretation of scalars such as "0.5."

We can think of both vectors under element-wise addition (in a finite field) and polynmoials under addition (also in a finite field) as [groups](https://www.rareskills.io/post/group-theory-and-coding).

The most important takeaway from this chapter is

**The group of vectors under addition in a finite field is homomorphic to the group of polynomials under addition in a finite field.**

This is critical because **vector equality testing takes $\mathcal{O}(n)$ time, but polynomial equality testing takes $\mathcal{O}(1)$ time.**

Therefore, whereas testing R1CS equality took $\mathcal{O}(n)$ time, we can leverage this homomorphism to test the equality of R1CSs in $\mathcal{O}(1)$ time.

This is what a *Quadratic Arithmetic Program* is.

## Using Lagrange interpolation and the Schwartz-Zippel Lemma in ZK-SNARKs
Now here's the killer idea that allows us to make ZK-SNARKs succinct.

**We can test if two vectors are equal in $\mathcal{O}(1)$ time by converting them to polynomials, then testing if the polynomials are equal using the Schwartz-Zippel Lemma.**

### A vector can be uniquely summarized by a single point
When we say "two vectors" are equal to each other in the context of polynomial equality, we are saying the vector $\mathcal{L}(\mathbf{v})$ tested at a random point TODO

Since a Rank 1 Constraint Systems have a lot of vectors in them, this gives us hope that we can test if a witness satisfies an R1CS in $\mathcal{O}(1)$ by converting the vectors to polynomials then running the Scwartz-Zippel Lemma test.

## A Rank 1 Constraint System in Polynomials

Consider that matrix multiplication between a rectangular matrix and a vector can be written in terms of vector addition and scalar multiplication.

For example, if we have a $3 \times 4$ matrix $A$ and a 4 dimensional vector $v$, then we can write the matrix multiplication as

$$
A \cdot v = \begin{bmatrix}
a_{11} & a_{12} & a_{13} & a_{14}\\
a_{21} & a_{22} & a_{23} & a_{24}\\
a_{31} & a_{32} & a_{33} & a_{34}
\end{bmatrix}
\begin{bmatrix}
v_1\\
v_2\\
v_3\\
v_4
\end{bmatrix}
$$

We typically think of the vector $v$ "flipping" and doing an inner product (generalized dot product) with each of the rows, i.e.

$$
A\cdot v = 
\begin{bmatrix}
a_{11}\cdot v_1 + a_{12}\cdot v_2 + a_{13}\cdot v_3 + a_{14}\cdot v_4\\
a_{21}\cdot v_1 + a_{22}\cdot v_2 + a_{23}\cdot v_3 + a_{24}\cdot v_4\\
a_{31}\cdot v_1 + a_{32}\cdot v_2 + a_{33}\cdot v_3 + a_{34}\cdot v_4
\end{bmatrix}
$$

However, we could instead think of splitting matrix $A$ into a bunch of vectors as follows:

$$
A = \begin{bmatrix}
a_{11} \\
a_{21} \\
a_{31} 
\end{bmatrix}
,
\begin{bmatrix}
a_{12} \\
a_{22} \\
a_{32} 
\end{bmatrix}
,
\begin{bmatrix}
a_{13} \\
a_{23} \\
a_{33} 
\end{bmatrix}
,
\begin{bmatrix}
a_{14} \\
a_{24} \\
a_{34} 
\end{bmatrix}
$$

and multiplying each vector by a scalar from the vector $v$:

$$
A\cdot v = \begin{bmatrix}
a_{11} \\
a_{21} \\
a_{31} 
\end{bmatrix}\cdot v_1
+
\begin{bmatrix}
a_{12} \\
a_{22} \\
a_{32} 
\end{bmatrix}\cdot v_2
+
\begin{bmatrix}
a_{13} \\
a_{23} \\
a_{33} 
\end{bmatrix}\cdot v_3
+
\begin{bmatrix}
a_{14} \\
a_{24} \\
a_{34} 
\end{bmatrix}\cdot v_4
$$

We have expressed matrix multiplication between $A$ and $v$ purely in terms of vector addition and scalar multiplication.

Because we established earlier that the group of vectors under addition in a finite field is homomorphic to the group of polynomials under addition in a finite field, can


## Succintly testing that $\mathbf{A}\mathbf{v}_1 = \mathbf{B}\mathbf{v}_2$

Suppose we have matrix $\mathbf{A}$ and $\mathbf{B}$ such that

$$
\begin{align*}
\mathbf{A} = \begin{bmatrix}
6 & 3\\
4 & 7\\
\end{bmatrix}\\
\mathbf{B} = \begin{bmatrix}
3 & 9 \\
12 & 6\\
\end{bmatrix}
\end{align*}
$$

and vectors $\mathbf{v}_1$ and $\mathbf{v}_2$

$$
\begin{align*}
\mathbf{v}_1 = \begin{bmatrix}
2 \\
4 \\
\end{bmatrix}\\
\mathbf{v}_2 = \begin{bmatrix}
2 \\
2 \\
\end{bmatrix}
\end{align*}
$$

We want to test if

$$
\mathbf{A}\mathbf{v}_1 = \mathbf{B}\mathbf{v}_1
$$

is true. Without loss of generality, let's assume we are in the finite field $\mathbb{F}_{17}$, i.e. everything is done modulo 17.

Obviously we can carry out the matrix arithmetic, but the final check will require $n$ comparisons, where $n$ is the number of rows in $\mathbf{A}$ and $\mathbf{B}$. We want to do it in $\mathcal{O}(1)$ time.

First, we convert the matrix multiplication $\mathbf{A}\mathbf{v}_1$ and $\mathbf{B}\mathbf{v}_1$ to the group of vectors under addition in $\mathbb{F}_{17}$:

$$
\begin{align*}
\mathbf{A} &= \begin{bmatrix}  
6 \\
4 \\
\end{bmatrix}
,
\begin{bmatrix}  
3 \\
7 \\
\end{bmatrix}\\
\mathbf{B} &= \begin{bmatrix}  
3 \\
12 \\
\end{bmatrix}
,
\begin{bmatrix}  
9 \\
6 \\
\end{bmatrix}
\end{align*}
$$

We now want to find the homomorphic equivalent of

$$
\begin{bmatrix}  
6 \\
4 \\
\end{bmatrix}\cdot 2+
\begin{bmatrix}  
3 \\
7 \\
\end{bmatrix}\cdot 4\stackrel{?}{=}
\begin{bmatrix}  
3 \\
12 \\
\end{bmatrix}\cdot 2=
\begin{bmatrix}  
9 \\
6 \\
\end{bmatrix}\cdot 2
$$

Let's convert each of the vectors to polynomials over the $x$ values $[1,2]$:

$$
\underbrace{
\begin{bmatrix}  
6 \\
4 \\
\end{bmatrix}}_{p_1(x)}\cdot 2+
\underbrace{
\begin{bmatrix}  
3 \\
7 \\
\end{bmatrix}}_{p_2(x)}\cdot 4\stackrel{?}{=}
\underbrace{
\begin{bmatrix}  
3 \\
12 \\
\end{bmatrix}}_{q_1(x)}\cdot 2=
\underbrace{
\begin{bmatrix}  
9 \\
6 \\
\end{bmatrix}}_{q_2(x)}\cdot 2
$$

We will invoke some Python to compute the Langrage interpolation:

```python
import galois
import numpy as np

p = 17
GF = galois.GF(p)

x_values = GF(np.array([1, 2]))

def L(v):
    return galois.lagrange_poly(x_values, v)

p1 = L(GF(np.array([6, 4])))
p2 = L(GF(np.array([3, 7])))
q1 = L(GF(np.array([3, 12])))
q2 = L(GF(np.array([9, 6])))

print(p1)
# 15x + 8 (mod 17)
print(p2)
# 4x + 16 (mod 17)
print(q1)
# 9x + 11 (mod 17)
print(q2)
# 14x + 12 (mod 17)
```

Finally, we can check if

$$p_1(x) \cdot 2+ p_2(x) \cdot 4 \stackrel{?}= q_1(x) \cdot 2 + q_2(x) \cdot 2$$

is true by invoking the Schwartz-Zippel Lemma:

```python
tau = GF(14) # a random point

left_hand_side = p1(tau) * GF(2) + p2(tau) * GF(4)
right_hand_side = q1(tau) * GF(2) + q2(tau) * GF(2)

assert left_hand_side == right_hand_side
```

## R1CS to QAP: Succinctly testing that $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}=\mathbf{O}\mathbf{a}$
[Todo]

### Dealing with imbalance due to the 
Suppose $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$ have $n$ rows. The degree of polynomials that comes from their column vectors will be $n - 1$. Since we add the column vectors together, the degree of the sum of the polynomials will also be $n - 1$.


...

Consider that the following equality

$$
\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}=\mathbf{O}\mathbf{a} + \mathbf{0}
$$

where $\mathbf{0}$ is a vector of all zeros. The key insight here is that *we do not have to interpolate the $\mathbf{0}$ vector with $f(x) = 0$. There are an infinite number of polynomials that interpolate the zero vector. Consider the following degree four polynomial that interpolates $[(1,0), (2,0), (3,0), (4,0)]$:

![alt text](https://static.wixstatic.com/media/935a00_9e7c088301a441e986d0c54473d938e1~mv2.png/v1/fill/w_1480,h_762,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_9e7c088301a441e986d0c54473d938e1~mv2.png)