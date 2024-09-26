# Converting Algebraic Circuits to R1CS (Rank One Constraint System)

This article is explains how to turn a set of arithmetic constraints into Rank One Constraint System (R1CS).

The focus of this resource is implementation: we cover a lot more corner cases of doing this transformation than other materials, discuss optimizations, and explain how the Circom library accomplishes it.

## Prerequisites
- We assume the reader understands how to use [arithmetic circuits (zk circuits)](https://www.rareskills.io/post/arithmetic-circuit) to represent the validity of a computation.
- The reader is familiar with [modular arithmetic](https://www.rareskills.io/post/finite-fields). All operations here happen in a finite field, so $-5$ really means the additive inverse of $5$ modulo $p$ and $2/3$ means the multiplicative inverse of $3$ modulo $p$ times $2$.

## Rank 1 Constraint System overview
A Rank 1 Constraint System (R1CS) is an arithmetic circuit with the requirement that each equality constraint has one multiplication (and no restriction on the number of additions).

This makes the representation of the arithmetic circuit compatible with the use of bilinear pairings. The output of a pairing $G_1 \bullet G_2 \rightarrow G_T$ cannot be paired again, as an element in $G_T$ cannot be used as part of the input of another pairing. Hence, we only allow one multiplication per constraint.

## The witness vector
In an arithmetic circuit, the witness is an assignment to all the signals that satisfies the constraints of the equation.

In a Rank 1 Constraint System the witness vector is a $1 \times n$ vector that contains the value of all the input variables, the output variable, and the intermediate values. It shows you have executed the circuit from start to finish, knowing both the input, output, and all the intermediate values.

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

where each term has a value that satisfies the constraints above.

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

## Example 1: Transforming $z = x \cdot y$ into a Rank 1 Constraint System

For our example, we will say we are proving $41 \times 103 = 4223$.

Therefore, our witness vector is $[1, 4223, 41, 103]$ as an assignment to $[1, z, x, y]$.

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

Matrix $\mathbf{L}$ encodes the the variable on the left side of the multiplication and $\mathbf{R}$ encodes the variables on the right side of the multiplication. $\mathbf{O}$ encodes the result variables. The vector $\mathbf{a}$ is the witness vector.

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

For the left hand terms, $x$ is the only variable present on the left side of the multiplication, so if the columns represent $[1, z, x, y]$, then…

$\mathbf{L}$ is $[0, 0, 1, 0]$, because $x$ is present, and none of the other variables are.

$\mathbf{R}$ is $[0, 0, 0, 1]$ because the only variable in the right side of the multiplication is $y$, and

$\mathbf{O}$ is $[0, 1, 0, 0]$ because we only have the $z$ variable in the "output" of the multiplication.

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

You may be wondering what the point of this is, aren’t we just saying that $41 \times 103 = 4223$ is a much less compact way?

You would be correct.

An R1CS can be quite verbose, but they map nicely to [Quadratic Arithmetic Programs (QAPs)](https://www.rareskills.io/post/quadratic-arithmetic-program), which can be made succinct. But we will not concern ourselves with QAPs here.

But this is an important point of R1CS. A R1CS communicates exactly the same information as the original arithmetic constraints, but with only one multiplication per equality constraint. In this example, we have only one constraint, but we’ll add more in the next example.

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
Because we are dealing with 7 variables $(r, x, y, z, u, v_1, v_2)$, our witness vector will have eight elements (the first being the constant 1) and our matrices will have eight columns.

Because we have three constraints, the matrices will have three rows.

### Left hand terms and right hand terms
This example will strongly enforce the idea of a "left hand term" and a "right hand term." Specifically, $x$, $z$, and $v_1$ are left hand terms, and $y$, $u$, and $v_2$ are right hand terms.

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
Let’s construct the matrix A. We know it will have three rows (since there are three constraints) and eight columns (since there are eight variables).

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
1 & r &x & y & z & u & v_1 & v_2
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

Recall that the columns of $\mathbf{L}$ are labelled as follows:

$$
\begin{bmatrix}
1 & r &x & y & z & u & v_1 & v_2\\
\end{bmatrix}
$$

and we see that the $1$ is in the $x$ column.

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

Matrix $\mathbf{R}$ must have 1s representing $y$, $u$, and $v_2$. The row in the matrix corresponds to the row of the arithmetic constraint, i.e. we can number the constraints (rows) as follows:

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
In all of the examples above, we never multiplied variables by constants. That’s why the entries in the R1CS was always 1. As you may have guessed from the above example, the entry in the matrices is the same value of the constant the variable is multiplied by as the following example will show.

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

Here we have one row (constraints) and one 
"true" multiplication. As a general rule:

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

$$
A = \begin{bmatrix}
0 & 0 & \textcolor{violet}{3} & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & \textcolor{violet}{1} \\
0 & 0 & \textcolor{violet}{5} & 0 & 0 & 0 \\
\end{bmatrix}
$$

$$
B = \begin{bmatrix}
0 & 0 & \textcolor{blue}{1} & 0 & 0 & 0 \\
0 & 0 & 0 & \textcolor{blue}{1} & 0 & 0 \\
0 & 0 & 0 & 0 & \textcolor{blue}{1} & 0 \\
\end{bmatrix}
$$

$$
C = \begin{bmatrix}

0 & 0 & 0 & 0 & \textcolor{red}{1} & 0 \\
0 & 0 & 0 & 0 & 0 & \textcolor{red}{1} \\
\textcolor{red}{-3} & 1 & 1 & 2 & 0 & \textcolor{red}{-1} \\
\end{bmatrix}
$$

with column labels

$$\begin{bmatrix}1 & \text{out} & x & y & v_1 & v_2\end{bmatrix}$$

Let's check our work as usual.

```python
import numpy as np
import random

# Define the matrices
A = np.array([[0,0,3,0,0,0],
               [0,0,0,0,1,0],
               [0,0,1,0,0,0]])

B = np.array([[0,0,1,0,0,0],
               [0,0,0,1,0,0],
               [0,0,0,5,0,0]])

C = np.array([[0,0,0,0,1,0],
               [0,0,0,0,0,1],
               [-3,1,1,2,0,-1]])

# pick random values for x and y
x = random.randint(1,1000)
y = random.randint(1,1000)

# this is our orignal formula
out = 3 * x * x * y + 5 * x * y - x- 2*y + 3# the witness vector with the intermediate variables inside
v1 = 3*x*x
v2 = v1 * y
w = np.array([1, out, x, y, v1, v2])

result = C.dot(w) == np.multiply(A.dot(w),B.dot(w))
assert result.all(), "result contains an inequality"
```

## Rank 1 Constraint Systems do not require starting with a single polynomial
To keep things simple, we've been using examples of the form $z = xy + ...$ but most realistic arithmetic constraints are going to be set of arithmetic constraints, not a single one.

For example, suppose we are proving that an array $[x₁, x₂, x₃, x₄]$ is binary and $v$ is less than 16. The set of constraints will be

$$
\begin{align*}
x₁² &= x₁\\
x₂² &= x₂\\
x₃² &= x₃\\
x₄² &= x₄ \\
v &= 8x₄ + 4x₃ + 2x₂ + x₁
\end{align*}
$$

To get the into a rank one constraint system, we notice that the final row doesn't have any multiplication, so we can substitute $x_1$ into the first constraint:

$$
\begin{align*}
x₁² &= v - 8x₄ - 4x₃ - 2x₂\\
x₂² &= x₂\\
x₃² &= x₃\\
x₄² &= x₄ \\
\end{align*}
$$

Assuming our witness vector is $[1, v, x_1, x_2, x_3, x_4]$, we can create the R1CS as follows:

$$
\begin{align*}
\mathbf{L} &= \begin{bmatrix}
0 & 0 & 1 & 0 & 0 & 0 \\
0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix} \\
\mathbf{R} &= \begin{bmatrix}
0 & 0 & 1 & 0 & 0 & 0 \\
0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix} \\
\mathbf{O} &= \begin{bmatrix}
0 & 1 & 0 & -2 & -4 & -8 \\
0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix} \\
\end{align*}
$$

Doing the substitution is not strictly necessary, but it saves a row in the R1CS. In a later section, we will show a valid R1CS where we do not do the substitution.

## Everything is done modulo prime in r1cs
In the above examples, we used traditional arithmetic for the sake of simplicity, but real world implementations use modular arithmetic instead.

The reason is simple: encoding numbers like 2/3 leads to ill-behaved floats which are computationally intensive and error prone.

If we do all our math modulo a prime number, let’s say 23, then encoding $2/3$ is straightforward. It’s the same as $2 \cdot 3^{-1}$, and multiplying by two and raising to the power of negative 1 are straightforward in modular arithmetic

## Circom implementation.
In Circom, a language for constructing Rank 1 Constraint Systems, the finite field uses the prime number $21888242871839275222246405745257275088548364400416034343698204186575808495617$ (this is equal to the order of the BN128 curve we discussed in [Elliptic Curves over Finite Fields](https://www.rareskills.io/post/elliptic-curves-finite-fields)).

This means $-1$ in that representation is

```python
p = 21888242871839275222246405745257275088548364400416034343698204186575808495617

# 1 - 2 = -1
(1 - 2) % p

# 21888242871839275222246405745257275088548364400416034343698204186575808495616
```

### Circom for out = x * y
If we write `out = x * y` in Circom, it would look like the following:

```javascript
pragma circom 2.0.0;

template Multiply2() {
    signal input x;
    signal input y;
    signal output out;

    out <== x * y;
 }

component main = Multiply2();
```

Let’s turn this into an R1CS file and print the R1CS file

```bash
circom multiply2.circom --r1cs --sym
snarkjs r1cs print multiply2.r1cs
```

We get the following output:

![console result of Circom compilation](https://static.wixstatic.com/media/935a00_ce8574af090e4b4d8465fd45d7dda8ff~mv2.png/v1/fill/w_1480,h_496,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_ce8574af090e4b4d8465fd45d7dda8ff~mv2.png)

This looks quite a bit different from our R1CS solution, but it is actually encoding the same information.

Here are the differences in Circom’s implementation:
- Columns with zero value are not printed
- Circom writes $\mathbf{O}\mathbf{a} = \mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}$ as $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a}  - \mathbf{O}\mathbf{a} = \mathbf{0}$

What about the 21888242871839275222246405745257275088548364400416034343698204186575808495616 which is really -1?

Circom's solution is

$$
\begin{align*}
A &= \begin{bmatrix}
0 & 0 & -1 & 0 
\end{bmatrix}\\
B &= \begin{bmatrix}
0 & 0 & 0 & 1 
\end{bmatrix}\\
C &= \begin{bmatrix}
0 & -1 & 0 & 0 
\end{bmatrix}
\end{align*}
$$

Even though the negative ones might be unexpected, with the witness vector `[1 out x y]`, this is actually consistent with the form $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a} - \mathbf{O}\mathbf{a} = \mathbf{0}$. (We will see in a second that Circom did indeed use this column assignment).

You can plug in values for $x$, $y$, and out and see that the equation $\mathbf{L}\mathbf{a}\circ\mathbf{R}\mathbf{a} - \mathbf{O}\mathbf{a} = \mathbf{0}$ holds.

Let’s see Circom’s variable to column assignment. Let’s recompile our circuit with a wasm solver:

```bash
circom multiply2.circom --r1cs --wasm --sym

cd multiply2_js/
```

We create the `input.json` file

```bash
echo '{"x": "11", "y": "9"}' > input.json
```

And compute the witness

```bash
node generate_witness.js multiply2.wasm input.json witness.wtns

snarkjs wtns export json witness.wtns witness.json

cat witness.json
```

We get the following result:

![terminal output after computing the witness](https://static.wixstatic.com/media/935a00_6ffb172a2e7649cab8cc6db8cace8de8~mv2.png/v1/fill/w_1428,h_316,al_c,lg_1,q_90,enc_auto/935a00_6ffb172a2e7649cab8cc6db8cace8de8~mv2.png)

It is clear that Circom is using the same column layout we have been using: `[1, out, x, y]`, as $x$ was set to $11$ and $y$ to $9$ in our `input.json`.

If we use Circom’s generated witness (replacing the massive number with -1 for readability), then we see Circom's R1CS is correct

$$
\begin{align*}
\mathbf{a} &= \begin{bmatrix}
1 & 99 & 11 & 9
\end{bmatrix}\\
\mathbf{L} &= \begin{bmatrix}
0 & 0 & -1 & 0
\end{bmatrix} \rightarrow \mathbf{L}\mathbf{a} = -11\\
\mathbf{R} &= \begin{bmatrix}
0 & 0 & 0 & 1
\end{bmatrix} \rightarrow \mathbf{R}\mathbf{a} = 9\\
\mathbf{O} &= \begin{bmatrix}
0 & -1 & 0 & 0
\end{bmatrix} \rightarrow \mathbf{O}\mathbf{a} = -99
\end{align*}
$$

$$
\begin{align*}
Aw \cdot Bw - Cw &= 0\\
(-11)(9) - (-99) &= 0 \\
-99 + 99 &= 0
\end{align*}
$$

$\mathbf{L}$ has one coefficient of $-1$ for $x$, $\mathbf{R}$ has one coefficient of $+1$ for $y$, and $\mathbf{O}$ has $-1$ for $\text{out}$. In modular form, this is identical to what the terminal outputted above:

![terminal output of the R1CS](https://static.wixstatic.com/media/935a00_36651c70d5aa49d89059cbae553be7e9~mv2.png/v1/fill/w_1480,h_114,al_c,lg_1,q_85,enc_auto/935a00_36651c70d5aa49d89059cbae553be7e9~mv2.png)

### Checking the rest of our work
By way of review, the formulas we explored were

$$
\begin{align}
z &= x * y \\
z &= x * y * z * u \\
z &= x * y + 2 \\
z &= 3x^2 y + 5xy - x - 2y + 3
\end{align}
$$

We just did (1) in the section above, for this section we will illustrate the principle that the number of non-constant multiplications is the number of constraints.

The circuit for (2) is:
```javascript
pragma circom 2.0.8;

template Multiply4() {
    signal input x;
    signal input y;
    signal input z;
    signal input u;
    
    signal v1;
    signal v2;
    
    signal out;
    
    v1 <== x * y;
    v2 <== z * u;
    
    out <== v1 * v2;
}

template main = Multiply4();
```

With everything we’ve discussed so far, the Circom output and the annotations should be self-explanatory.

![annotation of constraint generation for Multiply4()](https://static.wixstatic.com/media/935a00_21b46f6f9ffd4a80b1a2a374be0de279~mv2.png/v1/fill/w_990,h_420,al_c,q_90,enc_auto/935a00_21b46f6f9ffd4a80b1a2a374be0de279~mv2.png)

With that in mind, our other formulas should have constraints as follows:

$$
\begin{align}
z &= x * y && \text{1 constraint} \\
z &= x * y * z * u && \text{3 constraints} \\
z &= x * y + 2 && \text{1 constraint} \\
z &= 3x^2 y + 5xy - x - 2y + 3 && \text{3 constraints}
\end{align}
$$

It is an exercise for the reader to write the Circom circuits and verify the above.

### You do not need a witness to calculate the R1CS
Note that in the Circom code we never supplied the witness before calculating the R1CS. We supplied the witness earlier to make the example less abstract and to make it easy to check our work, but it isn’t necessary. This is important, because if a verifier needed a witness to construct an R1CS, then the prover would have to give the hidden solution away!

When we say "witness" we mean a vector with populated values. The verifier knows the "structure" of the witness, i.e. the variable to column assignments, but doesn’t know the values.

## An R1CS is valid even if it is not optimized
A valid transformation from a polynomial to an R1CS is not unique. You can encode the same problem with more constraints, which is less efficient. Here is an example.

In some R1CS tutorials, the constraints for a formula like

$$z = x² + y$$

is transformed to

$$
\begin{align*}
v₁ &= x  x \\
z &= v₁ + y
\end{align*}
$$

As we’ve noted, this is not efficient. However, you create a valid R1CS for this using the methodology in this article. We simply add a dummy multiplication like so:

$$
\begin{align*}
v₁ &= x  x \\
z &= (v₁ + y) * 1
\end{align*}
$$

Our witness vector is of the form $[1, z, x, y, v1]$ and $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$ are defined as follows:

$$
\mathbf{L} = \begin{bmatrix}
0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 1 & 1 
\end{bmatrix}
$$

$$
\mathbf{R} = \begin{bmatrix}
0 & 0 & 1 & 0 & 0 \\
1 & 0 & 0 & 0 & 0 
\end{bmatrix}
$$

$$
\mathbf{O} = \begin{bmatrix}
0 & 0 & 0 & 0 & 1 \\
0 & 1 & 0 & 0 & 0 
\end{bmatrix}
$$

The second row of $\mathbf{L}$ accomplishes the addition, and the multiply by one is accomplished by using the first element of the second row of $\mathbf{R}$.

This is perfectly valid, but the solution has one more row and and one more column than it needs.

## What if there are no multiplications?
What if we want to encode the following circuit?

$$
z = x + y
$$

This is pretty useless in practice, but for the sake of completeness, there can be solved with a dummy multiplication by one.

$$
out = (x + y)*1
$$

With our typical witness vector layout of $[1, z, x, y]$, we have the following matrices:

$$
\begin{align*}
\mathbf{L} &= \begin{bmatrix}
0 & 0 & 1 & 1 \\
\end{bmatrix} \\
\mathbf{R} &= \begin{bmatrix}
1 & 0 & 0 & 0 \\
\end{bmatrix} \\
\mathbf{O} &= \begin{bmatrix}
0 & 1 & 0 & 0 \\
\end{bmatrix} 
\end{align*}
$$

## Rank One Constraint Systems are for convenience
The original [paper for Groth16](https://eprint.iacr.org/2016/260.pdf) don’t have any reference to the term Rank One Constraint System. A R1CS is handy from an implementation perspective, but from a pure math perspective, it is simply explicitly labeling and grouping the coefficients of different variables. So when you read academic papers on the subject, it is usually missing because it is an implementation detail of a more abstract concept.

## Handy Resources
- This [web tool calculates R1CS](https://asecuritysite.com/zero/go_r1cs) for a set of constraints (but it only works with one input and output variable).

- [Vitalik’s famous example of x**3 + x + 5 == 35](https://medium.com/@VitalikButerin/quadratic-arithmetic-programs-from-zero-to-hero-f6d558cea649)

- [Zero knowledge blog’s R1CS tutorial](https://www.zeroknowledgeblog.com/index.php/the-pinocchio-protocol/r1cs)

## Learn more with RareSkills
This blog post is taken from learning materials in our [zero knowledge course](https://www.rareskills.io/zk-bootcamp).
