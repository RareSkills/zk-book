# Bilinear Pairings in Python, Solidity, and the EVM

Sometimes also called bilinear mappings, bilinear parings allow us to take three numbers, $a$, $b$, and $c$, where $ab = c$, encrypt them to become $E(a)$, $E(b)$, $E(c)$, where $E$ is an encryption function, then send the two encrypted values to a verifier who can verify $E(a)E(b) = E(c)$ but not know the original values. We can use bilinear pairings to prove that a 3rd number is the product of the first two without knowing the first two original numbers.

We will explain bilinear pairings at a high level and provide some examples in Python.

## Prerequisites
- The reader should know what [point addition](https://www.rareskills.io/post/elliptic-curve-addition) and scalar multiplication are in the context of elliptic curves.
- The reader should also know the discrete logarithm problem in this context: a scalar multiplied by a point will result in another point, and it is infeasible in general to calculate the scalar given the elliptic curve point.
- The reader should know what a [finite field](rareskills.io/post/finite-fields) and cyclic group are, and what a generator is in the context of elliptic curves. We will refer to generators with the variable G.
- The reader should know about [Ethereum Precompiles](https://www.rareskills.io/post/solidity-precompiles).
We will use capital letters to denote EC (elliptic curve) points and lower case letters to denote elements of finite fields ("scalars"). When we say element, this could be an integer in a finite field or it could be a point on an elliptic curve. The context will make it clear.

It is possible to read this tutorial without fully understanding all of the above, but it will be harder to build a good intuition about this subject.

## How the numbers are encrypted
When a scalar is multiplied by a point on an elliptic curve, another elliptic curve point is produced. That is $P = pG$ where $p$ is a scalar, and $G$ is the generator. Given $P$ and $G$ we cannot determine $p$.

Assume $pq = r$. What we are trying to do is take

$$
\begin{align*}
P = pG\\
Q = qG\\
R = rG\\
\end{align*}
$$

and convince a verifier that the discrete logs of $P$ and $Q$ multiply to produce the discrete log of $R$.

If $pq = r$, and $P = pG$, $Q = qG$, and $R = rG$, then we want a function such that

$$f(P,Q)=R$$

and not equal to $R$ when $pq ≠ r$. This should be true of all possible combinations of $p$, $q$, and $r$ in the group.

*Originally Published July 18, 2023*