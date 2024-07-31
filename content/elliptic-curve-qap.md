# Evaluating and Quadratic Arithmetic Program on a Trusted Setup

Evaluating a [Quadratic Arithmetic Program (QAP)](https://www.rareskills.io/post/quadratic-arithmetic-programs) on a trusted setup enables a prover to demonstrate that a QAP is satisfied without revealing the witness while using a constant sized proof.

Specifically, the QAP polynomials are evaluated at an unknown point $\tau$. The QAP equation

$$\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

will be balanced if the vector $\mathbf{a}$ satisfies the equation, and unbalanced with overwhelming probability otherwise.

The scheme shown here is not a secure ZK Proof, but it is a stepping stone towards showing how Groth16 works.

## A Concrete Example
To make this a little less abstract, let’s say that matrices of the Rank 1 Constraint System (R1CS) $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$ have 3 rows and 4 columns.

$$\mathbf{L}\mathbf{a} \circ \mathbf{R}\mathbf{a} = \mathbf{O}\mathbf{a}$$

Since we have 3 rows, it means our interpolating polynomials will be of degree 2. Because we have 4 columns, each matrix will result in 4 polynomials (for a total of 12 polynomials).

Our QAP will be

$$\sum_{i=1}^4a_iu_i(x)\sum_{i=1}^4a_iv_i(x) = \sum_{i=1}^4a_iw_i(x) + h(x)t(x)$$

## Notation and Preliminaries
We refer to the generators elliptic curve points in the groups $\mathbb{G}_1$ and $\mathbb{G}_2$ as $G_1$ and $G_2$ respectively. An element in $\mathbb{G}_1$ is denoted as $[X]_1$. An element in $\mathbb{G}_2$ is denoted as $[X]_2$. Where there might be ambiguity with the subscripts referring to indices in a list, we say $X \in \mathbb{G}_1$ or $X \in \mathbb{G}_2$. An [elliptic curve pairing](https://www.rareskills.io/post/bilinear-pairing) between two points is denoted as $[X]_1 \bullet [Y]_2$.

Let $\mathbf{L}_{(*,j)}$ be the $j$-th column of $\mathbf{L}$. In our example, the rows will be $(1,2,3)$ and the columns $(1,2,3,4)$. Let $\mathcal{L}(\mathbf{L}_{(*,j)})$ be the polynomial obtained from running Lagrange interpolation on the $j$-th column of $\mathbf{L}$ using the $x$ values $(1,2,3,4)$ and the $y$ values being the values of the $j$-th column.

Since we have 4 columns, we obtain four polynomials from $\mathbf{L}$

$$
\begin{align*}
u_1(x) = \mathcal{L}(\mathbf{L}_{(*,1)}) =u_{12}x^2 + u_{11}x+u_{10}\\
u_2(x) = \mathcal{L}(\mathbf{L}_{(*,2)}) =u_{22}x^2 + u_{21}x+u_{20}\\
u_3(x) = \mathcal{L}(\mathbf{L}_{(*,3)}) =u_{32}x^2 + u_{31}x+u_{30}\\
u_4(x) = \mathcal{L}(\mathbf{L}_{(*,4)}) =u_{42}x^2 + u_{41}x+u_{40}\\
\end{align*}
$$

four polynomials from $\mathbf{R}$

$$
\begin{align*}
v_1(x) = \mathcal{L}(\mathbf{R}_{(*,1)}) =v_{12}x^2 + v_{11}x+v_{10}\\
v_2(x) = \mathcal{L}(\mathbf{R}_{(*,2)}) =v_{22}x^2 + v_{21}x+v_{20}\\
v_3(x) = \mathcal{L}(\mathbf{R}_{(*,3)}) =v_{32}x^2 + v_{31}x+v_{30}\\
v_4(x) = \mathcal{L}(\mathbf{R}_{(*,4)}) =v_{42}x^2 + v_{41}x+v_{40}\\
\end{align*}
$$

and four polynomials from $\mathbf{O}$

$$
\begin{align*}
v_1(x) = \mathcal{L}(\mathbf{O}_{(*,1)}) =v_{12}x^2 + v_{11}x+v_{10}\\
v_2(x) = \mathcal{L}(\mathbf{O}_{(*,2)}) =v_{22}x^2 + v_{21}x+v_{20}\\
v_3(x) = \mathcal{L}(\mathbf{O}_{(*,3)}) =v_{32}x^2 + v_{31}x+v_{30}\\
v_4(x) = \mathcal{L}(\mathbf{O}_{(*,4)}) =v_{42}x^2 + v_{41}x+v_{40}\\
\end{align*}
$$

A polynomial $p_{ij}$ means the $i$-th polynomial of the and the $j$-th coefficient (power). For example, $j=2$ means the coefficient associated with $x^2$.

The QAP for our example is

$$
\sum_{i=1}^4a_iu_i(x)\sum_{i=1}^4a_iv_i(x) = \sum_{i=1}^4a_iw_i(x) + h(x)t(x)
$$
where $t(x) = (x - 1)(x - 2)(x - 3)$ and $h(x)$ is

$$
h(x)=\frac{\sum_{i=1}^4a_iu_i(x)\sum_{i=1}^4a_iv_i(x) - \sum_{i=1}^4a_iw_i(x)}{t(x)}
$$

Note that $h(x)$ can have at most degree 1 in our example. The highest degree $\sum_{i=1}^4a_iu_i(x)\sum_{i=1}^4a_iv_i(x)$ can have is 4 (degree 2 times degree 2), the lowest degree $\sum_{i=1}^4a_iw_i(x)$ can have is zero (a constant). Since $t(x)$ has degree 3, the highest degree the ratio can have is 1. In general, the highest degree $h(x)$ can have is $n - 2$, where $n$ is the number of rows in the R1CS.

## Expanding the terms

If we expand the sums from our previous example, we get the following

$$
\begin{align*}
\sum_{i=1}^4 a_iu_i(x) &= a_1(u_{12}x^2 + u_{11}x+u_{10}) + a_2(u_{22}x^2 + u_{21}x+u_{20}) + a_3(u_{32}x^2 + u_{31}x+u_{30}) + a_4(u_{42}x^2 + u_{41}x+u_{40})\\
&= (a_1u_{12}+a_2u_{22}+a_3u_{32}+a_4u_{42})x^2 + (a_1u_{11}+a_2u_{21}+a_3u_{31}+a_4u_{41})x + (a_1u_{10}+a_2u_{20}+a_3u_{30}+a_4u_{40})\\
&=u_{2a}x^2+u_{1a}x+u_{0a}\\
\sum_{i=1}^4 a_iv_i(x) &= a_1(v_{12}x^2 + v_{11}x+v_{10}) + a_2(v_{22}x^2 + v_{21}x+v_{20}) + a_3(v_{32}x^2 + v_{31}x+v_{30}) + a_4(v_{42}x^2 + v_{41}x+v_{40})\\
&= (a_1v_{12}+a_2v_{22}+a_3v_{32}+a_4v_{42})x^2 + (a_1v_{11}+a_2v_{21}+a_3v_{31}+a_4v_{41})x + (a_1v_{10}+a_2v_{20}+a_3v_{30}+a_4v_{40})\\
&=v_{2a}x^2+v_{1a}x+v_{0a}\\
\sum_{i=1}^4 a_iw_i(x) &= a_1(w_{12}x^2 + w_{11}x+w_{10}) + a_2(w_{22}x^2 + w_{21}x+w_{20}) + a_3(w_{32}x^2 + w_{31}x+w_{30}) + a_4(w_{42}x^2 + w_{41}x+w_{40})\\
&= (a_1w_{12}+a_2w_{22}+a_3w_{32}+a_4w_{42})x^2 + (a_1w_{11}+a_2w_{21}+a_3w_{31}+a_4w_{41})x + (a_1w_{10}+a_2w_{20}+a_3w_{30}+a_4w_{40})\\
&=w_{2a}x^2+w_{1a}x+w_{0a}\\
\end{align*}
$$

In each of the cases, since we are adding 4 degree 2 polynomials, we get a degree 2 polynomial.

In general expression $\sum_{i=1}^m a_ip_i(x)$ produces a polynomial with at most the same power as $p(x)$ (it could be less, if for example $(a_1w_{12}+a_2w_{22}+a_3w_{32}+a_4w_{42})x^2$ added up to 0). For convenience, we have introduced the coefficients $p_{ia}$ where $i$ is the power of the coefficient and $_a$ means we combined the polynomials with the witness $\mathbf{a}$.

Here are the polynomials after reducing the polynomials in this manner:

$$
\begin{align*}
\sum_{i=1}^4 a_iu_i(x) &= u_{2a}x^2+u_{1a}+u_{0a}\\
\sum_{i=1}^4 a_iv_i(x) &= v_{2a}x^2+v_{1a}+v_{0a}\\
\sum_{i=1}^4 a_iw_i(x) &= w_{2a}x^2+w_{1a}+w_{0a}\\
\end{align*}
$$

## Combining a trusted setup with a QAP
We can now apply the structured reference string from the trusted setup to evaluate the polynomials.

That is, given a structured reference string

$$[\Omega_2, \Omega_1, G_1], [\Theta_2, \Theta_1, G_2], \space\Omega_i \in \mathbb{G}_1, \space\Theta_i \in \mathbb{G}_2$$

which was computed in the trusted setup as

$$
\begin{align*}
[\Omega_2, \Omega_1, G_1] &= [\tau^2G_1, \tau G_1, G_1], \space\Omega_i \in \mathbb{G}_1\\
[\Theta_2, \Theta_1, G_1] &= [\tau^2G_2, \tau G_2, G_2], \space\Theta_i \in \mathbb{G}_2
\end{align*}
$$

We can compute

$$
\begin{align*}
[A]_1 &=\sum_{i=1}^4 a_iu_i(\tau) = \langle[u_{2a}, u_{1a}, u_{0a}],[\Omega_2, \Omega_1, G_1]\rangle\\
[B]_2 &=\sum_{i=1}^4 a_iv_i(\tau) = \langle[v_{2a}, v_{1a}, v_{0a}],[\Theta_2, \Theta_1, G_2]\rangle\\
[C]_1 &=\sum_{i=1}^4 a_iw_i(\tau) = \langle[v_{2a}, v_{1a}, v_{0a}],[\Omega_2, \Omega_1, G_1]\rangle \\
\end{align*}
$$

Here, $u_i(\tau), v_i(\tau), w_i(\tau)$ mean the polynomials were evaluated using the structured reference string generated from $\tau$ in the trusted setup, it does not mean "plug in $\tau$ and evaluate the polynomials". Since $\tau$ was destroyed after the trusted setup, the value $\tau$ is unknown.

We have computed most of the QAP using the srs, but we haven't computed $h(x)t(x)$ yet:

$$
\underbrace{\sum_{i=1}^m a_iu_i(x)}_{[A]_1}\underbrace{\sum_{i=1}^m a_iv_i(x)}_{[B]_2} = \underbrace{\sum_{i=1}^m a_iw_i(x)}_{[C]_1} + \underbrace{h(x)t(x)}_{??}
$$

## Computing $h(x)t(x)$

Recall that the degree of $t(x)$ is 3 (generally $n$) and the degree of $h(x)$ is 1 (generally $n - 2$). If we multiply these together, we could get up to a degree 3 polynomial, which is more than the powers of tau ceremony provides. Instead, the powers of tau ceremony must be adjusted to provide a structured reference string for $h(x)t(x)$.

The person doing the trusted setup knows $t(x)$, it is simply $(x - 1)(x - 2)...(x - n)$. However, $h(x)$ is a polynomial computed by the prover and changed based on the values of $\mathbf{a}$, so it cannot be known during the trusted setup.

Note that we cannot evaluate $h(\tau)$ and $t(\tau)$ separately (using a structured reference string) and then pair them together. That would not result in a $\mathbb{G}_1$ element which we need.

### SRS for polynomial products
Observe that the following computations all result in the same value:
- The polynomial $h(x)t(x)$ evaluated at $u$, or $(h(x)t(x))(u)$
- $h(u)$ multiplied by $t(u)$, or $h(u)t(u)$ ($h$ evaluated at $u$ and $t$ evaluated at $u$)
- $h(x)$ multiplied by the evaluation $t(u)$, then evaluated at $u$, i.e. $(h(x)t(u))(u)$

We will use the third method to compute $h(\tau)t(\tau)$. Suppose, without loss of generality, that $h(x)$ is $3x^2 + 6x + 2$ and $t(u) = 4$. The computation would be

$$h(x)t(u) = (3x^2 + 6x + 2) \cdot 4 = 12x^2 + 24x + 8$$

If we plug in $u$ to the $12x^2 + 24x + 8$, that would be $h(u)t(u)$.

However, evaluating this polynomial at $\tau$ would require the prover to know $\tau$. The key insight here is that the computation above can be structured as:

$$h(u)t(u) = \langle[3, 6, 2], [4u^2, 4u, 4]\rangle=12u^2+24u+8$$

If the trusted setup provides $[4u^2, 4u, 4]$, and the prover provides $[3, 6, 2]$, then the prover can compute $h(u)t(u)$ without knowing $u$, because anything involving $u$ is in the right vector of the inner product.

### Structured reference string for $h(\tau)t(\tau)$
To create a structured reference string for $h(\tau)t(\tau)$, we create $n - 1$ evaluations of $t(\tau)$ multiplied by successive powers of $\tau$.

$$[\Upsilon_{n-2}, \Upsilon_{n-3}, ..., \Upsilon_1, \Upsilon_0] = [\tau^{n-2}t(\tau)G_1, \tau^{n-3}t(\tau)G_1, ..., \tau t(\tau)G_1, t(\tau)G_1]$$

(Somewhat confusingly, a polynomial of degree $k$ has $k+1$ terms, hence we generate $k - 1$ evaluations for a polynomial of degree $k - 2$. Note that Upsilon starts at ${n-1}$ and ends at 0).

Here, $n$ is the number of rows in the R1CS, and we established that $h$ cannot have a degree greater than $n - 2$.

To use the structured reference string to compute $h(\tau)t(\tau)$, the prover does:

$$h(\tau)t(\tau) = \langle[h_{n-2}, h_{n-3}, ..., h_1, h_0], [\Upsilon_{n-2}, \Upsilon_{n-3}, ..., \Upsilon_1, \Upsilon_0] \rangle$$

## Evaluating a QAP on a trusted setup
We now tie everything together. Suppose we have a R1CS with matrices of $n$ rows and $m$ columns. From this, we can apply Lagrange interpolation to convert it to a QAP

$$\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

The sum terms will each produce a polynomial of degree $n - 1$ (a Lagrange polynomial has one less degree than the number of points it interpolates), and the $h(x)$ polynomial will have degree at most $n - 2$, and $t(x)$ will have degree $n$.

A trusted setup generates a random field element $\tau$ and computes:

$$
\begin{align*}
[\Omega_{n-1},\Omega_{n-2},..., \Omega_1, G_1] &= [\tau^{n-1}G_1, \tau^{n-2}G_1,\dots, \tau G_1, G_1]\\
[\Theta_{n-1}, \Theta_{n-2}, ..., \Theta_1, G_2] &= [\tau^{n-1}G_2, \tau^{n-2}G_2,\dots, \tau G_2, G_2]\\
[\Upsilon_{n-2}, \Upsilon_{n-3}, ..., \Upsilon_1, \Upsilon_0] &= [\tau^{n-2}t(\tau)G_1, \tau^{n-3}t(\tau)G_1, ..., \tau t(\tau)G_1, t(\tau)G_1]
\end{align*}
$$

Note that the structured reference strings need to have enough terms to accomodate the polynomials in the QAP.

Then the trusted setup destroys $\tau$ and publishes the structured reference strings:

$$([\Omega_2, \Omega_1, G_1], [\Theta_2, \Theta_1, G_2], [\Upsilon_{n-2}, \Upsilon_{n-3}, ..., \Upsilon_1, \Upsilon_0])$$

The prover evaluates the components of the QAP as follows:

$$\underbrace{\sum_{i=1}^m a_iu_i(x)}_{A}\underbrace{\sum_{i=1}^m a_iv_i(x)}_B = \underbrace{\sum_{i=1}^m a_iw_i(x) + h(x)t(x)}_{C}$$

$$
\begin{align*}
[A]_1 &=\sum_{i=1}^m a_iu_i(\tau) = \langle[u_{{n-1}a}, u_{{n-2}a}, \dots, u_{1a}, u_{0a}],[\Omega_{n-1}, \Omega_{n-2}, \dots, \Omega_1, G_1]\rangle\\
[B]_2 &=\sum_{i=1}^m a_iv_i(\tau) = \langle[v_{{n-1}a}, v_{{n-2}a}, \dots, v_{1a}, v_{0a}],[\Theta_{n-1}, \Theta_{n-2}, \dots, \Theta_1, G_2]\rangle\\
[C]_1 &=\sum_{i=0}^m a_iw_i(\tau) + h(\tau)t(\tau) = \langle[w_{{n-1}a}, w_{{n-2}a}, \dots, w_{1a}, w_{0a}],[\Omega_{n-1}, \Omega_{n-2}, \dots, \Omega_1, G_1]\rangle \\
&+\langle[h_{n-2}, h_{n-3}, \dots, h_1, h_0], [\Upsilon_{n-2}, \Upsilon_{n-3}, \dots, \Upsilon_1, \Upsilon_0] \rangle\\
\end{align*}
$$

The prover publishes $([A]_1, [B]_2, [C]_1)$ and the verifier can check that

$$[A]_1 \bullet [B]_2 \stackrel{?}= [C]_1 \bullet G_2$$

If the witness $\mathbf{a}$ satisfies the QAP, then the equation above will be balanced. But the equation being balanced doesn't ensure the prover knows a satisfying $\mathbf{a}$ because the prover can publish arbitrary elliptic curve points and the verifier doesn't know if they are actually derived from the QAP.

## The proof is very small
Observe that the proof only consists of three elliptic curve points. If a $\mathbb{G}_1$ element is 64 bytes large, and a $\mathbb{G}_2$ element is 128 bytes large, then the proof is only 256 bytes. This is true *regardless* of the size of the R1CS!

The larger the R1CS, the more work the prover has, but the verifier's work remains constant.

The solution to this problem is described in the next chapter on the [Groth16 protocol](https://www.rareskills.io/post/groth16).

The proof still remains of constant size in Groth16 as can be seen in the Tornado Cash source code on the [struct](https://github.com/tornadocash/tornado-core/blob/master/contracts/Verifier.sol#L167-L171)
 called `Proof`.

*Originally Published August 28, 2023*