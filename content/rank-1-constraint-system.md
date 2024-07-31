# Converting Algebraic Circuits to R1CS (Rank One Constraint System)

This article is explains how to turn a set of arithmetic constraints into Rank One Constraint System (R1CS).

The focus of this resource is implementation: we cover a lot more corner cases of doing this transformation than other materials, discuss optimizations, and explain how the Circom library accomplishes it.

## Prerequisites
- We assume the reader understands how to use [arithmetic circuits (zk circuits)](https://www.rareskills.io/post/arithmetic-circuit) to represent the validity of a computation.
- The reader is familiar with [modular arithmetic](https://www.rareskills.io/post/finite-fields). All operations here happen in a finite field, so "-5" really means the additive inverse of 5 modulo $p$ and "2/3" means the multiplicative inverse of 3 modulo $p$ times 2.

## Rank 1 Constraint System overview
A Rank 1 Constraint System (R1CS) is an arithmetic circuit with the requirement that each equality constraint has one multiplication (and no restriction on the number of additions).

This makes the representation of the arithmetic circuit compatible with the use of bilinear pairings. The output of a pairing $G_1 \bullet G_2 \rightarrow G_T$ cannot be paired again, as an element in $G_T$ cannot be used as part of the input of another pairing. Hence, we only allow one multiplication per constraint.

## The witness vector
In an arithmetic circuit, the witness is an assignment to all the signals that satisfies the constraints of the equation.

In a Rank 1 Constraint System

The witness vector is a 1 x n vector that contains the value of all the input variables, the output variable, and the intermediate values. It shows you have executed the circuit from start to finish, knowing both the input, output, and all the intermediate values.


By convention, the first element is always 1 to make some calculations easier, which we will demonstrate later.

For example, if we have the constraint

$$z = x^2y$$

that we claim to know the solution for, then that must mean we know $x$, $y$, and $z$. Because Rank One Constraint Systems require exactly one multiplication per constraint, the polynomial above constraints must be written as

$$
\begin{align*}
v₁ = xx \\
z = v₁y
\end{align*}
$$

A witness means we don’t just know $x$, $y$, and $z$, we must know every intermediate variable in this expanded form. Specifically, our witness is a vector:

$$[1, z, x, y, v₁]$$

where each term satisfies the constraints above.

For example, 

$$[1, 18, 3, 2, 9]$$

is a valid witness because when we plug the values in,

$$[\text{constant} = 1, z = 18, x = 3, y = 2, v₁ = 9]$$
it satisfies the constraints

$$
\begin{align*}
v_1 = x*x \rightarrow 9 = 3\cdot3\\
z = v_1*y \rightarrow 18 = 9\cdot2
\end{align*}
$$

The extra 1 term is not used in this example and is a convenience we will explain later.

## Example 1: Transforming $z = x \cdot y$

In the circuit $z = xy$, there are no intermediate variables. For our example, we will say we are proving $41 x 103 = 4223$.

Therefore, our witness vector is `[1, 4223, 41, 103]` as an assignment to `[1, z, x, y]`.

Before we can create an R1CS, our constraints need to be of the form

```
result = left_hand_side × right_hand_side
```

Luckily for us, it already is
$$
\underbrace{z}_\text{result} = \underbrace{x}_\text{left hand side} \times \underbrace{y}_\text{right hand side}
$$

This is obviously a trivial example, but trivial examples are usually a great place to start.

To create a valid R1CS, you need a list of formulas that contain exactly one multiplication.

We will discuss later how to handle cases that do not have exactly one multiplication like $z = x³$ or $z = x³ + y$.

Our goal is to create a system of equations of the form:

$$
\mathbf{O}\mathbf{a} = \mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}
$$

Where $O$, $L$, and $R$ are matrices of size $n$ x $m$ ($n$ rows and $m$ columns).

Matrix $\mathbf{L}$ encodes the `left_hand_side` variables $\mathbf{R}$ encodes the `right_hand_side` variables. $\mathbf{O}$ encodes the result variables. The vector $\mathbf{a}$ is the witness vector.

Specifically, $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$ are matrices with the same number of columns as the witness vector $\mathbf{a}$, and each column represents the same variable the index is using.

So for our example, the witness has 4 elements $(1, z, x, y)$ so each of our matrices will have 4 columns, so $m = 4$.

The number of rows will correspond to the number of constraints in the circuit. In our case, we have only one constraint: $z = x * y$, so we will only have one row, so $n = 1$.

Let’s jump to the answer and explain how we obtained it.

$$\mathbf{O}\mathbf{a} = \mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}$$
$$
\underbrace{\begin{bmatrix}
0 & 1 & 0 & 0 \\
\end{bmatrix}}_{\mathbf{O}}\mathbf{a} =
\underbrace{\begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}}_{\mathbf{L}}\mathbf{a}\circ
\underbrace{\begin{bmatrix}
0 & 0 & 0 & 1 \\
\end{bmatrix}}_{\mathbf{R}}\mathbf{a}
$$

$$
\begin{bmatrix}
0 & 1 & 0 & 0 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
4223 \\
41 \\
103 \\
\end{bmatrix}=
\begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
4223 \\
41 \\
103 \\
\end{bmatrix}\circ
\begin{bmatrix}
0 & 0 & 0 & 1 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
4223 \\
41 \\
103 \\
\end{bmatrix}
$$

In this example, each item in the matrix serves as an indicator variable for whether or not the variable the column corresponds to is present. (Technically, it’s the coefficient of the variable, but we’ll get to that later).

For the left hand terms, $x$ is present, so if the columns represent `[1, z, x, y]`, then…

$\mathbf{L}$ is `[0, 0, 1, 0]`, because $x$ is present, and none of the other variables are.

$\mathbf{R}$ is `[0, 0, 0, 1]` because the variables in the right hand side are just $y$, and

$\mathbf{O}$ is `[0, 1, 0, 0]` because we only have the $z$ variable.

We don’t have any constants anywhere so the 1 column is zero everywhere (We’ll discuss when it is non-zero later).

This equation is correct, which we can verify in Python

```python
import numpy as np

# define the matrices
O = np.matrix([[0,1,0,0]])
L = np.matrix([[0,0,1,0]])
R = np.matrix([[0,0,0,1]])

# witness vector
a = np.array([1, 4223, 41, 103])

# Multiplication `*` is element-wise, not matrix multiplication.
# Result contains a bool indicating an element-wise indicator that the equality is true for that element.
result = np.matmul(O, a) == np.matmul(L, a) * np.matmul(R, a) 

# check that every element-wise equality is true
assert result.all(), "result contains an inequality"
```

You may be wondering what the point of this is, aren’t we just saying that 41 x 103 = 4223 is a much less compact way?

You would be correct.

An R1CS can be quite verbose, but they map nicely to [Quadratic Arithmetic Programs (QAPs)](https://www.rareskills.io/post/quadratic-arithmetic-program), which can be made succinct. But we will not concern ourselves with QAPs here.

But this is an important point of R1CS. A R1cs communicates exactly the same information as the original arithmetic constraints, but with a lot of extra zeros. In this example, we have only one constraint, but we’ll add more in the next example.

## Example 2: Transforming r = x * y * z * u
In this slightly more complicated example, we need to deal with intermediate variables now. Each row of our computation can only have one multiplication, so we must break up our equation as follows:

$$
\begin{align*}
v_1 &= xy \\
v_2 &= zu \\
r &= v_1v_2
\end{align*}
$$

There is no rule to say we had to break it up like that, the following is also valid:

$$
\begin{align*}
v_1 &= xy \\
v_2 &= v_1z \\
r &= v_2u
\end{align*}
$$

We will use the first transformation for this example.

### Size of $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$
Because we are dealing with 7 variables $(r, x, y, z, u, v_1, v_2)$, our witness vector will have 8 elements (the first being the constant 1) and our matrices will have 8 columns.

Because we have three constraints, the matrices will have three rows.

### Left hand terms and right hand terms
This example will strongly enforce the idea of a “left hand term” and a “right hand term.” Specifically, $x$, $z$, and $v_1$ are left hand terms, and $y$, $u$, and $v_2$ are right hand terms.

$$
\underbrace{
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}
}_\text{ Output Terms }
\begin{matrix}
=\\
=\\
=
\end{matrix}
\underbrace{
    \begin{matrix}
        x \\
        z \\
        v_1 \\
    \end{matrix}
}_\text{ Left Hand Terms }
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\underbrace{
    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}
}_\text{ Right Hand Terms }
$$

### Constructing matrix $\mathbf{L}$ from left hand terms
Let’s construct the matrix A. We know it will have three rows and eight columns

$$
\begin{bmatrix}
& l_{1,2} & l_{1,3} & l_{1,4} & l_{1,5} & l_{1,6} &  l_{1,7} & l_{1,8} \\
& l_{2,2} & l_{2,3} & l_{2,4} & l_{2,5} & l_{2,6} &  l_{2,7} & l_{2,8} \\
& l_{3,2} & l_{3,3} & l_{3,4} & l_{3,5} & l_{3,6} &  l_{3,7} & l_{3,8} \\
\end{bmatrix}
$$

Our witness vector will be multiplied by this, so let’s define our witness vector to have the following layout:

$$
\begin{bmatrix}
1 & x & y & z & u & v_1 & v_2 & r \\
\end{bmatrix}
$$

This informs us as to what $\mathbf{L}$’s columns represents:

$$
\mathbf{L} = 
\begin{bmatrix}
l_{1, 1} & l_{1, r} & l_{1, x} & l_{1, y} & l_{1, z} & l_{1, u} & l_{1, v_1} & l_{1, v_2} \\
l_{2, 1} & l_{2, r} & l_{2, x} & l_{2, y} & l_{2, z} & l_{2, u} & l_{2, v_1} & l_{2, v_2} \\
l_{3, 1} & l_{3, r} & l_{3, x} & l_{3, y} & l_{3, z} & l_{3, u} & l_{3, v_1} & l_{3, v_2} \\
\end{bmatrix}
$$

#### First row of  $\mathbf{L}$
In the first row, for the first left variable, we have $v₁ = xy$:

$$
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
\underset{\mathbf{L}}{\boxed{
    \begin{matrix}
        \color{red}{x} \\
        z \\
        v_1 \\
    \end{matrix}
}}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}
$$

This means with respect to the left hand side, the variable $x$ is present, and no other variables are present. Therefore, we transform the first row as follows:

$$
\mathbf{L}=\begin{bmatrix}
0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 & 0 \\
l_{2, 1} & l_{2, r} & l_{2, x} & l_{2, y} & l_{2, z} & l_{2, u} & l_{2, v_1} & l_{2, v_2} \\
l_{3, 1} & l_{3, r} & l_{3, x} & l_{3, y} & l_{3, z} & l_{3, u} & l_{3, v_1} & l_{3, v_2} \\
\end{bmatrix}
$$

#### Second row of $\mathbf{L}$
Working our way down, we see that only $z$ is present for the left-hand side of our systems of equations.

$$
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
\underset{\mathbf{L}}{\boxed{
    \begin{matrix}
        x \\
        \color{green}{z} \\
        v_1 \\
    \end{matrix}
}}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}
$$

Therefore, we set everything in that row to be zero, except the column that represents $z$.

$$
\mathbf{L}=\begin{bmatrix}
0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & \color{green}{1} & 0 & 0 & 0 \\
l_{3, 1} & l_{3, r} & l_{3, x} & l_{3, y} & l_{3, z} & l_{3, u} & l_{3, v_1} & l_{3, v_2} \\
\end{bmatrix}
$$

#### Third row of $\mathbf{L}$
Finally, we have $v₁$ as the only present variable in the left hand operators in the third row

$$
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
\underset{\mathbf{L}}{\boxed{
    \begin{matrix}
        x \\
        z \\
        \color{violet}{v_1} \\
    \end{matrix}
}}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}
$$

This completes matrix $\mathbf{L}$

$$
\mathbf{L}=\begin{bmatrix}
0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & \color{green}{1} & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & \color{violet}{1} & 0 \\
\end{bmatrix}
$$

The following image should make the mapping more clear:

$$
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
\underset{\mathbf{L}}{\boxed{
    \begin{matrix}
        \color{red}{x} \\
        \color{green}{z} \\
        \color{violet}{v_1} \\
    \end{matrix}
}}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}
\space\space\space\space
\begin{array}{c}
\begin{array}{cc}
\begin{matrix}
1 & r & x & y & z & u & v_1 & v_2 \\
\end{matrix}
\end{array} \\[10pt]
\begin{array}{cc}
\begin{bmatrix}
0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & \color{green}{1} & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & \color{violet}{1} & 0 \\
\end{bmatrix}
\end{array}
\end{array}
$$

#### Alternative transformation of $\mathbf{L}$
We could accomplish this same exercises by expanding the left hand values of

$$
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
{
    \begin{matrix}
        x \\
        z \\
        v_1 \\
    \end{matrix}
}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}
$$

as

$$
\begin{align*}
v_1 &= (0\cdot 1 + 0\cdot r + \boxed{1\cdot x} + 0\cdot y + 0\cdot z + 0\cdot u + 0\cdot v_1 + 0\cdot v_2) \times y\\
v_2 &= (0\cdot 1 + 0\cdot r + 0\cdot x + 0\cdot y + \boxed{1\cdot z} + 0\cdot u + 0\cdot v_1 + 0\cdot v_2) \times u\\
r &= (0\cdot 1 + 0\cdot r + 0\cdot x + 0\cdot y + 0\cdot z + 0\cdot u + \boxed{1\cdot v_1} + 0\cdot v_2) \times v_2 \\ 
\end{align*}
$$

We can do that because adding zero terms doesn’t change the values. We just have to be careful to expand the zero variables to have the same “columns” as how we’ve defined the witness vector.

And then, if we take the coefficients (shown in boxes) out of the above expansion,

$$
\begin{align*}
v_1 &= (\boxed{0}\cdot 1 + \boxed{0}\cdot r + \boxed{1}\cdot x + \boxed{0}\cdot y + \boxed{0}\cdot z + \boxed{0}\cdot u + \boxed{0}\cdot v_1 + \boxed{0}\cdot v_2) \times y\\
v_2 &= (\boxed{0}\cdot 1 + \boxed{0}\cdot r + \boxed{0}\cdot x + \boxed{0}\cdot y + \boxed{1}\cdot z + \boxed{0}\cdot u + \boxed{0}\cdot v_1 + \boxed{0}\cdot v_2) \times u\\
r &= (\boxed{0}\cdot 1 + \boxed{0}\cdot r + \boxed{0}\cdot x + \boxed{0}\cdot y + \boxed{0}\cdot z + \boxed{0}\cdot u + \boxed{1}\cdot v_1 + \boxed{0}\cdot v_2) \times v_2 \\ 
\end{align*}
$$

We get the same matrix for $\mathbf{L}$ that we generated a moment ago.

$$
\mathbf{L}=\begin{bmatrix}
0 & 0 & 1 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 1 & 0 \\
\end{bmatrix}
$$


### Constructing matrix $\mathbf{R}$ from right hand terms
$$
R = \begin{bmatrix}
r_{1,1} & r_{1,r} & r_{1,x} & r_{1,y} & r_{1,z} & r_{1,u} & r_{1,v_1} & r_{1,v_2} \\
r_{2,1} & r_{2,r} & r_{2,x} & r_{2,y} & r_{2,z} & r_{2,u} & r_{2,v_1} & r_{2,v_2} \\
r_{3,1} & r_{3,r} & r_{3,x} & r_{3,y} & r_{3,z} & r_{3,u} & r_{3,v_1} & r_{3,v_2} \\
\end{bmatrix}
$$

Matrix $\mathbf{R}$ represents the right hand terms of our equation:

$$
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
{
    \begin{matrix}
        x \\
        z \\
        v_1 \\
    \end{matrix}
}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
    \underset{\mathbf{R}}{\boxed{
    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}}}
$$

Matrix $\mathbf{R}$ must have 1s representing $y$, $u$, and $v_2$. The row in the matrix corresponds to the row of the arithmetic constraint, i.e. we can number the polynomial constraints (rows) as follows:

$$
    \begin{matrix}
        (1) \\
        (2) \\
        (3) \\
    \end{matrix}
    \space\space
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}
{
    \begin{matrix}
        x \\
        z \\
        v_1 \\
    \end{matrix}
}
\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
    \underset{\mathbf{R}}{\boxed{
    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}}}
$$

So the first row has 1 in the $y$ column, the second row has 1 in the $u$ column, and the third row has 1 in the $v_2$ column. Everything else is zero.

This results in the following for matrix $\mathbf{R}$:

$$
\begin{array}{c}
\begin{array}{cc}
\begin{matrix}
1 & r & x & y & z & u & v_1 & v_2 \\
\end{matrix}
\end{array} \\[10pt]
\begin{array}{cc}
\begin{bmatrix}
0 & 0 & 0 & 1 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix}
\end{array}
\end{array}
$$

This diagram illustrates the transformation.

$$
    \begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}

\begin{matrix}
=\\
=\\
=
\end{matrix}

    \begin{matrix}
        x \\
        z \\
        v_1 \\
    \end{matrix}

\begin{matrix}
\times\\
\times\\
\times
\end{matrix}
\underset{\mathbf{R}}
{\boxed{
    \begin{matrix}
        \color{red}{y} \\
        \color{green}{u} \\
        \color{violet}{v_2} \\
    \end{matrix}
}}
\space\space\space\space
\begin{array}{c}
\begin{array}{cc}
\begin{matrix}
1 & r & x & y & z & u & v_1 & v_2 \\
\end{matrix}
\end{array} \\[10pt]
\begin{array}{cc}
\begin{bmatrix}
0 & 0 & 0 & \color{red}{1} & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & \color{green}{1} & 0 & 0  \\
0 & 0 & 0 & 0 & 0 & 0 & 0 &\color{violet}{1}  \\
\end{bmatrix}
\end{array}
\end{array}
$$

### Constructing matrix $\mathbf{O}$
It is an exercise for the reader to determine that matrix $\mathbf{O}$ is

$$
\mathbf{O}=\begin{bmatrix}
0 & 0 & 0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 1  \\
0 & 1 & 0 & 0 & 0 & 0 & 0 & 0  \\
\end{bmatrix}
$$

using the column labels consistent with earlier matrices.

By way of reminder, $\mathbf{C}$ is derived from the result of the multiplication

$$
\underset{\mathbf{O}}{
    \boxed{\begin{matrix}
        v_1 \\
        v_2 \\
        r \\
    \end{matrix}}}

\begin{matrix}
=\\
=\\
=
\end{matrix}

    \begin{matrix}
        x \\
        z \\
        v_1 \\
    \end{matrix}

\begin{matrix}
\times\\
\times\\
\times
\end{matrix}

    \begin{matrix}
        y \\
        u \\
        v_2 \\
    \end{matrix}
$$

And the column labels are as follows

$$
\begin{array}{c}
\begin{array}{cc}
\begin{matrix}
1 & r & x & y & z & u & v_1 & v_2 \\
\end{matrix}
\end{array} \\[10pt]
\begin{array}{cc}
\begin{bmatrix}
0 & 0 & 0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 1  \\
0 & 1 & 0 & 0 & 0 & 0 & 0 & 0  \\
\end{bmatrix}
\end{array}
\end{array}
$$

Checking our work for $r = x \cdot y \cdot z \cdot u$

```python
import numpy as np

# enter the A B and C from above
L = np.matrix([[0,0,1,0,0,0,0,0],
              [0,0,0,0,1,0,0,0],
              [0,0,0,0,0,0,1,0]])
              
R = np.matrix([[0,0,0,1,0,0,0,0],
              [0,0,0,0,0,1,0,0],
              [0,0,0,0,0,0,0,1]])
              
O = np.matrix([[0,0,0,0,0,0,1,0],
              [0,0,0,0,0,0,0,1],
              [0,1,0,0,0,0,0,0]])

# random values for x, y, z, and u
import random
x = random.randint(1,1000)
y = random.randint(1,1000)
z = random.randint(1,1000)
u = random.randint(1,1000)

# compute the algebraic circuit
r = x * y * z * u
v1 = x*y
v2 = z*u

# create the witness vector
a = np.array([1, r, x, y, z, u, v1, v2])

# element-wise multiplication, not matrix multiplication
result = np.matmul(O, a) == np.multiply(np.matmul(L, a), np.matmul(R, a))

assert result.all(), "system contains an inequality"
```

## Example 3: Addition with a constant
What if we want to build an rank one constraint system for the following?

$$z = x * y + 2$$

This is where that 1 column comes in handy.

### Addition is free
You’ve probably heard the statement “addition is free” in the context of ZK-SNARKs. What that means is we don’t have to create an additional constraint when we have an addition operation.

We could write the above formula as

$$\begin{align*}
v_1 = xy \\
z = v_1 + 2 \\
\end{align*}$$

but that would make our R1CS larger than it needs to be.

Instead, we can write it as

$$-2 + z = xy$$

Then the variable $z$ and the constant $-2$ are automatically “combined” when we multiply $\mathbf{a}$ by $\mathbf{O}$ with our witness vector.

Our witness vector has the form `[1, z, x, y]`, so our matrix $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$ are as follows:

$$
\mathbf{L} = \begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}$$

$$
\mathbf{R} = \begin{bmatrix}
0 & 0 & 0 & 1 \\
\end{bmatrix}$$

$$
\mathbf{O} = \begin{bmatrix}
-2 & 1 & 0 & 0 \\
\end{bmatrix}$$

Whenever there are additive constants, we simply place them in the $1$ column, which by convention is the first column.

Again, let’s do some unit tests on our math:

```python
import numpy as np
import random

# Define the matrices
A = np.matrix([[0,0,1,0]])
B = np.matrix([[0,0,0,1]])
C = np.matrix([[-2,1,0,0]])

# pick random values to test the equation
x = random.randint(1,1000)
y = random.randint(1,1000)
z = x * y + 2 # witness vector
a = np.array([1, z, x, y])

# check the equality
result = C.dot(w) == np.multiply(np.matmul(L, a), B.dot(w))
assert result.all(), "result contains an inequality"
```

## Example 4: Multiplication with a constant
In all of the examples above, we never multiplied variables by constants. That’s why the entries in the r1cs was always 1. As you may have guessed from the above example, the entry in the matrices is the same value of the constant the variable is multiplied by as the following example will show.

Let’s work out the solution for

$$z = 2x^2 + y$$

Note that when we say “one multiplication per constraint” we mean the multiplication of two variables. Muliplication with a constant is not "real" multiplication because it is really repeated addition of the same variable.

The following solution is valid, but creates unnecessary rows:

$$
\begin{align*}
v_1 &= xx \\
z &= 2v_1
\end{align*}
$$

The more optimal solution is as follows:

$$-y + z = 2xx$$

Using the more optimal solution, our witness vector will have the form `[1, out, x, y]`.

The matrices will be defined as follows:

$$
\begin{align*}
\mathbf{L} &= \begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix} \\
\mathbf{R} &= \begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix} \\
\mathbf{O} &= \begin{bmatrix}
0 & 1 & 0 & -1 \\
\end{bmatrix} \\
\end{align*}
$$

Symbolically multiplying the above by `[1, z, x, y]` in the r1cs form gives us our original equation back: 

$$
\begin{bmatrix}
0 & 1 & 0 & -1 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
z \\
x \\
y \\
\end{bmatrix}
=
\begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
z \\
x \\
y \\
\end{bmatrix}\circ
\begin{bmatrix}
0 & 0 & 1 & 0 \\
\end{bmatrix}
\begin{bmatrix}
1 \\
z \\
x \\
y \\
\end{bmatrix}
$$
$$
z - y = 2xx
$$
$$
z = 2x^2 + y
$$

so we know we set up $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$ correctly.

Here we have one row (constraints) and one “true” multiplication. As a general rule:

The number of constraints in a Rank One Constraint system should be equal the number of non-constant multiplications.

## Example 5: A large constraint
Let’s do something less trivial that incorporates everything learned above

Suppose we have the following constraint:

$$
z = 3x^2 + 5xy - x - 2y + 3
$$

We will break it up as follows:

$$
\begin{align*}
v_1 &= 3xx \\
v_2 &= v_1y \\
-v_2 + x + 2y - 3 + z  &= 5xy \\
\end{align*}
$$

Note how all the addition terms have been moved to the left (this is what we did in the addition example, but it is more apparent here).

Leaving the right hand side as $5xy$ in the third row is arbitrary. We could divide both sides by 5 and have the final constraint be

$$
\frac{-v_2}{5} + \frac{x}{5} + \frac{2y}{5} - \frac{3}{5} + \frac{z}{5}= xy
$$

This doesn’t change the witness however, so both are valid. Since everything is done in a finite field, this operation is multiplying the left-hand-side and the right-hand-side by the multiplicative inverse of 5.

Our witness vector will be of the form

$$[1, z, x, y, v_1, v_2]$$

And our matrices will have three rows, since we have three constraints:

$$
\begin{align*}
\color{red}{v_1} &= \color{green}{3x}\color{violet}{x} \\
\color{red}{v_2} &= \color{green}{v_1}\color{violet}{y} \\
\color{red}{-v_2 + x + 2y - 3 + z}  &= \color{green}{5x}\color{violet}{y} \\
\end{align*}
$$

We've marked the output $\mathbf{O}$ in <span style="color:red">red</span>, the left hand side $\mathbf{L}$ in <span style="color:green">green</span>, and the right hand side $\mathbf{R}$ in <span style="color:violet">violet</span>.  This produces the following matrices:

