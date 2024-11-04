# Bulletproofs ZKP: Zero Knowledge and Succinct Proofs for Inner Products

Bulletproofs ZKPs allow a prover to prove knowledge of an inner product with a logarithmic-sized proof. Bulletproofs do not require a trusted setup.

In the previous chapters, we showed how to prove knowledge of an inner product without revealing the vectors or the inner product, albeit with a proof of size $\mathcal{O}(n)$ where $n$ is the length of the vector. We also showed how to prove knowledge of an inner product using logarithmic-sized data, but without the zero knowledge property.

In this chapter, we combine the algorithms together to demonstrate the Bulletproof ZK algorithm.

(This work if part of a series on [ZK Bulletproofs](https://www.rareskills.io/post/bulletproofs-zk).)

## Problem Statement
The prover and verifier agree on two elliptic curve basis vectors $\mathbf{G}$ and $\mathbf{H}$ of length $n$ and elliptic curve points $Q$ and $B$. The discrete log relationships between all these points are unknown.

The prover has vectors $\mathbf{a}$ and $\mathbf{b}$ with inner product $v$. The prover commits $\mathbf{a}$ and $\mathbf{b}$ to $A$ as $A =\langle\mathbf{a},\mathbf{G}\rangle + \langle\mathbf{b},\mathbf{H}\rangle + \alpha B$ where $\alpha$ is a blinding term. The prover commits $V = \langle\mathbf{a},\mathbf{b}\rangle Q + \gamma B$.

The prover sends $(A, V)$ to to the verifier and aims to prove that $\mathbf{a}$ and $\mathbf{b}$ are committed to $A$ and their inner product is committed to $V$. The verifier does not learn the vectors or the inner product.

The size of the proof must be $\mathcal{O}(\log n)$.

## The Bulletproof ZK Algorithm

The prover generates random scalars $\set{\alpha, \beta,\gamma,\tau_1,\tau_2}$ and random vectors $\set{\mathbf{s}_L,\mathbf{s}_R}$ and computes the commitments

$$
\begin{align}
A &= \langle\mathbf{a},\mathbf{G}\rangle + \langle\mathbf{b},\mathbf{H}\rangle+\alpha B\\
S &= \langle\mathbf{s}_L,\mathbf{G}\rangle + \langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B\\
V &= vQ + \gamma B \\
\end{align}$$

The prover prepares (but does not send) vector polynomials

$$
\begin{align*}
\mathbf{l}(x) &= \mathbf{a} + \mathbf{s}_Lx\\
\mathbf{r}(x) &= \mathbf{b} + \mathbf{s}_Rx\\
t(x)&=\langle\mathbf{l}(x),\mathbf{r}(x)\rangle = \langle\mathbf{a},\mathbf{b}\rangle+(\langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle) x+(\langle\mathbf{s}_L,\mathbf{s}_R\rangle)x^2
\end{align*}
$$

$A$ is a commitment to the constant terms of the vector polynomial, $S$ is a commitment to the linear terms, and $V$ is a commitment to the inner product.

The prover creates commitments to the coefficients of $t(x)$ as

$$
\begin{align*}
T_1 &= (\langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle)Q + \tau_1B\\
T_2 &= \langle\mathbf{s}_L,\mathbf{s}_R\rangle Q + \tau_2B
\end{align*}
$$

Note that $V$ is a commitment to the constant coefficient of $t(x)$, and $T_1$ and $T_2$ are commitments to the linear and quadratic coefficients of $t(x)$, respectively.

The prover sends $(A, S, V, T_1, T_2)$ to the verifier.

The verifier responds with random value $u$.

The prover then evaluates the polynomials at $u$ and creates proofs that they were evaluated correctly:

$$
\begin{align*}
\mathbf{l}_u &= \mathbf{l}(u) = \mathbf{a} + \mathbf{s}_Lu \\
\mathbf{r}_u &= \mathbf{r}(u) = \mathbf{b} + \mathbf{s}_Ru \\
t_u &= t(u) =v + (\langle\mathbf{a},\mathbf{s}_R\rangle + \langle\mathbf{b},\mathbf{s}_L\rangle)u + \langle\mathbf{s}_L,\mathbf{s}_R\rangle u^2\\
\pi_{lr} &=\alpha+\beta u\\
\pi_t &= \gamma + \tau_1u + \tau_2u^2\\
\end{align*}
$$

Previously, the prover transmits $(\mathbf{l}_u, \mathbf{r}_u, t_u, \pi_{lr}, \pi_t)$ so the verifier could check that 

$$
\begin{align*}
t_u&\stackrel{?}=\langle\mathbf{l}_u,\mathbf{r}_u\rangle\\
A + Su &\stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H} \rangle + \pi_{lr} B\\
t_u Q &\stackrel{?}{=} V + T_1 u + T_2 u^2 - \pi_t B\\
\end{align*}
$$

but this would be linear in size due to the vectors $\mathbf{l}_u$ and $\mathbf{r}_u$. Instead, the prover commits $\mathbf{l}_u$ and $\mathbf{r}_u$ as

$$C=\langle\mathbf{l}_u,\mathbf{G}\rangle+\langle\mathbf{r}_u,\mathbf{H}\rangle$$

and sends $(C, t_u, \pi_{lr}, \pi_t)$.

We can re-arrange the first two verifier checks as follows:

$$
\begin{align*}
t_u&\stackrel{?}=\langle\mathbf{l}_u,\mathbf{r}_u\rangle\\
A + Su -\pi_{lr}B&\stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H} \rangle\\
\end{align*}
$$

Observe that if we set $P = A + Su -\pi_{lr}B$, then this is the same problem statement as proving $P$ holds commitments to two vectors $\mathbf{l}_u$ and $\mathbf{r}_u$ with respect to the basis vectors $\mathbf{G}$ and $\mathbf{H}$, and that $\mathbf{l}_u$ and $\mathbf{r}_u$ have an inner product of $t_u$. Therefore, we can reuse the logarithmic-size proof of knowledge of a commitment opening to $P$.

For this proof, we do not need secrecy because $\mathbf{l}_u$ and $\mathbf{r}_u$ were made public anyway in the previous algorithm.

Now that the verifier has all the necessary data, the prover engages in an interactive proof to prove that $C$ holds the commitments to $\mathbf{l}_u$ and $\mathbf{r}_u$ and that their inner product is $t_u$:

$$\texttt{prove_commitments_log}(C + t_uQ, \mathbf{G}, \mathbf{H}, Q, \mathbf{l}_u, \mathbf{r}_u)$$

That subroutine will prove that $t_u\stackrel{?}=\langle\mathbf{l}_u,\mathbf{r}_u\rangle$ and $C\stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H} \rangle$ without having to send $\mathbf{l}_u$ and $\mathbf{r}_u$. It also only sends logarithmic-sized data. Note that the recursive algorithm from the previous chapter uses a commitment $P = \langle \mathbf{a}, \mathbf{G} \rangle + \langle \mathbf{b}, \mathbf{H} \rangle + \langle\mathbf{a},\mathbf{b}\rangle Q$, so the verifier needs to add in the "$Q$ portion" themselves. Now the verifier can be assured that

$$
\begin{align*}
t_u&\stackrel{?}=\langle\mathbf{l}_u,\mathbf{r}_u\rangle\\
C&\stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H} \rangle\\
\end{align*}
$$

Finally, the verifier checks that

$$
\begin{align*}
C&\stackrel{?}=A + Su-\pi_{lr}B\\
t_u Q &\stackrel{?}{=} V + T_1 u + T_2 u^2 - \pi_t B
\end{align*}
$$

Recall that $A$ and $S$ are commitments to the constant and linear terms of the vector polynomials $\mathbf{l}(x)$ and $\mathbf{r}(x)$, respectively. The first check ensures that the vectors committed to $C$ are evaluations of those polynomials at $u$.

The second check is to ensure that $t(u)$ was evaluated correctly, given the commitments to the coefficients $V$, $T_1$, and $T_2$.

## Non-interactivity via the Fiat Shamir Transform
In practice, this algorithm is made non-interactive via the *Fiat Shamir Transform*. Instead of asking the verifier for randomness, the prover generates randomness by concatenating all the data it has transmitted so far and hashing that. The verifier then re-hashes the data to ensure the prover generated the randomness correctly.

It is critical that the hash include all previous data transmissions, otherwise the implementation will have a [frozen heart vulnerability](https://blog.trailofbits.com/2022/04/15/the-frozen-heart-vulnerability-in-bulletproofs/).

## Next steps
In practice, problems of practical interest consist of multiple inner products. For example, a Rank 1 Constraint System:

$$L\mathbf{a}\circ R\mathbf{a} = O\mathbf{a}$$

is really $3n$ inner products (e.g. multiplying $\mathbf{a}$ by the $n$ rows of $L$ and so on for $R$ and $O$) and a single Hadamard product. Therefore, it will be handy to know some mathematical tricks for combining multiple inner products into a single one so that we don't have to send $3n$ Bulletproofs. We will learn how to accomplish this in our upcoming chapter on random linear combinations.

Furthermore, some useful problems can be directly encoded as an inner product, notably the range proof or the subset sum problem. In those situations, we can skip encoding the problem as an [arithmetic circuit](https://www.rareskills.io/post/arithmetic-circuit) and directly encode it as an inner product. To increase the flexibility of our inner product representation, as well as to lay the ground work for understanding random linear combinations, we will learn some inner product algebra in the next chapter.

**Exercise:** Combine the previous exercises to prove that $A =\langle\mathbf{a},\mathbf{G}\rangle + \langle\mathbf{b},\mathbf{H}\rangle + \alpha B$ where $\mathbf{a}$ and $\mathbf{b}$ are vectors of length 4. Your proof should be both succinct and zero knowledge. Create an interactive proof for the sake of simplicity. Refer to [this repository](https://github.com/RareSkills/ZK-bulletproofs) for the exercises.
