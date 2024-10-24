# What are Pedersen Commitments and How They Work
Pedersen commitments allow us to encode arbitrarily large vectors with a single elliptic curve point, while optionally hiding any information about the vector.

It allows us to make claims about a vector without revealing the vector itself.

## Motivation
When we discuss Bulletproof Zero Knowledge Proofs, they will generally be of the form "I have two vectors whose inner product is $v$." This might seem basic, but you can actually use this mechanism to prove very non-trivial claims. We’ll get to that later.

But for such a proof to work, the vectors can't just exist in the prover's head – otherwise the prover can change them at will. They have to be mathematical entities in the real world. Generally, the prover does not want to just pass the two vectors to the verifier, but they still need to "pass something" to the verifier to represent that they’ve selected a pair of vectors and cannot change it.

This is where Pedersen commitments enter the picture.

In an inner product argument, the prover provides two *commitments* to two vectors, then provides a proof that the committed vectors have a certain inner product.

## Prerequisites
We assume the reader is already familiar with [elliptic curve point addition](https://www.rareskills.io/post/elliptic-curve-addition) and scalar multiplication and what it means for a point to be "on the curve."

Notation-wise, capital letters are elliptic curve points, lowercase letters are finite field elements.

We say $A$ is an elliptic curve (EC) point, a is a [finite field](https://www.rareskills.io/post/finite-fields) element, and $aA$ is point multiplication between finite field element $a$ and EC point $A$. The expression $A + B$ denotes elliptic curve point addition.

## Traditional commitments
When we design commit reveal functions in smart contracts, they are usually of the form

$$
\text{commitment} = \mathsf{hash}(\text{value}, \text{salt})
$$

where the $\text{salt}$ is a random value to prevent an attacker from brute-force guessing $\text{value}$.

For example, if we were committing a vote, there are only a limited number of choices, and thus the vote selection can be guessed by trying all the votes seeing which hash matches.

The academic terminology for the *salt* variable in the case of Pedersen commitments is the *blinding factor*. Because it is random, the attacker is "blinded" from being able to guess the value committed.

Because the value "commitment" cannot be guess by an adversary, we say this commitment scheme is *hiding*.

During the reveal phase, the committer reveals the value and the salt, so the other party (or smart contract) can validate that it matches the original commitment. It isn't possible to obtain another $(\text{value}, \text{salt})$ pair that can result in the same commitment, so we say this scheme is binding – the committer cannot change (i.e. is bound to) their committed value after the fact.

A $(\text{value}, \text{salt})$ pair that results in the hash is called the *opening*. To say that someone "knows an opening to the commitment" means they know (value, salt). To *reveal* $(\text{value}, \text{salt})$ means to *open* the commitment.

When discussing Pedersen commitments, there is a distinction between *knowing the opening* and *opening* the commitment. We usually want to prove we *know* the opening, but not necessarily *open* it.

## Terminology summary
- A **hiding** commitment does not allow an adversary to know what value was selected by the commiter. This is usually accomplished by including a random term that the attacker cannot guess.
- A **blinding** term is the random number that makes the commitment impossible to guess.
- An **opening** is the values that will compute to the commitment.
- A **binding** commitment does not allow the committer to compute a hash with different values. That is, they cannot find two (value, salt) pairs that hash to the same value.

## Pedersen Commitments
Pedersen commitments behave very similar to the commit-reveal scheme described earlier, except that they use elliptic curve groups instead of cryptographic hash functions.

Under the discrete logarithm assumption, given elliptic curve points $V$ and $U$, we cannot compute $x$ where $V$ = $xU$. That is to say, we do not know their *discrete log relationship*, i.e. how many times $V$ needs to be added to itself to get $U$.

We still refer to $u$ as the discrete logarithm of $U$ even though we cannot compute it, because we know it exists. All (cryptographic) elliptic curve points have a discrete logarithm, even if they cannot be computed.

In this sense, elliptic curve point multiplication behaves like a hash function. They are binding as long as we only allow openings within the curve order.

However, if the range of discrete logarithms is small and bound by the context of the application (such as vote choices), then the discrete logarithm might become guessable.

We can make a The Pedersen hiding in the following manner:

$$
\text{commitment} = vG + sB
$$

where $v$ is the value we are committing and $s$ is the salt (or blinding factor) and $B$ is another elliptic curve point that the committer does not know the discrete logarithm of.

We should emphasize that although the discrete logarithms are unknown, the points $G$ and $B$ are public and known to both the verifier and the committer.

### Why the committer must not know the discrete logarithm of an EC point
Suppose the committer knows the discrete logarithm relationship between $B$ and $G$. That is, they know $u$ such that $B = uG$.

In that case, they can open the commitment 

$$
\text{commitment} = vG + sB
$$

to a different $(v', s')$ other than the value they originally committed.

Here's how the committer could cheat if they know that $g$ is the discrete logarithm of $G$ and $b$ is the discrete logarithm of $B$.
$$
B = bG 
$$
$$
G = gB 
$$

The committer can rewrite the commitment equation:
$$
\begin{align*}
\text{commitment} &= vG + sB \\
&= vG + s(bG) \ \text{(substituting B = bG)} \\
&= (v + sb)G
\end{align*}
$$

The committer picks a new value $v'$ and computes $s'$:

$$
\begin{align*}
v' + s'b = v + sb \\
s' = \frac{v + sb - v'}{b} 
\end{align*}
$$ 


Then, the prover presents $(v', s')$ as the forged opening.

This works because
$$
\begin{align*}
\text{commitment} &= v'G + \frac{v + sb - v'}{b} B \\
\text{commitment} &= v'G + (v + sb - v')G \\
\text{commitment} &= \cancel{v'G} + vG + s(bG) - \cancel{v'G} \\
\text{commitment} &= vG + sB \\
\text{commitment} &= \text{commitment} \\
\end{align*}
$$
**The committer must not know the discrete logarithm relationship between the elliptic curve points they are using.**

One way to accomplish this is to have a verifier supply the elliptic curve points for the committer. A simpler way however is to pick the elliptic curve points in a random and transparent way, such as by pseudorandomly selecting elliptic curve points. Given a random elliptic curve point, we do not know its discrete logarithm.

For example, we could start with the generator point, hash the $x$ and $y$ values, then use that to seed a pseudorandom but deterministic search for the next point.

## Why are Pedersen Commitments useful?
It seems like Pedersen Commitments are just a normal commit-reveal with a different hash-function, so what’s the point?

This scheme has a couple advantages.

### Pedersen commitments are additively homomorphic
Given a point $G$, we can add two commitments together $a_1G + a_2G$ = $(a_1 + a_2)G$.

If we include random blinding terms, we can still do a valid opening by adding the blinding terms together and providing that to the verifier. Let $C$ be commitments. Now consider what happens when we add $C_1 + C_2$ together:

$$
\begin{aligned}
C_1 &= a_1G + s_1B \\
C_2 &= a_2G + s_2B \\
C_3 &= C_1 + C_2 \\
\pi &= s_1 + s_2 \\
\text{committer reveals...} \\
&(a_1, a_2, \pi) \\
\text{and the verifier checks...} \\
C_3 &\stackrel{?}{=} a_1G + a_2G + \pi B
\end{aligned}
$$

Alternatively, the verifier can check that

$$C_3 = (a_1 + a_2)G + \pi B$$

Regular hashes (such as SHA-256) cannot be added together in this manner.

Given two Pedersen commitments that use the same elliptic curve points to commit to, we can add the commitments together and still have a valid opening for them.

Pedersen commitments allow a prover to make claims about the sums of committed values.

### We can encode as many points as we like in a single point
Our example of using $G$ and $B$ can also be thought of a 2D vector commitment without a blinding term. But we can add as many elliptic curve points as we like $[G₁, G₂, …, Gₙ]$ and commit as many scalars as we like. (Here, $G_1$, $G_2$, etc mean different points in the same group, not generators of different groups).

## Pedersen Vector Commitments
We can take the above scheme a step further and commit a set of values rather than a value and a blinding term.

## Vector commitment scheme
Suppose we have a set of random elliptic curve points $(G₁,…,Gₙ)$ (that we do not know the discrete logarithm of), and we do the following:

$$C_1 = \underbrace{v_1G_1 + v_2G_2 + … + v_nG_n}_\text{committed vector} + \underbrace{sB}_\text{blinding term}$$

This lets us commit $n$ values to $C$ and hide it with $s$.

Since the committer does not know the discrete logarithm of any of $G_i$, they don’t know the discrete logarithm of $C$. Hence, this scheme is binding: they can only reveal $(v₁,…,vₙ)$ to produce $C$ later, they cannot produce another vector.

### Vector commitments can be combined
We can add two Pedersen Vector Commitments to get one commitment to two vectors. This will still only allow the committer to open to the original vectors. The important implementation detail is that we have to use a different set of elliptic curve points to commit against.

$$
\begin{align*}
C_1 &= v_1 G_1 + v_2 G_2 + \ldots + v_n G_n + r B \\
C_2 &= w_1 H_1 + w_2 H_2 + \ldots + w_n H_n + s B \\
C_3 &= C_1 + C_2
\end{align*}
$$

By adding $C_1$ and $C_2$ together, we are functionally committing one larger vector of size $2n$.

Here, $rB$ and $sB$ are the blinding terms. Even if the committer commits the zero vector, the commitment will still appear to be a random point.

The committer will later reveal the original vectors $(v₁…vₙ)$ and $(w₁…wₙ)$ and the blinding term $r + s$. This is binding: they cannot reveal another pair of vectors and blinding terms.

The fact that we are using $(G₁,…,Gₙ)$ for one vector and $(H₁,…,Hₙ)$ should not imply that there is a special relationship among the $G$ points and a special relationship among the $H$ points. All the points need to be selected pseudorandomly. This is merely notational convenience for saying "this vector of elliptic curve points goes with this vector of field elements, and this other vector of EC points goes with this other vector of field elements."

There is no practical upper limit to the number of vectors we can commit.

**Exercise for the reader:** If we used the same $G₁…Gₙ$ for both vectors before adding them, how could a committer open two different vectors for $C_3$? Give an example. How does using a different set of points $H₁…Hₙ$ prevent this?

**Exercise for the reader:** What happens if the committer tries to switch the same elements inside the vector?

For example, they commit:

$$C_1 = v_1G_1 + v_2G_2 + \ldots + v_nG_n + rB$$

But open with the first two elements swapped:

$$[v_2, v_1, v_3, ..., v_n]$$

That is, they switch the first two elements leaving everything else unchanged. Assume that the vector $G₁…Gₙ$ is unpermuted.

## Generating random points transparently
How can we generate these random elliptic curve points? One obvious solution is to use a trusted setup, but this isn’t necessary. The committer is able to set up the points in a way they cannot know their discrete logarithm by randomly selecting the points in a transparent way.

They can pick the generator point, mix in a publicly chosen random number, and hash that result (and take it modulo the field_modulus) to obtain another value. if that results in an x value that lies on the elliptic curve, use that as the next generator and hash the $(x, y)$ pair again. Otherwise, if the x-value does not land on the curve, increment $x$ until it does. Because the committer is not generating the points, they don’t know their discrete log.

**Exercise:** Adjust the following code to generate `n` points with unknown discrete logs:
```python
from py_ecc.bn128 import is_on_curve, FQ
from py_ecc.fields import field_properties
field_mod = field_properties["bn128"]["field_modulus"]
from hashlib import sha256
from libnum import has_sqrtmod_prime_power, sqrtmod_prime_power

b = 3 # for bn128, y^2 = x^3 + 3
seed = "RareSkills"

x = int(sha256(seed.encode('ascii')).hexdigest(), 16) % field_mod 

entropy = 0

vector_basis = []
# modify the code below to generate n points
while not has_sqrtmod_prime_power((x**3 + b) % field_mod, field_mod, 1):
    # increment x, so hopefully we are on the curve
    x = (x + 1) % field_mod
    entropy = entropy + 1

# pick the upper or lower point depending on if entropy is even or odd
y = list(sqrtmod_prime_power((x**3 + b) % field_mod, field_mod, 1))[entropy & 1 == 0]
point = (FQ(x), FQ(y))
assert is_on_curve(point, b), "sanity check"
vector_basis.append(point)

# new x value
x = int(sha256(str(x).encode('ascii')).hexdigest(), 16) % field_mod 
print(vector_basis)
```

At no point should you generate a point by picking a scalar and them multiplying it with the generator, as that would lead to the discrete logarithm being known. You need to select the $x$ values of the curve point pseudorandomly via a hash function and figure out if it is on the curve.

It is okay to start with the generator (which has a known discrete logarithm of 1) and generate the other points.

**Exercise for the reader:** Suppose we commit a vector of values to the point points $G_1$ and $G_2$. The discrete logarithm for $G_1$ is known, but the discrete logarithm for $G_2$ is not known. We will ignore the blinding term for now. Can the committer open to two different vectors? Why or why not?

Learn More with RareSkills
Check out our ZK bootcamp if you are looking to [learn zero knowledge proofs](https://www.rareskills.io/zk-bootcamp).
