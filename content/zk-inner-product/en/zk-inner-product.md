# A Zero Knowledge Proof for the Inner Product

In the previous chapter, we showed how to multiply two scalars together in a zero knowledge fashion: we commit to two degree-one polynomials, and prove that we correctly computed their product, and then showed that the constant term of the degree one polynomials are the commitments to the secret factors we are multiplying.

If the coefficients of our polynomial are vectors instead of scalars, then we can prove that we computed the inner product of the vector correctly.

## Polynomials with vectors as coefficients
The following are two polynomials with vector coefficients:

$$
\begin{align*}
\mathbf{l}(x) &= \begin{bmatrix} 1 \\ 2 \end {bmatrix} x + \begin{bmatrix} 3 \\ 4 \end{bmatrix} \\
\mathbf{r}(x) &= \begin{bmatrix} 2 \\ 3 \end{bmatrix} x +\begin{bmatrix} 7 \\ 2 \end{bmatrix}
\end{align*}
$$

Evaluating a vector polynomial produces another vector. For example, $\mathbf{l}(2)$ produces

$$
\mathbf{l}(2) = \begin{bmatrix} 1 \\ 2 \end{bmatrix} (2) + \begin{bmatrix} 3 \\ 4 \end{bmatrix} = \begin{bmatrix} 5 \\ 8 \end{bmatrix}
$$


and evaluating $\mathbf{r}$ at 2 returns:

$$
\mathbf{r}(2) = \begin{bmatrix} 2 \\ 3 \end{bmatrix} (2) + \begin{bmatrix} 7 \\ 2 \end{bmatrix} = \begin{bmatrix} 11 \\ 8 \end{bmatrix}
$$

## Multiplying vector polynomials
Vector polynomials can be multiplied together like scalar polynomials. For example, multiplying $\mathbf{l}(x)$ and $\mathbf{r}(x)$ yields:

$$
\mathbf{l}(x)\mathbf{r}(x) = 
(\begin{bmatrix}
1\\2
\end{bmatrix}x+
\begin{bmatrix}
3\\4
\end{bmatrix})(
\begin{bmatrix}
2 \\ 3
\end{bmatrix}x + 
\begin{bmatrix}
7\\2
\end{bmatrix}
)=$$
$$
=\begin{bmatrix}
2\\6
\end{bmatrix}x^2+
\begin{bmatrix}
7\\4
\end{bmatrix}x+
\begin{bmatrix}
6\\12
\end{bmatrix}x+
\begin{bmatrix}
21\\8
\end{bmatrix}$$
$$=
\begin{bmatrix}
2\\6
\end{bmatrix}x^2+
\begin{bmatrix}
13\\16
\end{bmatrix}x+
\begin{bmatrix}
21\\8
\end{bmatrix}
$$

When we multiply each of the vectors together, we take the Hadamard product (element-wise product, denoted with $\circ$).

Note that if we plug $x = 2$ into the resulting vector polynomial, we get the following:

$$
\begin{bmatrix}
2\\6
\end{bmatrix}(2)^2+
\begin{bmatrix}
13\\16
\end{bmatrix}(2)+
\begin{bmatrix}
21\\8
\end{bmatrix}=
\begin{bmatrix}
55\\64
\end{bmatrix}
$$

This is the same as if we compute:

$\mathbf{l}(2)\circ\mathbf{r}(2) = \begin{bmatrix}5\\8\end{bmatrix}\circ\begin{bmatrix}11\\8\end{bmatrix}=\begin{bmatrix}55\\64\end{bmatrix}$

## Inner product of vector polynomials
To compute the inner product of two vector polynomials, we multiply them together as described above, but then sum up all the vectors so they become scalars. We denote this operation as $\langle \mathbf{l}(x), \mathbf{r}(x) \rangle$. We can accomplish the same thing by using the inner product when we multiply vector coefficients instead of using the Hadamard product.

For the two example polynomials above, this would be:

$$\langle \mathbf{l}(x), \mathbf{r}(x) \rangle = \langle \begin{align*}\end{align*} \begin{bmatrix} 1 \\ 2 \end{bmatrix} x +\begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}2\\3\end{bmatrix}x+\begin{bmatrix}7\\2\end{bmatrix}\rangle$$

$$=\langle \begin{bmatrix} 1 \\ 2 \end{bmatrix},\begin{bmatrix}2 \\ 3 \end{bmatrix}\rangle x^2 + \langle \begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}2 \\ 3 \end{bmatrix}\rangle x + \langle \begin{bmatrix} 1 \\ 2 \end{bmatrix},\begin{bmatrix}7 \\ 2 \end{bmatrix}\rangle x+\langle \begin{bmatrix} 3 \\ 4 \end{bmatrix},\begin{bmatrix}7 \\ 2 \end{bmatrix}\rangle$$

$$=8x^2 + 18x + 11x + 29$$

$$=8x^2 + 29x + 29$$

Observe that $\langle\mathbf{l}(2), \mathbf{r}(2)\rangle$ is the same as $\langle \mathbf{l}(x), \mathbf{r}(x)\rangle$ evaluated at $x = 2$. That is, $\langle [5, 8], [11, 8]\rangle = 119$ and $8(2)^2 + 29(2) + 29 = 119$.

### Why this works in general
Suppose we multiplied vector polynomials together the "normal" way -- i.e. we take the elementwise-product (Hadamard product) of the coefficients instead of the inner product. The inner product of each of the coefficients is simply the sum of the terms of the Hadamard product of each of the coefficients. Therefore, we can say that if we have two vector polynomials $\mathbf{l}(x)$ and $\mathbf{r}(x)$, and we multiply them together as $\mathbf{t}(x)=\mathbf{l}(x)\mathbf{r}(x)$ then the inner product of $\langle \mathbf{l}(x), \mathbf{r}(x) \rangle$ is equal to the element-wise sum of the coefficients of $\mathbf{t}$. Note that the multiplication of two vector polynomials results in a vector polynomial, but the inner product of two vector polynomials results in polynomial where all the coefficients are scalars.

## Zero knowledge inner product proof
In the previous chapter on zero knowledge multiplication, we demonstrated that we have a valid multiplication by proving that the product of the constant terms of two linear polynomials equals the constant term in the product of the polynomials.

To prove correct computation of an inner product, we replace the polynomials with vector polynomials and we replace the multiplication of scalar polynomials with the inner product of vector polynomials.

Everything else remains the same.

## The algorithm
The goal is for the prover to convince the verifier that $A$ is a commitment to $\mathbf{a}$ and $\mathbf{b}$, $V$ is a commitment to $v$, and that $\langle \mathbf{a}, \mathbf{b} \rangle = v$ without revealing $\mathbf{a}$, $\mathbf{b}$, or $v$.

### Setup
The prover and verifier agree on *basis vectors* $\mathbf{G}$ and $\mathbf{H}$ with which the prover can commit the vectors and elliptic curve point $B$ for the blinding terms.

### Prover
The prover generates the blinding terms $\alpha$, $\beta$, $\gamma$, $\tau_1$, and $\tau_2$ and computes:

$$
\begin{align}
A &= \langle\mathbf{a},\mathbf{G}\rangle + \langle\mathbf{b},\mathbf{H}\rangle+\alpha B\\
S &= \langle\mathbf{s}_L,\mathbf{G}\rangle + \langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B\\
V &= vG + \gamma B \\
T_1 &= \langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle + \tau_1B\\
T_2 &= \langle\mathbf{s}_L,\mathbf{s}_R\rangle G + \tau_2B
\end{align}$$

Note that this time the linear coefficients $\mathbf{s}_L$ and $\mathbf{s}_R$ are vectors instead of scalars. The prover transmits $(A, S, V, T_1, T_2)$ to the verifier. After the verifier responds with a random $u$, the prover evaluates $\mathbf{l}(x)$, $\mathbf{r}(x)$, and their inner product $\mathbf{t}(x)$.

$$
\begin{align*}
\mathbf{l}_u &= \mathbf{a} + \mathbf{s}_Lu \\
\mathbf{r}_u &= \mathbf{b} + \mathbf{s}_Ru \\
t_u &= v + (\langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle)u + \langle\mathbf{s}_L,\mathbf{s}_R\rangle u^2\\
\pi_{lr} &=\alpha+\beta u\\
\pi_t &= \gamma + \tau_1u + \tau_2u^2\\
\end{align*}
$$

### Final verification step
First, the verifier checks that $t_u$ is the inner product of $\mathbf{l}_u$ and $\mathbf{r}_u$ evaluated at $u$.

$t_u \stackrel{?}{=} \langle \mathbf{l}, \mathbf{r} \rangle$

This should hold if the prover is honest, because the inner product of the polynomials evaluated at $u$ is the same as the inner product of the vector polynomials $\mathbf{l}_x$ and $\mathbf{r}_x$ evaluated at $x = u$.

Second, the verifier checks that $A$ and $S$ are commitments to the constant and linear terms of $\mathbf{l}$ and $\mathbf{r}$ respectively.

$A + Su \stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H} \rangle + \pi_{lr} B$

Recall that $A$ and $S$ are commitments to the constant and linear terms of $\mathbf{l}$ and $\mathbf{r}$ and $\pi_{lr}$ is the sum of the blinding terms in $A$ and $S$.

Finally, the verifier checks that $t_u$ is the evaluation of the quadratic polynomial commited to $V, T_1, T_2$:

$t_u \stackrel{?}{=} V + T_1 u + T_2 u^2 + \pi B$

## Improving the proof size
When the prover sends $(\mathbf{l}, \mathbf{r}, t, T_1, T_2, \pi)$, the prover sends over $2n$ elements (the length of $\mathbf{l}$ and $\mathbf{r}$) which is not succinct.

In the following chapters we will learn how to reduce the size of the proof. Specifically, it is possible to create a proof of size $\log n$ that an inner product is correct.

## Summary
We have described a protocol that proves that $A$ is a commitment to $\mathbf{a}$ and $\mathbf{b}$, $V$ is a commitment to $v$, and that $\langle \mathbf{a}, \mathbf{b} \rangle = v$ without revealing $\mathbf{a}$, $\mathbf{b}$, or $v$. The proof size however is linear, as $\mathbf{l}$ and $\mathbf{r}$ in $(\mathbf{l}, \mathbf{r}, t, T_1, T_2, \pi_{lr},\pi_t)$ are each of size $n$.