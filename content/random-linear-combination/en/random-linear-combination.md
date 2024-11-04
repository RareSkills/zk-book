# Reducing the number of equality checks (constraints) through random linear combinations

Random linear combination are a common trick in zero knowledge proof algorithms to enable $m$ equality checks to be probabilistically checked with a single equality check. Suppose we have $m$ inner products we are trying to prove. Instead of creating $m$ proofs, we create a random linear combination of the equalities and prove that.

## Equality of Pedersen Commitments
First, let's consider how we might prove the equality of multiple Pedersen commitments.

If we have elliptic curve points $G$ and $B$ with unknown discrete logs, and blinding terms $\alpha$ and $\beta$ we can construct [Pedersen committments](https://www.rareskills.io/post/pedersen-commitment) $L$ and $R$ where

$L = aG + \alpha B$
$R = bG + \beta B$

The verifier can check if $a = b$ if the prover provides the difference in the blinding terms. The verifier cannot simply check $L = R$ because the blinding terms will generally not be equal to each other, i.e. $\alpha \neq \beta$.

If the prover wishes to convince the verifier that $a$ and $b$ are committed to $L$ and $R$ respectively, but without revealing $a$ and $b$, the prover can compute

$\pi = \alpha - \beta$

And give $\pi$ to the verifier. The verifier computes

$L \stackrel{?}{=} R + \pi B$

Under the hood, this expands to

$(aG + \alpha B) = (bG + \beta B) + (\alpha - \beta) B$

All the blinding terms will cancel out leaving $aG \stackrel{?}{=} bG$.

But suppose the prover wishes to establish equality for several commitments, i.e. $L_1 = L_2, L_2 = R_2, ..., L_m = R_m$. The naïve solution is to send $m$ blinding terms $\pi_1,...,\pi_m$ and the verifier will run $m$ equality checks. This will require sending $m$ field elements ($\pi_1,...,\pi_m$) and the verifier's algorithm will run in $\mathcal{O}(m)$ time.

## Why the prover cannot simply add up all the commitments
Suppose we have $l_1, l_2, r_1, r_2$ with commitments $L_1, L_2, R_1, R_2$ respectively. Suppose also the prover wants to show that $l_1 = r_1$ and $l_2 = r_2$ without revealing them.

The following check is not secure:

$$L_1 + L_2 = R_1 + R_2 + \pi B$$

where $\pi$ is the difference in the blinding terms. As a counterexample, consider the case where $l_1 = 1, r_1 = 2, l_2 = 2, r_2 = 1$. The *sums* are balanced, but the original claim is incorrect.

## Random linear combinations
However, if the prover is required to show that

$$L_1 + L_2z = R_1 + R_2z + \pi B$$

for a random value $z$ they cannot predict, then the scheme is secure.

Specifically, the prover and verifier do the following algorithm:

### Randomized proof of equality
#### Setup
The prover and verifier agree on elliptic curve points $G$ and $B$, where the discrete logs are unknown.

#### Prover sends commitments
The prover generates blinding terms $\alpha_1, \alpha_2, \beta_1, \beta_2$ and creates the Pedersen commitments

$L_1 = aG + \alpha_1 B$
$R_1 = aG + \beta_1 B$
$L_2 = bG + \alpha_2 B$
$R_2 = bG + \beta_2 B$

and sends $(L_1, L_2, R_1, R_2)$ to the verifier.

#### Verifier picks a random $z$
The verifier chooses a random field element $z$ and sends it to the prover.

#### Prover computes the difference in blinding terms
The prover computes $\pi = \alpha_1+\beta_1\cdot z-\alpha_2-\beta_2\cdot z$ and sends $\pi$ to the verifier.

#### Final verification check
The verifier checks that

$$L_1+L_2z\stackrel{?}=R_1+R_2z+\pi B$$

### Security analysis
If $l_1 = r_1$ and $l_2 = r_2$ then the equation will be balanced regardless of the choice of $z$, assuming the prover computed $\pi$ correctly.

Now suppose $l_1\neq r_1$ or $l_2 \neq r_2$. The prover still will not be able to produce a valid $\pi$ because doing so would require solving for the discrete logs of $G$ and $B$.

## Generalizing to $m$ checks

If we have $m$ equality checks, $L_1 = L_1, L_2 = R_2, ..., R_m = R_m$, the verifier could send $m$ random elements $z_1,\dots,z_m$ and the prover could provide $\pi$ such that

$L_1 + L_2z_1 + L_3z_2 + ... L_mz_{m-1} \stackrel{?}{=}R_1 + R_1z_1+R_2z_2+\dots+R_mz_{m-1} + \pi B$

However, this requires the verifier to send $m$ elements, leading to a linear communication overhead. The communication overhead can be reduced to constant if the verifier only sends $z$ and the prover and verifier separate the commitments by successive powers of $z$:

$L_1 + L_2z_1 + L_3z^2 + ... L_mz^{m-1} \stackrel{?}{=}R_1+R_2z+R_3z^2\dots+R_mz^{m-1} + \pi B$

### Security analysis
The left-hand-side and right-hand-side are both polynomials of degree $m$. If they are unequal to each other, then they intersect in at most $m$ points by the [Schwartz Zippel Lemma](https://www.rareskills.io/post/schwartz-zippel-lemma). If $m\ll p$ where $p$ is the order of the finite field, then again the probability of $z$ being an intersection point is negligible.

## Random linear combinations of inner products

We can generalize the above technique to combine multiple inner products together.
 
Suppose we have two inner products

$\langle \mathbf{a}_L, \mathbf{a}_R\rangle = v_1$ and $\langle \mathbf{a}_L, \mathbf{a}_W\rangle=v_2$

Because the two inner products share a common term, it is algebraically possible to combine them as follows:

$\langle\mathbf{a}_L, \mathbf{a}_R + \mathbf{a}_W\rangle = v_1 + v_2$

However, this is not secure from a soundness perspective because it is possible because that $\langle \mathbf{a}_L, \mathbf{a}_R\rangle \neq v_1$ and $\langle \mathbf{a}_L, \mathbf{a}_W\rangle\neq v_2$ but $\langle\mathbf{a}_L, \mathbf{a}_R + \mathbf{a}_W\rangle = v_1 + v_2$.

As expected, we can solve this by using a random linear combination.

$$\begin{align*}
&\langle \mathbf{a}_L, \mathbf{a}_R\rangle = v_1 &&\text{ // first inner product}\\
&z\langle \mathbf{a}_L, \mathbf{a}_W\rangle=z\cdot v_2 &&\text{ // second inner product}\\
&\langle \mathbf{a}_L, z\cdot\mathbf{a}_W\rangle=z\cdot v_2 &&\text{ // bring } z \text{ inside}\\
&\langle\mathbf{a}_L, \mathbf{a}_R + z\cdot\mathbf{a}_W\rangle = v_1 + z\cdot v_2&&\text{ // combine into one inner product}
\end{align*}
$$

We only need to create an inner product proof for a single inner product instead of two. It is crucial that the prover receives $z$ after they have sent the relevant commitments, but we leave the exact details for the next chapter when we see an example of an algorithm using this technique: range proofs.

*This tutorial is part of a series on [ZK Bulletproofs](rareskills.io/post/bulletproofs-zk).*
