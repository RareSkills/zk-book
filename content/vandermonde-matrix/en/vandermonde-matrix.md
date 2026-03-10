# Vandermonde Matrices

A **Vandermonde matrix** is a matrix that converts a polynomial from its coefficient representation into its value representation at a set of points.

For a polynomial $f(x) = a_0 +a_1x + a_2x^2+\dots+a_{k-1}x^{k-1}$ with its [coefficient representation](https://rareskills.io/post/polynomial-multiplication-point-form#ways-to-represent-a-polynomial):

$$
\mathbf{a} =
\begin{bmatrix}
a_0\\
a_1\\
a_2\\
\vdots\\
a_{k-1}
\end{bmatrix}
$$

The Vandermonde matrix evaluates it at $k$ distinct points as a single operation.

## Evaluating a polynomial as a matrix product

For simplicity, we assume $k=4$, then we have a polynomial of degree $k-1 =3$.

### Evaluation at single point

The evaluation of polynomial $f(x)$ at the point $x_0$ is:

$$
f(x_0) = a_0 +a_1\cdot x_0 + a_2\cdot x_0^2+a_{3}\cdot x_0^{3}
$$

This can be written as matrix product: multiplying a $1\times 4$ matrix containing the successive powers of $x_0$ by the vector of polynomial coefficients, as follows:

$$
\begin{bmatrix}
f(x_0)
\end{bmatrix}
= \begin{bmatrix} 1 & x_0^1 & x_0^2 & x_0^{3}
\end{bmatrix}
\cdot
\begin{bmatrix}
a_0\\
a_1\\
a_2\\
a_{3}
\end{bmatrix}
$$

### Evaluation at two points

To evaluate at two points, $x_0$ and $x_1$, we could express these as two separate matrix products. Instead, we stack these row vectors into a $2 \times 4$ matrix:

$$
\begin{bmatrix}
f(x_0) \\
f(x_1)
\end{bmatrix}
= 
\begin{bmatrix} 1 & x_0^1 & x_0^2 & x_0^{3}\\
1 & x_1^1 & x_1^2 & x_1^{3}\\
\end{bmatrix}
\cdot
\begin{bmatrix}
a_0\\
a_1\\
a_2\\
a_{3}
\end{bmatrix}
$$

Where each row contains the successive powers of $x_0$ and $x_1$, respectively.

Therefore, evaluating the polynomial at two points is equivalent to multiplying a $2 \times k = 2 \times 4$ matrix by the coefficient vector.

### Evaluation at $4$ points

If we extend our points to $4$ points, then with $k=4$ (already assumed), the resulting system of equations is equivalent to multiplying a $k\times k = 4\times 4$ matrix by the vector of coefficients:

$$
\begin{bmatrix}
f(x_0) \\
f(x_1)\\
f(x_2)\\
f(x_{3})
\end{bmatrix}
= 
\begin{bmatrix}
1 & x_0 & x_0^2 & x_0^{3} \\
1 & x_1 & x_1^2 & x_1^{3} \\
1 & x_2 & x_2^2 & x_2^{3} \\
1 & x_{3} & x_{3}^2 & x_{3}^{3}
\end{bmatrix}
\cdot
\begin{bmatrix}
a_0\\
a_1\\
a_2\\
a_{3}
\end{bmatrix}
$$

This matrix is called a $4\times 4$ **Vandermonde matrix** and is denoted by $\mathbf{V}$.

The equation above is compactly written below as 

$$
\mathbf{p} = \mathbf{V}\cdot\mathbf{a}
$$

where $\mathbf{a}$ is the vector of the polynomial’s coefficients and $\mathbf{p}$ is the vector of its point values.

## Evaluating the polynomial at the 4th roots of unity as a matrix product

Now, consider evaluating the polynomial $f(x)$ at the 4th [roots of unity](https://rareskills.io/post/roots-of-unity-finite-field), $\{\omega^0, \omega^1, \omega^{2}, \omega^{3}\}$, instead of at arbitrary $4$ points. We get the **Vandermonde matrix** $\mathbf{V}$ as:

$$
\mathbf{V} = 
\begin{bmatrix}
1 & 1^1 & 1^2 & 1^3 \\
1 & \omega & \omega^2 & \omega^{3} \\
1 & (\omega^2) & (\omega^2)^2 & (\omega^2)^{3} \\
1 & (\omega^3) & (\omega^3)^2 & (\omega^3)^{3}
\end{bmatrix}
$$

We can simplify every term that is $\omega^{\frac{k}{2}}$ or greater, by leveraging the properties that $\omega^{\frac{k}{2}} = \omega^2 = -1$ and $\omega^k=1$ as follows:

- $\omega^2 \equiv -1$ imply that $(\omega^2)^2 \equiv (-1)^2 = 1$ and $(\omega^2)^3 \equiv (-1)^3 = -1$.
- $\omega^3 = \omega^2\cdot\omega\equiv -1\cdot\omega = -\omega$ imply that:
    - $(\omega^3)^2 \equiv (-\omega)^2 = \omega^2\equiv -1$ and
    - $(\omega^3)^3 \equiv (-\omega)^3 = -\omega^3 =-(-\omega) =\omega$.

We now substitute these simplifications into the matrix:

$$
\mathbf{V} = 
\begin{bmatrix}
1 & 1^1 & 1^2 & 1^3 \\
1 & \omega & \omega^2\equiv-1 & \omega^{3}\equiv-\omega \\
1 & (\omega^2)\equiv-1 & (\omega^2)^2\equiv1 & (\omega^2)^{3}\equiv-1 \\
1 & (\omega^3)\equiv-\omega & (\omega^3)^2\equiv-1 & (\omega^3)^{3}\equiv\omega
\end{bmatrix}
$$

Therefore, the matrix simplifies to the following pattern:

$$
\mathbf{V} = 
\begin{bmatrix}
1 & 1 & 1 & 1 \\
1 & \omega & -1 & -\omega \\
1 & -1 & 1 & -1 \\
1 & -\omega & -1 & \omega
\end{bmatrix}
$$

For a concrete example, $\omega=13$ is a primitive 4th root of unity in the finite field $\mathbb{F}_{17}$ (where arithmetic is modulo 17), and the Vandermonde matrix is:

$$
\mathbf{V} = 
\begin{bmatrix}
1 & 1 & 1 & 1 \\
1 & 13 & 16 & 4 \\
1 & 16 & 1 & 16 \\
1 & 4 & 16 & 13
\end{bmatrix}
$$

## **Conclusion**

Evaluating a polynomial of degree $k-1$ at $k$ points is equivalent to multiplying a $k \times k$ Vandermonde $\mathbf{V}$ matrix by the coefficient vector $\mathbf{a}$, formalized by the equation $\mathbf{V}\cdot\mathbf{a} = \mathbf{p}$.
