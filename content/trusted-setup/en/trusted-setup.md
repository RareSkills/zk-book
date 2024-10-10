# Trusted Setup
A trusted setup is a mechanism ZK-SNARKs use to evaluate a polynomial at a secret value.

Observe that a polynomial $f(x)$ can be evaluated by computing the inner product of the coefficients with successive powers of $x$:

For example, if $f(x)=3x^3+2x^2+5x+10$, then the coefficients are $[3,2,5,10]$ and we can compute the polynomial as

$$
f(x)=\langle[3,2,5,10],[x^3,x^2,x, 1]\rangle
$$

In other words, we typically think of evaluating $f(2)$ for the polynomial above as

$$
f(2)=3(2)^3+2(2)^2+5(2)+10
$$

but we could also evaluate it as

$$
f(2)=\langle[3,2,5,10],[8,4,2,1]\rangle = 3\cdot8+2\cdot4+5
\cdot2+10\cdot1
$$

Now suppose that someone picks a secret scalar $\tau$ and computes

$$
[\tau^3,\tau^2,\tau,1]
$$

then multiplies each of those points with the generator point of a cryptographic elliptic curve group. The result would be as follows:

$$
[\Omega_3, \Omega_2, \Omega_1, G_1]=[\tau^3G_1,\tau^2G_1,\tau G_1,G_1]
$$

Now anyone can take the *structure reference string* (SRS) $[\Omega_3, \Omega_2, \Omega_1, G_1]$ and evaluate a degree three polynomial (or less) on $\tau$.

For example, if we have a degree 2 polynomial $g(x)=4x^2+7x+8$, we can evaluate $g(\tau)$ by taking the inner product of the structured reference string with the polynomial:

$$
\langle[0,4,7,8],[\Omega_3, \Omega_2, \Omega_1, G_1]\rangle=4\Omega_2+7\Omega_1+8G_1
$$

We have now computed $g(\tau)$ *without knowing what $\tau$ is!*

This is also called a *trusted setup* because although *we* don’t know what the discrete log of $g(\tau)$ is, the person who created the structured reference string does. This could lead to leaking information down the line, so we *trust* that the entity creating the trusted setup deletes $\tau$ and in no way remembers it.

## Example in Python

```python
from py_ecc.bn128 import G1, multiply, add
from functools import reduce

def inner_product(points, coeffs):
    return reduce(add, map(multiply, points, coeffs))

## Trusted Setup
tau = 88
degree = 3

# tau^3, tau^2, tau, 1
srs = [multiply(G1, tau**i) for i in range(degree,-1,-1)]

## Evaluate
# p(x) = 4x^2 + 7x + 8
coeffs = [0, 4, 7, 8]

poly_at_tau = inner_product(srs, coeffs)
```

## Verifying a Trusted Setup was Generated Properly

Given a structured reference string, how do we even know that they follow the structure $[x^d, x^{d-1},\dots,x,1]$ and weren’t chosen by the roll of the dice?

If the person doing the trusted setup also provides $\Theta=\tau G_2$, we can validate the structured reference string is indeed successive powers of  $\tau$.

$$
e(\Theta, \Omega_i)\stackrel{?}=e(G_2,\Omega_{i+1})
$$

where $e$ is a [bilinear pairing](https://www.rareskills.io/post/bilinear-pairing). Intuitively, we are computing $\tau\cdot\tau^i$ on the left side and $1\cdot\tau^{i+1}$ on the right side..

To validate that $\Theta$ and $\Omega_1$ have the same discrete logarithms ($\Omega_1$ is supposed to be $\tau G_1$, we can check that

$$
e(\Theta,G_1)\stackrel{?}=e(G_2,\Omega_1)
$$

## Generating a structured reference string as part of a multiparty computation

It’s not a good trust assumption the person generating the structured reference string actually deleted $\tau$.

We now describe the algorithm for multiple parties to collaboratively create the structured reference string, and as long as one of them is honest (i.e. deletes $\tau$), then the discrete logs of the structured reference string will be unknown.

Alice generates the structured reference string $([\Omega_n,...,\Omega_2,\Omega_1, G_1],\Theta)$ and passes it to Bob.

Bob verifies the SRS is “correct” by using the checks from the earlier section. Then Bob picks his own secret parameter $\gamma$ and computes

$$
([\gamma^n\Omega_n,...,\gamma^2\Omega_2,\gamma\Omega_1,G_1],\gamma\Theta)
$$

Note that the discrete logs of the srs are now

$$
([(\tau\gamma)^n,...,(\tau\gamma)^2,(\tau\gamma),1],\tau\gamma)
$$

If either Alice or Bob delete their $\tau$ or $\gamma$, then the discrete logs of the final srs are not recoverable.

Of course, we don’t need to limit the participants to two, we could have as many participants as we like.

This multiparty computation is often informally referred to as the *powers of tau ceremony*.

## The use of a trusted setup in ZK-SNARKs
Evaluating a polynomial on a structured reference string doesn't reveal information about the polynomial to the verifier, and the prover doesn't know what point they are evaluating on. We will see later that this scheme helps prevent the prover from cheating and helps keep their witness zero knowledge.
