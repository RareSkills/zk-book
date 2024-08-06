# Quadratic Arithmetic Programs

A quadratic arithmetic program is an arithmetic circuit represented as a set of polynomials. It is derived using Lagrange interpolation on a Rank 1 Constraint System (R1CS). Unlike a Rank 1 Constraint System, a Quadratic Arithmetic Program (QAP) can be tested for equality in $\mathcal{O}(1)$ time via the Schwartz-Zippel Lemma.

## Key ideas
In the chapter on the Schwartz-Zippel Lemma, we saw that we can test if two vectors are equal in $\mathcal{O}(1)$ time by converting them to polynomials, then running the Schwartz-Zippel Lemma test on the polynomials.

Because a Rank 1 Constraint System is entirely composed of vector operations, we aim to test if

$$\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}\stackrel{?}{=}\mathbf{O}\mathbf{a}$$

holds in $\mathcal{O}(1)$ time instead of $\mathcal{O}(n)$ time (where $n$ is the number of rows in $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$).

But before we do that, we need to understand some key properties of the relationship between vectors and polynomials that represent them.

For all math here, we assume we are working in a [finite field](https://www.rareskills.io/post/finite-fields), but we skip the $\mod p$ notation for succinctness.

## Homomorphisms between vector addition and polynomial addition
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

Because we established earlier that the group of vectors under addition in a finite field is homomorphic to the group of polynomials under addition in a finite field, can express the computation above in terms of polynomials that represent the vectors.

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
\mathbf{A}\mathbf{v}_1 = \mathbf{B}\mathbf{v}_2
$$

is true. Without loss of generality, let's assume we are in the finite field $\mathbb{F}_{17}$, i.e. everything is done modulo 17.

Obviously we can carry out the matrix arithmetic, but the final check will require $n$ comparisons, where $n$ is the number of rows in $\mathbf{A}$ and $\mathbf{B}$. We want to do it in $\mathcal{O}(1)$ time.

First, we convert the matrix multiplication $\mathbf{A}\mathbf{v}_1$ and $\mathbf{B}\mathbf{v}_2$ to the group of vectors under addition in $\mathbb{F}_{17}$:

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
import random
u = random.randint(0, 17)
tau = GF(u) # a random point

left_hand_side = p1(tau) * GF(2) + p2(tau) * GF(4)
right_hand_side = q1(tau) * GF(2) + q2(tau) * GF(2)

assert left_hand_side == right_hand_side
```

## R1CS to QAP: Succinctly testing that $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}=\mathbf{O}\mathbf{a}$
Since we know how to test of $\mathbf{A}\mathbf{v}_1 = \mathbf{B}\mathbf{v}_2$ succinctly, can we also test if $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}=\mathbf{O}\mathbf{a}$ succinctly?

The matrices have $m$ columns, so let's break each of the matrices into $m$ column vectors and interpolate them on $(1, 2, ..., n)$ to produce $m$ polynomials each.

Let $u_1(x), u_2(x), ..., u_m(x)$ be the polynomials that interpolate the column vectors of $\mathbf{L}$.

Let $v_1(x), v_2(x), ..., v_m(x)$ be the polynomials that interpolate the column vectors of $\mathbf{R}$.

Let $w_1(x), w_2(x), ..., w_m(x)$ be the polynomials that interpolate the column vectors of $\mathbf{O}$.

Without loss of generality, let's say we have 4 columns ($m = 4$) and three rows ($n = 3$).

Visually, this can be represented as
$$
\begin{array}{c}
\mathbf{L} = \begin{bmatrix}
\quad l_{11} \quad& l_{12} \quad& l_{13} \quad& l_{14} \quad\\
\quad l_{21} \quad& l_{22} \quad& l_{23} \quad& l_{24} \quad\\
\quad l_{31} \quad& l_{32} \quad& l_{33} \quad& l_{34} \quad
\end{bmatrix} \\
\\
\qquad u_1(x) \quad u_2(x) \quad u_3(x) \quad u_4(x)
\end{array}
\begin{array}{c}
\mathbf{R} = \begin{bmatrix}
\quad r_{11} \quad& r_{12} \quad& r_{13} \quad& r_{14} \quad\\
\quad r_{21} \quad& r_{22} \quad& r_{23} \quad& r_{24} \quad\\
\quad r_{31} \quad& r_{32} \quad& r_{33} \quad& r_{34} \quad
\end{bmatrix} \\
\\
\qquad v_1(x) \quad v_2(x) \quad v_3(x) \quad v_4(x)
\end{array}
$$

$$
\begin{array}{c}
\mathbf{O} = \begin{bmatrix}
\quad o_{11} \quad& o_{12} \quad& o_{13} \quad& o_{14} \quad\\
\quad o_{21} \quad& o_{22} \quad& o_{23} \quad& o_{24} \quad\\
\quad o_{31} \quad& o_{32} \quad& o_{33} \quad& o_{34} \quad
\end{bmatrix} \\
\\
\qquad w_1(x) \quad w_2(x) \quad w_3(x) \quad w_4(x)
\end{array}
$$

Since multiplying a column vector by a scalar is homomorphic to multiplying a polynomial by a scalar, each the polynomials can be multiplied by the respective element in the witness.

For example, 

$$
\mathbf{L}\mathbf{a} = \begin{bmatrix}
\quad l_{11} \quad& l_{12} \quad& l_{13} \quad& l_{14} \quad\\
\quad l_{21} \quad& l_{22} \quad& l_{23} \quad& l_{24} \quad\\
\quad l_{31} \quad& l_{32} \quad& l_{33} \quad& l_{34} \quad
\end{bmatrix}
\begin{bmatrix}
a_1 \\
a_2 \\
a_3 \\
a_4
\end{bmatrix}
$$

becomes

$$
\begin{align*}
&=\begin{bmatrix}
u_1(x) & u_2(x) & u_3(x) & u_4(x)
\end{bmatrix}
\begin{bmatrix}
a_1 \\
a_2 \\
a_3 \\
a_4
\end{bmatrix}\\
&=a_1u_1(x) + a_2u_2(x) + a_3u_3(x) + a_4u_4(x)\\
&=\sum_{i=1}^4 a_iu_i(x)
\end{align*}
$$

Observe that the final result is a single polynomial with degree at most $n - 1$ (since there are $n$ rows in $\mathbf{L}$, $u_1(x), ..., u_n(x)$ have degree at most $n - 1$).

In the general case, $\mathbf{L}\mathbf{a}$ can be written as

$$
\sum_{i=1}^m a_iu_i(x)
$$

after converting each of the $m$ columns to polynomials.

Using the same steps above, each matrix-witness product in the R1CS $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a} = \mathbf{O}\mathbf{a}$ can be transformed as

$$
\begin{align*}
\mathbf{L}\mathbf{a} \rightarrow \sum_{i=1}^m a_iu_i(x) \\
\mathbf{R}\mathbf{a} \rightarrow \sum_{i=1}^m a_iv_i(x) \\
\mathbf{O}\mathbf{a} \rightarrow \sum_{i=1}^m a_iw_i(x)
\end{align*}
$$

Since each of the sum terms produces a single polynomial, we can write them as:

$$
\begin{align*}
\mathbf{L}\mathbf{a} &\rightarrow \sum_{i=1}^m a_iu_i(x) = u(x)\\
\mathbf{R}\mathbf{a} &\rightarrow \sum_{i=1}^m a_iv_i(x) = v(x)\\
\mathbf{O}\mathbf{a} &\rightarrow \sum_{i=1}^m a_iw_i(x) = w(x)
\end{align*}
$$

However, we can't simply express the final result as

$$u(x)v(x) = w(x)$$

because the degrees won't match.

Multiplying two polynomials together results in a product polynomial whose degree is the sum of the degrees of the two polynomials.

Because each of $u(x)$, $v(x)$, and $w(x)$ will have degree $n - 1$, $u(x)v(x)$ will generally have degree $2n - 2$ and $w(x)$ will have degree $n - 1$, so they won't be equal even though the underlying vectors they multiplied are equal.

This is because the homorphisms we established earlier only make claims about vector addition, not Hadamard product.

However, there is a straightfoward way to fix this.

### Interpolating the $\mathbf{0}$ vector
We established that if $\mathbf{v_1} + \mathbf{v_2} = \mathbf{v_3}$, then $\mathcal{L}(\mathbf{v_1}) + \mathcal{L}(\mathbf{v_2}) = \mathcal{L}(\mathbf{v_3})$.

We got stuck on the fact that although $\mathbf{v_1}\circ \mathbf{v_2} = \mathbf{v_3}$, it is not the case that $\mathcal{L}(\mathbf{v_1})\mathcal{L}(\mathbf{v_2}) = \mathcal{L}(\mathbf{v_3})$ due to the mismatch in degrees.

Now consider that if $\mathbf{v_1} \circ \mathbf{v_2} = \mathbf{v_3}$, then $\mathbf{v_1} \circ \mathbf{v_2} = \mathbf{v_3} + \mathbf{0}$.

Instead of interpolating $\mathbf{0}$ with lagrange interpolation and getting $f(x) = 0$, we can use a higher degree polynomial that will balance out the mismatch in degrees.

For example, the following degree four polynomial that interpolates $[(1,0), (2,0), (3,0), (4,0)]$:

![alt text](https://static.wixstatic.com/media/935a00_9e7c088301a441e986d0c54473d938e1~mv2.png/v1/fill/w_1480,h_762,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_9e7c088301a441e986d0c54473d938e1~mv2.png)

The polynomial that interpolates $\mathbf{0}$ does not need to be zero everywhere, it only needs to be zero at the points $x=1,2,...,n$.

Let's call the polynomial that interpolates $\mathbf{0}$ the *balancing polynomial* b(x). It can be computed as

$$
b(x) = \mathcal{L}(\mathbf{v_3}) - \mathcal{L}(\mathbf{v_1})\mathcal{L}(\mathbf{v_2}) 
$$


### The union of roots of the polynomial product
**Theorem**: If $h(x) = f(x)g(x)$ and $f(x)$ has set of roots $\set{r_f}$ and $g(x)$ has set of roots $\set{r_g}$, then $h(x)$ has roots $\set{r_f} \cup \set{r_g}$.

#### Example
Let $f(x) = (x - 3)(x - 4)$ and $g(x) = (x - 5)(x - 6)$. Then $h(x) = f(x)g(x)$ has roots $\set{3,4,5,6}$.

We can use the theorem above to enforce that $b(x)$ has roots at $x = 1,2,\dots,n$.

We decompose $b(x)$ into $b(x) = h(x)t(x)$ where $t(x)$ is the polynomial

$$
t(x) = (x-1)(x-2)\dots(x-n)
$$

Thus, our equality will become

$$
u(x)v(x) = v(x) + h(x)t(x)
$$

We can solve for $h(x)$ using basic algebra:

$$
h(x) = \frac{u(x)v(x) - v(x)}{t(x)}
$$