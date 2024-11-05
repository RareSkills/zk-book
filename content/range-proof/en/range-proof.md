# Range Proof

A range proof in the context of inner product arguments is a proof that the scalar $v$ has been committed to $V$ and $v$ is less than $2^n$ for some non-negative integer $n$.

This article shows how the Bulletproofs paper constructs such a proof. The high level idea is that if we can prove that a vector $\mathbf{a}_L$ consists only of ones and zeros and that $\mathbf{a}_L$ is the binary representation of $v$, then $v$ must be less than $2^n$. This is analogous to saying that a number that fits in an 8 bit unsigned integer must be less than 256.

The advantage of using Bulletproofs for range proofs is that the range proof can be directly constructed without the need of an [arithmetic circuit](https://www.rareskills.io/post/arithmetic-circuit).

[Monero uses Bulletproof Range Proofs](https://github.com/monero-project/monero/blob/master/src/ringct/bulletproofs.cc) (the algorithm presented here) to ensure that the sum of transactions is not negative (in a [finite field](https://www.rareskills.io/post/finite-fields), the negative numbers are the elements greater than $p/2$ as they are additive inverses of the elements less than or equal $p/2$ where $p$ is the field order).

*This article is part of a series on [ZK Bulletproofs](rareskills.io/post/bulletproofs-zk).*

## Notation
$\mathbf{0}^n$ is an $n$ dimensional vector of all zeros.

$\mathbf{1}^n$ is an $n$ dimensional vector of all ones.

$\mathbf{2}^n$ is an $n$ dimensional vector $\mathbf{2}^n$ is $[1,2,4,8,...,2^{n-1}]$

$\mathbf{y}^n$ is an $n$ dimensional vector $[1, y, y^2, y^3, ..., y^{n-1}]$

$\mathbf{y}^{-n}$ is an $n$ dimensional vector $[1, y^{-1}, y^{-2}, ..., y^{-(n-1)}]$

Note that $\mathbf{y}^n\circ\mathbf{y}^{-n}=\mathbf{1}^n$.

## Range proof overview
Proving that $V$ is a commitment to a scalar with a value less than $2^n$ requires proving the following:

1. $\mathbf{a}_L$ is binary (only holds values $0$ and $1$).
2. The inner product $\langle \mathbf{a}_L,\mathbf{2}^n\rangle=v$.

The second point is easy to prove, we do a normal inner product proof then reveal $\mathbf{2}^n$ is one of the vectors in the commitment -- or have the verifier construct the commitment of $\mathbf{2}^n$ themselves. However, proving that $\mathbf{a}_L$ is binary without an arithmetic circuit requires a couple algebraic tricks.

## Four useful tricks
The bulletproofs paper implicitly uses four algebraic tricks that are best taught explicitly before looking at the range proof algorithm directly.

### 1. Proving $\mathbf{a}_L$ is binary
The statement $\mathbf{a}_L$ is binary is equivalent to the following two assertions:
- $\mathbf{a}_R = \mathbf{a}_L-\mathbf{1}^n$
- $\mathbf{a}_L \circ \mathbf{a}_R = \mathbf{0}^n$

For example, if $\mathbf{a}_L = [1,0,0,1]$ then $\mathbf{a}_R=[0,-1,-1,0]$.

In this case, $\mathbf{a}_L \circ\mathbf{a}_R=\mathbf{0}^n$ because

$$[1,0,0,1] \circ [0,-1,-1,0] = [0,0,0,0] = \mathbf{0}^n$$

Now consider a case where $\mathbf{a}_L$ is not binary, for example $[2, 1, 0, 0]$. $\mathbf{a}_R$ will be $[1,0,-1,-1]$ The Hadamard product of $\mathbf{a}_L$ and $\mathbf{a}_R$ will be $[2,0,0,0] \neq \mathbf{0}^n$.

More generally, if $\mathbf{a}_L$ has a non-binary entry, that entry will be subtracted by $1$, and the resulting entry in $\mathbf{a}_R$ will be non-zero. When the Hadamard product is computed, then at that particular index, $\mathbf{a}_L$ and $\mathbf{a}_R$ will both be non-zero and the product will be non-zero, meaning $\mathbf{a}_L \circ \mathbf{a}_R \neq \mathbf{0}^n$.

However, if a particular entry in $\mathbf{a}_L$ is $1$, then $\mathbf{a}_R$ will be $0$ at that index and the product of at that index when the Hadamard product is computed will be zero.

Finally, if a particular entry in $\mathbf{a}_L$ is $0$, then $\mathbf{a}_R$ will be $-1$ at that index and their element-wise product will still be zero at that index.

Therefore, if $\mathbf{a}_L$ is binary and $\mathbf{a}_R$ is computed as $\mathbf{a}_R = \mathbf{a}_L-\mathbf{1}$, then $\mathbf{a}_L \circ \mathbf{a}_R = \mathbf{0}^n$.

### 2. Proving a vector is all zero
Suppose we wish to prove that the Pedersen commitment $A$ holds a zero vector. We create the Pedersen commitment $A = \langle\mathbf{a},\mathbf{G}\rangle + \alpha B$ and wish to prove to a verifier that $\mathbf{a}=\mathbf{0}^n$.

It might seem sufficient to simply send the blinding term $\alpha$, but to make our solution more composable, we do not want to reveal the blinding term because that might affect other commitments we have created.

Instead, the prover sends $A$ to the verifier, and the verifier responds a vector full of random values $\mathbf{r}$. The prover must now prove that

$$\langle\mathbf{a},\mathbf{r}\rangle = 0$$

Note that this is a probabilistic test. It is possible, with negligible probability, that $\langle\mathbf{a},\mathbf{r}\rangle=0$ for $\mathbf{a}\neq\mathbf{0}^n$, but it is not possible for the prover to forge such an $\mathbf{a}$ because they do not know in advance what $\mathbf{r}$ will be.

However, transmitting $\mathbf{r}$ requires $\mathcal{O}(n)$ communication overhead, so the verifier instead only sends a single random element $y$ and the prover computes $\mathbf{y}^n$ and uses $\mathbf{y}^n$ as a the random vector.

Then, the prover proves that $\langle\mathbf{a},\mathbf{y}^n\rangle=0$.

### 3. Proving an inner product is of the form $\langle\mathbf{a}_L,\mathbf{a}_R\circ\mathbf{y}^n\rangle$ where $y$ is chosen by the verifier and the prover computes $\mathbf{y}^n$

We don't yet have a mechanism to prove that $\mathbf{a}_L\circ\mathbf{a}_R=\mathbf{0}^n$, as that is a Hadamard product, not an inner product. However, stating the vector $\mathbf{a}_L\circ\mathbf{a}_R$ is identically $\mathbf{0}^n$ is the same as stating that $\langle\mathbf{a}_L\circ\mathbf{a}_R,\mathbf{y}^n\rangle=0$. By the inner product rules, we can move $\mathbf{a}_R$ to the other side of the inner product and we now have $\langle\mathbf{a}_L,\mathbf{a}_R\circ\mathbf{y}^n\rangle=0$.

The verifier will receive commitments to $\mathbf{a}_L$ and $\mathbf{a}_R$, not $\mathbf{a}_R\circ\mathbf{y}^n$. It will be up to the verifier to construct a commitment to $\mathbf{a}_R\circ\mathbf{y}^n$ so they are convinced the prover used $\mathbf{a}_R\circ\mathbf{y}^n$ as the second vector in the inner product.

The key trick we rely on is that the prover uses the basis vectors $\mathbf{G}$ and $\mathbf{H}$ to commit their vectors, but the verifier uses $\mathbf{G}$ and $\mathbf{H}\circ\mathbf{y}^{-n}$.

When the prover sends the evaluation $\mathbf{r}_u$, the prover must ensure that $\mathbf{y}^n$ terms will cancel with the $\mathbf{y}^{-n}$ in the verifier's basis vector $\mathbf{y}^{-n}\circ\mathbf{H}$.

Specifically, the prover constructs the commitments

$$\begin{align*}
A &= \langle\mathbf{a}_L,\mathbf{G}\rangle+\langle\mathbf{a}_R,\mathbf{H}\rangle+\alpha B\\
S &= \langle\mathbf{s}_L,\mathbf{G}\rangle+\langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B
\end{align*}
$$

And sends $(A, S)$ to the verifier. There is no need to commit and send $V$ because it is zero in this case.

The prover's polynomials will be

$$\begin{align*}
\mathbf{l}(x)&=\mathbf{a}_L + \mathbf{s}_Lx\\
\mathbf{r}(x)&=\mathbf{a}_R\circ\mathbf{y}^n + \boxed{\mathbf{s}_R\circ\mathbf{y}^n}x
\end{align*}
$$

Crucially, the prover has Hadamard multiplied $\mathbf{s}_R$ by $\mathbf{y}^n$. Previously, $\mathbf{r}(x)$ was computed as $\mathbf{r}(x)=\mathbf{a}_R\circ\mathbf{y}^n + \mathbf{s}_Rx$ (without the $\mathbf{y}^n\circ\mathbf{s}_R$. This will later allow all of the $\mathbf{y}^n$ terms to be canceled when the verifier computes the commitment $\langle\mathbf{r}_u,\mathbf{y}^{-n}\circ\mathbf{H}\rangle$. Under the hood, $\mathbf{r}_u$ is $(\mathbf{a}_R+\mathbf{s}_Ru)\circ\mathbf{y}^n$ so the $\mathbf{y}^n$ will cancel when the verifier computes $\langle(\mathbf{a}_R+\mathbf{s}_Ru)\circ\mathbf{y}^n,\mathbf{y}^{-n}\circ\mathbf{H}\rangle$, i.e.

$$\begin{align*}
&\langle(\mathbf{a}_R+\mathbf{s}_Ru)\circ\mathbf{y}^n,\mathbf{y}^{-n}\circ\mathbf{H}\rangle\\
&=\langle(\mathbf{a}_R+\mathbf{s}_Ru),\mathbf{y}^n\circ\mathbf{y}^{-n}\circ\mathbf{H}\rangle\\
&=\langle(\mathbf{a}_R+\mathbf{s}_Ru),\mathbf{1}^n\circ\mathbf{H}\rangle\\
&=\langle(\mathbf{a}_R+\mathbf{s}_Ru),\mathbf{H}\rangle
\end{align*}$$

However, the prover cannot compute $\mathbf{l}(x)$ or $\mathbf{r}(x)$ yet because the verifier hasn't sent $y$ yet. Therefore, after receiving $(A, S)$ the verifier sends $y$ and the prover computes $\mathbf{y}^n$ and computes the polynomial $t(x)$:

$$t(x)=\langle\mathbf{l}(x),\mathbf{r}(x)\rangle=\langle\mathbf{a}_L,\mathbf{a}_R\circ\mathbf{y}^n\rangle+t_1x+t_2x^2$$

where

$$\begin{align*}
t_1&=\langle\mathbf{a}_L,\mathbf{s}_R\circ\mathbf{y}^n\rangle + \langle\mathbf{s}_L,\mathbf{a}_R\circ\mathbf{y}^n\rangle\\
t_2&=\langle\mathbf{s}_L,\mathbf{s}_R\circ\mathbf{y}
^n\rangle
\end{align*}$$

The prover commits to the coefficients $t_1$ and $t_2$ as

$$\begin{align*}
T_1&=t_1G+\tau_1B\\
T_2&=t_2G+\tau_2B
\end{align*}$$

and sends $(T_1, T_2)$ to the verifier. The verifier responds with $u$ and the prover evaluates the vector polynomials $\mathbf{l}(x)$ and $\mathbf{r}(x)$:

$$
\begin{align*}
\mathbf{l}_u&= \mathbf{a}_L\circ\mathbf{y}^n+(\mathbf{s}_L\circ\mathbf{y}^n)u\\
\mathbf{r}_u&= \mathbf{a}_R+\mathbf{s}_Ru\\
t_u&=\langle\mathbf{l}_u,\mathbf{r}_u\rangle\\
\pi_{lr}&=\alpha + \beta u\\
\pi_t&=\tau_1u+\tau_2u^2
\end{align*}
$$

Note that $\pi_t$ only includes the blinding terms for $t_1$ and $t_2$. In the previous implementation, $\pi_t$ was computed as $\gamma + \tau_1u+\tau_2u^2$, where $\gamma$ is the blinding term for $V$, which is also the constant coefficient of the polynomial $t(x)$.

There is no blinding term $\gamma$ because there is no commitment to $V$, i.e. $v$ is not secret -- it is $0$. The prover sends $(\mathbf{l}_u, \mathbf{r}_u, t_u, \pi_{lr}, \pi_t)$ and the verifier checks that:

$$
\begin{align*}
t_u&\stackrel{?}=\langle\mathbf{l}_u,\mathbf{r}_u\rangle\\
A+Su&\stackrel{?}=\langle\mathbf{l}_u,\mathbf{G}\rangle+\langle\mathbf{r}_u,\mathbf{y}^{-n}\circ\mathbf{H}\rangle+\pi_{lr}B\\
t_uG&\stackrel{?}{=} T_1 u + T_2 u^2 - \pi_t B\\
\end{align*}
$$

The first crucial difference is that the commitment to $\mathbf{r}_u$ is done with respect to the basis vector $\mathbf{y}^{-n}\circ\mathbf{H}$ instead of $\mathbf{H}$ for the reasons discussed earlier.

Second, $t_uG\stackrel{?}{=} T_1 u + T_2 u^2 + \pi_t B$ has no constant commitment. Normally, the equation is $t_uG\stackrel{?}{=} \boxed{V}+T_1 u + T_2 u^2 + \pi_t B$, but $V$ is a commitment to $0$ in this case.

In general, if $V$ contains values known to the verifier, the verifier can construct the commitment to $V$ as we show in the next section.

### 4. Proving an inner product when an additive public constant is involved

As alluded in the section above, the verifier can reconstruct commitments if the verifier knows the underlying vector.

For example, suppose we are proving that

$\langle\mathbf{a}_L + \mathbf{j},\mathbf{a}_R\circ\mathbf{y}^n + \mathbf{k}\rangle=vz$

where $\mathbf{j}$ and $\mathbf{k}$ are a vectors known to the verifier and $z$ is a scalar known to the verifier in advance. Unlike $\mathbf{y}^n$, these vectors and scalar are known before the proof begins. Note that $\mathbf{k}$ is not Hadamard multiplied by $\mathbf{y}^n$ in this example.

The prover still only commits to the secret values $\mathbf{a}_L$, $\mathbf{a}_R$ and $v$ as usual:

$$\begin{align*}
A &= \langle\mathbf{a}_L,\mathbf{G}\rangle+\langle\mathbf{a}_R,\mathbf{H}\rangle+\alpha B\\
S &= \langle\mathbf{s}_L,\mathbf{G}\rangle+\langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B\\
V &= vG + \gamma B
\end{align*}$$

As usual, the polynomials $\mathbf{l}(x)$ and $\mathbf{r}(x)$ are such that the constant term is the vector from the original inner product and the linear terms are $\mathbf{s}_L$ and $\mathbf{s}_R$. Upon receiving $y$ from the verifier, the prover computes $\mathbf{y}^n$ and crafts but does not evaluate $\mathbf{l}(x)$ and $\mathbf{r}(x)$:

$$\begin{align*}
\mathbf{l}(x)&=\underbrace{\mathbf{a}_L + \mathbf{j}}_\text{left vector} + \mathbf{s}_Lx\\
\mathbf{r}(x)&=\underbrace{\mathbf{a}_R\circ\mathbf{y}^n + \mathbf{k}}_\text{right vector} + \boxed{\mathbf{s}_R\circ\mathbf{y}^n}x
\end{align*}
$$

Note that $\mathbf{k}$ is not Hadamard multiplied with $\mathbf{y}^n$, but the linear term $\mathbf{s}_R$ still is. We will show how the verifier handles this later.

For now, we compute $t(x)$ as

$$t(x)=v+t_1x+t_2x$$

where

$$\begin{align*}
t_1&=\langle\mathbf{a}_L+\mathbf{j},\mathbf{s}_R\circ\mathbf{y}^n\rangle + \langle\mathbf{s}_L,\mathbf{a}_R\circ\mathbf{y}^n+\mathbf{k}\rangle\\
t_2&=\langle\mathbf{s}_L,\mathbf{s}_R\circ\mathbf{y}
^n\rangle
\end{align*}$$

Note that the constant term in $t(x)$ is $v$ and not $vz$. The commitments are computed as

$$\begin{align*}
T_1 &= t_1+\tau_1B\\
T_2 &= t_2+\tau_2B\\
\end{align*}$$

and sent to the verifier who then sends the random value $u$.

The prover computes:

$$
\begin{align*}
\mathbf{l}_u&= \mathbf{a}_L\circ\mathbf{y}^n+\mathbf{j}+(\mathbf{s}_L\circ\mathbf{y}^n)u\\
\mathbf{r}_u&= \mathbf{a}_R\circ\mathbf{y}^n+\mathbf{k}+\mathbf{s}_Ru\\
t_u&=\langle\mathbf{l}_u,\mathbf{r}_u\rangle\\
\pi_{lr}&=\alpha + \beta u\\
\pi_t&=vz+\tau_1u+\tau_2u^2
\end{align*}
$$

Note that the constant term in $\pi_t$ is $vz$. The prover sends $(\mathbf{l}_u,\mathbf{r}_u,t_u,\pi_{lr},\pi_t)$. Finally, the verifier computes:

$$
\begin{align*}
t_u&\stackrel{?}=\langle\mathbf{l}_u,\mathbf{r}_u\rangle\\
A+Su+\underbrace{\langle\mathbf{j,\mathbf{G}}\rangle}_{\text{commitment to } \mathbf{j} \text{ in  } \mathbf{l}(x)}+\underbrace{\langle\mathbf{k},\mathbf{y}^{-n}\circ\mathbf{H}\rangle}_{\text{commitment to } \mathbf{k} \text{ in } \mathbf{r}(x)}&\stackrel{?}=\langle\mathbf{l}_u,\mathbf{G}\rangle+\langle\mathbf{r}_u,\mathbf{y}^{-n}\circ\mathbf{H}\rangle+\pi_{lr}B\\
t_uG&\stackrel{?}{=} Vz+ T_1 u + T_2 u^2 - \pi_t B\\
\end{align*}
$$

$\mathbf{l}_u$ and $\mathbf{r}_u$ contain $\mathbf{j}$ and $\mathbf{k}$ respectively, but $A$ and $S$ do not. Hence, the verifier computes commitments to those vectors and adds them to the commitments $A$ and $S$. In the case of $\mathbf{k}$, the basis vector $\mathbf{y}^{-n}\circ\mathbf{H}$ will cause $\mathbf{k}$ to become $\mathbf{k}\circ\mathbf{y}^{-n}$, so the commitment must be computed with respect to $\mathbf{y}^{-n}\circ\mathbf{H}$. Finally, the blinding term $\pi_t$ contains $vz$ but $V$ does not contain $z$. Therefore, the prover must multiply $V$ by $z$.

By computing $\langle\mathbf{j},\mathbf{G}\rangle$, $\langle\mathbf{k},\mathbf{y}^n\circ\mathbf{H}\rangle$ and $Vz$, the verifier can be sure the inner product computation actually included those terms.

## Range proof
To prove that $V$ is a value less than $2^n$ we have three things to prove:

- the inner product $\langle \mathbf{a}_L,\mathbf{2}^n\rangle = V$, i.e. $\mathbf{a}_L$ is the binary representation of $v$
- $\mathbf{a}_R=\mathbf{a}_L-\mathbf{1}$
- $\mathbf{a}_L \circ \mathbf{a}_R = \mathbf{0}$

The last two claims are not directly in the form of an inner product. However, we can modify them slightly to accomplish this. What we are really saying is that the vectors
- $\mathbf{a}_R - \mathbf{a}_L+\mathbf{1}$
- $\mathbf{a}_L\circ\mathbf{a}_R$

are both $\mathbf{0}^n$. We can use the trick from a previous section to prove that they are zero. That is, the the prover needs to establish that

$$\langle\mathbf{a}_L\circ\mathbf{a}_R,\mathbf{y}^n\rangle=\mathbf{0}$$

and

$$\langle \mathbf{a}_R - \mathbf{a}_L+\mathbf{1},\mathbf{y}^n\rangle=\mathbf{0}$$

where $\mathbf{y}^n$ is the random vector derived from the $y$ value sent from the verifier.

The original bulletproofs paper slightly modifies the first claim as follows so that we can use the third trick in the previous section:

$$\langle\mathbf{a}_L,\mathbf{a}_R\circ\mathbf{y}^n\rangle=\mathbf{0}$$

Therefore, the prover has three inner products to establish:

1. $\langle \mathbf{a}_L,\mathbf{2}^n\rangle = v$
2. $\langle\mathbf{a}_L,\mathbf{a}_R\circ\mathbf{y}^n\rangle=\mathbf{0}^n$
3. $\langle\mathbf{a}_L -\mathbf{1}^n- \mathbf{a}_R,\mathbf{y}^n\rangle=\mathbf{0}^n$

### Combining three inner products into one
The three inner products can combined into a single one using a random linear combination with randomness $z$ provided from the verifier.

$$z^2 \cdot \langle \mathbf{a_L}, 2^n \rangle + z^1 \cdot \langle \mathbf{a_L} - \mathbf{1}^n - \mathbf{a_R}, \mathbf{y}^n \rangle + z^0\langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle = z^2 \cdot v + z^1\cdot\mathbf{0}^n+z^0\cdot\mathbf{0}^n$$

$$z^2 \cdot \langle \mathbf{a_L}, 2^n \rangle + z \cdot \langle \mathbf{a_L} - \mathbf{1}^n - \mathbf{a_R}, \mathbf{y}^n \rangle + \langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle = z^2 \cdot v$$

With some very hefty inner product algebra, we can combine all the inner products as follows. We show the derivation in the appendix.

$$\left\langle \mathbf{a_L} - z \cdot \mathbf{1}^n, \mathbf{y}^n \circ \mathbf{a_R} +  \mathbf{y}^n\cdot z + z^2 \cdot 2^n \right\rangle = z^2 \cdot v + (z - z^2) \cdot \langle \mathbf{1}^n, y^n \rangle - z^3 \langle \mathbf{1}^n, 2^n \rangle
$$

The terms in boxes below contain values known to the verifier, so we will construct our verification algorithm to explicitly check for those values. That is, the verifier will compute commitments to the values in the boxed terms, not the prover:

$$\left\langle \mathbf{a_L} - \boxed{z \cdot \mathbf{1}^n}, \mathbf{y}^n \circ \mathbf{a_R} +  \boxed{\mathbf{y}^n\cdot z + z^2 \cdot 2^n }\right\rangle = \boxed{z^2} \cdot v + \boxed{(z - z^2) \cdot \langle \mathbf{1}^n, y^n \rangle - z^3 \langle \mathbf{1}^n, 2^n \rangle}
$$

To save space, the Bulletproofs paper refers to the term $(z - z^2) \cdot \langle \mathbf{1}^n, y^n \rangle - z^3 \langle \mathbf{1}^n, 2^n \rangle$ as $\delta(y,z)$, so the inner product can be written as 

$$\left\langle \mathbf{a_L} - z \cdot \mathbf{1}^n, \mathbf{y}^n \circ \mathbf{a_R} +  \mathbf{y}^n\cdot z + z^2 \cdot 2^n \right\rangle = z^2 \cdot v + \delta(y,z)
$$

Note that $\delta(y,z)$ is a value the verifier can compute.

## Range Proof Algorithm
The prover chooses $v$ and it's binary representation $\mathbf{a}_L$ and computes $\mathbf{a}_R = \mathbf{a}_L - \mathbf{1}$.

The prover then randomly chooses the blinding term $\alpha$ and computes the combined commitment of $\mathbf{a}_L$ and $\mathbf{a}_R$ using basis vectors $\mathbf{G}$ and $\mathbf{H}$ as

$$A = \langle\mathbf{a}_L,\mathbf{G}\rangle+\langle\mathbf{a}_R,\mathbf{H}\rangle+\alpha B$$

The prover then chooses the linear terms of the soon-to-be-created vector polynomials $\mathbf{l}(x)$ and $\mathbf{r}(x)$ as $\mathbf{s}_L$ and $\mathbf{s}_R$ and commits to them

$$S = \langle\mathbf{s}_L,\mathbf{G}\rangle+\langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B$$

The prover commits the inner product to $V$ as with respect to $G$ of an unknown discrete log (unrelated to $\mathbf{G}$):

$$V = vG+\gamma B$$

The prover sends $(A, S, V)$ to the verifier.

The verifier responds with random values $(y, z)$ which the prover will use to combine the three inner products into a single one.

$$\left\langle \mathbf{a_L} - z \cdot \mathbf{1}^n, \mathbf{y}^n \circ \mathbf{a_R} +  \mathbf{y}^n\cdot z + z^2 \cdot 2^n \right\rangle = z^2 \cdot v + \delta(y,z)
$$

The left part of the inner product $\mathbf{a}_L-z\cdot\mathbf{1}$ will be the constant term of $\mathbf{l}(x)$ and $\mathbf{a_R} +  \mathbf{y}^n\cdot z + z^2 \cdot 2^n$ will be the constant term of $\mathbf{r}(x)$.

Thus, we construct $\mathbf{l}(x)$ as

$$\mathbf{l}(x)=\underbrace{\mathbf{a}_L-z\cdot\mathbf{1}}_\text{constant term}+\mathbf{s}_Lx$$


and we construct $\mathbf{r}(x)$ as

$$\mathbf{r}(x)=\underbrace{\mathbf{y}^n\circ(\mathbf{a}_R+z\cdot\mathbf{1})+z^2\mathbf{2}^n}_\text{constant term}+\mathbf{y}^n\circ\mathbf{s}_Rx$$

Note that we element-wise multiplied $\mathbf{s}_Rx$ with $\mathbf{y}^n$ for the reasons we discussed in part 3 of the prerequisites section above.

The prover can now construct $t(x) = \langle\mathbf{l}(x),\mathbf{r}(x)\rangle$ with constant coefficient $t_0$, linear coefficient $t_1$ and quadratic coefficient $t_2$ as:

$$\begin{align*}
t_0 &= \left\langle \mathbf{a_L} - z \cdot \mathbf{1}^n, \mathbf{y}^n \circ \mathbf{a_R} +  \mathbf{y}^n\cdot z + z^2 \cdot 2^n \right\rangle\\
t_1 &= \langle(\mathbf{a}_L-z\cdot\mathbf{1}),\mathbf{y}^n\circ\mathbf{s}_R\rangle+\langle\mathbf{y}^n\circ(\mathbf{a}_R+z\cdot\mathbf{1})+z^2\mathbf{2}^n,\mathbf{s_L}\rangle\\
t_2 &= \langle\mathbf{s}_L,\mathbf{y}^n\circ\mathbf{s}_R\rangle
\end{align*}
$$

where $t(x) = t_0 + t_1x + t_2x^2$

The prover sends commitments to $t_1$ and $t_2$ as

$$
\begin{align*}
T_1 &= t_1G+\tau_1B\\
T_2 &= t_2G+\tau_2B
\end{align*}
$$

There is no need to commit to $t_0$ -- observe that it is exactly the inner product we are trying to prove, so the verifier already has the commitment as $V$.

The verifier sends randomness $u$ and the prover computes

$$
\begin{align*}
\mathbf{l}_u &= \mathbf{l}(u) \\
\mathbf{r}_u &= \mathbf{r}(u) \\
t_u &= \mathbf{t}(u)\\
\pi_{lr} &=\alpha+\beta u\\
\pi_t &= z^2\gamma + \tau_1u + \tau_2u^2\\
\end{align*}
$$

Note that the constant term of $\pi_t$ is multiplied by $z^2$ to reflect the $z^2\cdot v$ term of the original inner product.

The verifier then computes a new basis vector $\mathbf{H}_{\mathbf{y}^{-1}}=\mathbf{y}^{-n}\circ\mathbf{H}$ and runs the following checks:

$t_u \stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{r}_u \rangle$

$A + Su + \boxed{\langle -z\cdot\mathbf{1}^n,\mathbf{G}\rangle} + \boxed{\langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle}\stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H}_{y^{-1}} \rangle + \pi_{lr} B$

$t_uG+\pi_tB=V\boxed{z^2}+\boxed{\delta(y,z)}\cdot G+T_1u+T_2u^2$

Recall that the prover did not commit the entire vectors they used for the left and right side of the inner product, but only $\mathbf{a}_L$ and $\mathbf{b}_L$. The rest of the vectors were additive public vectors known to the verifier, so the verifier reconstructed the commitments to the vectors by constructing commitments to the constant terms and adding them to the commitment of the secret vectors supplied by the prover.

By way of reminder, here is the original inner product with the values known the the verifier boxed:

$$\left\langle \mathbf{a_L} + \boxed{-z \cdot \mathbf{1}^n}, \mathbf{y}^n \circ \mathbf{a_R} +  \boxed{\mathbf{y}^n\cdot z + z^2 \cdot 2^n }\right\rangle = \boxed{z^2} \cdot v + \boxed{\delta(y,z)}
$$

The reader is encouraged to verify that the boxed terms (values known to the verifier) in the original product were reconstructed by the verifier in the boxed terms in the set of equality checks above. 

By replicating a portion of the prover's computation, the verifier asserts that the prover actually carried out the computation as claimed. 

### Correctness of the verification algorithm
We now show that the final verification checks are identically correct if the prover was honest.

Below we show the exact algebra, but intuitively the verifier is "reconstructing" the left vector in the inner product $\mathbf{a_L} - z \cdot \mathbf{1}^n$, the right vector in the inner product $\mathbf{y}^n \circ \mathbf{a_R} +  \mathbf{y}^n\cdot z + z^2 \cdot 2^n$ and the output $z^2v+\delta(y,z)$.

The verifier is not given commitments to $\mathbf{a_L} - z \cdot \mathbf{1}^n$ and $\mathbf{y}^n \circ \mathbf{a_R} +  \mathbf{y}^n\cdot z + z^2 \cdot 2^n$ but to $\mathbf{a}_L$ and $\mathbf{a}_R$. Similarly, the verifier is not given a commitment to the output $z^2v + \delta(y,z)$ but only to $v$.

The additive terms and the terms element-wise multiplied by $\mathbf{y}^n$ must be reconstructed by the verifier.

#### Correctness of $t_u = \mathbf{t}(u)$
For the $t_u\stackrel{?}
=\langle\mathbf{l}_u,\mathbf{r}_u\rangle$ check, this is true by definition, as that is how the prover computed $t_u$.

#### Correctness of the committed $\mathbf{l}(x)$ and $\mathbf{r}(x)$ with respect to $A$ and $S$
For 
$A + Su + \langle -z\cdot\mathbf{1}^n,\mathbf{G}\rangle + \langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle\stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{G} \rangle + \langle \mathbf{r}_u, \mathbf{H}_{y^{-1}} \rangle + \pi_{lr} B$

we make the following substitution:

$\underbrace{\langle\mathbf{a}_L,\mathbf{G}\rangle+\langle\mathbf{a}_R,\mathbf{H}\rangle+\alpha B}_A + \underbrace{(\langle\mathbf{s}_L,\mathbf{G}\rangle+\langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B)}_Su + \langle -z\cdot\mathbf{1}^n,\mathbf{G}\rangle + \langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle\stackrel{?}{=} \langle \underbrace{\mathbf{a}_L-z\cdot\mathbf{1}+\mathbf{s}_Lu}_{\mathbf{l}_u}, \mathbf{G} \rangle + \langle \underbrace{\mathbf{y}^n\circ(\mathbf{a}_R+z\cdot\mathbf{1})+z^2\mathbf{2}^n+\mathbf{y}^n\circ\mathbf{s}_Rx}_{\mathbf{r}_u}, \mathbf{H}_{y^{-1}} \rangle + \underbrace{(\alpha+\beta u)}_{\pi_{lr}} B$

all the $\mathbf{G}$ terms cancel as follows:

$\cancel{\langle\mathbf{a}_L,\mathbf{G}\rangle}+\langle\mathbf{a}_R,\mathbf{H}\rangle+\alpha B + (\cancel{\langle\mathbf{s}_L,\mathbf{G}\rangle}+\langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B)u + \cancel{\langle -z\cdot\mathbf{1}^n,\mathbf{G}\rangle} + \langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=} \cancel{\langle \mathbf{a}_L-z\cdot\mathbf{1}+\mathbf{s}_L u, \mathbf{G} \rangle} + \langle \mathbf{y}^n\circ(\mathbf{a}_R+z\cdot\mathbf{1})+z^2\mathbf{2}^n+\mathbf{y}^n\circ\mathbf{s}_R x, \mathbf{H}_{y^{-1}} \rangle + (\alpha+\beta u) B$

$\langle\mathbf{a}_R,\mathbf{H}\rangle+\alpha B + (\langle\mathbf{s}_R,\mathbf{H}\rangle+\beta B)u  + \langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=} \langle \mathbf{y}^n\circ(\mathbf{a}_R+z\cdot\mathbf{1})+z^2\mathbf{2}^n+\mathbf{y}^n\circ\mathbf{s}_R x, \mathbf{H}_{y^{-1}} \rangle + (\alpha+\beta u) B$

the blinding terms related to $B$ cancel as follows:

$\langle\mathbf{a}_R,\mathbf{H}\rangle+\cancel{\alpha B} + (\langle\mathbf{s}_R,\mathbf{H}\rangle+\cancel{\beta B)u}  + \langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=} \langle \mathbf{y}^n\circ(\mathbf{a}_R+z\cdot\mathbf{1})+z^2\mathbf{2}^n+\mathbf{y}^n\circ\mathbf{s}_R x, \mathbf{H}_{y^{-1}} \rangle + \cancel{(\alpha+\beta u) B}$

$\langle\mathbf{a}_R,\mathbf{H}\rangle + (\langle\mathbf{s}_R,\mathbf{H}\rangle u)  + \langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=} \langle \mathbf{y}^n\circ(\mathbf{a}_R+z\cdot\mathbf{1})+z^2\mathbf{2}^n+\mathbf{y}^n\circ\mathbf{s}_R u, \mathbf{H}_{y^{-1}} \rangle$

The $\mathbf{H}_{y^{-1}}$ cancels with the $\mathbf{y}^n$ terms:

$\langle\mathbf{a}_R,\mathbf{H}\rangle + (\langle\mathbf{s}_R,\mathbf{H}\rangle u)  + \langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=} \langle \mathbf{a}_R+z\cdot\mathbf{1},\mathbf{H}\rangle+\langle z^2\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle+\langle\mathbf{s}_R u, \mathbf{H} \rangle$

Split the inner products:

$\langle\mathbf{a}_R,\mathbf{H}\rangle + (\langle\mathbf{s}_R,\mathbf{H}\rangle u)  + \langle z\cdot\mathbf{y}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle+\langle z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=} \langle \mathbf{a}_R,\mathbf{H}\rangle+\langle z\cdot\mathbf{1},\mathbf{H}\rangle+\langle z^2\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle+\langle\mathbf{s}_R u, \mathbf{H} \rangle$

cancel like terms:

$$\cancel{\langle\mathbf{a}_R,\mathbf{H}\rangle} + (\langle\mathbf{s}_R,\mathbf{H}\rangle u)  + \langle z\cdot\mathbf{y}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle+\langle z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=} \cancel{\langle \mathbf{a}_R,\mathbf{H}\rangle}+\langle z\cdot\mathbf{1},\mathbf{H}\rangle+\langle z^2\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle+\langle\mathbf{s}_R u, \mathbf{H} \rangle$$

$$\cancel{(\langle\mathbf{s}_R,\mathbf{H}\rangle u)}  + \langle z\cdot\mathbf{y}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle+\langle z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=}\langle z\cdot\mathbf{1},\mathbf{H}\rangle+\langle z^2\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle+\cancel{\langle\mathbf{s}_R u, \mathbf{H} \rangle}$$

$$\langle z\cdot\mathbf{y}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle+\cancel{\langle z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle} \stackrel{?}{=}\langle z\cdot\mathbf{1},\mathbf{H}\rangle+\cancel{\langle z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle}$$

$$\langle z\cdot\mathbf{y}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle \stackrel{?}{=}\langle z\cdot\mathbf{1},\mathbf{H}\rangle$$

move $\mathbf{y}^n$ to the other side:

$$\langle z\cdot\mathbf{1},\mathbf{H}\rangle \stackrel{?}{=}\langle z\cdot\mathbf{1},\mathbf{H}\rangle$$

$$\cancel{\langle z\cdot\mathbf{1},\mathbf{H}\rangle} \stackrel{?}{=}\cancel{\langle z\cdot\mathbf{1},\mathbf{H}\rangle}$$

#### Correctness of the evaluation of $t(u)$
To see that

$$t_uG+\pi_tB=Vz^2+\delta(y,z)G+T_1u+T_2u^2$$

is correct, we could substitute the terms as follows:

$$\underbrace{\langle \mathbf{l}_u, \mathbf{r}_u \rangle}_{t_u}G+\underbrace{(z^2\gamma + \tau_1u + \tau_2u^2)}_{\pi_t}B=\underbrace{(vG+\gamma B)}_{V}z^2+\delta(y,z)G+\underbrace{(t_1G+\tau_1B}_{T_1})u+\underbrace{(t_2G+\tau_2B)}_{T_2}u^2$$

with $\mathbf{l}_u$, $\mathbf{r}_u$, $t_1$, $t_2$:
$$\begin{align*}
\mathbf{l}_u &= \mathbf{a_L} - z \cdot \mathbf{1}^n\\
\mathbf{r}_u &= \mathbf{y}^n \circ \mathbf{a_R} +  \mathbf{y}^n\cdot z + z^2 \cdot 2^n\\
t_1 &= \langle(\mathbf{a}_L-z\cdot\mathbf{1}),\mathbf{y}^n\circ\mathbf{s}_R\rangle+\langle\mathbf{y}^n\circ(\mathbf{a}_R+z\cdot\mathbf{1})+z^2\mathbf{2}^n,\mathbf{s_L}\rangle\\
t_2 &= \langle\mathbf{s}_L,\mathbf{y}^n\circ\mathbf{s}_R\rangle
\end{align*}
$$

However, such algebra would be extremely messy. Instead, we observe that $z^2v+\delta(y,z)G$ is the constant term of the vector polynomial inner product of of $\langle\mathbf{l}(x),\mathbf{r}(x)\rangle$. To cancel out the blinding term in $\gamma B$ in $V$, observe that $\pi_t$ contains $z^2\gamma$, so this will cancel with the gamma term in  $Vz^2 = (vG + \gamma B)z^2$.

Since Pedersen commitments are additively homomorphic, the verifier can simply compute and add $\delta(y,z)G$ to $Vz^2$ to compute the commitment to the constant term of the polynomial $t(x)$.

## Logarithmic-sized range proof
We can reduce the size of the data transmission by sending a commitment $C$ to $\mathbf{l}_u$ and $\mathbf{r}_u$ and proving that the committed vectors have inner product $t_u$ using the logarithmic-sized proof, and then verifying that

$$A + Su + \langle -z\cdot\mathbf{1}^n,\mathbf{G}\rangle + \langle z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n,\mathbf{H}_{\mathbf{y}^{-1}}\rangle-\pi_{lr}B\stackrel{?}{=} C$$

and 

$$t_u \stackrel{?}{=} \langle \mathbf{l}_u, \mathbf{r}_u \rangle$$

with respect to the basis vectors $\mathbf{G}$ and $\mathbf{H}_{\mathbf{y}^{-1}}$.

## Using the range proof algorithm for the subset sum

The [subset sum problem](https://en.wikipedia.org/wiki/Subset_sum_problem) asks, "given a set of numbers, does a subset (possibly including the entire set) sum up to $k$? For example if $k = 16$ and the set is $\set{3,5,7,11}$ the answer is yes because $5 + 11 = 16$. However if $k=13$, then the answer is no.

The subset sum problem is NP-Complete, meaning that, similar to a Boolean circuit or arithmetic circuit, it can represent any problem in [NP](https://www.rareskills.io/post/p-vs-np). That is, any problem in NP can be rewritten (the technical word is "[reduced](https://www.cs.cmu.edu/~ckingsf/bioinfo-lectures/npcomplete.pdf)") to a subset sum instance.

By replacing $\mathbf{2}^n$ with $[3,5,7,11]$, we can prove we know a solution to a subset sum without revealing the answer. Specifically, the prover would know that $\mathbf{a}_L= [0,1,0,1]$ if $k=16$. In general, a one entry in $\mathbf{a}_L$ means we include that element in the subset and a zero means it is not included in the subset.

Therefore, Bulletproofs are capable of proving knowledge of any witness for any problem in NP.

## Appendix: Derivation of combining three inner products into one

Starting with the three inner products:

$$z^2 \cdot \langle \mathbf{a_L}, \mathbf{2}^n \rangle + z \cdot \langle \mathbf{a_L} - \mathbf{1}^n - \mathbf{a_R}, \mathbf{y}^n \rangle + \langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle = z^2 \cdot v$$

We show how to derive the final result:

$$\langle \mathbf{a_L}-z\cdot\mathbf{1}^n, \mathbf{a}_R\circ\mathbf{y}^n+z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle= z^2 \cdot v+(z-z^2)\cdot\langle\mathbf{1}^n,\mathbf{y}^n\rangle-z^3\langle\cdot\mathbf{1}^n,\mathbf{2}^n\rangle$$

using the inner product algebra we learned previously.

1. The middle term can be split into separate inner products:

$$z^2 \cdot \langle \mathbf{a_L}, \mathbf{2}^n \rangle + \boxed{z \cdot \langle \mathbf{a_L} - \mathbf{1}^n - \mathbf{a_R}, \mathbf{y}^n \rangle} + \langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle = z^2 \cdot v$$

$$z^2 \cdot \langle \mathbf{a_L}, \mathbf{2}^n \rangle+\boxed{z\cdot\langle\mathbf{a}_L,\mathbf{y}^n\rangle+z\cdot\langle-\mathbf{1}^n,\mathbf{y}^n\rangle+z\cdot\langle-\mathbf{a}_R,\mathbf{y}^n\rangle}+\langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle=z^2\cdot v$$

2. We can move the constant $z$ terms inside the inner products
$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle+\langle-\mathbf{a}_R,z\cdot\mathbf{y}^n\rangle+\langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle= z^2 \cdot v$$

3. Move the values known to the verifier to the right
$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+\boxed{\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle}+\langle-\mathbf{a}_R,z\cdot\mathbf{y}^n\rangle+\langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle= z^2 \cdot v$$

$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+\langle-\mathbf{a}_R,z\cdot\mathbf{y}^n\rangle+\langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle= z^2 \cdot v-\boxed{\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle}$$

4. Convert the $\mathbf{a}_R$ terms to both be $\mathbf{a}_R\circ\mathbf{y}^n$.

$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+\boxed{\langle-\mathbf{a}_R\circ\mathbf{y}^n,z\cdot\mathbf{1}^n\rangle}+\langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+\boxed{\langle\mathbf{a}_R\circ\mathbf{y}^n,-z\cdot\mathbf{1}^n\rangle}+\langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+{\langle\mathbf{a}_R\circ\mathbf{y}^n,-z\cdot\mathbf{1}^n\rangle}+\boxed{\langle \mathbf{a_L}, \mathbf{a_R} \circ \mathbf{y}^n \rangle}= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,-z\cdot\mathbf{1}^n\rangle+\langle \mathbf{a_R} \circ \mathbf{y}^n,\mathbf{a_L} \rangle = z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

5. Combine the $\mathbf{a}_R\circ\mathbf{y}^n$ terms into one:

$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+\underbrace{\langle\mathbf{a}_R\circ\mathbf{y}^n,-z\cdot\mathbf{1}^n\rangle+\langle \mathbf{a_R} \circ \mathbf{y}^n,\mathbf{a_L} \rangle} = z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

$$\langle \mathbf{a_L}, z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_L,z\cdot\mathbf{y}^n\rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,\mathbf{a}_L-z\cdot\mathbf{1}^n\rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

6. Combine the two $\mathbf{a}_L$ terms on the left

$$\langle \boxed{\mathbf{a_L}}, z^2\cdot\mathbf{2}^n \rangle+\langle\boxed{\mathbf{a}_L},z\cdot\mathbf{y}^n\rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,\mathbf{a}_L-z\cdot\mathbf{1}^n\rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

$$\langle \mathbf{a_L}, z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,\mathbf{a}_L-z\cdot\mathbf{1}^n\rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

7. Split the last left hand side term into two inner products
$$\langle \mathbf{a_L}, z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle+\boxed{\langle\mathbf{a}_R\circ\mathbf{y}^n,\mathbf{a}_L-z\cdot\mathbf{1}^n\rangle}= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

$$\langle \mathbf{a_L}, z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,\mathbf{a}_L\rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,-z\cdot\mathbf{1}^n\rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

8. Combine the $\mathbf{a}_L$ terms
$$\langle \boxed{\mathbf{a_L}}, z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,
\boxed{\mathbf{a}_L}\rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,-z\cdot\mathbf{1}^n\rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

$$\langle \mathbf{a_L}, \mathbf{a}_R\circ\mathbf{y}^n+z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle+\langle\mathbf{a}_R\circ\mathbf{y}^n,-z\cdot\mathbf{1}^n\rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle$$

9. We can use the rule $\langle \mathbf{x}, \mathbf{b} + \mathbf{c}\rangle + \langle \mathbf{b}, \mathbf{y}\rangle = v \rightarrow \langle \mathbf{x} + \mathbf{y}, \mathbf{b} + \mathbf{c}\rangle = v + \langle\mathbf{y},\mathbf{c}\rangle$ to combine the terms that contain $\mathbf{a}_R\circ\mathbf{y}^n$. Here $\mathbf{b}$ is $\mathbf{a}_R\circ\mathbf{y}^n$, $\mathbf{c}$ is $z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n$, and $\mathbf{y}$ is $-z\cdot\mathbf{1}^n$

$$\langle \underbrace{\mathbf{a_L}}_\mathbf{x}, \underbrace{\mathbf{a}_R\circ\mathbf{y}^n}_\mathbf{b}+\underbrace{z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n}_\mathbf{c} \rangle+\langle\underbrace{\mathbf{a}_R\circ\mathbf{y}^n}_\mathbf{b},\underbrace{-z\cdot\mathbf{1}^n}_\mathbf{y}\rangle= \underbrace{z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle}_v$$

$$\langle \underbrace{\mathbf{a_L}}_\mathbf{x}-\underbrace{z\cdot\mathbf{1}^n}_\mathbf{y}, \underbrace{\mathbf{a}_R\circ\mathbf{y}^n}_\mathbf{b}+\underbrace{z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n}_\mathbf{c} \rangle= \underbrace{z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle}_v+\langle\underbrace{-z\cdot\mathbf{1}^n}_\mathbf{y},\underbrace{z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n}_\mathbf{c}\rangle$$

$$\langle \mathbf{a_L}-z\cdot\mathbf{1}^n, \mathbf{a}_R\circ\mathbf{y}^n+z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle+\langle-z\cdot\mathbf{1}^n,z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n\rangle$$

10. We now break up the terms on the right hand side

$$\langle \mathbf{a_L}-z\cdot\mathbf{1}^n, \mathbf{a}_R\circ\mathbf{y}^n+z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle= z^2 \cdot v-\langle-z\cdot\mathbf{1}^n,\mathbf{y}^n\rangle+\langle-z\cdot\mathbf{1}^n,z\cdot\mathbf{y}^n\rangle+\langle-z\cdot\mathbf{1}^n,z^2\cdot\mathbf{2}^n\rangle$$

11. Take the scalars out of the inner products on the right

$$\langle \mathbf{a_L}-z\cdot\mathbf{1}^n, \mathbf{a}_R\circ\mathbf{y}^n+z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle= z^2 \cdot v+z\cdot\langle\mathbf{1}^n,\mathbf{y}^n\rangle-z^2\cdot\langle\mathbf{1}^n,\mathbf{y}^n\rangle-z^3\langle\cdot\mathbf{1}^n,\mathbf{2}^n\rangle$$

12. Factor out $\langle\mathbf{1}^n,\mathbf{y}^n\rangle$

$$\langle \mathbf{a_L}-z\cdot\mathbf{1}^n, \mathbf{a}_R\circ\mathbf{y}^n+z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle= z^2 \cdot v+(z-z^2)\cdot\langle\mathbf{1}^n,\mathbf{y}^n\rangle-z^3\langle\cdot\mathbf{1}^n,\mathbf{2}^n\rangle$$

since $\delta(y,z)=(z-z^2)\cdot\langle\mathbf{1}^n,\mathbf{y}^n\rangle-z^3\langle\cdot\mathbf{1}^n,\mathbf{2}^n\rangle$ we have 

$$\langle \mathbf{a_L}-z\cdot\mathbf{1}^n, \mathbf{a}_R\circ\mathbf{y}^n+z\cdot\mathbf{y}^n+z^2\cdot\mathbf{2}^n \rangle= z^2 \cdot v+\delta(y,z)$$

This completes the derivation. $\blacksquare$
