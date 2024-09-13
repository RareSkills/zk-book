# Groth16 Explained

The Groth16 algorithm enables a quadratic arithmetic program to be computed by a prover over elliptic curve points derived in a trusted setup, and quickly checked by a verifier. It uses auxiliary elliptic curve points from the trusted setup to prevent forged proofs.

## Prerequisites
This article is a chapter in the [RareSkills Book of Zero Knowledge Proofs](https://www.rareskills.io/zk-book). It assumes you are familiar with the prior chapters.

## Notation
We refer to an [elliptic curve point](https://www.rareskills.io/post/elliptic-curves-finite-fields) belonging to the $\mathbb{G}_1$ elliptic curve group as $[x]_1$ and an elliptic curve point belonging to the $\mathbb{G}_2$ elliptic curve group as $[x]_2$. A [pairing](https://www.rareskills.io/post/bilinear-pairing) between $[x]_1$ and $[x]_2$ is denoted as $[x]_1\bullet[x]_2$ and produces an element in $\mathbb{G}_{12}$. Variables in bold such as $\mathbf{a}$ are vectors, upper case bold letters such as $\mathbf{L}$ are matrices, and field elements (sometimes informally referred to as "scalars") are lower case letters such as $d$. All arthmetic operations happen in a [finite field](https://www.rareskills.io/post/finite-fields) with a characteristic that equals the order of the elliptic curve group.

Given an [Arithmetic Circuit (ZK Circuit)](https://www.rareskills.io/post/arithmetic-circuit), we convert it to a [Rank 1 Constraint System (R1CS)](https://www.rareskills.io/post/rank-1-constraint-system) $\mathbf{L}\mathbf{a}\circ \mathbf{R}\mathbf{a} = \mathbf{O}\mathbf{a}$ with matrices of dimension $n$ rows and $m$ columns with a witness vector $\mathbf{a}$. Then, we can convert the R1CS to [Quadratic Arithmetic Program (QAP)](https://www.rareskills.io/post/quadratic-arithmetic-program) by interpolating the columns of the matrices as $y$ values over the $x$ values $[1,2,...,n]$. Since $\mathbf{L}$, $\mathbf{R}$, and $\mathbf{O}$ have $m$ columns, we will end up with three sets of $m$ polynomials:

$$
\begin{array}{}
u_1(x),...,u_m(x) & m \text{ polynomials interpolated on the }m \text{ columns of } \mathbf{L}\\
v_1(x),...,v_m(x)& m \text{ polynomials interpolated on the }m \text{ columns of } \mathbf{R}\\
w_1(x),...,w_m(x)& m \text{ polynomials interpolated on the }m \text{ columns of } \mathbf{O}\\
\end{array}
$$

From this, we can construct a Quadratic Arithmetic Program (QAP):

$$
\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)
$$
where
$$
t(x) = (x - 1)(x - 2)\dots(x - n)
$$
and
$$
h(x) = \frac{\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) - \sum_{i=1}^m a_iw_i(x)}{t(x)}
$$

If a third party creates a structured reference string (srs) via a powers of tau ceremony, then the prover can evaluate sum terms (the $\sum a_if_i(x)$ terms) in the QAP at a hidden point $\tau$. Let the structured reference strings be computed as follows:

$$
\begin{align*}
[\Omega_{n-1}, \Omega_{n-2},\dots,\Omega_2,\Omega_1,G_1] &= [\tau^nG_1,\tau^{n-1}G_1,\dots,\tau G_1,G_1] && \text{srs for } G_1 \\
[\Theta_{n-1}, \Theta_{n-2},\dots,\Theta_2,\Theta_2,G_2] &= [\tau^nG_2,\tau^{n-1}G_2,\dots,\tau G_2,G_2] && \text{srs for } G_2\\
[\Upsilon_{n-2},\Upsilon_{n-3},\dots,\Upsilon_1,\Upsilon_0]&=[\tau^{n-2}t(\tau)G_1,\tau^{n-3}t(\tau)G_1,\dots,\tau t(\tau)G_1,t(\tau)G_1] && \text{srs for }h(\tau)t(\tau)\\
\end{align*}
$$

We refer to $f(\tau)$ as a polynomial evaluated on a structured reference string $[\tau^dG_1,...,\tau^2G_1,\tau G_1,G_1]$ via the inner product:

$$
f(\tau) = \sum_{i=1}^d f_i\Omega_i=\langle[f_d, f_{d-1},...,f_1,f_0],[\Omega_d,\Omega_{d-1},...,G_1]\rangle
$$

or for $\mathbb{G}_2$ srs:

$$
f(\tau) = \sum_{i=1}^d f_i\Theta_i=\langle[f_d, f_{d-1},...,f_1,f_0],[\Theta_d,\Theta_{d-1},...,G_1]\rangle
$$

$f(\tau)$ is shorthand for the above expression, and produces an elliptic curve point. It does not mean the prover knows $\tau$.

The prover can evaluate their QAP on the trusted setup by computing:

$$
\begin{align*}
[A]_1 &= \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= \sum_{i=1}^m a_iv_i(\tau)\\
[C]_1 &= \sum_{i=1}^m a_iw_i(\tau) + h(\tau)t(\tau)
\end{align*}
$$

The details of this computation are discussed in our tutorial [Quadratic Arithmetic Programs over Elliptic Curves](https://www.rareskills.io/post/elliptic-curve-qap).

If the QAP is balanced, then the following equation holds:

$$
[A]_1\bullet[B]_2 \stackrel{?}= [C]_1\bullet G_2
$$

## Motivation
Simply presenting $([A]_1, [B]_2, [C]_1)$ is not a convincing argument that the prover knows $\mathbf{a}$ such that the QAP is balanced.

The prover can simply invent values $a$, $b$, $c$ where $ab = c$, compute

$$
\begin{align*}
[A]_1 &= aG_1\\
[B]_2 &= bG_2\\
[C]_1 &= cG_1
\end{align*}
$$

and present those as elliptic curve points $[A]_1$, $[B]_2$, $[C]_1$ to the verifier.


Thus, the verifier has no idea if $([A]_1, [B]_2, [C]_1)$ were the result of a satisfied QAP or not.

We need to force the prover to be honest without introducing too much computational overhead. The first algorithm to accomplish this was "[Pinocchio: Nearly Practical Verifiable Computation](https://eprint.iacr.org/2013/279.pdf)." This was usable enough for ZCash to base the first version of their blockchain on it.

However, Groth16 was able to accomplish the same thing in much fewer steps, and the algorithm is still widely in use today, as no algorithm since has produced as efficient an algorithm for the verification step (though other algorithms have eliminated the trusted setup or significantly reduced the amount of work for the prover).

**Update for 2024:** A paper rather triumphantly titled "[Polymath: Groth16 is not the limit](https://eprint.iacr.org/2024/916)" published in Cryptology demonstrates an algorithm that requires fewer verifier steps than Groth16. However, there are no known implementations of the algorithm at this time of writing.

## Preventing forgery Part 1: Introducing $\alpha$ and $\beta$

### An "unsolveable" verification formula
Suppose we update our verification formula to the following:

$$[A]_1 \bullet [B]_2 \stackrel{?}= [D]_{12} + [C]_1\bullet G_2$$

*Note that we are using additive notation for the $G_{12}$ group for convenience.*

Here, $[D]_{12}$ is an element from $G_{12}$ and has an unknown discrete logarithm.

We now show that it is impossible for a verifier to provide a solution $([A]_1, [B]_2, [C]_1)$ to this equation, without knowing the discrete logarithm of $[D]_{12}$.

#### Attack 1: Forging A and B and deriving C
Suppose the prover randomly selects $a’$ and $b’$ to produce $[A]₁$ and $[B]₂$ and tries to derive a value $[C’]$ that is compatible with the verifier’s formula.

$$[A]_1 \bullet [B]_2 \stackrel{?}= [D]_{12} + [C]_1\bullet G_2$$

Knowing the discrete logarithms of $[A]₁$ and $[B]₂$, the malicious prover tries to solve for $[C’]$ by doing

$$\begin{align*}\underbrace{[A]_1\bullet [B]_2 - [D]_{12}}_{\chi_{12}}=[C']_1\bullet G_2\\
[\chi]_{12}=[C']_1\bullet G_2
\end{align*}$$

The final line is requires the prover to solve for the discrete log of $\chi_{12}$, so they cannot compute a valid discrete log for $[C']_1$.

#### Attack 2: Forging C and deriving A and B
Here the prover picks a random point $c'$ and computes $[C']_1$. Because they know $c'$, they can try to discover a compatible combination of $a'$ and $b'$ such that


$$\begin{align*}[A]_1 \bullet [B]_2 &\stackrel{?}= \underbrace{[D]_{12} + [C]_1\bullet G_2}_{[\zeta]_{12}}\\
[A]_1 \bullet [B]_2 &\stackrel{?}=[\zeta]_{12}
\end{align*}$$

This requires the prover, given $[\zeta]_{12}$, to come up with an $[A]₁$ and $[B]₂$ that pair to produce $[\zeta]_{12}$.

Similar to the discrete log problem, we rely on unproven cryptographic assumptions that this computation (decomposing an element in $\mathbb{G}_{12}$ into a $\mathbb{G}_1$ and $\mathbb{G}_2$ element) is infeasible. In this case, the assumption that we cannot decompose $[\zeta]_{12}$ into $[A]₁$ and $[B]₂$ is called the *Bilinear Diffie-Hellman Assumption*. The interested reader can see a related discussion on the [Decisional Diffie-Hellman Assumption](https://en.wikipedia.org/wiki/Decisional_Diffie–Hellman_assumption).

(Unproven does not mean unreliable. If you can find a way to prove or disprove this assumption, fame and fortune awaits you! In practice, there is no known way to decompose $[\zeta]_{12}$ into $[A]₁$ and $[B]₂$ and it is believed to be computationally infeasible.)

### How $\alpha$ and $\beta$ are used
In practice, Groth16 doesn't use a term $[D]_{12}$. Instead, the trusted setup generates two random scalars $\alpha$ and $\beta$ and publishes the elliptic curve points $([\alpha]_1,[\beta]_2)$ computed as:

$$
\begin{align*}
[α]_1 &= α G_1 \\
[β]_2 &= β G_2
\end{align*}
$$

What we referred to as $[D]_{12}$ is simply $[\alpha]_1 \bullet [\beta]_2$.

### Re-deriving the proving and verification formulas
To make the verification formula $[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1\bullet[\beta]_2 + [C]_1\bullet G_2$ "solvable", we need to alter our QAP formula to incorporate $\alpha$ and $\beta$.

$$\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x) = \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

Now consider what happens if we introduce terms $\theta$ and $\eta$ to the left hand side of the equation:

$$(\boxed{\theta}+\sum_{i=1}^m a_iu_i(x))(\boxed{\eta} +\sum_{i=1}^m a_iv_i(x)) =$$
$$=\boxed{\theta\eta} + \boxed{\theta}\sum_{i=1}^m a_iv_i(x) + \boxed{\eta}\sum_{i=1}^m a_iu_i(x) + \sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)$$

We can substitute the rightmost terms using the original QAP definition:
$$=\theta\eta + \theta\sum_{i=1}^m a_iv_i(x) + \eta\sum_{i=1}^m a_iu_i(x) + \boxed{\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)}$$

$$=\theta\eta + \theta\sum_{i=1}^m a_iv_i(x) + \eta\sum_{i=1}^m a_iu_i(x) + \boxed{\sum_{i=1}^m a_iw_i(x) + h(x)t(x)}$$

Now we can introduce an "expanded" QAP with the following definition:

$$(\theta+\sum_{i=1}^m u_i(x))(\eta +\sum_{i=1}^m v_i(x)) =\theta\eta + \theta\sum_{i=1}^m a_iv_i(x) + \eta\sum_{i=1}^m a_iu_i(x) + \sum_{i=1}^m a_iw_i(x) + h(x)t(x)$$

As a sneak peak to where we are going, if we replace $\theta$ with $[\alpha]_1$ and $\eta$ with $[\beta]_2$, we get updated verification formula from earlier:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [C]_1\bullet G_2$$

where

$$\underbrace{([\alpha]_1+\sum_{i=1}^m a_iu_i(\tau))}_{[A]_1}\underbrace{([\beta]_2 +\sum_{i=1}^m a_iv_i(\tau))}_{[B]_2} =[\alpha]_1\bullet[\beta]_2 + (\underbrace{\alpha\sum_{i=1}^m a_iv_i(\tau) + \beta\sum_{i=1}^m a_iu_i(\tau) + \sum_{i=1}^m a_iw_i(\tau) + h(\tau)t(\tau)}_{[C]_1}) \bullet G_2$$

The prover can compute $[A]_1$ and $[B]_2$ without knowing $\tau$, $\alpha$, or $\beta$. Given the structured reference string (powers of $\tau$) and the elliptic curve points $([α]_1,[β]_2)$, the prover computes $[A]_1$ and $[B]_2$ as

$$
\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)\\
\end{align*}
$$

Here, $a_iu_i(\tau)$ does not mean the prover knows $\tau$. The prover is using the structure reference string $[\tau^{n-1}G_1,\tau^{n-2}G_1,\dots,\tau G_1,G_1]$ to compute $u_i(\tau)$ for $i=1,2,\dots,m$ and the $G_2$ srs for for $[B]_2$.

However, it isn't currently possible to compute $[C]_1$ without knowing $\alpha$ and $\beta$. The prover cannot pair $[\alpha]_1$ with $\sum a_iu_i(\tau)$ and $[\beta]_2$ with $\sum a_iv_i(\tau)$ because that would create a $\mathbb{G}_{12}$ point, whereas the prover needs a $\mathbb{G}_1$ point for $[C]_1$.

Instead, the trusted setup needs to precompute $m$ polynomials for the problematic $C$ term of the expanded QAP.

$$\alpha\sum_{i=1}^m a_iv_i(\tau) + \beta\sum_{i=1}^m a_iu_i(\tau) + \sum_{i=1}^m a_iw_i(\tau)$$

With some algebraic manipulation, we combine the sum terms into a single sum:

$$=\sum_{i=1}^m (\alpha a_iv_i(\tau)+\beta a_iu_i(\tau) + a_iw_i(\tau))$$

and factor out $a_i$:

$$=\sum_{i=1}^m a_i\boxed{(\alpha v_i(\tau)+\beta u_i(\tau) + w_i(\tau))}$$

The trusted setup can create $m$ polynomials evaluated at $\tau$ from the boxed term above, and the prover can use that to compute the sum. The exact details are shown in the next section.

### Summary of the algorithm so far
#### Trusted setup steps
Concretely, the trusted setup computes the following:
$$\begin{align*}
\alpha,\beta,\tau &\leftarrow \text{random scalars}\\
[\tau^{n-1}G_1,\tau^{n-2}G_1,\dots,\tau G_1,G_1] &\leftarrow \text{srs for } \mathbb{G}_1\\
[\tau^{n-1}G_2,\tau^{n-2}G_2,\dots,\tau G_2,G_2] &\leftarrow \text{srs for } \mathbb{G}_2\\
[\tau^{n-2}t(\tau),\tau^{n-3}t(\tau),\dots,\tau t(\tau),t(\tau)] &\leftarrow \text{srs for }h(\tau)t(\tau)\\
[\Psi_1]_1 &= (\alpha v_1(\tau) + \beta u_1(\tau) + w_1(\tau))G_1\\
[\Psi_2]_1 &= (\alpha v_2(\tau) + \beta u_2(\tau) + w_2(\tau))G_1\\
&\vdots\\
[\Psi_m]_1 &= (\alpha v_m(\tau) + \beta u_m(\tau) + w_m(\tau))G_1\\
\end{align*}$$

The trusted setup publishes

$$([\alpha]_1,[\beta]_2,\text{srs}_{G_1},\text{srs}_{G_2}[\Psi_1]_1,[\Psi_2]_1,\dots,[\Psi_m]_1)$$

#### Prover steps
The prover computes

$$\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)\\
[C]_1 &= \sum_{i=1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau)\\    
\end{align*}$$

Note that we replaced the "problematic" polynomial

$$=\sum_{i=1}^m a_i\boxed{(\alpha v_i(\tau)+\beta u_i(\tau) + w_i(\tau))}$$

(the one that contained $\alpha$ and $\beta$) with 

$$\sum_{i=1}^m a_i[\Psi_i]_1$$

#### Verifier steps

The verifier computes:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [C]_1\bullet G_2$$

## Supporting public inputs

The verifier formula so far does not support public inputs, i.e. making a portion of the witness public.

By convention, public portions of the witness are the first $\ell$ elements of the vector $\mathbf{a}$. To make those elements public, the prover simply reveals them:

$$[a_1, a_2, \dots, a_\ell]$$

For the verifier to test that those values were in fact used, verifier must carry out some of the computation that the prover was originally doing.

Specifically, the prover computes:

$$\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)\\
[C]_1 &= \sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau)\\    
\end{align*}$$

Note that only the computation of $[C]_1$ changed -- the prover only uses the $a_i$ and $\Psi_i$ terms $\ell + 1$ to $m$.

The verifier computes the first $\ell$ terms of the sum:
$$[X]_1=\sum_{i=1}^\ell a_i\Psi_i$$

And the verification equation is:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet G_2 + [C]_1\bullet G_2$$

## Part 2: Separating the public inputs from the private inputs with $\gamma$ and $\delta$
### Forging proofs by misuing $\Psi_i$ for $i\leq\ell$

The assumption in the equation above is that the prover is only using $\Psi_{\ell+1}$ to $\Psi_m$ to compute $[C]_1$, but nothing stops a dishonest prover from using $\Psi_1$ to $\Psi_{\ell}$ to compute $[C]_1$, leading to a forged proof.

For example, here is our current verification equation:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + \sum_{i=1}^\ell a_i\Psi_i +  [C]_1\bullet G_2$$

If we expand the C term under the hood, we get the following:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + \sum_{i=1}^\ell a_i\Psi_i + \underbrace{(\sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau))}_C \bullet G_2$$

Suppose for example and without loss of generality that $\mathbf{a} = [1,2,3,4,5]$ and $\ell=3$. In that case, the public part of the witness is $[1,2,3]$ and the private part is $[4,5]$.

The final equation would be as follows:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + (1\Psi_1+2\Psi_2+3\Psi_3)\bullet G2 + \underbrace{(4\Psi_4 + 5\Psi_5  + h(\tau)t(\tau))}_C \bullet G_2$$

However, nothing stops the prover from creating an valid portion of the public witness as [1,2,0] and moving the zeroed out public portion to the private part of the computation as follows:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + (1\Psi_1+2\Psi_2+\boxed{0\Psi_3})\bullet G2 + \underbrace{(\boxed{3\Psi_3}+4\Psi_4 + 5\Psi_5  + h(\tau)t(\tau))}_C \bullet G_2$$

The equation above is valid, but the witness does not necessarily satisfy the original constraints.

Therefore, we need to prevent the prover from using $\Psi_1$ to $\Psi_{\ell}$ as part of the computation of $[C]_1$.

### Introducing $\gamma$ and $\delta$
To avoid the problem above, the trusted setup introduces new scalars $\gamma$ and $\delta$ to force $\Psi_{\ell+1}$ to $\Psi_m$ to be separate from $\Psi_1$ to $\Psi_{\ell}$. To do this, the trusted setup divides (multiplies by the modular inverse) the private terms (that constitute $[C]_1$) by $\delta$ and the public terms (that constitute $[X]_1$, the sum the verifier computes) by $\gamma$.

Since the $h(\tau)t(\tau)$ term is embedded in $[C]_1$, those terms also need to be divided by $\delta$.

$$\begin{align*}
\alpha,\beta,\tau,\gamma,\delta &\leftarrow \text{random scalars}\\
[\tau^{n-1}G_1,\tau^{n-2}G_1,\dots,\tau G_1,G_1] &\leftarrow \text{srs for } \mathbb{G}_1\\
[\tau^{n-1}G_2,\tau^{n-2}G_2,\dots,\tau G_2,G_2] &\leftarrow \text{srs for } \mathbb{G}_2\\
[\frac{\tau^{n-2}t(\tau)}{\delta},\frac{\tau^{n-3}t(\tau)}{\delta},\dots,\frac{\tau t(\tau)}{\delta},
\frac{t(\tau)}{\delta}] &\leftarrow \text{srs for }h(\tau)t(\tau)\\
\\
&\text{public portion of the witness}\\
[\Psi_1]_1 &= \frac{\alpha v_1(\tau) + \beta u_1(\tau) + w_1(\tau)}{\gamma}G_1\\
[\Psi_2]_1 &= \frac{\alpha v_2(\tau) + \beta u_2(\tau) + w_2(\tau)}{\gamma}G_1\\
&\vdots\\
[\Psi_\ell]_1 &= \frac{\alpha v_m(\tau) + \beta u_m(\tau) + w_m(\tau)}{\gamma}G_1\\
\\
&\text{private portion of the witness}\\
[\Psi_{\ell+1}]_1 &= \frac{\alpha v_{\ell+1}(\tau) + \beta u_{\ell+1}(\tau) + w_{\ell+1}(\tau)}{\delta}G_1\\
[\Psi_{\ell+2}]_1 &= \frac{\alpha v_{\ell+2}(\tau) + \beta u_{\ell+2}(\tau) + w_{\ell+2}(\tau)}{\delta}G_1\\
&\vdots\\
[\Psi_{m}]_1 &= \frac{\alpha v_{m}(\tau) + \beta u_{m}(\tau) + w_{m}(\tau)}{\delta}G_1\\
\end{align*}$$

The trusted setup publishes
$$([\alpha]_1,[\beta]_2,[\gamma]_2,[\delta]_2,\text{srs}_{G_1},\text{srs}_{G_2},[\Psi_1]_1,[\Psi_2]_1,\dots,[\Psi_m]_1)$$

The prover steps are the same as before:

$$\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)\\
[C]_1 &= \sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau)\\    
\end{align*}$$

And the verifier steps now include pairing by $[\gamma]_2$ and $[\delta]_2$ to cancel out the denominators:

$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet [\gamma]_2 + [C]_1\bullet [\delta]_2$$

## Part 3: Enforcing true zero knowledge: r and s
Our scheme is not yet truly zero knowledge. If an attacker is able to guess our witness vector (which is possible if there is only a small range of valid inputs, e.g. secret voting from privileged addresses), then they can verify their guess is correct by comparing their constructed proof to the original proof.

As a trivial example, suppose our claim is $x_1$ and $x_2$ are both either $0$ or $1$. The corresponding arithmetic circuit would be

$$
\begin{align*}
x_1 (x_1 - 1) = 0\\
x_2 (x_2 - 1) = 0
\end{align*}
$$

An attacker only needs to guess four combinations to figure out what the witness is. That is, they guess a witness, generate a proof, and see if their answer matches the original proof.

To prevent guessing, the prover needs to "salt" their proof, and the verification equation needs to be modified to accommodate the salt.

The prover samples two random field elements $r$ and $s$ and adds them to $A$ and $B$ to make the witness unguessable -- an attacker would have to guess both the witness and the salts $r$ and $s$:

$$
\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau) + r[\delta]_1\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau) + s[\delta]_2\\
[B]_1 &= [\beta]_1 + \sum_{i=1}^m a_iv_i(\tau) + s[\delta]_1\\
[C]_1 &= \sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau) + As+Br-rs[\delta]_1\\
\end{align*}
$$

To derive the final verification formula, let's temporarily ignore that we don't know the discrete logs of the Greek letter terms and compute the left-hand-side of the verification equation $AB$:

$$\underbrace{(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)}_A \underbrace{(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)}_B$$

Expanding the terms we get:

$$
\alpha\beta+\alpha\sum_{i=1}^m a_iv_i(x)+\alpha s\delta + \beta\sum_{i=1}^m a_iu_i(x) + \sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)+\sum_{i=1}^m a_iu_i(x) s\delta + r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + r\delta s\delta
$$

We can select out the original terms for $C$

$$
\alpha\beta+\boxed{\alpha\sum_{i=1}^m a_iv_i(x)}+\alpha s\delta + \boxed{\beta\sum_{i=1}^m a_iu_i(x)} + \boxed{\sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)}+\sum_{i=1}^m a_iu_i(x) s\delta + r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + r\delta s\delta
$$

And combine them on the left, leaving the new terms on the right:

$$
\alpha\beta + \boxed{\alpha\sum_{i=1}^m a_iv_i(x) + \beta\sum_{i=1}^m a_iu_i(x) + \sum_{i=1}^m a_iu_i(x)\sum_{i=1}^m a_iv_i(x)}+ \underline{\alpha s\delta + \sum_{i=1}^m a_iu_i(x) s\delta + r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + r\delta s\delta}
$$

We further rearrange the underlined terms to write them in terms of $As\delta$ and $Br\delta$ as follows. We also split $r\delta s\delta$ into $rs\delta^2 + rs\delta^2 - rs\delta^2$:

$$
=\alpha s\delta + \sum_{i=1}^m a_iu_i(x) s\delta + rs\delta^2 + r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + rs\delta^2 - rs\delta^2
$$

Group the $s$ and $r$ terms together:
$$
=(\alpha s\delta + \sum_{i=1}^m a_iu_i(x) s\delta + rs\delta^2) + (r\delta\beta + r\delta\sum_{i=1}^m a_iv_i(x) + rs\delta^2) - rs\delta^2
$$

Factor out $s\delta$ and $r\delta$:
$$
=\underbrace{(\alpha+ \sum_{i=1}^m a_iu_i(x) + r\delta)s\delta}_{As\delta} + \underbrace{(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)r\delta}_{Br\delta} - rs\delta^2
$$

Substitute $A$ and $B$:
$$
=As\delta + Bs\delta - rs\delta
$$

So our final equation is

$$(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)=\alpha\beta+\sum_{i=1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x) + As\delta + Bs\delta - rs\delta$$

We now break it into the public and private portions:

$$(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)=\alpha\beta+\underbrace{\sum_{i=1}^\ell a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x))}_\text{public} + \underbrace{\sum_{i=\ell+1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x) + As\delta + Bs\delta - rs\delta}_\text{private}$$

We want the public portion and the private portion to be separated by $\gamma$ and $\delta$ respectively:

$$(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)=\alpha\beta+\gamma\frac{\sum_{i=1}^\ell a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x))}{\gamma} + \delta\frac{\sum_{i=\ell+1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x) + As\delta + Bs\delta - rs\delta}{\delta}$$

$\delta$ cancels for some of the terms:

$$(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)=\alpha\beta+\gamma\frac{\sum_{i=1}^\ell a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x))}{\gamma} + \delta\frac{\sum_{i=\ell+1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x)}{\delta} + As + Bs - rs\delta$$

We now separate this equation in to the verifier and prover portions. The boxed terms are the verifier portion, the underbrace terms are the terms that the prover provides:

$$\underbrace{(\alpha + \sum_{i=1}^m a_iu_i(x) + r\delta)}_{[A]_1}\underbrace{(\beta + \sum_{i=1}^m a_iv_i(x) + s\delta)}_{[B]_2}=\boxed{\alpha\beta}+\boxed{\gamma}\boxed{\frac{\sum_{i=1}^\ell a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x))}{\gamma}} + \boxed{\delta}\underbrace{\frac{\sum_{i=\ell+1}^m a_i(\alpha v_i(x) + \beta u_i(x)+w_i(x)) + h(x)t(x)}{\delta} + As + Bs - rs\delta}_{[C]_1}$$

## Groth16 Proof Algorithm
We are now ready to show the Groth16 algorithm end-to-end.

### Trusted Setup

$$\begin{align*}
\alpha,\beta,\tau,\gamma,\delta &\leftarrow \text{random scalars}\\
[\tau^{n-1}G_1,\tau^{n-2}G_1,\dots,\tau G_1,G_1] &\leftarrow \text{srs for } \mathbb{G}_1\\
[\tau^{n-1}G_2,\tau^{n-2}G_2,\dots,\tau G_2,G_2] &\leftarrow \text{srs for } \mathbb{G}_2\\
[\frac{\tau^{n-2}t(\tau)}{\delta},\frac{\tau^{n-3}t(\tau)}{\delta},\dots,\frac{\tau t(\tau)}{\delta},
\frac{t(\tau)}{\delta}] &\leftarrow \text{srs for }h(\tau)t(\tau)\\
\\
&\text{public portion of the witness}\\
[\Psi_1]_1 &= \frac{\alpha v_1(\tau) + \beta u_1(\tau) + w_1(\tau)}{\gamma}G_1\\
[\Psi_2]_1 &= \frac{\alpha v_2(\tau) + \beta u_2(\tau) + w_2(\tau)}{\gamma}G_1\\
&\vdots\\
[\Psi_\ell]_1 &= \frac{\alpha v_m(\tau) + \beta u_m(\tau) + w_m(\tau)}{\gamma}G_1\\
\\
&\text{private portion of the witness}\\
[\Psi_{\ell+1}]_1 &= \frac{\alpha v_{\ell+1}(\tau) + \beta u_{\ell+1}(\tau) + w_{\ell+1}(\tau)}{\delta}G_1\\
[\Psi_{\ell+2}]_1 &= \frac{\alpha v_{\ell+2}(\tau) + \beta u_{\ell+2}(\tau) + w_{\ell+2}(\tau)}{\delta}G_1\\
&\vdots\\
[\Psi_{m}]_1 &= \frac{\alpha v_{m}(\tau) + \beta u_{m}(\tau) + w_{m}(\tau)}{\delta}G_1\\
\end{align*}$$

The trusted setup publishes
$$([\alpha]_1,[\beta]_1[\beta]_2,[\gamma]_2,[\delta]_1[\delta]_2,\text{srs}_{G_1},\text{srs}_{G_2},[\Psi_1]_1,[\Psi_2]_1,\dots,[\Psi_m]_1)$$

### Prover Steps
Prover has a witness $\mathbf{a}$ and generates random scalars $r$ and $s$.
$$\begin{align*}
[A]_1 &= [\alpha]_1 + \sum_{i=1}^m a_iu_i(\tau)+r[\delta]_1\\
[B]_1 &= [\beta]_1 + \sum_{i=1}^m a_iv_i(\tau)+s[\delta]_1\\
[B]_2 &= [\beta]_2 + \sum_{i=1}^m a_iv_i(\tau)+s[\delta]_2\\
[C]_1 &= \sum_{i=\ell+1}^m a_i[\Psi_i]_1 + h(\tau)t(\tau)+[A]_1s+[B]_2r-rs[\delta]_1\\
\end{align*}$$

The prover publishes $([A]_1, [B]_2, [C]_1, [a_1,...,a_\ell])$.

### Verifier Steps
The verifier checks

$$
\begin{align*}
[X]_1&=\sum_{i=1}^\ell a_i\Psi_i\\
[A]_1\bullet[B]_2 &\stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet [\gamma]_2 + [C]_1\bullet [\delta]_2
\end{align*}
$$

## Verifying Groth16 in Solidity
At this point, you have sufficient knowledge to understand the proof verification code in Solidity. Here is [Tornado Cash’s proof verification code](https://github.com/tornadocash/tornado-core/blob/master/contracts/Verifier.sol#L192). The reader is encouraged to read the source code closely. If the reader is comfortable with Solidity assembly programming, then understanding this source code will not be difficult as the variable names are consistent with the ones in this article.


There is also library support for [Groth16 on Solana](https://lib.rs/crates/groth16-solana).

## Security Issues to Be Aware Of
### Groth16 is Malleable
Groth16 proofs are malleable. Given a valid proof

$([A]_1, [B]_2, [C]_1)$, an attacker can compute the point negation of $[A]_1$ and $[B]_2$ and present a new proof as $([A']_1, [B']_2, [C]_1)$ where $[A']_1 = \mathsf{neg}([A]_1)$ and $[B']_2 = \mathsf{neg}([B]_2)$.

To see that $[A]_1\bullet[B]_2 = [A']_1\bullet[B']_2$, consider the following code:
```python
from py_ecc.bn128 import G1, G2, multiply, neg, eq, pairing

# chosen arbitrarily
x = 10
y = 100
A = multiply(G1, x)
B = multiply(G2, y)

A_p = neg(A)
B_p = neg(B)

assert eq(pairing(B, A), pairing(B_p, A_p))
```

Intuitively, the attacker is multiplying $A$ and $B$ by $-1$, and $(-1)\times(-1)$ cancels itself out in the pairing.

Hence, if the verification formula accepts
$$[A]_1\bullet[B]_2 \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet [\gamma]_2 + [C]_1\bullet [\delta]_2$$

then it will also accept

$$\mathsf{neg}([A]_1)\bullet\mathsf{neg}([B]_2) \stackrel{?}= [\alpha]_1 \bullet [\beta]_2 + [X]_1\bullet [\gamma]_2 + [C]_1\bullet [\delta]_2$$

The defense against this attack is described in the following section.

You can see a proof of concept of this attack in this [article](https://medium.com/@cryptofairy/exploring-vulnerabilities-the-zksnark-malleability-attack-on-the-groth16-protocol-8c80d13751c5).

### The prover can create an unlimited number of proofs for the same witness
This isn't a "security issue" per se -- it is necessary to achieve Zero Knowledge. However, the application needs a mechanism to track which facts have already been proven and cannot rely on the uniqueness of the proof to achieve that.

## Learn more with RareSkills
Our ability to publish material like this free of charge depends on the continued support of our students. Consider signing up for our [Zero Knowledge Bootcamp](https://www.rareskills.io/zk-bootcamp), [Web3 Bootcamps](https://www.rareskills.io/web3-blockchain-bootcamps), or getting a job on [RareTalent](https://www.raretalent.xyz).

*Originally Published August 31, 2023*
