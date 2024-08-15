# R1CS to Quadratic Arithmetic Program over a Finite Field in Python

To make the transformation from R1CS to QAP less abstract, let’s use a real example.

Let’s say we are encoding the [arithmetic circuit](https://www.rareskills.io/post/arithmetic-circuit)

$$z = x⁴ - 5y²x²$$

Converted to a [Rank 1 Constraint System](https://www.rareskills.io/post/rank-1-constraint-system), this becomes

$$\begin{align*}
v_1 &= xx \\
v_2 &= v_1 * v_1 && //x^4\\
v_3 &= -5yy \\
-v_2 + z &= v_3 * v_1 && //-5y^2 * x^2\\
\end{align*}$$

We need to pick a characteristic of the [finite field](https://www.rareskills.io/post/finite-fields) we will do this over. When we later combine this with [elliptic curves](https://www.rareskills.io/post/elliptic-curves-finite-fields), the order of our prime field needs to equal the order of the elliptic curve. (Not matching the two a very common mistake).

But for now, we will pick a small number to make this manageable. We will pick the prime number 79.

First, we define our matrices $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$ as follows:

```python
import numpy as np

# 1, out, x, y, v1, v2, v3
L = np.array([
    [0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, -5, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1],
])

R = np.array([
    [0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0],
])

O = np.array([
    [0, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 1],
    [0, 1, 0, 0, 0, -1, 0],
])
```

To verify we constructed the R1CS correctly (it’s very easy to mess up when doing manually!) we create a valid witness and do the matrix multiplication:

```python
x = 4
y = -2
v1 = x * x
v2 = v1 * v1        # x^4
v3 = -5*y * y
z = v3*v1 + v2    # -5y^2 * x^2

# witness
a = np.array([1, z, x, y, v1, v2, v3])

assert all(np.equal(np.matmul(L, a) * np.matmul(R, a), np.matmul(O, a))), "not equal"
```
## Finite Field Arithmetic in Python
The next step is to convert this to a field array. Doing modular arithmetic in Numpy will get very messy, but is straightforward with the galois library. This was introduced in our article on finite fields, but here is quick recap on how to use it:

```python
import galois

GF = galois.GF(79)

a = GF(70)
b = GF(10)

print(a + b)
# prints 1
```

We cannot give it negative values such as GF(-1) or it will throw an exception. To convert negative numbers to their congruent representation in the field, we can add the curve order to them. To avoid "overflowing" positive values, we take the modulus with the curve order. 

```python
L = (L + 79) % 79
R = (R + 79) % 79
O = (O + 79) % 79
```

Our new matrices are
```python
## New values of L, R, O
'''
L

[[ 0  0  1  0  0  0  0]
 [ 0  0  0  0  1  0  0]
 [ 0  0  0 74  0  0  0]
 [ 0  0  0  0  0  0  1]]

R

[[ 0  0  1  0  0  0  0]
 [ 0  0  0  0  1  0  0]
 [ 0  0  0  1  0  0  0]
 [ 0  0  0  0  1  0  0]]

O

[[ 0  0  0  0  1  0  0]
 [ 0  0  0  0  0  1  0]
 [ 0  0  0  0  0  0  1]
 [ 0  1  0  0  0 78  0]]
'''
```

We can convert them to field arrays simply by wrapping them with GF now. We will also need to recompute our witness, because it contains negative values.

```python
L_galois = GF(L)
R_galois = GF(R)
O_galois = GF(O)

x = GF(4)
y = GF(-2 + 79) # we are using 79 as the field size, so 79 - 2 is -2
v1 = x * x
v2 = v1 * v1         # x^4
v3 = GF(-5 + 79)*y * y
out = v3*v1 + v2    # -5y^2 * x^2

witness = GF(np.array([1, out, x, y, v1, v2, v3]))

assert all(np.equal(np.matmul(L_galois, witness) * np.matmul(R_galois, witness), np.matmul(O_galois, witness))), "not equal"
```

## Polynomial interpolation in finite fields
Now, we need to turn each of the columns of the matrices into a list of galois polynomials that interpolate the columns. The points we will interpolate are `x = [1,2,3,4]`, since we have 4 rows.

```python
def interpolate_column(col):
    xs = GF(np.array([1,2,3,4]))
    return galois.lagrange_poly(xs, col)

# axis 0 is the columns.
# apply_along_axis is the same as doing a for loop over the columns and collecting the results in an array
U_polys = np.apply_along_axis(interpolate_column, 0, L_galois)
V_polys = np.apply_along_axis(interpolate_column, 0, R_galois)
W_polys = np.apply_along_axis(interpolate_column, 0, O_galois)
```

If we look again at the contents of our matrices, we expect the first two polynomials of `U_polys` and `V_polys` to be zero, and the first column of `W_polys` to be zero also.

We run the following sanity check:

```python
print(U_polys[:2])
print(V_polys[:2])
print(W_polys[:1])

# [Poly(0, GF(79)) Poly(0, GF(79))]# [Poly(0, GF(79)) Poly(0, GF(79))]# [Poly(0, GF(79))]
```

The term `Poly(0, GF(79))` is simply a polynomial where all the coefficients are zero.

The reader is encouraged to evaluate the polynomials at the values in the R1CS to see they interpolate the matrix values correctly.

## Computing h(x)
We already know $t(x)$ will be $(x - 1)(x - 2)(x - 3)(x - 4)$ since there are four rows.

By way of reminder, this is the formula for a Quadratic Arithmetic Program. The vector $\mathbf{a}$ is the witness:

$$
\underbrace{\sum_{i=1}^{m} a_i u_i(x)}_\text{term 1} \underbrace{\sum_{i=1}^m a_i v_i(x)}_\text{term 2} = \underbrace{\sum_{i=1}^{m} a_i w_i(x)}_\text{term 3} + h(x)t(x)
$$

Each of the terms is taking the inner product of the witness with the column-interpolating polynomials. That is, each of summation terms are effectively the inner product between $[a₁, …, aₘ]$ and $[u₁(x), ..., uₘ(x)]$

```python
def inner_product_polynomials_with_witness(polys, witness):
    mul_ = lambda x, y: x * y
    sum_ = lambda x, y: x + y
    return reduce(sum_, map(mul_, polys, witness))

term_1 = inner_product_polynomials_with_witness(U_polys, witness)

term_2 = inner_product_polynomials_with_witness(V_polys, witness)

term_3 = inner_product_polynomials_with_witness(W_polys, witness)
```

To compute $h(x)$, we simply solve for it. Note that we cannot compute $h(x)$ unless we have a valid witness, otherwise there will be a remainder.

```python
# t = (x - 1)(x - 2)(x - 3)(x - 4)
t = galois.Poly([1, 78], field = GF) * galois.Poly([1, 77], field = GF) * galois.Poly([1, 76], field = GF) * galois.Poly([1, 75], field = GF)

h = (term_1 * term_2 - term_3) // t
```

Unlike [poly1d from numpy](https://numpy.org/doc/stable/reference/generated/numpy.poly1d.html), the galois library won’t indicate to us if there is a remainder, so we need to check if the QAP formula is still true.

```python
assert term_1 * term_2 == term_3 + h * t, "division has a remainder"
```

The check executed above is very similar to what the verifier will check for.

The scheme above will not work when we evaluate the polynomials on a hidden point from a trusted setup. However, the computer doing the trusted setup will still have to execute many of the computations above.

## Summary
In this article, we present the Python code for converting a R1CS to a QAP.

## Learn more with RareSkills
This material is from our [Zero Knowledge Course](https://www.rareskills.io/zk-bootcamp).